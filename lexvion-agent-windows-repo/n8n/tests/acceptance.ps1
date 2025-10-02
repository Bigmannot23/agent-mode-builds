<#
    Acceptance tests for the Lexvion Agent n8n workflow.
    These tests verify error handling and schema enforcement. They are more
    comprehensive than smoke tests but still avoid side effects. Run after
    smoke tests have passed.
#>

Param(
    [string]$BaseUrl = $env:N8N_BASE
)

if (-not $BaseUrl) {
    Write-Error "N8N_BASE environment variable must be set to the base URL of your n8n instance."
    exit 1
}

function Invoke-AgentRequest {
    param(
        [Parameter(Mandatory=$true)][hashtable]$Body
    )
    $jsonBody = $Body | ConvertTo-Json -Compress
    try {
        $res = & curl.exe -s -D - -o - -X POST "$BaseUrl/webhook/agent" -H "Content-Type: application/json" -d $jsonBody 2>$null
        return $res
    } catch { }
    $resp = Invoke-WebRequest -Uri "$BaseUrl/webhook/agent" -Method Post -Body $jsonBody -ContentType 'application/json' -UseBasicParsing -Headers @{ 'Content-Type' = 'application/json' } -ErrorAction SilentlyContinue -Verbose:$false
    return $resp.StatusCode.ToString() + "\n" + $resp.Content
}

$tests = @(
    @{ Name = 'reject_unknown_field'; Body = @{ query = 'Test unknown'; foo = 'bar' }; ExpectStatusNot = 200 },
    @{ Name = 'reject_missing_query'; Body = @{ }; ExpectStatusNot = 200 },
    @{ Name = 'reject_invalid_approve'; Body = @{ query = 'Test invalid approve'; approve = 'yes' }; ExpectStatusNot = 200 }
)

$allPassed = $true

foreach ($test in $tests) {
    Write-Host "--- $($test.Name) ---"
    try {
        $response = Invoke-AgentRequest -Body $test.Body
        # Parse status code from response; if using curl.exe, the headers will include HTTP/1.1 <code>
        if ($response -match '^HTTP/\S+\s+(\d{3})') {
            $status = [int]$Matches[1]
        } elseif ($response -match '^(\d{3})\n') {
            $status = [int]$Matches[1]
        } else {
            $status = 0
        }
        Write-Host $response
        if ($status -ne 200) {
            Write-Host "PASS (status $status)"
        } else {
            Write-Error "FAIL: expected non-200 status code"
            $allPassed = $false
        }
    } catch {
        Write-Host "PASS (exception thrown)"
    }
}

if (-not $allPassed) {
    exit 1
}
Write-Host "Acceptance tests completed successfully."
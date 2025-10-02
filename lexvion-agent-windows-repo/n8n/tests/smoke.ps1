<#
    Smoke tests for the Lexvion Agent n8n workflow.
    These tests run from PowerShell 7+ on Windows and verify the
    correct behaviour of the webhook endpoint.  Set the environment
    variable `$env:N8N_BASE` to your n8n base URL (e.g. https://n8n.example.com)
    before running.
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
        # Prefer curl.exe if available for consistent behaviour
        $res = & curl.exe -s -X POST "$BaseUrl/webhook/agent" -H "Content-Type: application/json" -d $jsonBody 2>$null
        if ($LASTEXITCODE -eq 0) { return $res }
    } catch { }
    # Fallback to Invoke-WebRequest
    $resp = Invoke-WebRequest -Uri "$BaseUrl/webhook/agent" -Method Post -Body $jsonBody -ContentType 'application/json' -UseBasicParsing -ErrorAction Stop
    return $resp.Content
}

$tests = @(
    @{ Name = 'no_side_effect';   Body = @{ query = 'Summarize and ask which tool.'; context = @{ user = 'alex' } }; Expect = '"tool"' },
    @{ Name = 'gate_side_effect'; Body = @{ query = 'Append ok row to Logs!A:F'; context = @{ user = 'alex' } };           Expect = 'REVIEW_REQUIRED' },
    @{ Name = 'approve_side_effect'; Body = @{ query = 'Append ok row to Logs!A:F'; context = @{ user = 'alex' }; approve = $true }; Expect = 'ok' }
)

$allPassed = $true

foreach ($test in $tests) {
    Write-Host "--- $($test.Name) ---"
    try {
        $response = Invoke-AgentRequest -Body $test.Body
        Write-Host $response
        if ($response -match $test.Expect) {
            Write-Host "PASS"
        } else {
            Write-Error "FAIL: expected '$($test.Expect)' in response"
            $allPassed = $false
        }
    } catch {
        Write-Error "FAIL: $($_.Exception.Message)"
        $allPassed = $false
    }
}

if (-not $allPassed) {
    exit 1
}
Write-Host "Smoke tests completed successfully."
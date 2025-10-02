<#
    dev.ps1

    Helper script for local development of the Lexvion Agent.
    Provides convenience functions and environment setup when working on Windows.

    Usage examples:
        # Set the base URL for your n8n instance
        .\scripts\dev.ps1 -BaseUrl "https://n8n.example.com"

        # Start a local n8n instance (if n8n is installed globally via npm)
        Start-N8nLocal

        # Stop the local n8n instance (relies on Stop-Process)
        Stop-N8nLocal

    This script does not install n8n; install it via npm (`npm i -g n8n`) or use
    Docker as appropriate for your environment.
#>

param(
    [string]$BaseUrl
)

if ($PSBoundParameters.ContainsKey('BaseUrl')) {
    $env:N8N_BASE = $BaseUrl
    Write-Host "[Dev] N8N_BASE set to $BaseUrl"
}

function Start-N8nLocal {
    <#
        Start a local n8n instance on port 5678. Requires n8n to be installed via
        npm (`npm install -g n8n`) or available in your PATH. The process is
        started in a separate PowerShell job.
    #>
    if (-not (Get-Command n8n -ErrorAction SilentlyContinue)) {
        Write-Error "n8n command not found. Install it globally with 'npm install -g n8n' or use Docker."
        return
    }
    Write-Host "[Dev] Starting n8n on port 5678..."
    Start-Job -Name 'n8n' -ScriptBlock { n8n start } | Out-Null
    Start-Sleep -Seconds 5
    $env:N8N_BASE = "http://localhost:5678"
    Write-Host "[Dev] n8n started. N8N_BASE set to $env:N8N_BASE"
}

function Stop-N8nLocal {
    <#
        Stop the local n8n instance started with Start-N8nLocal.
    #>
    $job = Get-Job -Name 'n8n' -ErrorAction SilentlyContinue
    if ($null -eq $job) {
        Write-Warning "[Dev] No n8n job found."
        return
    }
    Write-Host "[Dev] Stopping n8n..."
    Stop-Job -Job $job | Out-Null
    Remove-Job -Job $job | Out-Null
    Write-Host "[Dev] n8n stopped."
}

function Show-Env {
    <#
        Display current environment variables relevant to the agent.
    #>
    Write-Host "N8N_BASE      : $env:N8N_BASE"
    Write-Host "LOG_SHEET_ID : $env:LOG_SHEET_ID"
    Write-Host "NOTION_DB_ID : $env:NOTION_DB_ID"
}

Write-Host "[Dev] Development helpers loaded. Use Start-N8nLocal/Stop-N8nLocal/Show-Env as needed."
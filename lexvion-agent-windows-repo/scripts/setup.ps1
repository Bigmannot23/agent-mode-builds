<#
    setup.ps1

    Bootstraps a Windows environment for running and developing the Lexvion Agent.
    - Ensures execution policy allows local scripts.
    - Installs jq and GitHub CLI via winget when missing.
    - Verifies that curl.exe is available.

    Run this script from a PowerShell 7+ prompt. Administrator rights are not
    required; winget installs per‑user packages by default.
#>

Param()

Write-Host "[Setup] Configuring environment..."

# Set execution policy for current user to RemoteSigned if not already less restrictive
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser -ErrorAction SilentlyContinue
if ($null -eq $currentPolicy -or $currentPolicy -eq 'Undefined' -or $currentPolicy -eq 'Restricted') {
    Write-Host "[Setup] Setting execution policy to RemoteSigned for current user..."
    try {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
    } catch {
        Write-Warning "Unable to set execution policy. Try running PowerShell as administrator."
    }
}

# Helper to install a package via winget if not present
function Install-PackageIfMissing {
    param(
        [Parameter(Mandatory)][string]$CommandName,
        [Parameter(Mandatory)][string]$WingetId,
        [string]$AppDisplayName
    )
    if (-not (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            Write-Warning "winget not found. Please install winget or install $AppDisplayName manually."
            return
        }
        Write-Host "[Setup] Installing $AppDisplayName via winget ($WingetId)..."
        try {
            winget install --id $WingetId -e -h 0 | Out-Null
        } catch {
            Write-Warning "Failed to install $AppDisplayName. You may need to run winget as administrator or install manually."
        }
    } else {
        Write-Host "[Setup] $AppDisplayName already installed."
    }
}

# Ensure jq is installed for JSON manipulation
Install-PackageIfMissing -CommandName 'jq' -WingetId 'jqlang.jq' -AppDisplayName 'jq JSON utility'

# Ensure GitHub CLI is installed for optional repository operations
Install-PackageIfMissing -CommandName 'gh' -WingetId 'GitHub.cli' -AppDisplayName 'GitHub CLI'

# Verify curl.exe exists (ships with Windows 10/11)
if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
    Write-Warning "curl.exe not found. Please ensure curl is installed or add a compatible tool to your PATH."
} else {
    Write-Host "[Setup] curl.exe found."
}

Write-Host "[Setup] Environment configuration complete."
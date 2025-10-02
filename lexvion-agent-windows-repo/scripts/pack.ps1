<#
    pack.ps1

    Create a ZIP archive of the repository for distribution. The archive will be
    placed into a `dist` subfolder with the file name `lexvion-agent-windows-repo.zip`.
    This script should be executed from the repository root.
#>

Param()

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $repoRoot

$distDir = Join-Path $repoRoot 'dist'
if (-not (Test-Path $distDir)) { New-Item -ItemType Directory -Path $distDir | Out-Null }

$zipName = 'lexvion-agent-windows-repo.zip'
$zipPath = Join-Path $distDir $zipName

if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Write-Host "[Pack] Creating $zipName..."

# Exclude dist folder itself from the zip to avoid recursion
$itemsToZip = Get-ChildItem -Path . -Recurse -File | Where-Object { -not $_.FullName.StartsWith($distDir) }

Compress-Archive -Path $itemsToZip -DestinationPath $zipPath -Force

Write-Host "[Pack] Archive created at: $zipPath"
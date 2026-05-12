param(
    [Parameter(Mandatory = $true)]
    [string]$ExePath,

    [Parameter(Mandatory = $true)]
    [string]$IconPath
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ExePath)) {
    throw "Executable was not found: $ExePath"
}

if (-not (Test-Path $IconPath)) {
    throw "Icon was not found: $IconPath"
}

$rcedit = Get-ChildItem "$env:LOCALAPPDATA\electron-builder\Cache\winCodeSign" `
    -Recurse `
    -Filter "rcedit-x64.exe" `
    -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $rcedit) {
    throw "rcedit-x64.exe was not found in electron-builder cache. Run electron-builder once or install rcedit."
}

& $rcedit.FullName $ExePath --set-icon $IconPath
if ($LASTEXITCODE -ne 0) {
    throw "rcedit failed with exit code $LASTEXITCODE"
}

Write-Host "Icon applied to $ExePath"

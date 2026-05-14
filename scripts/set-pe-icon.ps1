param(
    [Parameter(Mandatory = $true)]
    [string]$ExePath,

    [Parameter(Mandatory = $true)]
    [string]$IconPath,

    [string]$ProductName,

    [string]$ProductVersion,

    [string]$FileDescription,

    [string]$CompanyName,

    [string]$OriginalFilename
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

$arguments = @($ExePath, "--set-icon", $IconPath)

if ($ProductName) {
    $arguments += @("--set-version-string", "ProductName", $ProductName)
}

if ($ProductVersion) {
    $arguments += @("--set-product-version", $ProductVersion)
    $arguments += @("--set-file-version", $ProductVersion)
}

if ($FileDescription) {
    $arguments += @("--set-version-string", "FileDescription", $FileDescription)
}

if ($CompanyName) {
    $arguments += @("--set-version-string", "CompanyName", $CompanyName)
}

if ($OriginalFilename) {
    $arguments += @("--set-version-string", "OriginalFilename", $OriginalFilename)
}

& $rcedit.FullName @arguments
if ($LASTEXITCODE -ne 0) {
    throw "rcedit failed with exit code $LASTEXITCODE"
}

Write-Host "Icon applied to $ExePath"

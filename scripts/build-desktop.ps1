$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$frontendDir = Join-Path $repoRoot "frontend"
$backendDir = Join-Path $repoRoot "backend"
$desktopDir = Join-Path $repoRoot "desktop"
$postgresRuntime = Join-Path $desktopDir "runtime\postgres\bin\pg_ctl.exe"

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )

    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code ${LASTEXITCODE}: $FilePath $($Arguments -join ' ')"
    }
}

if (-not (Test-Path $postgresRuntime)) {
    throw "PostgreSQL runtime is missing. Run scripts\prepare-postgres-runtime.ps1 first."
}

Push-Location $frontendDir
try {
    if (Test-Path "package-lock.json") {
        Invoke-Checked "npm.cmd" "ci"
    } else {
        Invoke-Checked "npm.cmd" "install"
    }
    Invoke-Checked "npm.cmd" "run" "build"
}
finally {
    Pop-Location
}

$venvDir = Join-Path $backendDir ".venv-desktop"
$pythonExe = Join-Path $venvDir "Scripts\python.exe"

if (-not (Test-Path $pythonExe)) {
    Invoke-Checked "python" "-m" "venv" $venvDir
}

Invoke-Checked $pythonExe "-m" "pip" "install" "--upgrade" "pip"
Invoke-Checked $pythonExe "-m" "pip" "install" "-r" (Join-Path $backendDir "requirements-build.txt")

Push-Location $backendDir
try {
    Invoke-Checked $pythonExe "-m" "PyInstaller" "smartrecipe-api.spec" "--noconfirm" "--clean"
}
finally {
    Pop-Location
}

Push-Location $desktopDir
try {
    Invoke-Checked "npm.cmd" "install"
    Invoke-Checked "npm.cmd" "run" "pack"
}
finally {
    Pop-Location
}

Invoke-Checked "powershell" "-NoProfile" "-ExecutionPolicy" "Bypass" "-File" (Join-Path $repoRoot "scripts\set-pe-icon.ps1") "-ExePath" (Join-Path $desktopDir "dist\win-unpacked\Dietrix.exe") "-IconPath" (Join-Path $desktopDir "build\icon.ico")
Invoke-Checked "powershell" "-NoProfile" "-ExecutionPolicy" "Bypass" "-File" (Join-Path $repoRoot "scripts\build-iexpress-installer.ps1")

Write-Host "Installer build finished. Check desktop\dist."

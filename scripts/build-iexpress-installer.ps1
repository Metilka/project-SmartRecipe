$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$desktopDir = Join-Path $repoRoot "desktop"
$distDir = Join-Path $desktopDir "dist"
$unpackedDir = Join-Path $distDir "win-unpacked"
$installerPath = Join-Path $distDir "Dietrix Setup 1.0.0.exe"
$iconPath = Join-Path $desktopDir "build\icon.ico"
$workRoot = Join-Path $env:TEMP "DietrixIExpress"
$stageDir = Join-Path $workRoot "stage"
$tempInstallerPath = Join-Path $workRoot "Dietrix Setup 1.0.0.exe"
$zipPath = Join-Path $stageDir "Dietrix-app.zip"
$installerScript = Join-Path $stageDir "install-dietrix.ps1"
$sedPath = Join-Path $stageDir "dietrix-iexpress.sed"

if (-not (Test-Path (Join-Path $unpackedDir "Dietrix.exe"))) {
    throw "Electron unpacked build was not found. Run npm.cmd run pack in desktop first."
}

if (-not (Test-Path $iconPath)) {
    throw "Installer icon was not found: $iconPath"
}

if (Test-Path $workRoot) {
    Remove-Item -LiteralPath $workRoot -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $stageDir | Out-Null

if (Test-Path $installerPath) {
    Remove-Item -LiteralPath $installerPath -Force
}

if (Test-Path $tempInstallerPath) {
    Remove-Item -LiteralPath $tempInstallerPath -Force
}

Compress-Archive -Path (Join-Path $unpackedDir "*") -DestinationPath $zipPath -CompressionLevel Optimal -Force

@'
$ErrorActionPreference = "Stop"

$zipPath = Join-Path $PSScriptRoot "Dietrix-app.zip"

Add-Type -AssemblyName System.Windows.Forms

function Select-Folder {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,

        [Parameter(Mandatory = $true)]
        [string]$DefaultPath
    )

    New-Item -ItemType Directory -Force -Path $DefaultPath | Out-Null

    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = $Title
    $dialog.SelectedPath = $DefaultPath
    $dialog.ShowNewFolderButton = $true

    $result = $dialog.ShowDialog()
    if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
        exit 0
    }

    return $dialog.SelectedPath
}

$programsParent = Select-Folder `
    -Title "Select the folder where the Dietrix program folder will be created." `
    -DefaultPath (Join-Path $env:LOCALAPPDATA "Programs")

$dataParent = Select-Folder `
    -Title "Select the folder where Dietrix data will be stored." `
    -DefaultPath $env:APPDATA

$installDir = Join-Path $programsParent "Dietrix"
$dataDir = Join-Path $dataParent "Dietrix"

if (Test-Path $installDir) {
    Remove-Item -LiteralPath $installDir -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $installDir | Out-Null
New-Item -ItemType Directory -Force -Path $dataDir | Out-Null
Expand-Archive -LiteralPath $zipPath -DestinationPath $installDir -Force

$installConfigPath = Join-Path $installDir "resources\install-config.json"
@{
    dataDir = $dataDir
} | ConvertTo-Json | Set-Content -LiteralPath $installConfigPath -Encoding UTF8

$exePath = Join-Path $installDir "Dietrix.exe"
if (-not (Test-Path $exePath)) {
    throw "Dietrix.exe was not installed."
}

$shell = New-Object -ComObject WScript.Shell

$desktopDir = [Environment]::GetFolderPath("DesktopDirectory")
$desktopShortcut = $shell.CreateShortcut((Join-Path $desktopDir "Dietrix.lnk"))
$desktopShortcut.TargetPath = $exePath
$desktopShortcut.WorkingDirectory = $installDir
$desktopShortcut.Save()

$programsDir = [Environment]::GetFolderPath("Programs")
$startMenuDir = Join-Path $programsDir "Dietrix"
New-Item -ItemType Directory -Force -Path $startMenuDir | Out-Null

$startMenuShortcut = $shell.CreateShortcut((Join-Path $startMenuDir "Dietrix.lnk"))
$startMenuShortcut.TargetPath = $exePath
$startMenuShortcut.WorkingDirectory = $installDir
$startMenuShortcut.Save()

Start-Process -FilePath $exePath -WorkingDirectory $installDir
'@ | Set-Content -LiteralPath $installerScript -Encoding UTF8

@"
[Version]
Class=IEXPRESS
SEDVersion=3

[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=0
HideExtractAnimation=1
UseLongFileName=1
InsideCompressed=0
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=
DisplayLicense=
FinishMessage=
TargetName=$tempInstallerPath
FriendlyName=Dietrix
AppLaunched=powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File install-dietrix.ps1
PostInstallCmd=<None>
AdminQuietInstCmd=
UserQuietInstCmd=
SourceFiles=SourceFiles

[SourceFiles]
SourceFiles0=$stageDir

[SourceFiles0]
%FILE0%=
%FILE1%=

[Strings]
FILE0="Dietrix-app.zip"
FILE1="install-dietrix.ps1"
"@ | Set-Content -LiteralPath $sedPath -Encoding ASCII

iexpress.exe /N /Q $sedPath
if ($null -ne $LASTEXITCODE -and $LASTEXITCODE -ne 0) {
    throw "IExpress failed with exit code $LASTEXITCODE"
}

function Wait-FileReady {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [int]$TimeoutSeconds = 300
    )

    for ($i = 0; $i -lt $TimeoutSeconds; $i++) {
        if (Test-Path $Path) {
            try {
                $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::None)
                $stream.Close()
                return
            }
            catch {
                Start-Sleep -Seconds 1
                continue
            }
        }

        Start-Sleep -Seconds 1
    }

    throw "File was not ready in ${TimeoutSeconds}s: $Path"
}

function Wait-FileStable {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [int]$TimeoutSeconds = 300
    )

    $lastLength = -1
    $stableTicks = 0

    for ($i = 0; $i -lt $TimeoutSeconds; $i++) {
        if (Test-Path $Path) {
            $currentLength = (Get-Item -LiteralPath $Path).Length
            if ($currentLength -gt 0 -and $currentLength -eq $lastLength) {
                $stableTicks += 1
                if ($stableTicks -ge 3) {
                    return
                }
            } else {
                $stableTicks = 0
                $lastLength = $currentLength
            }
        }

        Start-Sleep -Seconds 1
    }

    throw "File size did not stabilize in ${TimeoutSeconds}s: $Path"
}

for ($i = 0; $i -lt 300 -and -not (Test-Path $tempInstallerPath); $i++) {
    Start-Sleep -Seconds 1
}

if (-not (Test-Path $tempInstallerPath)) {
    throw "Installer was not created: $tempInstallerPath"
}

Wait-FileReady -Path $tempInstallerPath
Wait-FileStable -Path $tempInstallerPath
Copy-Item -LiteralPath $tempInstallerPath -Destination $installerPath -Force
$iconResult = Start-Process `
    -FilePath "powershell" `
    -ArgumentList @(
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        (Join-Path $repoRoot "scripts\set-pe-icon.ps1"),
        "-ExePath",
        $installerPath,
        "-IconPath",
        $iconPath
    ) `
    -NoNewWindow `
    -Wait `
    -PassThru

if ($iconResult.ExitCode -ne 0) {
    Write-Warning "Installer was created, but icon update was skipped because set-pe-icon failed."
}

Write-Host "IExpress installer created: $installerPath"

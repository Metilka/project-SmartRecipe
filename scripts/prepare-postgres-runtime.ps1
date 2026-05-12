param(
    [string]$PostgresHome = $env:POSTGRES_HOME
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$target = Join-Path $repoRoot "desktop\runtime\postgres"

function Find-InstalledPostgres {
    $base = "C:\Program Files\PostgreSQL"
    if (-not (Test-Path $base)) {
        return $null
    }

    Get-ChildItem $base -Directory |
        Sort-Object Name -Descending |
        Select-Object -First 1 |
        ForEach-Object { $_.FullName }
}

if (-not $PostgresHome) {
    $PostgresHome = Find-InstalledPostgres
}

if (-not $PostgresHome -or -not (Test-Path $PostgresHome)) {
    throw "PostgreSQL installation was not found. Pass -PostgresHome or set POSTGRES_HOME."
}

$required = @(
    "bin\postgres.exe",
    "bin\pg_ctl.exe",
    "bin\psql.exe",
    "bin\initdb.exe",
    "lib",
    "share"
)

foreach ($item in $required) {
    $path = Join-Path $PostgresHome $item
    if (-not (Test-Path $path)) {
        throw "Required PostgreSQL runtime item is missing: $path"
    }
}

if (Test-Path $target) {
    Remove-Item -LiteralPath $target -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $target | Out-Null

Copy-Item -LiteralPath (Join-Path $PostgresHome "bin") -Destination $target -Recurse
Copy-Item -LiteralPath (Join-Path $PostgresHome "lib") -Destination $target -Recurse
Copy-Item -LiteralPath (Join-Path $PostgresHome "share") -Destination $target -Recurse

Write-Host "PostgreSQL runtime prepared at $target"

# SmartRecipe Desktop Packaging

This folder contains the Electron shell for the desktop build.

The packaged app starts a local PostgreSQL instance, starts the Flask API,
serves the React build, and opens the application in an Electron window.

## Build prerequisites

- Windows build machine
- Node.js and npm
- Python 3.11+
- A local PostgreSQL installation or extracted PostgreSQL runtime

The end user does not need Docker, Node.js, Python, or PostgreSQL. These are
only build-time requirements.

## Prepare PostgreSQL runtime

The installer must include PostgreSQL binaries. If PostgreSQL is installed in
the default Windows location, run from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\prepare-postgres-runtime.ps1
```

If PostgreSQL is installed elsewhere:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\prepare-postgres-runtime.ps1 -PostgresHome "C:\Path\To\PostgreSQL"
```

The script copies `bin`, `lib`, and `share` into `desktop/runtime/postgres`.

## Build installer

From the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\build-desktop.ps1
```

Expected output:

```text
desktop/dist/SmartRecipe Setup 1.0.0.exe
```

The default build uses Electron's unpacked Windows build plus Windows IExpress
to create a self-extracting installer. NSIS is available as `npm run dist:nsis`
inside `desktop/`, but it may require extra electron-builder downloads and
Windows symlink privileges.

## Runtime behavior

On first launch, the app creates its local runtime data under:

```text
%APPDATA%/SmartRecipe/
```

It initializes PostgreSQL, creates `med_diet_db`, filters the original
`database/seed.sql`, imports it, and then starts the Flask backend.

Logs are written to:

```text
%APPDATA%/SmartRecipe/logs/
```

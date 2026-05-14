const crypto = require("crypto");
const fs = require("fs");
const http = require("http");
const net = require("net");
const path = require("path");
const { spawn, spawnSync } = require("child_process");
const { app, BrowserWindow, dialog } = require("electron");

const PRODUCT_NAME = "Dietrix";
const POSTGRES_USER = "smartrecipe";
const POSTGRES_DB = "med_diet_db";

app.setName(PRODUCT_NAME);

let mainWindow = null;
let backendProcess = null;
let postgresStarted = false;
let postgresDataDir = null;
let postgresPgCtlPath = null;
let logFile = null;
let shuttingDown = false;

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function pathExists(filePath) {
  try {
    fs.accessSync(filePath);
    return true;
  } catch (error) {
    return false;
  }
}

function appendLog(message) {
  if (!logFile) {
    return;
  }

  const line = `[${new Date().toISOString()}] ${message}`;
  try {
    fs.appendFileSync(logFile, `${line}\n`, "utf8");
  } catch (error) {
    // Logging must never break startup.
  }
}

function appRoot() {
  if (app.isPackaged) {
    return process.resourcesPath;
  }

  return path.resolve(__dirname, "..", "..");
}

function resolveResources() {
  const root = appRoot();

  return {
    frontendDir: app.isPackaged
      ? path.join(root, "frontend")
      : path.join(root, "frontend", "dist"),
    backendExe: app.isPackaged
      ? path.join(root, "backend", "smartrecipe-api.exe")
      : path.join(root, "backend", "dist", "smartrecipe-api", "smartrecipe-api.exe"),
    backendScript: path.join(root, "backend", "desktop_server.py"),
    postgresDir: app.isPackaged
      ? path.join(root, "postgres")
      : path.join(root, "desktop", "runtime", "postgres"),
    seedFile: path.join(root, "database", "seed.sql"),
    iconFile: app.isPackaged
      ? path.join(root, "icon.ico")
      : path.join(root, "desktop", "build", "icon.ico"),
    installConfigFile: app.isPackaged
      ? path.join(root, "install-config.json")
      : path.join(root, "desktop", "install-config.json"),
  };
}

function loadInstallConfig(resources) {
  if (!pathExists(resources.installConfigFile)) {
    return {};
  }

  try {
    return JSON.parse(fs.readFileSync(resources.installConfigFile, "utf8"));
  } catch (error) {
    appendLog(`install config could not be read: ${error.message}`);
    return {};
  }
}

function run(command, args, options = {}) {
  const {
    cwd,
    env,
    timeoutMs = 120000,
    allowNonZero = false,
    logPrefix = path.basename(command),
    stdio = ["ignore", "pipe", "pipe"],
  } = options;

  appendLog(`run: ${command} ${args.join(" ")}`);

  return new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      cwd,
      env,
      stdio,
      windowsHide: true,
    });

    let stdout = "";
    let stderr = "";
    let settled = false;

    const timer = setTimeout(() => {
      if (settled) {
        return;
      }
      settled = true;
      child.kill();
      reject(new Error(`Command timed out: ${command}`));
    }, timeoutMs);

    if (child.stdout) {
      child.stdout.on("data", (chunk) => {
        const text = chunk.toString();
        stdout += text;
        appendLog(`[${logPrefix}:stdout] ${text.trimEnd()}`);
      });
    }

    if (child.stderr) {
      child.stderr.on("data", (chunk) => {
        const text = chunk.toString();
        stderr += text;
        appendLog(`[${logPrefix}:stderr] ${text.trimEnd()}`);
      });
    }

    child.on("error", (error) => {
      if (settled) {
        return;
      }
      settled = true;
      clearTimeout(timer);
      reject(error);
    });

    child.on("close", (code) => {
      if (settled) {
        return;
      }
      settled = true;
      clearTimeout(timer);

      if (code === 0 || allowNonZero) {
        resolve({ code, stdout, stderr });
        return;
      }

      reject(new Error(`Command failed with code ${code}: ${command}\n${stderr || stdout}`));
    });
  });
}

function findFreePort() {
  return new Promise((resolve, reject) => {
    const server = net.createServer();
    server.unref();
    server.on("error", reject);
    server.listen(0, "127.0.0.1", () => {
      const address = server.address();
      const port = address.port;
      server.close(() => resolve(port));
    });
  });
}

function loadRuntimeConfig(userDataDir) {
  const configFile = path.join(userDataDir, "desktop-config.json");

  if (pathExists(configFile)) {
    return JSON.parse(fs.readFileSync(configFile, "utf8"));
  }

  const config = {
    dbUser: POSTGRES_USER,
    dbName: POSTGRES_DB,
    dbPassword: crypto.randomBytes(24).toString("hex"),
    jwtSecret: crypto.randomBytes(32).toString("hex"),
  };

  fs.writeFileSync(configFile, JSON.stringify(config, null, 2), "utf8");
  return config;
}

function postgresBinary(postgresDir, name) {
  return path.join(postgresDir, "bin", `${name}.exe`);
}

function assertPostgresRuntime(postgresDir) {
  const required = ["initdb", "pg_ctl", "psql", "postgres"];
  const missing = required
    .map((name) => postgresBinary(postgresDir, name))
    .filter((filePath) => !pathExists(filePath));

  if (missing.length > 0) {
    throw new Error(
      [
        "Bundled PostgreSQL runtime is missing.",
        `Expected runtime directory: ${postgresDir}`,
        `Missing files: ${missing.join(", ")}`,
        "Prepare it with scripts\\prepare-postgres-runtime.ps1 before building the installer.",
      ].join("\n")
    );
  }
}

function postgresEnv(config) {
  return {
    ...process.env,
    PGPASSWORD: config.dbPassword,
  };
}

async function initializePostgresIfNeeded(resources, userDataDir, config) {
  postgresDataDir = path.join(userDataDir, "postgres-data");
  postgresPgCtlPath = postgresBinary(resources.postgresDir, "pg_ctl");

  if (pathExists(path.join(postgresDataDir, "PG_VERSION"))) {
    return;
  }

  appendLog("initializing postgres data directory");
  const passwordFile = path.join(userDataDir, "postgres-password.txt");
  fs.writeFileSync(passwordFile, config.dbPassword, "utf8");

  const initProfiles = [
    {
      name: "utf8-builtin",
      args: ["--locale-provider", "builtin", "--builtin-locale", "C.UTF-8", "--encoding", "UTF8"],
    },
    {
      name: "win1251-russian",
      args: ["--locale", "Russian_Russia.1251", "--encoding", "WIN1251"],
    },
    {
      name: "utf8-no-locale",
      args: ["--no-locale", "--encoding", "UTF8"],
    },
  ];

  let lastError = null;

  for (const profile of initProfiles) {
    try {
      appendLog(`trying initdb profile: ${profile.name}`);
      fs.rmSync(postgresDataDir, { recursive: true, force: true });
      ensureDir(postgresDataDir);

      await run(
        postgresBinary(resources.postgresDir, "initdb"),
        [
          "-D",
          postgresDataDir,
          "-U",
          config.dbUser,
          "-A",
          "scram-sha-256",
          "--pwfile",
          passwordFile,
          "--no-instructions",
          ...profile.args,
        ],
        {
          env: postgresEnv(config),
          timeoutMs: 180000,
          logPrefix: `initdb:${profile.name}`,
        }
      );
      return;
    } catch (error) {
      lastError = error;
      appendLog(`initdb profile failed: ${profile.name}: ${error.message}`);
    }
  }

  throw lastError || new Error("PostgreSQL initdb failed.");
}

async function startPostgres(resources, userDataDir, config, port) {
  const logsDir = path.join(userDataDir, "logs");
  ensureDir(logsDir);

  await run(
    postgresPgCtlPath,
    [
      "-D",
      postgresDataDir,
      "-l",
      path.join(logsDir, "postgres.log"),
      "-o",
      `-h 127.0.0.1 -p ${port}`,
      "-w",
      "start",
    ],
    {
      env: postgresEnv(config),
      timeoutMs: 180000,
      logPrefix: "pg_ctl",
      stdio: "ignore",
    }
  );

  postgresStarted = true;
}

function quoteIdentifier(value) {
  return `"${String(value).replace(/"/g, "\"\"")}"`;
}

async function runPsql(resources, config, port, database, sql, options = {}) {
  return run(
    postgresBinary(resources.postgresDir, "psql"),
    [
      "-h",
      "127.0.0.1",
      "-p",
      String(port),
      "-U",
      config.dbUser,
      "-d",
      database,
      "-tAc",
      sql,
    ],
    {
      env: postgresEnv(config),
      timeoutMs: options.timeoutMs || 120000,
      allowNonZero: options.allowNonZero || false,
      logPrefix: "psql",
    }
  );
}

async function ensureDatabaseExists(resources, config, port) {
  const existsResult = await runPsql(
    resources,
    config,
    port,
    "postgres",
    `SELECT 1 FROM pg_database WHERE datname='${config.dbName.replace(/'/g, "''")}'`
  );

  if (existsResult.stdout.trim() === "1") {
    return;
  }

  await runPsql(
    resources,
    config,
    port,
    "postgres",
    `CREATE DATABASE ${quoteIdentifier(config.dbName)} WITH ENCODING 'UTF8' TEMPLATE template0`
  );
}

async function databaseHasSeedData(resources, config, port) {
  const tableResult = await runPsql(
    resources,
    config,
    port,
    config.dbName,
    "SELECT to_regclass('public.diets') IS NOT NULL",
    { allowNonZero: true }
  );

  if (tableResult.code !== 0 || tableResult.stdout.trim() !== "t") {
    return false;
  }

  const countResult = await runPsql(
    resources,
    config,
    port,
    config.dbName,
    "SELECT COUNT(*) FROM public.diets",
    { allowNonZero: true }
  );

  const count = Number.parseInt(countResult.stdout.trim(), 10);
  return Number.isFinite(count) && count > 0;
}

function prepareSeedFile(seedFile, userDataDir) {
  if (!pathExists(seedFile)) {
    throw new Error(`Seed file was not found: ${seedFile}`);
  }

  const preparedFile = path.join(userDataDir, "seed-prepared.sql");
  const lines = fs.readFileSync(seedFile, "utf8").split(/\r?\n/);
  const prepared = [];
  let skippingCreateDatabase = false;

  for (const line of lines) {
    if (/^\\restrict/.test(line) || /^\\unrestrict/.test(line) || /^\\connect/.test(line)) {
      continue;
    }

    if (/^DROP DATABASE\b/.test(line)) {
      continue;
    }

    if (/^CREATE DATABASE\b/.test(line)) {
      skippingCreateDatabase = true;
      continue;
    }

    if (skippingCreateDatabase) {
      if (/;\s*$/.test(line)) {
        skippingCreateDatabase = false;
      }
      continue;
    }

    if (/^ALTER\s+.+\s+OWNER TO\s+postgres;?\s*$/.test(line)) {
      continue;
    }

    prepared.push(line);
  }

  fs.writeFileSync(preparedFile, prepared.join("\n"), "utf8");
  return preparedFile;
}

async function importSeedIfNeeded(resources, userDataDir, config, port) {
  if (await databaseHasSeedData(resources, config, port)) {
    return;
  }

  appendLog("importing database seed");
  const preparedSeed = prepareSeedFile(resources.seedFile, userDataDir);

  await run(
    postgresBinary(resources.postgresDir, "psql"),
    [
      "-h",
      "127.0.0.1",
      "-p",
      String(port),
      "-U",
      config.dbUser,
      "-d",
      config.dbName,
      "--set",
      "ON_ERROR_STOP=0",
      "--quiet",
      "--file",
      preparedSeed,
    ],
    {
      env: postgresEnv(config),
      timeoutMs: 300000,
      logPrefix: "seed",
    }
  );

  fs.writeFileSync(path.join(userDataDir, "seed-applied.txt"), new Date().toISOString(), "utf8");
}

function startBackend(resources, config, postgresPort, backendPort) {
  const backendEnv = {
    ...process.env,
    DB_HOST: "127.0.0.1",
    DB_PORT: String(postgresPort),
    DB_USER: config.dbUser,
    DB_PASSWORD: config.dbPassword,
    DB_NAME: config.dbName,
    JWT_SECRET_KEY: config.jwtSecret,
    BACKEND_HOST: "127.0.0.1",
    BACKEND_PORT: String(backendPort),
    FLASK_DEBUG: "0",
    FRONTEND_DIST: resources.frontendDir,
    PYTHONUNBUFFERED: "1",
  };

  delete backendEnv.DATABASE_URL;

  let command = resources.backendExe;
  let args = [];

  if (!pathExists(command)) {
    if (app.isPackaged) {
      throw new Error(`Backend executable was not found: ${command}`);
    }

    command = process.env.PYTHON || "python";
    args = [resources.backendScript];
  }

  appendLog(`starting backend: ${command} ${args.join(" ")}`);
  backendProcess = spawn(command, args, {
    env: backendEnv,
    cwd: appRoot(),
    windowsHide: true,
  });

  backendProcess.stdout.on("data", (chunk) => {
    appendLog(`[backend:stdout] ${chunk.toString().trimEnd()}`);
  });

  backendProcess.stderr.on("data", (chunk) => {
    appendLog(`[backend:stderr] ${chunk.toString().trimEnd()}`);
  });

  backendProcess.on("exit", (code, signal) => {
    appendLog(`backend exited: code=${code} signal=${signal}`);
  });
}

function waitForHttp(url, timeoutMs = 90000) {
  const startedAt = Date.now();

  return new Promise((resolve, reject) => {
    const attempt = () => {
      const request = http.get(url, (response) => {
        response.resume();
        if (response.statusCode >= 200 && response.statusCode < 500) {
          resolve();
          return;
        }
        retry();
      });

      request.on("error", retry);
      request.setTimeout(2000, () => {
        request.destroy();
        retry();
      });
    };

    const retry = () => {
      if (Date.now() - startedAt > timeoutMs) {
        reject(new Error(`Timed out waiting for ${url}`));
        return;
      }
      setTimeout(attempt, 1000);
    };

    attempt();
  });
}

function createWindow(appUrl, iconFile) {
  mainWindow = new BrowserWindow({
    width: 1280,
    height: 820,
    minWidth: 1024,
    minHeight: 700,
    icon: iconFile,
    show: false,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true,
    },
  });

  mainWindow.once("ready-to-show", () => {
    mainWindow.show();
  });

  mainWindow.loadURL(appUrl);
}

async function startApplication() {
  const resources = resolveResources();
  const installConfig = loadInstallConfig(resources);
  const userDataDir = installConfig.dataDir || app.getPath("userData");
  const logsDir = path.join(userDataDir, "logs");
  ensureDir(logsDir);
  logFile = path.join(logsDir, "desktop.log");

  appendLog(`${PRODUCT_NAME} startup`);
  appendLog(`user data directory: ${userDataDir}`);
  const config = loadRuntimeConfig(userDataDir);

  assertPostgresRuntime(resources.postgresDir);

  const postgresPort = await findFreePort();
  const backendPort = await findFreePort();
  appendLog(`selected ports: postgres=${postgresPort}, backend=${backendPort}`);

  await initializePostgresIfNeeded(resources, userDataDir, config);
  await startPostgres(resources, userDataDir, config, postgresPort);
  await ensureDatabaseExists(resources, config, postgresPort);
  await importSeedIfNeeded(resources, userDataDir, config, postgresPort);

  startBackend(resources, config, postgresPort, backendPort);

  const appUrl = `http://127.0.0.1:${backendPort}/`;
  await waitForHttp(`http://127.0.0.1:${backendPort}/api/health`);
  createWindow(appUrl, resources.iconFile);
}

function stopServicesSync() {
  if (backendProcess && !backendProcess.killed) {
    backendProcess.kill();
    backendProcess = null;
  }

  if (postgresStarted && postgresPgCtlPath && postgresDataDir) {
    spawnSync(
      postgresPgCtlPath,
      ["-D", postgresDataDir, "-m", "fast", "-w", "stop"],
      {
        windowsHide: true,
      }
    );
    postgresStarted = false;
  }
}

const gotLock = app.requestSingleInstanceLock();
if (!gotLock) {
  app.quit();
} else {
  app.on("second-instance", () => {
    if (mainWindow) {
      if (mainWindow.isMinimized()) {
        mainWindow.restore();
      }
      mainWindow.focus();
    }
  });

  app.whenReady().then(() => {
    startApplication().catch((error) => {
      appendLog(`startup failed: ${error.stack || error.message}`);
      dialog.showErrorBox("Dietrix startup failed", error.message);
      stopServicesSync();
      app.quit();
    });
  });

  app.on("activate", () => {
    if (BrowserWindow.getAllWindows().length === 0 && mainWindow) {
      mainWindow.show();
    }
  });

  app.on("window-all-closed", () => {
    app.quit();
  });

  app.on("before-quit", () => {
    if (shuttingDown) {
      return;
    }
    shuttingDown = true;
    stopServicesSync();
  });
}

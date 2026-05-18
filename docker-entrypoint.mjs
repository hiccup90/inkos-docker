import { mkdir } from "node:fs/promises";
import { execSync } from "node:child_process";
import { join } from "node:path";
import { pathToFileURL } from "node:url";

const HOME_DIR = process.env.HOME || "/config";
const PROJECT_ROOT = process.env.INKOS_PROJECT_ROOT || "/data";
const PORT = Number.parseInt(process.env.INKOS_STUDIO_PORT || "4567", 10);

process.env.HOME = HOME_DIR;
process.env.INKOS_PROJECT_ROOT = PROJECT_ROOT;
process.env.INKOS_STUDIO_PORT = String(PORT);

const GLOBAL_NODE_MODULES = execSync("npm root -g", { encoding: "utf-8" }).trim();
const CLI_ROOT = join(GLOBAL_NODE_MODULES, "@actalk", "inkos");
const STUDIO_ROOT = join(GLOBAL_NODE_MODULES, "@actalk", "inkos-studio");

const cliBootstrapUrl = pathToFileURL(join(CLI_ROOT, "dist", "project-bootstrap.js")).href;
const studioServerUrl = pathToFileURL(join(STUDIO_ROOT, "dist", "api", "server.js")).href;

await mkdir(HOME_DIR, { recursive: true });
await mkdir(PROJECT_ROOT, { recursive: true });

const { ensureProjectDirectoryInitialized } = await import(cliBootstrapUrl);
await ensureProjectDirectoryInitialized(PROJECT_ROOT, { language: "zh" });

const { startStudioServer } = await import(studioServerUrl);
await startStudioServer(PROJECT_ROOT, PORT, { staticDir: join(STUDIO_ROOT, "dist") });

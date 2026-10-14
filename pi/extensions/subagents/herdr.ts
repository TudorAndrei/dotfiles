/**
 * Herdr surface layer for interactive subagents.
 *
 * Child agents run in sibling Herdr panes. All commands use the caller pane
 * (`--current`) and `--no-focus`, so spawning never steals the user's focus.
 */
import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";

function herdrAvailable(): boolean {
  if (process.env.HERDR_ENV !== "1") return false;
  try {
    execFileSync("herdr", ["--version"], { stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
}

function requireHerdr(): void {
  if (!herdrAvailable()) throw new Error(muxSetupHint());
}

function command(args: string[]): unknown {
  const stdout = execFileSync("herdr", args, { encoding: "utf8" });
  try {
    return JSON.parse(stdout);
  } catch {
    return stdout;
  }
}

function findPaneId(value: unknown): string | undefined {
  if (typeof value === "string") return value.match(/w\d+:p\d+/)?.[0];
  if (!value || typeof value !== "object") return undefined;
  for (const [key, child] of Object.entries(value as Record<string, unknown>)) {
    if (key === "pane_id" && typeof child === "string") return child;
    const found = findPaneId(child);
    if (found) return found;
  }
}

function findText(value: unknown): string | undefined {
  if (typeof value === "string") return value;
  if (!value || typeof value !== "object") return undefined;
  const object = value as Record<string, unknown>;
  for (const key of ["output", "text", "content", "screen"]) {
    if (typeof object[key] === "string") return object[key] as string;
  }
  for (const child of Object.values(object)) {
    const found = findText(child);
    if (found) return found;
  }
  return undefined;
}

export function isMuxAvailable(): boolean {
  return herdrAvailable();
}

export function muxSetupHint(): string {
  return "Run pi inside a Herdr-managed pane (HERDR_ENV=1).";
}

export function shellEscape(value: string): string {
  return `'${value.replace(/'/g, "'\\''")}'`;
}

/** Create a sibling background pane from the calling agent's pane. */
export function createSurface(_name: string): string {
  requireHerdr();
  const result = command(["pane", "split", "--current", "--direction", "right", "--cwd", process.cwd(), "--no-focus"]);
  const paneId = findPaneId(result);
  if (!paneId) throw new Error(`Herdr did not return a pane id: ${JSON.stringify(result)}`);
  return paneId;
}

export function sendCommand(surface: string, message: string): void {
  requireHerdr();
  // The pane id is a valid agent target once Herdr recognizes the pi process.
  command(["agent", "prompt", surface, message]);
}

export function sendLongCommand(
  surface: string,
  commandText: string,
  options?: { scriptPath?: string; scriptPreamble?: string },
): string {
  requireHerdr();
  const scriptPath = options?.scriptPath ?? join(tmpdir(), "pi-subagent-scripts", `cmd-${Date.now()}.sh`);
  mkdirSync(dirname(scriptPath), { recursive: true });
  writeFileSync(scriptPath, ["#!/usr/bin/env bash", options?.scriptPreamble?.trimEnd(), commandText].filter(Boolean).join("\n") + "\n", { mode: 0o755 });
  command(["pane", "run", surface, `bash ${shellEscape(scriptPath)}`]);
  return scriptPath;
}

export function readScreen(surface: string, lines = 50): string {
  requireHerdr();
  const result = command(["pane", "read", surface, "--source", "recent-unwrapped", "--lines", String(lines)]);
  return findText(result) ?? JSON.stringify(result);
}

export function closeSurface(surface: string): void {
  requireHerdr();
  // This extension only closes panes it created.
  command(["pane", "close", surface]);
}

export interface PollResult {
  reason: "done" | "sentinel" | "error";
  exitCode: number;
  errorMessage?: string;
}

export async function pollForExit(
  surface: string,
  signal: AbortSignal,
  options: { interval: number; sessionFile?: string; sentinelFile?: string; onTick?: (elapsed: number) => void },
): Promise<PollResult> {
  const start = Date.now();
  while (!signal.aborted) {
    if (options.sessionFile && existsSync(`${options.sessionFile}.exit`)) {
      try {
        const payload = JSON.parse(await import("node:fs/promises").then(({ readFile }) => readFile(`${options.sessionFile}.exit`, "utf8")));
        return payload?.type === "error"
          ? { reason: "error", exitCode: 1, errorMessage: payload.errorMessage }
          : { reason: "done", exitCode: 0 };
      } catch { /* retry terminal sentinel */ }
    }
    if (options.sentinelFile && existsSync(options.sentinelFile)) return { reason: "sentinel", exitCode: 0 };
    try {
      const match = readScreen(surface, 8).match(/__SUBAGENT_DONE_(\d+)__/);
      if (match) return { reason: "sentinel", exitCode: Number(match[1]) };
    } catch { /* pane can close immediately after completion */ }
    options.onTick?.(Math.floor((Date.now() - start) / 1000));
    await new Promise<void>((resolve, reject) => {
      const timer = setTimeout(resolve, options.interval);
      signal.addEventListener("abort", () => { clearTimeout(timer); reject(new Error("Aborted")); }, { once: true });
    });
  }
  throw new Error("Aborted while waiting for subagent");
}

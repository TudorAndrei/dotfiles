#!/usr/bin/env python3
"""Serve on and off switches for systemd user units to the local Homepage."""

import json
import subprocess
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

HOST, PORT, NVIDIA_SMI = sys.argv[1], int(sys.argv[2]), sys.argv[3]
UNITS = sys.argv[4:]

PAGE = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Switches</title>
<style>
  body { margin: 0; padding: 8px; background: transparent; color: #e5e7eb;
         font: 15px system-ui, sans-serif; }
  .row { display: flex; align-items: center; gap: 12px; padding: 10px 12px;
         margin-bottom: 8px; border-radius: 6px; background: rgba(255, 255, 255, 0.06); }
  .dot { width: 12px; height: 12px; border-radius: 50%; background: #6b7280; flex: none; }
  .dot.active { background: #34d399; }
  .dot.failed { background: #f87171; }
  .name { flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .state { color: #9ca3af; font-size: 13px; }
  button { min-width: 84px; padding: 8px 12px; border: 0; border-radius: 6px;
           background: #374151; color: inherit; font: inherit; cursor: pointer; }
  button:hover { background: #4b5563; }
  button:disabled { opacity: 0.5; cursor: wait; }
  #gpu, #error { padding: 4px 12px; color: #9ca3af; font-size: 13px; }
  #error { color: #f87171; }
</style>
</head>
<body>
<div id="rows"></div>
<div id="gpu"></div>
<div id="error"></div>
<script>
const rows = document.getElementById("rows");
const gpu = document.getElementById("gpu");
const error = document.getElementById("error");

function render(data) {
  rows.replaceChildren(...Object.entries(data.units).map(([unit, state]) => {
    const on = state === "active" || state === "activating";
    const row = document.createElement("div");
    row.className = "row";
    const dot = document.createElement("span");
    dot.className = "dot " + state;
    const name = document.createElement("span");
    name.className = "name";
    name.textContent = unit;
    const label = document.createElement("span");
    label.className = "state";
    label.textContent = state;
    const button = document.createElement("button");
    button.textContent = on ? "Turn off" : "Turn on";
    button.onclick = () => {
      button.disabled = true;
      send((on ? "/stop/" : "/start/") + unit);
    };
    row.append(dot, name, label, button);
    return row;
  }));
  gpu.textContent = data.gpu_total_mib
    ? `GPU memory: ${data.gpu_used_mib} of ${data.gpu_total_mib} MiB`
    : "";
}

async function send(path) {
  try {
    const response = await fetch(path, { method: "POST", headers: { "X-Switch": "1" } });
    if (!response.ok) throw new Error(await response.text());
    error.textContent = "";
    render(await response.json());
  } catch (problem) {
    error.textContent = String(problem.message || problem).trim();
    refresh();
  }
}

async function refresh() {
  try {
    render(await (await fetch("/status")).json());
  } catch (problem) {
    error.textContent = "The switch service does not answer.";
  }
}

refresh();
setInterval(refresh, 5000);
</script>
</body>
</html>
""".encode()


def unit_state(unit):
    result = subprocess.run(
        ["systemctl", "--user", "is-active", f"{unit}.service"],
        capture_output=True, text=True, timeout=5,
    )
    return result.stdout.strip() or "unknown"


def gpu_memory():
    try:
        result = subprocess.run(
            [NVIDIA_SMI, "--query-gpu=memory.used,memory.total",
             "--format=csv,noheader,nounits"],
            check=True, capture_output=True, text=True, timeout=5,
        )
        used, total = (int(value) for value in result.stdout.splitlines()[0].split(","))
    except (OSError, subprocess.SubprocessError, ValueError, IndexError):
        return {}
    return {"gpu_used_mib": used, "gpu_total_mib": total}


def status():
    states = {unit: unit_state(unit) for unit in UNITS}
    return {"units": states, **states, **gpu_memory()}


class Handler(BaseHTTPRequestHandler):
    def reply(self, code, body, content_type):
        self.send_response(code)
        self.send_header("Content-Type", content_type)
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def reply_status(self):
        try:
            body = json.dumps(status()).encode()
        except (OSError, subprocess.SubprocessError):
            self.send_error(503, "Unit state is unavailable")
            return
        self.reply(200, body, "application/json")

    def do_GET(self):
        if self.path == "/":
            self.reply(200, PAGE, "text/html; charset=utf-8")
        elif self.path == "/status":
            self.reply_status()
        else:
            self.send_error(404)

    def do_POST(self):
        parts = self.path.strip("/").split("/")
        if len(parts) != 2 or parts[0] not in ("start", "stop") or parts[1] not in UNITS:
            self.send_error(404)
            return
        if self.headers.get("X-Switch") != "1":
            self.send_error(403, "The X-Switch header is necessary")
            return
        try:
            subprocess.run(
                ["systemctl", "--user", parts[0], f"{parts[1]}.service"],
                check=True, capture_output=True, text=True, timeout=60,
            )
        except (OSError, subprocess.SubprocessError) as problem:
            detail = getattr(problem, "stderr", "") or str(problem)
            self.reply(500, detail.encode(), "text/plain; charset=utf-8")
            return
        self.reply_status()

    def log_message(self, *args):
        pass


if __name__ == "__main__":
    ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()

#!/usr/bin/env python3
"""Serve read-only LVM thin pool use to the local Homepage process."""

import json
import subprocess
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != "/pool":
            self.send_error(404)
            return

        try:
            result = subprocess.run(
                [sys.argv[1], "--reportformat", "json", "--noheadings", "-o",
                 "data_percent,metadata_percent", "default/IncusThinPool"],
                check=True, capture_output=True, text=True, timeout=5,
            )
            values = json.loads(result.stdout)["report"][0]["lv"][0]
            payload = json.dumps({
                "data_percent": float(values["data_percent"]),
                "metadata_percent": float(values["metadata_percent"]),
            }).encode()
        except (OSError, subprocess.SubprocessError, ValueError, KeyError, IndexError):
            self.send_error(503, "Thin pool data is unavailable")
            return

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)


if __name__ == "__main__":
    ThreadingHTTPServer(("127.0.0.1", int(sys.argv[2])), Handler).serve_forever()

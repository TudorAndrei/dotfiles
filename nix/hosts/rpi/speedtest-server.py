import http.server
import sys


class Handler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-cache")
        super().end_headers()


http.server.ThreadingHTTPServer.allow_reuse_address = True
server = http.server.ThreadingHTTPServer(
    ("0.0.0.0", int(sys.argv[1])),
    lambda *a, **k: Handler(*a, directory=sys.argv[2], **k),
)
server.serve_forever()

"""Dependency-free web dashboard for the DevOps diploma project."""

import json
import os
import socket
import sys
import time
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit


STATIC_DIR = Path(__file__).with_name("static")
STARTED_AT = time.monotonic()


def get_ip_address():
    """Use Kubernetes POD_IP when provided; otherwise resolve the hostname."""
    if os.environ.get("POD_IP"):
        return os.environ["POD_IP"]
    try:
        return socket.gethostbyname(socket.gethostname())
    except socket.gaierror:
        return "unknown"


def status_payload():
    """Return safe runtime metadata used by the dashboard."""
    version = os.environ.get("APP_VERSION", "development")
    release = version.removeprefix("sha-")[:8] if version != "development" else version
    return {
        "status": "ok",
        "service": "dan-it-backend",
        "ip": get_ip_address(),
        "environment": "AWS EKS" if os.environ.get("POD_IP") else "local",
        "delivery": "GitHub Actions → Git → ArgoCD",
        "release": release,
        "uptime_seconds": round(time.monotonic() - STARTED_AT),
        "server_time": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "runtime": f"Python {sys.version_info.major}.{sys.version_info.minor}",
    }


class RequestHandler(BaseHTTPRequestHandler):
    server_version = "dan-it-backend"
    sys_version = ""

    def do_GET(self):
        path = urlsplit(self.path).path

        if path in ("/", "/index.html"):
            self._send_file(STATIC_DIR / "index.html", "text/html; charset=utf-8")
        elif path == "/assets/styles.css":
            self._send_file(STATIC_DIR / "styles.css", "text/css; charset=utf-8")
        elif path == "/assets/app.js":
            self._send_file(STATIC_DIR / "app.js", "application/javascript; charset=utf-8")
        elif path == "/api/status":
            self._send_json(200, status_payload())
        elif path == "/healthz":
            self._send_json(200, {"status": "ok"})
        else:
            self._send_json(404, {"error": "Not found"})

    def _send_file(self, file_path, content_type):
        try:
            body = file_path.read_bytes()
        except FileNotFoundError:
            self._send_json(500, {"error": "Static asset unavailable"})
            return
        self._send(200, body, content_type, cache_control="no-cache")

    def _send_json(self, status, payload):
        body = json.dumps(payload, separators=(",", ":")).encode("utf-8")
        self._send(status, body, "application/json; charset=utf-8", cache_control="no-store")

    def _send(self, status, body, content_type, cache_control):
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", cache_control)
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("Referrer-Policy", "no-referrer")
        self.send_header(
            "Content-Security-Policy",
            "default-src 'self'; script-src 'self'; style-src 'self'; "
            "connect-src 'self'; img-src 'self' data:; object-src 'none'; "
            "base-uri 'none'; frame-ancestors 'none'",
        )
        self.end_headers()
        self.wfile.write(body)


if __name__ == "__main__":
    port = int(os.environ.get("PORT", "8000"))
    with ThreadingHTTPServer(("0.0.0.0", port), RequestHandler) as server:
        print(f"Dashboard listening on 0.0.0.0:{port}", flush=True)
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            pass

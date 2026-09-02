"""Minimal HTTP backend for the DevOps diploma project."""

import json
import os
import socket
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit


def get_ip_address():
    """Use Kubernetes POD_IP when provided; otherwise resolve the hostname."""
    if os.environ.get("POD_IP"):
        return os.environ["POD_IP"]
    try:
        return socket.gethostbyname(socket.gethostname())
    except socket.gaierror:
        return "unknown"


class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if urlsplit(self.path).path == "/":
            status = 200
            payload = {"status": "ok", "ip": get_ip_address()}
        else:
            status = 404
            payload = {"error": "Not found"}

        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


if __name__ == "__main__":
    port = int(os.environ.get("PORT", "8000"))
    with ThreadingHTTPServer(("0.0.0.0", port), RequestHandler) as server:
        print(f"Server listening on 0.0.0.0:{port}", flush=True)
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            pass

#!/usr/bin/env python3
"""Serve exported Flutter web site with SPA fallback (/admin → index.html)."""
from __future__ import annotations

import os
import socket
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer


class SpaHandler(SimpleHTTPRequestHandler):
    def send_error(self, code, message=None, explain=None):
        if code == 404:
            path = self.path.split("?", 1)[0]
            if path not in ("/", "/index.html") and not path.startswith("/."):
                self.path = "/index.html"
                return self.do_GET()
        return super().send_error(code, message, explain)

    def log_message(self, format, *args):
        # Quieter logs (optional: comment out to see every request)
        if args and isinstance(args[0], str) and args[0].startswith("GET /"):
            super().log_message(format, *args)


def _port_available(port: int) -> bool:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        try:
            sock.bind(("", port))
        except OSError:
            return False
    return True


def _pick_port(preferred: int, max_tries: int = 20) -> int:
    for offset in range(max_tries):
        port = preferred + offset
        if _port_available(port):
            return port
    raise SystemExit(
        f"No free port found in range {preferred}–{preferred + max_tries - 1}. "
        f"Stop other servers or set PORT=9090 python3 serve_local.py"
    )


def main() -> None:
    preferred = int(os.environ.get("PORT", "8080"))
    port = _pick_port(preferred)
    root = os.path.dirname(os.path.abspath(__file__)) or "."
    os.chdir(root)

    if port != preferred:
        print(
            f"Note: port {preferred} is already in use "
            f"(often an old 'python3 -m http.server' or another app)."
        )
        print(f"Using port {port} instead.\n")

    server = ThreadingHTTPServer(("", port), SpaHandler)
    print(f"Serving: {root}")
    print(f"  Site:  http://localhost:{port}/")
    print(f"  Admin: http://localhost:{port}/admin")
    print("\nPress Ctrl+C to stop.")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopped.")


if __name__ == "__main__":
    main()

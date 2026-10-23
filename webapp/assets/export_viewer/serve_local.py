#!/usr/bin/env python3
"""Serve exported Flutter web site with SPA fallback (/admin → index.html)."""
from __future__ import annotations

import os
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer


class SpaHandler(SimpleHTTPRequestHandler):
    def send_error(self, code, message=None, explain=None):
        if code == 404:
            path = self.path.split("?", 1)[0]
            if path not in ("/", "/index.html") and not path.startswith("/."):
                self.path = "/index.html"
                return self.do_GET()
        return super().send_error(code, message, explain)


def main() -> None:
    port = int(os.environ.get("PORT", "8080"))
    root = os.path.dirname(os.path.abspath(__file__)) or "."
    os.chdir(root)
    server = ThreadingHTTPServer(("", port), SpaHandler)
    print(f"Serving {root}")
    print(f"  Site:  http://localhost:{port}/")
    print(f"  Admin: http://localhost:{port}/admin")
    server.serve_forever()


if __name__ == "__main__":
    main()

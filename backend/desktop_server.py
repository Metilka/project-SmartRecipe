import argparse
import os
import sys
from pathlib import Path

from flask import Flask, Response, send_from_directory
from waitress import serve

from app import create_app


class ApiPrefixDispatcher:
    """Route /api/* to the Flask API app with the /api prefix stripped."""

    def __init__(self, api_app, frontend_app):
        self.api_app = api_app
        self.frontend_app = frontend_app

    def __call__(self, environ, start_response):
        path = environ.get("PATH_INFO", "")

        if path == "/api" or path.startswith("/api/"):
            api_environ = environ.copy()
            api_environ["SCRIPT_NAME"] = environ.get("SCRIPT_NAME", "") + "/api"
            api_environ["PATH_INFO"] = path[4:] or "/"
            return self.api_app.wsgi_app(api_environ, start_response)

        return self.frontend_app.wsgi_app(environ, start_response)


def default_frontend_dist() -> Path:
    if getattr(sys, "frozen", False):
        return Path(sys.executable).resolve().parent.parent / "frontend"

    return Path(__file__).resolve().parents[1] / "frontend" / "dist"


def create_frontend_app(frontend_dist: Path) -> Flask:
    frontend_app = Flask("smartrecipe_desktop_frontend", static_folder=None)

    @frontend_app.route("/", defaults={"asset_path": ""})
    @frontend_app.route("/<path:asset_path>")
    def serve_frontend(asset_path):
        index_file = frontend_dist / "index.html"

        if not index_file.exists():
            return Response(
                "Frontend build was not found. Run npm run build in frontend first.",
                status=503,
                mimetype="text/plain",
            )

        if asset_path:
            candidate = frontend_dist / asset_path
            if candidate.is_file():
                return send_from_directory(frontend_dist, asset_path)

        return send_from_directory(frontend_dist, "index.html")

    return frontend_app


def build_wsgi_app(frontend_dist: Path):
    api_app = create_app()
    frontend_app = create_frontend_app(frontend_dist)
    return ApiPrefixDispatcher(api_app=api_app, frontend_app=frontend_app)


def parse_args():
    parser = argparse.ArgumentParser(description="SmartRecipe desktop backend")
    parser.add_argument("--host", default=os.getenv("BACKEND_HOST", "127.0.0.1"))
    parser.add_argument("--port", type=int, default=int(os.getenv("BACKEND_PORT", "5000")))
    parser.add_argument(
        "--frontend-dist",
        default=os.getenv("FRONTEND_DIST") or str(default_frontend_dist()),
    )
    return parser.parse_args()


def main():
    args = parse_args()
    frontend_dist = Path(args.frontend_dist).resolve()
    wsgi_app = build_wsgi_app(frontend_dist)

    serve(
        wsgi_app,
        host=args.host,
        port=args.port,
        threads=8,
        ident="SmartRecipe",
    )


if __name__ == "__main__":
    main()

"""Every error leaves the API as  {"error": "message"}  with a fitting status code."""
import logging
import os
from datetime import datetime
from pathlib import Path

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from sqlalchemy.exc import SQLAlchemyError
from starlette.exceptions import HTTPException as StarletteHTTPException

from .paths import PROJECT_DIR

logger = logging.getLogger("kopragrade")


def _log_path() -> Path:
    """Where failed requests are written. The tests point this at a temp file (see tests/conftest.py)."""
    custom = os.environ.get("ERROR_LOG_PATH", "").strip()
    return Path(custom) if custom else PROJECT_DIR / "logs" / "errors.log"


# Every failed request (404s above all) is also written here, so a problem can be looked up
# later without keeping the terminal open. The file is truncated after ~1 MB.
ERROR_LOG = _log_path()
MAX_LOG_BYTES = 1_000_000


def record_error(request: Request, status: int, detail: str) -> None:
    """Append one failed request to logs/errors.log. Never raises: the log must not change a response."""
    try:
        ERROR_LOG.parent.mkdir(parents=True, exist_ok=True)
        if ERROR_LOG.exists() and ERROR_LOG.stat().st_size > MAX_LOG_BYTES:
            ERROR_LOG.replace(ERROR_LOG.with_name("errors.log.1"))
        query = f"?{request.url.query}" if request.url.query else ""
        client = request.client.host if request.client else "-"
        agent = request.headers.get("user-agent", "-")
        stamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with ERROR_LOG.open("a", encoding="utf-8") as handle:
            handle.write(
                f"{stamp}\t{status}\t{request.method} {request.url.path}{query}\t{client}\t{agent}\t{detail}\n"
            )
    except OSError:
        logger.debug("Could not write %s", ERROR_LOG)


def _first_message(errors: list[dict]) -> str:
    if not errors:
        return "The request is not valid."
    err = errors[0]
    loc = [str(p) for p in err.get("loc", ()) if p not in ("body", "query", "path", "form")]
    field = loc[-1] if loc else ""
    kind = err.get("type", "")
    msg = err.get("msg", "")

    if kind == "json_invalid":
        return "Request body is not valid JSON."
    if field == "image":
        return 'Please attach one copra image in the "image" field.'
    if kind == "missing":
        return f'"{field}" is required.' if field else "Request body is required."
    if msg.startswith("Value error, "):
        return msg[len("Value error, "):]
    if err.get("loc") and err["loc"][0] == "path":
        return "The id in the address must be a number."
    if not field:
        return "Request body must be a JSON object."
    return f'The value of "{field}" is not valid.'


def install_error_handlers(app: FastAPI) -> None:
    @app.exception_handler(StarletteHTTPException)
    async def http_error(request: Request, exc: StarletteHTTPException) -> JSONResponse:
        detail = exc.detail if isinstance(exc.detail, str) else "The request could not be completed."
        if exc.status_code == 404 and detail == "Not Found":
            detail = "Route not found."
        record_error(request, exc.status_code, detail)
        return JSONResponse({"error": detail}, status_code=exc.status_code, headers=getattr(exc, "headers", None))

    @app.exception_handler(RequestValidationError)
    async def validation_error(request: Request, exc: RequestValidationError) -> JSONResponse:
        message = _first_message(exc.errors())
        record_error(request, 400, message)
        return JSONResponse({"error": message}, status_code=400)

    # Database or disk problems. Registered for these classes (not for Exception) so the
    # response still passes through the CORS middleware and the browser app can read it.
    @app.exception_handler(SQLAlchemyError)
    @app.exception_handler(OSError)
    async def server_problem(request: Request, exc: Exception) -> JSONResponse:
        logger.error("Server problem on %s %s: %r", request.method, request.url.path, exc)
        record_error(request, 500, "Something went wrong on the server.")
        return JSONResponse({"error": "Something went wrong on the server."}, status_code=500)

    @app.exception_handler(Exception)
    async def unexpected_error(request: Request, exc: Exception) -> JSONResponse:
        logger.exception("Unexpected error on %s %s", request.method, request.url.path)
        record_error(request, 500, f"Unexpected error: {exc!r}")
        return JSONResponse({"error": "Something went wrong on the server."}, status_code=500)

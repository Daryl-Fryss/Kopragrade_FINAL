"""KopraGrade REST API (FastAPI). One Python application: API + image processing + ML model.

Run from the backend folder:   uvicorn app.main:app --reload
"""
import asyncio
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, HTMLResponse, Response
from fastapi.staticfiles import StaticFiles
from sqlalchemy import text

from .config import settings
from .database import engine
from .errors import install_error_handlers
from .paths import PROJECT_DIR
from .routers import auth, classification, gradings, history, users
from .services.classifier import CopraClassifier

logging.basicConfig(level=logging.INFO, format="%(levelname)s:     %(name)s: %(message)s")
# TensorFlow warns on Windows before it even starts ("no GPU support"). That message is not
# actionable here and hides the real API log lines, so only its errors are shown.
logging.getLogger("tensorflow").setLevel(logging.ERROR)
logger = logging.getLogger("kopragrade")


@asynccontextmanager
async def lifespan(app: FastAPI):
    # 1. PostgreSQL must be reachable
    try:
        async with engine.connect() as conn:
            await conn.execute(text("SELECT 1"))
    except Exception as exc:
        logger.error("Cannot connect to PostgreSQL: %s", exc)
        logger.error("Check DATABASE_URL in backend/.env and run: python -m app.db_setup")
        raise

    # 2. load the trained model once (the API still starts if the model files are missing)
    classifier = CopraClassifier(settings.model_path, settings.class_names_path)
    await asyncio.to_thread(classifier.load)
    app.state.classifier = classifier

    logger.info("KopraGrade API is ready. Images folder: %s", settings.images_dir)
    yield
    await engine.dispose()


app = FastAPI(
    title="KopraGrade API",
    version="1.0.0",
    description="Copra drying-quality grading: JWT login, farmer/buyer roles, MobileNetV2 classification.",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=False,
    allow_methods=["GET", "POST", "PUT", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type", "Accept"],
)
install_error_handlers(app)

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(classification.router)
app.include_router(gradings.router)
app.include_router(history.router)


@app.get("/api/health", tags=["health"])
async def health(request: Request):
    classifier: CopraClassifier = request.app.state.classifier
    return {"status": "ok"}


@app.get("/health", include_in_schema=False)
@app.get("/healthz", include_in_schema=False)  # the plain name health checkers like to call
async def health_alias(request: Request):
    return await health(request)


@app.get("/api", include_in_schema=False)
@app.get("/api/", include_in_schema=False)
async def api_index():
    """A short list of the API addresses, so opening /api in a browser is not a 404."""
    return {
        "name": app.title,
        "version": app.version,
        "docs": "/docs",
        "health": "/api/health",
        "endpoints": [
            {"method": "POST", "path": "/api/auth/register", "who": "anyone", "purpose": "create an account"},
            {"method": "POST", "path": "/api/auth/login", "who": "anyone", "purpose": "get a token"},
            {"method": "POST", "path": "/api/classification/predict", "who": "farmer", "purpose": "grade a photo"},
            {"method": "GET", "path": "/api/gradings/{id}", "who": "farmer (own) / buyer (any)", "purpose": "one grading"},
            {"method": "GET", "path": "/api/history", "who": "farmer (own) / buyer (all)", "purpose": "grading list"},
            {"method": "GET", "path": "/api/users/me", "who": "logged in", "purpose": "current profile"},
            {"method": "PUT", "path": "/api/users/me", "who": "logged in", "purpose": "update profile"},
            {"method": "GET", "path": "/api/health", "who": "anyone", "purpose": "server and model check"},
        ],
    }


# The browser asks for this icon on every page it opens on this address (a missing one is a 404).
FAVICON_PATH = PROJECT_DIR / "frontend" / "web" / "favicon.png"


@app.get("/favicon.ico", include_in_schema=False)
async def favicon():
    if FAVICON_PATH.is_file():
        return FileResponse(FAVICON_PATH, media_type="image/png")
    return Response(status_code=204)


HOME_PAGE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>KopraGrade API</title>
<link rel="icon" href="/favicon.ico">
<style>
  body { margin:0; background:#F5F7F3; color:#223B32; font:16px/1.6 system-ui,Segoe UI,Roboto,sans-serif; }
  main { max-width:640px; margin:0 auto; padding:48px 24px; }
  h1 { font-size:30px; margin:0 0 4px; color:#24634B; }
  p.sub { margin:0 0 24px; color:#697B72; }
  ul { list-style:none; padding:0; margin:0 0 24px; }
  li { background:#fff; border:1px solid #DDE5DF; border-radius:8px; padding:12px 16px; margin-bottom:8px; }
  a { color:#24634B; font-weight:600; text-decoration:none; }
  a:hover { text-decoration:underline; }
  code { background:#E5EFE7; border-radius:4px; padding:1px 6px; }
  .note { font-size:14px; color:#697B72; }
  .ok::before { content:"\\2713 "; color:#24634B; font-weight:700; }
  .warn::before { content:"! "; color:#976700; font-weight:700; }
</style>
</head>
<body>
<main>
  <h1>KopraGrade API is running</h1>
  <p class="sub">Copra drying-quality grading &mdash; JWT login, farmer/buyer roles, MobileNetV2 classification.</p>
  <p class="{STATUS_CLASS}">{STATUS_TEXT}</p>
  <ul>
    <li><a href="/docs">/docs</a> &mdash; try every endpoint from the browser</li>
    <li><a href="/api">/api</a> &mdash; list of the API addresses</li>
    <li><a href="/api/health">/api/health</a> &mdash; server and model check</li>
  </ul>
  <p class="note">The Flutter app runs separately with <code>flutter run</code> (see README.md);
  it calls this server at <code>/api</code>.</p>
</main>
</body>
</html>
"""


@app.get("/", include_in_schema=False, response_class=HTMLResponse)
async def home(request: Request):
    """Opening the server address in a browser gives this page instead of a 404."""
    classifier: CopraClassifier = request.app.state.classifier
    if classifier.loaded:
        status_class, status_text = "ok", "The grading model is loaded and ready."
    else:
        status_class, status_text = "warn", "The grading model is not available: " + (classifier.error or "")
    return HTMLResponse(
        HOME_PAGE.replace("{STATUS_CLASS}", status_class).replace("{STATUS_TEXT}", status_text)
    )


@app.get("/v1/models", include_in_schema=False)
async def openai_style_model_list():
    """Answers the OpenAI-style model probe that editors and local tools send to a server on
    this port. KopraGrade is not an LLM server, so the list is empty: the caller gets a valid
    answer instead of a 404, and no model that cannot work here is advertised."""
    return {"object": "list", "data": []}


# Uploaded copra photos (random file names, so the addresses cannot be guessed).
app.mount("/images", StaticFiles(directory=str(settings.images_dir)), name="images")

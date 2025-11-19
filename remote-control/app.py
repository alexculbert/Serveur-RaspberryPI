"""REST API to forward prompts to Codex on the Raspberry Pi."""

from __future__ import annotations

import json
import os
import shlex
import subprocess
from pathlib import Path
from typing import Any, Dict, List, Optional

from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

DEFAULT_WORKDIR = Path(
    os.environ.get("CODEX_WORKDIR", "/home/alex/Desktop/serveur")
).expanduser()


class CodexRequest(BaseModel):
    prompt: str = Field(..., min_length=1, description="Instruction envoyée à Codex.")
    workdir: Optional[str] = Field(
        None, description="Répertoire de travail (par défaut: dépôt serveur)."
    )
    timeout: Optional[int] = Field(
        600,
        ge=5,
        le=3600,
        description="Temps max (secondes) avant de tuer l'exécution Codex.",
    )


class CodexResponse(BaseModel):
    command: str
    exit_code: int
    events: List[Dict[str, Any]]
    stdout: str
    stderr: str


allowed_origins_raw = os.environ.get("CODEX_ALLOWED_ORIGINS", "*")
allowed_origins = (
    ["*"]
    if allowed_origins_raw.strip() == "*"
    else [origin.strip() for origin in allowed_origins_raw.split(",") if origin.strip()]
)

app = FastAPI(
    title="Codex Remote Controller",
    description=(
        "API FastAPI exposant Codex pour piloter le dépôt Raspberry à distance. "
        "⚠️ À protéger absolument (auth + HTTPS) avant exposition."
    ),
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health", tags=["infrastructure"])
def healthcheck() -> Dict[str, str]:
    """Simple endpoint pour vérifier que l'API répond."""
    return {"status": "ok"}


@app.post("/codex/exec", response_model=CodexResponse, tags=["codex"])
def run_codex(request: CodexRequest) -> CodexResponse:
    """Lance `codex exec` avec le prompt fourni et retourne les événements JSON."""

    workdir = Path(request.workdir).expanduser() if request.workdir else DEFAULT_WORKDIR
    if not workdir.exists():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Répertoire inexistant: {workdir}",
        )

    quoted_cwd = shlex.quote(str(workdir))
    codex_cmd = (
        f'. "$HOME/.nvm/nvm.sh" && '
        f'codex exec --json --dangerously-bypass-approvals-and-sandbox '
        f"--skip-git-repo-check -C {quoted_cwd} -"
    )

    env = os.environ.copy()
    env.setdefault("HOME", str(Path.home()))
    env.setdefault("TERM", "xterm-256color")

    try:
        completed = subprocess.run(
            ["bash", "-lc", codex_cmd],
            input=request.prompt.encode("utf-8"),
            capture_output=True,
            env=env,
            timeout=request.timeout,
            check=False,
        )
    except subprocess.TimeoutExpired as exc:
        raise HTTPException(
            status_code=status.HTTP_504_GATEWAY_TIMEOUT,
            detail=f"Codex n'a pas répondu avant {request.timeout}s",
        ) from exc
    except FileNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Codex introuvable dans le PATH (nvm non initialisé ?)",
        ) from exc

    events: List[Dict[str, Any]] = []
    stdout_text = completed.stdout.decode("utf-8", errors="ignore")
    stderr_text = completed.stderr.decode("utf-8", errors="ignore")

    for line in stdout_text.splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        try:
            events.append(json.loads(stripped))
        except json.JSONDecodeError:
            # On ignore les lignes non JSON (ex. logs shell)
            continue

    return CodexResponse(
        command=codex_cmd,
        exit_code=completed.returncode,
        events=events,
        stdout=stdout_text,
        stderr=stderr_text,
    )

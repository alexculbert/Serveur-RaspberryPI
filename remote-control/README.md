# Codex Remote Controller

Service FastAPI qui expose Codex via HTTP afin de piloter la Raspberry Pi à distance (modifications du site Flutter, workflows n8n, etc.). L’API reçoit un prompt, exécute `codex exec` localement (avec `--dangerously-bypass-approvals-and-sandbox`) puis renvoie les événements JSON produits par Codex.

⚠️ **Sécurité** : cette API donne un accès total au dépôt et à la machine. Mettez-la derrière un reverse proxy HTTPS + authentification (ou VPN/Tailscale) avant de l’exposer.

## Installation

```bash
cd ~/Desktop/serveur/remote-control
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Démarrage

```bash
cd ~/Desktop/serveur/remote-control
source .venv/bin/activate
uvicorn app:app --host 0.0.0.0 --port 8080
```

Endpoints :

- `GET /health` → ping simple.
- `POST /codex/exec` → body JSON `{ "prompt": "Explique le workflow...", "timeout": 900 }`.

L’exécution appelle `codex exec --json --dangerously-bypass-approvals-and-sandbox -C ~/Desktop/serveur -` (en chargeant `~/.nvm/nvm.sh`). La réponse inclut :

- `exit_code` : code retour de Codex.
- `events` : les objets JSONL produits (plan, messages, diff, etc.).
- `stdout` / `stderr` : flux bruts pour debug.
- `command` : commande exacte exécutée.

## Étapes suivantes

- Ajouter une authentification (token, OAuth) et limiter les IP autorisées.
- Connecter le front Flutter ou une app mobile en envoyant les prompts sur cet endpoint.
- Optionnel : stocker les sessions dans une base (Redis/PostgreSQL) pour reprendre des conversations (`codex exec resume ...`).

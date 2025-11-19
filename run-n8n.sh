#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
set -a
if [ -f .env ]; then
  # shellcheck disable=SC1091
  source .env
fi
set +a
if ! command -v docker >/dev/null 2>&1; then
  echo "docker introuvable dans le PATH" >&2
  exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  echo "Le plugin docker compose n'est pas disponible" >&2
  exit 1
fi
printf '\nDémarrage de n8n (Docker compose) ...\n'
docker compose up -d
printf '\nn8n est disponible sur http://%s:%s\n' "${N8N_HOST:-localhost}" "${N8N_PORT:-5678}"
printf 'Interromps les logs avec CTRL+C (le conteneur reste actif).\n\n'
docker compose logs -f

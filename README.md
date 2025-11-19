# Projet Serveur Raspberry Pi

Ce dépôt contient la configuration Docker Compose utilisée pour faire tourner [n8n](https://n8n.io) localement sur ton Raspberry Pi. Tous les fichiers nécessaires (compose, script de lancement, données persistantes) sont regroupés ici pour garder le reste du système propre.

## Structure du dossier

- `docker-compose.yml` : stack n8n officiel avec le dossier `./data` monté comme persistance.
- `run-n8n.sh` : script pratique qui charge `.env`, vérifie Docker/Compose puis lance n8n et suit les logs.
- `.env` (ignoré par git) : configuration active. Un gabarit est fourni via `.env.example`.
- `data/` : contient les workflows, identifiants et paramètres n8n (à sauvegarder régulièrement, ignoré dans git).
- `bonjour_flutter/` : front Flutter Web (écran d’accueil, lecteur de conversation et console pour écrire à Codex).
- `remote-control/` : API FastAPI pour piloter Codex à distance (cf. section « Contrôle à distance »).

## Architecture suggérée (site + n8n)

Pour transformer le Raspberry Pi en serveur multi-services accessible partout :

- **Reverse proxy** (Traefik/Caddy/nginx) exposant plusieurs hôtes : ex. `https://alex.example.com` pour ton site et `https://n8n.alex.example.com` pour n8n.
- **Service web** (conteneur supplémentaire) qui affiche ton site et peut consommer les API/webhooks fournis par n8n pour montrer l’état du serveur, lancer des automatisations, etc.
- **n8n** (conteneur actuel) pour orchestrer les workflows, exposer des webhooks/API et alimenter ton site.
- **Sécurité** : HTTPS automatique via Let’s Encrypt, authentification basique ou OAuth devant n8n, sauvegardes régulières de `data/`, monitoring (workflow n8n de supervision ou outils comme Uptime Kuma).
- **Accès distant** : DNS dynamique ou tunnel sécurisé (Cloudflare Tunnel, Tailscale) si ton IP change ou si tu ne veux pas ouvrir de ports.

Cette structure reste modulaire : ajoute d’autres conteneurs (base de données, watcher, exporter métriques) et laisse n8n orchestrer tout en servant de “panneau de contrôle” via ton site web.

## Contrôle à distance (Codex Remote)

- Le dossier `remote-control/` fournit une API FastAPI (`app.py`) qui expose Codex via un endpoint `POST /codex/exec`.
- Usage rapide :
  ```bash
  cd remote-control
  python3 -m venv .venv
  source .venv/bin/activate
  pip install -r requirements.txt
  uvicorn app:app --host 0.0.0.0 --port 8080
  ```
- L’API lit `~/.nvm/nvm.sh`, exécute `codex exec --json --dangerously-bypass-approvals-and-sandbox -C ~/Desktop/serveur -` puis renvoie les événements JSON et les flux bruts.
- ⚠️ À sécuriser avant exposition (HTTPS + authentification, VPN/Tailscale). Sans protection, n’importe qui pourrait modifier le Raspberry.
- Le front Flutter (ou une app mobile) pourra appeler cet endpoint pour envoyer des instructions à Codex et récupérer les réponses sans ouvrir le terminal local.
- Pour la couche web actuelle (`bonjour_flutter`), lancez :
  ```bash
  cd bonjour_flutter
  export PATH="$HOME/flutter/bin:$PATH"
  flutter run -d web-server --web-hostname=0.0.0.0 --web-port=9000 \
    --dart-define=CODEX_API_URL=http://localhost:8080
  ```
  Ensuite, ouvrez `http://<IP>:9000` : bouton « Parler à Codex » → champ libre + sortie/erreurs. Ajustez `CODEX_API_URL` vers votre domaine public si besoin (avec HTTPS).

## Prérequis

- Docker + Docker Compose plugin installés.
- L’utilisateur courant doit pouvoir lancer `docker compose`.

## Mise en place

1. Copier la configuration d’exemple puis l’adapter :
   ```bash
   cp .env.example .env
   ```
2. Dans `.env`, pense à :
   - Régler `TZ`, `N8N_HOST`, `N8N_PROTOCOL`, `WEBHOOK_URL`, etc.
   - Générer et décommenter `N8N_ENCRYPTION_KEY` (`openssl rand -hex 32`) pour protéger les identifiants.
   - Activer éventuellement l’auth basique (`BASIC_AUTH_USER/BASIC_AUTH_PASSWORD`).
3. Lancer n8n :
   ```bash
   ./run-n8n.sh
   ```
   Le script lance `docker compose up -d` puis affiche les logs (CTRL+C pour sortir, le conteneur reste actif). Tu peux aussi utiliser directement `docker compose up -d`.
4. L’interface est accessible sur `http://<N8N_HOST>:<N8N_PORT>` (par défaut `http://localhost:5678`).

## Commandes utiles

- Voir les logs en continu : `docker compose logs -f`
- Arrêter les services : `docker compose down`
- Mettre à jour n8n : `docker compose pull && docker compose up -d`

Les données critiques vivent dans `data/`. Sauvegarde ce dossier (ou exporte les workflows) avant toute réinstallation. Pour une exposition publique, place un reverse proxy (Traefik/Caddy/Nginx) devant le port 5678 et active HTTPS + authentification. 

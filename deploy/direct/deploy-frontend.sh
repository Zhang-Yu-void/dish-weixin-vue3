#!/usr/bin/env bash
# Direct deploy: build Vue dist and sync to host Nginx document root.
set -euo pipefail

FRONTEND_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_FILE="${ENV_FILE:-${FRONTEND_REPO}/.env.prod}"

if [[ -f "${ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
fi

WWW_ROOT="${WWW_ROOT:-/data/ruoyi/www}"
NGINX_SITE="${NGINX_SITE:-/etc/nginx/conf.d/ruoyi.conf}"
NGINX_PORT="${NGINX_PORT:-8080}"
BACKEND_PORT="${BACKEND_PORT:-8082}"

install_nginx_site() {
  local template="${FRONTEND_REPO}/deploy/nginx/ruoyi.conf"
  local rendered="/tmp/ruoyi-nginx-${NGINX_PORT}.conf"

  if [[ ! -f "${template}" ]]; then
    echo "Error: nginx template not found: ${template}"
    exit 1
  fi

  sed -e "s/listen 8080;/listen ${NGINX_PORT};/" \
      -e "s|root /data/ruoyi/www;|root ${WWW_ROOT};|" \
      -e "s|proxy_pass http://127.0.0.1:8082/;|proxy_pass http://127.0.0.1:${BACKEND_PORT}/;|" \
      "${template}" > "${rendered}"

  if command -v sudo >/dev/null 2>&1; then
    sudo mkdir -p "$(dirname "${NGINX_SITE}")"
    sudo cp "${rendered}" "${NGINX_SITE}"
    sudo nginx -t
    sudo systemctl reload nginx
  else
    mkdir -p "$(dirname "${NGINX_SITE}")"
    cp "${rendered}" "${NGINX_SITE}"
    nginx -t
    systemctl reload nginx 2>/dev/null || nginx -s reload
  fi
  echo "Nginx site installed: ${NGINX_SITE} (listen :${NGINX_PORT}, proxy -> :${BACKEND_PORT})"
}

DIST_DIR="${DIST_DIR:-${FRONTEND_REPO}/dist}"

if [[ "${SKIP_BUILD:-0}" == "1" ]]; then
  if [[ ! -f "${DIST_DIR}/index.html" ]]; then
    echo "Error: dist not found at ${DIST_DIR} (SKIP_BUILD=1)"
    exit 1
  fi
  mkdir -p "${WWW_ROOT}"
  rsync -av --delete "${DIST_DIR}/" "${WWW_ROOT}/"
  echo "Frontend dist synced -> ${WWW_ROOT}"
else
  if [[ ! -f "${FRONTEND_REPO}/package.json" ]]; then
    echo "Error: package.json not found in ${FRONTEND_REPO}"
    exit 1
  fi

  cd "${FRONTEND_REPO}"
  if ! command -v pnpm >/dev/null 2>&1; then
    echo "Error: pnpm is required (this repo uses pnpm-lock.yaml, not npm)."
    echo "Install: corepack enable && corepack prepare pnpm@latest --activate"
    exit 1
  fi
  if [[ -f pnpm-lock.yaml ]]; then
    pnpm install --frozen-lockfile
  else
    pnpm install
  fi
  pnpm run build:prod

  mkdir -p "${WWW_ROOT}"
  rsync -av --delete "${FRONTEND_REPO}/dist/" "${WWW_ROOT}/"
  echo "Frontend built -> ${WWW_ROOT}"
fi

install_nginx_site
echo "Frontend ready at http://8.141.20.44:${NGINX_PORT}"

#!/usr/bin/env bash
# Publish pre-built dist to Nginx (no npm build).
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
DIST_DIR="${DIST_DIR:-${FRONTEND_REPO}/dist}"

install_nginx_site() {
  local template="${NGINX_TEMPLATE:-${FRONTEND_REPO}/deploy/nginx/ruoyi.conf}"
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

if [[ ! -f "${DIST_DIR}/index.html" ]]; then
  echo "Error: dist not found: ${DIST_DIR}/index.html"
  exit 1
fi

mkdir -p "${WWW_ROOT}"
rsync -av --delete "${DIST_DIR}/" "${WWW_ROOT}/"
echo "Static files published -> ${WWW_ROOT}"

install_nginx_site

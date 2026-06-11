#!/usr/bin/env bash
# Run on server after SSH login to diagnose frontend / Nginx connectivity.
set -euo pipefail

FRONTEND_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_FILE="${ENV_FILE:-${FRONTEND_REPO}/.env.prod}"
if [[ -f "${ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
fi

NGINX_PORT="${NGINX_PORT:-8080}"
BACKEND_PORT="${BACKEND_PORT:-8082}"
WWW_ROOT="${WWW_ROOT:-/data/ruoyi/www}"
DOCKER_FRONTEND_CONTAINER="${DOCKER_FRONTEND_CONTAINER:-vue-front-app}"

echo "=== Frontend connectivity diagnostics ==="
echo "Time: $(date -Iseconds)"
echo "Expected: nginx :${NGINX_PORT}, backend proxy target :${BACKEND_PORT}"
echo

check_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    echo "[ok] $1 found"
    return 0
  fi
  echo "[skip] $1 not installed"
  return 1
}

echo "--- Listening ports ---"
if check_cmd ss; then
  ss -lntp 2>/dev/null | grep -E ":${NGINX_PORT} |:${BACKEND_PORT} " || echo "(no ${NGINX_PORT}/${BACKEND_PORT} listeners found)"
fi
echo

echo "--- Static files (${WWW_ROOT}) ---"
if [[ -f "${WWW_ROOT}/index.html" ]]; then
  echo "[ok] ${WWW_ROOT}/index.html exists"
else
  echo "[fail] ${WWW_ROOT}/index.html missing"
fi
echo

echo "--- Nginx prod-api proxy (:${NGINX_PORT}) ---"
PROXY_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 "http://127.0.0.1:${NGINX_PORT}/prod-api/captchaImage" 2>/dev/null || true)
PROXY_CODE=${PROXY_CODE:-000}
echo "http://127.0.0.1:${NGINX_PORT}/prod-api/captchaImage -> ${PROXY_CODE}"
echo

if check_cmd nginx; then
  echo "--- Nginx prod-api config ---"
  nginx -T 2>/dev/null | grep -A6 'location /prod-api' || echo "(no /prod-api location in nginx -T)"
  echo
fi

if check_cmd docker; then
  echo "--- Docker containers (legacy frontend container should be removed) ---"
  docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null | head -10
  if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -qx "${DOCKER_FRONTEND_CONTAINER}"; then
    echo "[warn] Legacy container still present: ${DOCKER_FRONTEND_CONTAINER} (run migrate-from-docker.sh)"
  fi
  echo
fi

echo "--- Summary ---"
if [[ "${PROXY_CODE}" == "200" ]]; then
  echo "Nginx proxy on :${NGINX_PORT}: OK"
else
  echo "Nginx proxy: FAIL - run: bash deploy/direct/deploy-frontend.sh"
  echo "Ensure backend is running on :${BACKEND_PORT} (dish-weixin-springboot3)"
  echo "Ensure VITE_APP_BASE_API=/prod-api in .env.production"
fi

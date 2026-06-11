#!/usr/bin/env bash
# Frontend + Nginx proxy checks (run on server after deploy).
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
FAIL=0

check() {
  local label="$1"
  local url="$2"
  local code
  code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "${url}" 2>/dev/null || true)
  code=${code:-000}
  if [[ "${code}" == "200" ]]; then
    echo "[ok] ${label} (${code}) ${url}"
  else
    echo "[fail] ${label} (${code}) ${url}"
    FAIL=1
  fi
}

echo "=== Frontend E2E verification ==="

check "Static index" "http://127.0.0.1:${NGINX_PORT}/"
check "Nginx prod-api proxy" "http://127.0.0.1:${NGINX_PORT}/prod-api/captchaImage"
check "Backend direct (sanity)" "http://127.0.0.1:${BACKEND_PORT}/captchaImage"

if [[ "${FAIL}" -eq 0 ]]; then
  echo
  echo "All checks passed. Open http://8.141.20.44:${NGINX_PORT} and login with admin/admin123"
  exit 0
fi

echo
echo "Some checks failed. Run: bash deploy/scripts/diagnose-server.sh"
exit 1

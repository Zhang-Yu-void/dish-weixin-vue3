#!/usr/bin/env bash
# Stop vue-front-app container and switch to direct Nginx deployment.
# Backend migration is in dish-weixin-springboot3 repo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRONTEND_REPO="$(cd "${SCRIPT_DIR}/../.." && pwd)"
ENV_FILE="${ENV_FILE:-${FRONTEND_REPO}/.env.prod}"

if [[ -f "${ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
fi

DOCKER_FRONTEND_CONTAINER="${DOCKER_FRONTEND_CONTAINER:-vue-front-app}"
WWW_ROOT="${WWW_ROOT:-/data/ruoyi/www}"

if command -v docker >/dev/null 2>&1; then
  echo "=== Migrating frontend from Docker container ==="

  if docker ps -a --format '{{.Names}}' | grep -qx "${DOCKER_FRONTEND_CONTAINER}"; then
    if [[ ! -f "${WWW_ROOT}/index.html" ]]; then
      echo "Copying static files from ${DOCKER_FRONTEND_CONTAINER} to ${WWW_ROOT} ..."
      mkdir -p "${WWW_ROOT}"
      docker cp "${DOCKER_FRONTEND_CONTAINER}:/usr/share/nginx/html/." "${WWW_ROOT}/"
    fi
    echo "Stopping ${DOCKER_FRONTEND_CONTAINER} ..."
    docker stop "${DOCKER_FRONTEND_CONTAINER}" || true
    docker rm "${DOCKER_FRONTEND_CONTAINER}" || true
  fi

  echo "Remaining containers:"
  docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
else
  echo "docker not found, skipping container migration"
fi

echo
echo "=== Direct deploy frontend ==="
bash "${SCRIPT_DIR}/deploy-frontend.sh"

echo
echo "Migration complete. Verify: bash deploy/scripts/verify-e2e.sh"

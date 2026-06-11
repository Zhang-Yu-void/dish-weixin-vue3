#!/usr/bin/env bash
# Build dist locally, upload to server, and reload Nginx.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_REPO="$(cd "${SCRIPT_DIR}/../.." && pwd)"
ENV_FILE="${ENV_FILE:-${LOCAL_REPO}/.env.prod}"

if [[ -f "${ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
fi

SSH_HOST="${SSH_HOST:-aliyun}"
WWW_ROOT="${WWW_ROOT:-/data/ruoyi/www}"
REMOTE_ENV_FILE="${REMOTE_ENV_FILE:-/data/ruoyi/.env.frontend.prod}"
REMOTE_DEPLOY_DIR="${REMOTE_DEPLOY_DIR:-/data/ruoyi/deploy}"
# Use LOCAL_REPO, not FRONTEND_REPO from .env.prod (that variable is the remote git URL).
DIST_LOCAL="${DIST_DIR:-${LOCAL_REPO}/dist}"
NGINX_PORT="${NGINX_PORT:-8080}"

if [[ -z "${SSH_HOST}" ]]; then
  echo "Error: set SSH_HOST in .env.prod (e.g. SSH_HOST=aliyun or SSH_HOST=root@8.141.20.44)"
  exit 1
fi

bash "${SCRIPT_DIR}/build.sh"

sync_dist_to_remote() {
  local src="${DIST_LOCAL}/"
  local dest="${SSH_HOST}:${WWW_ROOT}/"

  if ssh "${SSH_HOST}" "command -v rsync >/dev/null 2>&1"; then
    rsync -avz --delete "${src}" "${dest}"
    return
  fi

  echo ">>> Remote rsync not found, falling back to tar+ssh ..."
  ssh "${SSH_HOST}" "mkdir -p '${WWW_ROOT}' && find '${WWW_ROOT}' -mindepth 1 -delete"
  tar -C "${DIST_LOCAL}" -czf - . | ssh "${SSH_HOST}" "tar -xzf - -C '${WWW_ROOT}'"
}

echo ">>> Upload frontend dist to ${SSH_HOST}:${WWW_ROOT} ..."
ssh "${SSH_HOST}" "mkdir -p '${WWW_ROOT}' '${REMOTE_DEPLOY_DIR}'"
sync_dist_to_remote
scp "${ENV_FILE}" "${SSH_HOST}:${REMOTE_ENV_FILE}"
scp "${LOCAL_REPO}/deploy/nginx/ruoyi.conf" "${SSH_HOST}:${REMOTE_DEPLOY_DIR}/ruoyi.conf"
scp "${LOCAL_REPO}/deploy/direct/publish-static.sh" "${SSH_HOST}:${REMOTE_DEPLOY_DIR}/publish-static.sh"

echo ">>> Reload Nginx on server ..."
ssh "${SSH_HOST}" bash -s <<EOF
set -euo pipefail
ENV_FILE='${REMOTE_ENV_FILE}' DIST_DIR='${WWW_ROOT}' NGINX_TEMPLATE='${REMOTE_DEPLOY_DIR}/ruoyi.conf' \
  bash '${REMOTE_DEPLOY_DIR}/publish-static.sh'
EOF

echo ">>> Verify frontend ..."
ssh "${SSH_HOST}" bash -s <<EOF
set -euo pipefail
NGINX_PORT="\$(grep -E '^NGINX_PORT=' '${REMOTE_ENV_FILE}' | cut -d= -f2- || true)"
NGINX_PORT="\${NGINX_PORT:-8080}"
BACKEND_PORT="\$(grep -E '^BACKEND_PORT=' '${REMOTE_ENV_FILE}' | cut -d= -f2- || true)"
BACKEND_PORT="\${BACKEND_PORT:-8082}"
for url in "http://127.0.0.1:\${NGINX_PORT}/" "http://127.0.0.1:\${NGINX_PORT}/prod-api/captchaImage"; do
  code=\$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "\${url}" || true)
  if [[ "\${code}" == "200" ]]; then
    echo "[ok] \${url} (\${code})"
  else
    echo "[fail] \${url} (\${code:-000})"
    exit 1
  fi
done
EOF

HOST="${SSH_HOST#*@}"
echo "Frontend deployed: http://${HOST}:${NGINX_PORT}"

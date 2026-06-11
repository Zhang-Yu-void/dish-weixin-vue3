#!/usr/bin/env bash
# Run ON Aliyun server (or pipe via: ssh root@8.141.20.44 'bash -s' < remote-deploy.sh)
set -euo pipefail

RUOYI_HOME="${RUOYI_HOME:-$HOME/ruoyi}"
FRONTEND_DIR="${FRONTEND_DIR:-${RUOYI_HOME}/dish-weixin-vue3}"

echo "=== Remote frontend deploy start ==="
echo "RUOYI_HOME=${RUOYI_HOME}"
echo "FRONTEND_DIR=${FRONTEND_DIR}"
echo "User: $(whoami)  Host: $(hostname)"
echo

mkdir -p "${RUOYI_HOME}" /data/ruoyi/www 2>/dev/null || \
  sudo mkdir -p "${RUOYI_HOME}" /data/ruoyi/www

clone_if_missing() {
  local url="$1" dir="$2"
  if [[ -d "${dir}/.git" ]]; then
    return 0
  fi
  echo ">>> Cloning ${url} ..."
  git clone "${url}" "${dir}"
}

clone_if_missing "https://github.com/Zhang-Yu-void/dish-weixin-vue3.git" "${FRONTEND_DIR}"

echo ">>> Sync frontend code ..."
cd "${FRONTEND_DIR}"
git fetch origin
git checkout main 2>/dev/null || git checkout master
git reset --hard origin/main 2>/dev/null || git reset --hard origin/master
git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || true

if [[ ! -f deploy/direct/run-on-server.sh ]]; then
  echo "Error: deploy/direct/run-on-server.sh not found after git pull."
  echo "Try: cd ${FRONTEND_DIR} && git log -1 --oneline && ls -la deploy/direct/"
  exit 1
fi

export RUOYI_HOME
bash deploy/direct/run-on-server.sh

echo "=== Remote frontend deploy finished ==="

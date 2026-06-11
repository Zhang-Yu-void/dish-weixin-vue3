#!/usr/bin/env bash
# First-time server setup: create dirs and clone/pull frontend repo.
# Usage:
#   export RUOYI_HOME=/opt/ruoyi          # or $HOME/ruoyi if no sudo
#   bash bootstrap-server.sh
set -euo pipefail

RUOYI_HOME="${RUOYI_HOME:-/opt/ruoyi}"
FRONTEND_REPO="${FRONTEND_REPO:-https://github.com/Zhang-Yu-void/dish-weixin-vue3.git}"
FRONTEND_DIR="${FRONTEND_DIR:-${RUOYI_HOME}/dish-weixin-vue3}"

clone_or_update() {
  local repo_url="$1"
  local target_dir="$2"
  local name
  name="$(basename "${target_dir}")"

  if [[ -d "${target_dir}/.git" ]]; then
    echo ">>> Updating ${name} ..."
    git -C "${target_dir}" pull --ff-only origin master \
      || git -C "${target_dir}" pull --ff-only origin main \
      || git -C "${target_dir}" pull
    return
  fi

  if [[ -d "${target_dir}" ]]; then
    echo "Error: ${target_dir} exists but is not a git repo. Remove it or pick another path."
    exit 1
  fi

  echo ">>> Cloning ${name} from ${repo_url} ..."
  mkdir -p "$(dirname "${target_dir}")"
  if ! git clone "${repo_url}" "${target_dir}"; then
    cat <<EOF

*** git clone failed ***

If the repo is private, use one of:

  1) SSH (recommended on server):
     git clone git@github.com:Zhang-Yu-void/dish-weixin-vue3.git ${FRONTEND_DIR}

  2) HTTPS + Personal Access Token:
     git clone https://<TOKEN>@github.com/Zhang-Yu-void/dish-weixin-vue3.git ${FRONTEND_DIR}

See: https://github.com/settings/tokens
EOF
    exit 1
  fi
}

echo "=== Bootstrap frontend server ==="
echo "RUOYI_HOME=${RUOYI_HOME}"
echo "FRONTEND_DIR=${FRONTEND_DIR}"
echo

if [[ "${RUOYI_HOME}" == /opt/* ]] && [[ ! -w "$(dirname "${RUOYI_HOME}")" ]] 2>/dev/null; then
  if ! mkdir -p "${RUOYI_HOME}" 2>/dev/null; then
    echo "Cannot create ${RUOYI_HOME}. Try:"
    echo "  sudo mkdir -p ${RUOYI_HOME} && sudo chown \$(whoami) ${RUOYI_HOME}"
    echo "  or: export RUOYI_HOME=\$HOME/ruoyi"
    exit 1
  fi
fi
mkdir -p "${RUOYI_HOME}"

clone_or_update "${FRONTEND_REPO}" "${FRONTEND_DIR}"

mkdir -p /data/ruoyi/www 2>/dev/null \
  || sudo mkdir -p /data/ruoyi/www

echo
echo "Bootstrap OK."
echo "Next:"
echo "  cd ${FRONTEND_DIR}"
echo "  bash deploy/direct/run-on-server.sh"

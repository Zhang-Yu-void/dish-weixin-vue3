#!/usr/bin/env bash
# Check Node and Nginx on host for frontend direct deployment.
set -euo pipefail

echo "=== Frontend dependency check ==="

check_version() {
  local name="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "[ok] ${name}: $("$@" 2>&1 | head -1)"
  else
    echo "[missing] ${name}"
    return 1
  fi
}

MISSING=0
check_version "node" node -version || MISSING=1
check_version "pnpm" pnpm -version || MISSING=1
check_version "nginx" nginx -v || MISSING=1

echo
if [[ "${MISSING}" -eq 0 ]]; then
  echo "All frontend dependencies present."
else
  echo "Install hints (Alibaba Cloud Linux / CentOS):"
  echo "  sudo yum install -y nginx rsync"
  echo "  # Node: use nvm or official tarball"
  exit 1
fi

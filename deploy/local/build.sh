#!/usr/bin/env bash
# Build frontend dist locally.
set -euo pipefail

FRONTEND_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DIST_DIR="${DIST_DIR:-${FRONTEND_REPO}/dist}"

cd "${FRONTEND_REPO}"
if [[ -f package-lock.json ]]; then
  npm ci
else
  npm install
fi
npm run build:prod

if [[ ! -f "${DIST_DIR}/index.html" ]]; then
  echo "Error: build finished but dist missing: ${DIST_DIR}/index.html"
  exit 1
fi

echo "Built: ${DIST_DIR}"
du -sh "${DIST_DIR}"

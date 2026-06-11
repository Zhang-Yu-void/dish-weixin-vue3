#!/usr/bin/env bash
# Build frontend dist locally.
set -euo pipefail

FRONTEND_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DIST_DIR="${DIST_DIR:-${FRONTEND_REPO}/dist}"

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

if [[ ! -f "${DIST_DIR}/index.html" ]]; then
  echo "Error: build finished but dist missing: ${DIST_DIR}/index.html"
  exit 1
fi

echo "Built: ${DIST_DIR}"
du -sh "${DIST_DIR}"

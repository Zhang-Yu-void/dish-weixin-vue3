#!/usr/bin/env bash
# Run on server after git pull: build frontend and configure Nginx.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "${SCRIPT_DIR}/deploy-frontend.sh"
bash "${SCRIPT_DIR}/../scripts/verify-e2e.sh"

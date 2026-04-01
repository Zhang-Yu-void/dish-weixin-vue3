#!/usr/bin/env bash
set -euo pipefail

# Default image coordinates (can be overridden by env).
REGISTRY="${REGISTRY:-crpi-xuhg3aumkquvtuvn.cn-beijing.personal.cr.aliyuncs.com}"
NAMESPACE="${NAMESPACE:-hardo}"
IMAGE="${IMAGE:-vue-front}"
LAST_TAG_FILE="${LAST_TAG_FILE:-.docker_last_tag}"
# 默认从北京 ACR（hardo 命名空间备份）拉基础镜像；需 Docker Hub 时：
# NODE_IMAGE=node:20-alpine NGINX_IMAGE=nginx:alpine ./publish.sh
NODE_IMAGE="${NODE_IMAGE:-crpi-xuhg3aumkquvtuvn.cn-beijing.personal.cr.aliyuncs.com/hardo/node-20:latest}"
NGINX_IMAGE="${NGINX_IMAGE:-crpi-xuhg3aumkquvtuvn.cn-beijing.personal.cr.aliyuncs.com/hardo/nginx-latest:latest}"

print_usage() {
  cat <<'EOF'
Usage:
  ./publish.sh [-t TAG]

Options:
  -t TAG    Use manual tag, e.g. -t 1.2.3

Behavior:
  - With -t: use the provided TAG.
  - Without -t: auto-increment patch version by +0.0.1.
    Initial auto tag starts from 1.0.0.

Environment overrides:
  REGISTRY, NAMESPACE, IMAGE, LAST_TAG_FILE
  NODE_IMAGE, NGINX_IMAGE  (default: Beijing ACR hardo/node-20 & hardo/nginx-latest; override for Docker Hub)
  DOCKER_PLATFORM  (default linux/amd64 so ECS can pull; set linux/arm64 on Apple Silicon if you only test locally)

Examples:
  ./publish.sh -t 1.2.3
  ./publish.sh
  REGISTRY=xxx NAMESPACE=yyy IMAGE=zzz ./publish.sh
  # Example: crpi-.../hardo/vue-front:1.2.3
  REGISTRY=crpi-xuhg3aumkquvtuvn.cn-beijing.personal.cr.aliyuncs.com NAMESPACE=hardo IMAGE=vue-front ./publish.sh -t 1.2.3
  NODE_IMAGE=node:20-alpine NGINX_IMAGE=nginx:alpine ./publish.sh
EOF
}

MANUAL_TAG=""
AUTO_TAG_MODE="1"
while getopts ":t:h" opt; do
  case "${opt}" in
    t) MANUAL_TAG="${OPTARG}" ;;
    h)
      print_usage
      exit 0
      ;;
    \?)
      echo "Unknown option: -${OPTARG}" >&2
      print_usage
      exit 1
      ;;
    :)
      echo "Option -${OPTARG} requires a value." >&2
      print_usage
      exit 1
      ;;
  esac
done

validate_semver() {
  local value="$1"
  [[ "${value}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

next_tag() {
  local last_tag="$1"
  local major minor patch
  IFS='.' read -r major minor patch <<<"${last_tag}"
  patch=$((patch + 1))
  echo "${major}.${minor}.${patch}"
}

if [[ -n "${MANUAL_TAG}" ]]; then
  AUTO_TAG_MODE="0"
  if ! validate_semver "${MANUAL_TAG}"; then
    echo "Invalid manual tag: ${MANUAL_TAG}. Expected format like 1.2.3" >&2
    exit 1
  fi
  TAG="${MANUAL_TAG}"
else
  LAST_TAG="0.9.9"
  if [[ -f "${LAST_TAG_FILE}" ]]; then
    LAST_TAG="$(tr -d '[:space:]' < "${LAST_TAG_FILE}")"
  fi

  if ! validate_semver "${LAST_TAG}"; then
    echo "Invalid last tag in ${LAST_TAG_FILE}: ${LAST_TAG}" >&2
    exit 1
  fi

  TAG="$(next_tag "${LAST_TAG}")"
fi

FULL_IMAGE="${REGISTRY}/${NAMESPACE}/${IMAGE}:${TAG}"
DOCKER_PLATFORM="${DOCKER_PLATFORM:-linux/amd64}"

print_image_refs() {
  echo ""
  echo "========== Image version (copy below) =========="
  echo "TAG=${TAG}"
  echo "FULL_IMAGE=${FULL_IMAGE}"
  echo "DOCKER_PLATFORM=${DOCKER_PLATFORM}"
  echo "NODE_IMAGE=${NODE_IMAGE}"
  echo "NGINX_IMAGE=${NGINX_IMAGE}"
  echo "docker pull ${FULL_IMAGE}"
  echo "================================================"
  echo ""
}

echo "Publishing image: ${FULL_IMAGE}"
print_image_refs

docker build \
  --platform "${DOCKER_PLATFORM}" \
  --build-arg NODE_IMAGE="${NODE_IMAGE}" \
  --build-arg NGINX_IMAGE="${NGINX_IMAGE}" \
  --build-arg APP_VERSION="${TAG}" \
  -t "${FULL_IMAGE}" .
docker push "${FULL_IMAGE}"

if [[ "${AUTO_TAG_MODE}" == "1" ]]; then
  echo "${TAG}" > "${LAST_TAG_FILE}"
fi

echo "Done. Published successfully."
print_image_refs

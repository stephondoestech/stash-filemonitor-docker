#!/bin/sh
set -eu

if [ ! -f "${FILEMONITOR_DIR}/filemonitor.py" ]; then
  echo "filemonitor.py was not found in FILEMONITOR_DIR=${FILEMONITOR_DIR}" >&2
  echo "Mount your Stash FileMonitor plugin directory to ${FILEMONITOR_DIR}." >&2
  exit 1
fi

if [ -z "${STASH_URL:-}" ]; then
  echo "STASH_URL is required. Example: STASH_URL=https://stash.lan.stephondoestech.com" >&2
  exit 1
fi

STASH_URL="${STASH_URL%/}"
case "${STASH_URL}" in
  http://*) default_port=80 ;;
  https://*) default_port=443 ;;
  *)
    echo "STASH_URL must start with http:// or https://." >&2
    exit 1
    ;;
esac

url_scheme="${STASH_URL%%://*}"
url_without_scheme="${STASH_URL#*://}"
url_authority="${url_without_scheme%%/*}"
url_path=""
case "${url_without_scheme}" in
  */*) url_path="/${url_without_scheme#*/}" ;;
esac

case "${url_authority}" in
  \[*\]:*) ;;
  \[*\]) url_authority="${url_authority}:${default_port}" ;;
  *:*) ;;
  *) url_authority="${url_authority}:${default_port}" ;;
esac
STASH_URL="${url_scheme}://${url_authority}${url_path}"

FILEMONITOR_SCRIPT="${FILEMONITOR_DIR}/filemonitor.py"

if [ "${FILEMONITOR_ALLOW_DOCKER:-false}" = "true" ]; then
  FILEMONITOR_SCRIPT="/tmp/filemonitor-docker-shim.py"
  cat > "${FILEMONITOR_SCRIPT}" <<'PY'
import pathlib
import runpy
import sys

filemonitor_dir = pathlib.Path(__import__("os").environ["FILEMONITOR_DIR"])
sys.path.insert(0, str(filemonitor_dir))

import StashPluginHelper

StashPluginHelper.StashPluginHelper.isDocker = lambda self: False
runpy.run_path(str(filemonitor_dir / "filemonitor.py"), run_name="__main__")
PY
fi

set -- python "${FILEMONITOR_SCRIPT}" --url "${STASH_URL}"

if [ -n "${STASH_API_KEY:-}" ]; then
  set -- "$@" --apikey "${STASH_API_KEY}"
fi

if [ -n "${FILEMONITOR_DOCKER_CONFIG:-}" ]; then
  set -- "$@" --docker "${FILEMONITOR_DOCKER_CONFIG}"
fi

if [ "${FILEMONITOR_TRACE:-false}" = "true" ]; then
  set -- "$@" --trace
fi

echo "Starting FileMonitor with STASH_URL=${STASH_URL}"
echo "FileMonitor plugin directory: ${FILEMONITOR_DIR}"
if [ -n "${STASH_API_KEY:-}" ]; then
  echo "Stash API key: set"
else
  echo "Stash API key: not set"
fi
if [ -n "${FILEMONITOR_DOCKER_CONFIG:-}" ]; then
  echo "Docker mapping config: ${FILEMONITOR_DOCKER_CONFIG}"
else
  echo "Docker mapping config: not set"
fi
echo "Trace mode: ${FILEMONITOR_TRACE:-false}"
echo "Docker guard shim: ${FILEMONITOR_ALLOW_DOCKER:-false}"
trace_arg=""
if [ "${FILEMONITOR_TRACE:-false}" = "true" ]; then
  trace_arg=" --trace"
fi
docker_arg=""
if [ -n "${FILEMONITOR_DOCKER_CONFIG:-}" ]; then
  docker_arg=" --docker ${FILEMONITOR_DOCKER_CONFIG}"
fi
if [ -n "${STASH_API_KEY:-}" ]; then
  echo "Executing: python ${FILEMONITOR_SCRIPT} --url ${STASH_URL} --apikey [redacted]${docker_arg}${trace_arg}"
else
  echo "Executing: python ${FILEMONITOR_SCRIPT} --url ${STASH_URL}${docker_arg}${trace_arg}"
fi

exec "$@"

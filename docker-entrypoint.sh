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

set -- python "${FILEMONITOR_DIR}/filemonitor.py" --url "${STASH_URL}"

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

exec "$@"

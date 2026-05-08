#!/bin/sh
set -eu

if [ ! -f "${FILEMONITOR_DIR}/filemonitor.py" ]; then
  echo "filemonitor.py was not found in FILEMONITOR_DIR=${FILEMONITOR_DIR}" >&2
  echo "Mount your Stash FileMonitor plugin directory to ${FILEMONITOR_DIR}." >&2
  exit 1
fi

set -- python "${FILEMONITOR_DIR}/filemonitor.py" --url "${STASH_URL}"

if [ -n "${STASH_API_KEY:-}" ]; then
  set -- "$@" --apikey "${STASH_API_KEY}"
fi

if [ -n "${FILEMONITOR_DOCKER_CONFIG:-}" ]; then
  set -- "$@" --docker "${FILEMONITOR_DOCKER_CONFIG}"
fi

exec "$@"

FROM python:3.12-slim

ARG FILEMONITOR_REQUIREMENTS_URL=https://raw.githubusercontent.com/stashapp/CommunityScripts/main/plugins/FileMonitor/requirements.txt

LABEL org.opencontainers.image.title="Stash FileMonitor Docker Wrapper" \
      org.opencontainers.image.description="Unraid-friendly Docker wrapper for the upstream Stash FileMonitor plugin. This image is not the FileMonitor plugin itself." \
      org.opencontainers.image.source="https://github.com/David-Maisonave/Axter-Stash" \
      org.opencontainers.image.licenses="MIT"

ENV PYTHONUNBUFFERED=1 \
    PIP_ROOT_USER_ACTION=ignore \
    FILEMONITOR_DIR=/filemonitor \
    STASH_URL=http://127.0.0.1:9999

WORKDIR /app

RUN python -m pip install --no-cache-dir --upgrade pip \
    && python -m pip install --no-cache-dir -r "${FILEMONITOR_REQUIREMENTS_URL}"

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

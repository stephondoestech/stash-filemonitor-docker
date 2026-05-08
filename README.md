# Stash FileMonitor Docker

Small Docker image for running the Stash CommunityScripts FileMonitor plugin without installing Python on the Unraid host.

This project is only an Unraid-friendly Docker wrapper. It does not create, own, or modify the FileMonitor plugin.

FileMonitor is created and maintained upstream in Axter-Stash:

https://github.com/David-Maisonave/Axter-Stash

The image includes Python dependencies only. It expects the FileMonitor plugin directory to be mounted at `/filemonitor`, so plugin updates managed by Stash remain outside the image.

## Build

```sh
docker build -t stash-filemonitor:local .
```

## Unraid Run Command

Adjust the media mount so the container path matches the path Stash uses in its library configuration.

```sh
docker run -d \
  --name stash-filemonitor \
  --restart unless-stopped \
  --network host \
  -e STASH_URL="http://127.0.0.1:9999" \
  -e STASH_API_KEY="YOUR_API_KEY" \
  -v /mnt/user/appdata/stash/plugins/community/filemonitor:/filemonitor:ro \
  -v /mnt/user/Media:/data:ro \
  stash-filemonitor:local
```

If Stash library paths use `/data`, mount the relevant Unraid share to `/data`. If Stash uses `/mnt/user/Media`, mount the share to `/mnt/user/Media` instead.

## Optional Docker Mapping Config

FileMonitor supports `--docker` for translating host paths to Stash container paths. If you maintain a compose file or compatible mapping file for Stash, mount it and set `FILEMONITOR_DOCKER_CONFIG`.

```sh
docker run -d \
  --name stash-filemonitor \
  --restart unless-stopped \
  --network host \
  -e STASH_URL="http://127.0.0.1:9999" \
  -e STASH_API_KEY="YOUR_API_KEY" \
  -e FILEMONITOR_DOCKER_CONFIG="/config/docker-compose.yml" \
  -v /mnt/user/appdata/stash/plugins/community/filemonitor:/filemonitor:ro \
  -v /mnt/user/appdata/stash-filemonitor:/config:ro \
  -v /mnt/user/Media:/data:ro \
  stash-filemonitor:local
```

## Logs

```sh
docker logs -f stash-filemonitor
```

## GitHub Actions

The workflow in `.github/workflows/dockerhub.yml` builds the image on pull requests and pushes to Docker Hub on `main`, version tags, and manual dispatch.

Create these repository secrets before publishing:

- `DOCKER_USERNAME`
- `DOCKER_TOKEN`

Published tags:

- `latest` from the default branch
- `sha-<commit>` for pushed commits
- semantic versions from tags like `v1.2.3`

# inkos-docker

Unofficial Docker image build for [Narcooo/inkos](https://github.com/Narcooo/inkos).

## What this repo does

- Builds InkOS from published upstream npm releases
- Publishes a ready-to-run Docker image to GHCR
- Checks upstream `Narcooo/inkos` default branch and npm `@actalk/inkos` latest release on a schedule
- Rebuilds automatically when upstream HEAD or npm latest changes
- Also supports manual rebuild with `workflow_dispatch`

## Published image

- `ghcr.io/hiccup90/inkos-docker:latest`
- `ghcr.io/hiccup90/inkos-docker:upstream-<shortsha>`

## Runtime defaults

- `HOME=/config`
- `INKOS_PROJECT_ROOT=/data`
- Exposes `4567`
- Installs published InkOS packages from npm under `/opt/inkos-runtime/node_modules`
- Uses the current npm `@actalk/inkos` `dist-tags.latest` as `INKOS_VERSION` at build time
- Writes wrapper scripts to `/usr/local/bin`
- If `/data/inkos.json` is missing, runs `/usr/local/bin/inkos-cli-entry init --lang zh` first
- Then starts `/usr/local/bin/inkos-studio-entry "${INKOS_PROJECT_ROOT:-/data}"`

## Suggested mounts

- `/config`
- `/data`

## Notes

This image tracks upstream changes on a schedule, but the container itself is built from published npm release artifacts so runtime package contents match the released distribution.

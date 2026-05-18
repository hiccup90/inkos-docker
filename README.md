# inkos-docker

Unofficial Docker image build for [Narcooo/inkos](https://github.com/Narcooo/inkos).

## What this repo does

- Builds InkOS from upstream source, not just from npm latest
- Publishes a ready-to-run Docker image to GHCR
- Checks upstream `Narcooo/inkos` default branch on a schedule
- Rebuilds automatically when upstream HEAD changes
- Also supports manual rebuild with `workflow_dispatch`

## Published image

- `ghcr.io/hiccup90/inkos-docker:latest`
- `ghcr.io/hiccup90/inkos-docker:upstream-<shortsha>`

## Runtime defaults

- `HOME=/config`
- `INKOS_PROJECT_ROOT=/data`
- Exposes `4567`
- If `/data/inkos.json` is missing, runs `inkos init --lang zh` first
- Then starts `node "$(npm root -g)/@actalk/inkos-studio/dist/api/index.js" "${INKOS_PROJECT_ROOT:-/data}"`

## Suggested mounts

- `/config`
- `/data`

## Notes

This image is intentionally built from the upstream Git repository so that upstream commits can trigger a rebuild even before npm package publication cadence catches up.

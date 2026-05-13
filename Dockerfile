FROM node:22-bookworm AS builder

ARG UPSTREAM_REF=master
WORKDIR /src

RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates \
 && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/Narcooo/inkos.git . \
 && git checkout "$UPSTREAM_REF" \
 && npm i -g pnpm@9 \
 && pnpm install --no-frozen-lockfile \
 && pnpm -r build \
 && cd packages/cli \
 && npm pack --pack-destination /tmp

FROM node:22-bookworm
ENV HOME=/config \
    INKOS_PROJECT_ROOT=/data

WORKDIR /app
COPY --from=builder /tmp/actalk-inkos-*.tgz /tmp/inkos.tgz
RUN npm install -g /tmp/inkos.tgz \
 && rm -f /tmp/inkos.tgz \
 && mkdir -p /config /data

WORKDIR /data
EXPOSE 4567
ENTRYPOINT ["/bin/bash", "-lc", "mkdir -p /config /data && exec inkos"]

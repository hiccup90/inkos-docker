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
 && cd packages/core \
 && npm pack --pack-destination /tmp \
 && cd ../studio \
 && npm pack --pack-destination /tmp \
 && cd ../cli \
 && npm pack --pack-destination /tmp

FROM node:22-bookworm
ENV PATH=/usr/local/bin:$PATH

WORKDIR /opt/inkos-runtime
COPY --from=builder /tmp/actalk-inkos-core-*.tgz /tmp/inkos-core.tgz
COPY --from=builder /tmp/actalk-inkos-studio-*.tgz /tmp/inkos-studio.tgz
COPY --from=builder /tmp/actalk-inkos-*.tgz /tmp/inkos.tgz
RUN set -eux; \
 npm init -y; \
 npm install /tmp/inkos-core.tgz /tmp/inkos-studio.tgz /tmp/inkos.tgz; \
 test -f /opt/inkos-runtime/node_modules/@actalk/inkos/dist/index.js; \
 test -f /opt/inkos-runtime/node_modules/@actalk/inkos-studio/dist/api/index.js; \
 node -e 'const fs=require("fs"); fs.writeFileSync("/usr/local/bin/inkos-cli-entry", "#!/bin/sh\nexec node /opt/inkos-runtime/node_modules/@actalk/inkos/dist/index.js \"$@\"\n"); fs.writeFileSync("/usr/local/bin/inkos-studio-entry", "#!/bin/sh\nexec node /opt/inkos-runtime/node_modules/@actalk/inkos-studio/dist/api/index.js \"$@\"\n");'; \
 chmod +x /usr/local/bin/inkos-cli-entry /usr/local/bin/inkos-studio-entry; \
 rm -f /tmp/inkos-core.tgz /tmp/inkos-studio.tgz /tmp/inkos.tgz; \
 mkdir -p /config /data

ENV HOME=/config \
    INKOS_PROJECT_ROOT=/data \
    INKOS_STUDIO_PORT=4567

WORKDIR /data
EXPOSE 4567
ENTRYPOINT ["/bin/sh", "-lc", "mkdir -p /config /data && cd \"${INKOS_PROJECT_ROOT:-/data}\" && if [ ! -f inkos.json ]; then /usr/local/bin/inkos-cli-entry init --lang zh; fi && exec /usr/local/bin/inkos-studio-entry \"${INKOS_PROJECT_ROOT:-/data}\""]

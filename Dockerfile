FROM node:22-bookworm
ARG INKOS_VERSION=1.4.1
ENV PATH=/usr/local/bin:$PATH

WORKDIR /opt/inkos-runtime
RUN set -eux; \
 npm init -y; \
 npm install "@actalk/inkos-core@${INKOS_VERSION}" "@actalk/inkos-studio@${INKOS_VERSION}" "@actalk/inkos@${INKOS_VERSION}"; \
 test -f /opt/inkos-runtime/node_modules/@actalk/inkos/dist/index.js; \
 test -f /opt/inkos-runtime/node_modules/@actalk/inkos-studio/dist/api/index.js; \
 node -e 'const fs=require("fs"); fs.writeFileSync("/usr/local/bin/inkos-cli-entry", "#!/bin/sh\nexec node /opt/inkos-runtime/node_modules/@actalk/inkos/dist/index.js \"$@\"\n"); fs.writeFileSync("/usr/local/bin/inkos-studio-entry", "#!/bin/sh\nexec node /opt/inkos-runtime/node_modules/@actalk/inkos-studio/dist/api/index.js \"$@\"\n");'; \
 chmod +x /usr/local/bin/inkos-cli-entry /usr/local/bin/inkos-studio-entry; \
 mkdir -p /config /data

ENV HOME=/config \
    INKOS_PROJECT_ROOT=/data \
    INKOS_STUDIO_PORT=4567

WORKDIR /data
EXPOSE 4567
ENTRYPOINT ["/bin/sh", "-lc", "mkdir -p /config /data && cd \"${INKOS_PROJECT_ROOT:-/data}\" && if [ ! -f inkos.json ]; then /usr/local/bin/inkos-cli-entry init --lang zh; fi && exec /usr/local/bin/inkos-studio-entry \"${INKOS_PROJECT_ROOT:-/data}\""]

FROM node:8 AS base
WORKDIR /home/node/

FROM base AS setcap
# https://github.com/noble/noble#running-on-linux
RUN apt-get update && \
    apt-get install -y \
        libcap2-bin \
        && \
    rm -rf /var/lib/apt/lists/*
RUN setcap cap_net_raw+eip /usr/local/bin/node

FROM base AS setcapped
COPY --from=setcap /usr/local/bin/node /usr/local/bin/node

FROM setcapped AS builddeps
COPY --chown=node:node package.json /home/node/
RUN apt-get update && \
    apt-get install -y \
        libbluetooth-dev \
        libbluetooth3 \
        libudev-dev \
        udev \
        && \
    rm -rf /var/lib/apt/lists/*
USER node
RUN npm install

FROM setcapped AS run
USER node
COPY --chown=node:node . /home/node/
COPY --from=builddeps --chown=node:node /home/node/node_modules /home/node/node_modules

ENTRYPOINT [ "node", "index.js" ]

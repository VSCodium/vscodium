FROM node:20.19.0

# Accept GITHUB_TOKEN as build argument
ARG GITHUB_TOKEN
ENV GITHUB_TOKEN=${GITHUB_TOKEN}

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        g++ \
        libx11-dev \
        libxkbfile-dev \
        libsecret-1-dev \
        libkrb5-dev \
        python-is-python3 \
        pkg-config \
        libssl-dev \
        jq

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"


COPY . /opt/vscodium
WORKDIR /opt/vscodium
RUN ./dev/build.sh

# RUN node build/lib/preLaunch.js && \
#     npm run electron && \
#     npm run compile

ENV VSCODE_SERVER_HOST=0.0.0.0
ENV VSCODE_SERVER_PORT=8000
WORKDIR /opt/vscodium/vscode-reh-web-linux-x64

RUN mkdir scripts ; cp ../vscode/scripts/code-server.js ./scripts/code-server.cjs
RUN rm -rf node_modules && \
    cp -r ../vscode/node_modules ./node_modules

EXPOSE 8000
CMD ["node", "scripts/code-server.cjs","--host","0.0.0.0","--port","8000","--without-connection-token"]


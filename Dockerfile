FROM node:20.19.0 as builder

# Accept GITHUB_TOKEN as build argument
ARG GITHUB_TOKEN
ENV GITHUB_TOKEN=${GITHUB_TOKEN}

# Setting this skips the run of the script that sideloads extensions
ENV SKIP_EXTENSIONS=true

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
        jq \
        unzip \
        curl

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"


COPY . /opt/vscodium
WORKDIR /opt/vscodium

RUN ./dev/build.sh && \
    mkdir ./vscode-reh-web-linux-x64/scripts && \
    cp ./vscode/scripts/code-server.js ./vscode-reh-web-linux-x64/scripts/code-server.cjs && \
    cp -r ./vscode/node_modules ./vscode-reh-web-linux-x64/


FROM node:20.19.0 as runtime
COPY --from=builder /opt/vscodium/vscode-reh-web-linux-x64 /opt/codex

ENV VSCODE_SERVER_HOST=0.0.0.0
ENV VSCODE_SERVER_PORT=8000
WORKDIR /opt/codex

EXPOSE 8000
RUN useradd -m -s /bin/bash codex && \
    chown -R codex:codex /opt/codex && \
    mkdir -p /opt/data && \
    chown codex:codex /opt/data
USER codex

RUN ./bin/codex-server --install-extension project-accelerate.codex-editor-extension --extensions-dir --extensions-dir /home/codex/.codex-server/extensions && \
    ./bin/codex-server --install-extension frontier-rnd.frontier-authentication --extensions-dir /home/codex/.codex-server/extensions

ENTRYPOINT [ "node", "scripts/code-server.cjs" ]
CMD ["--host","0.0.0.0","--port","8000","--without-connection-token"]

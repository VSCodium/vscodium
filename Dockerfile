FROM node:8

RUN mkdir -p /app
WORKDIR /app

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y --no-install-recommends install libtool automake autoconf nasm git travis sudo bash libx11-dev libxkbfile-dev libsecret-1-dev fakeroot rpm jq

RUN git clone https://github.com/Microsoft/vscode.git
RUN cd vscode && git checkout $(git describe --tags `git rev-list --tags --max-count=1`)

COPY . /app/

ENTRYPOINT ["/bin/bash", "-c"]

CMD ["/app/build.sh"]

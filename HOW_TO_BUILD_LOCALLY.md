## Tested on Debian 10

* Debian 10 has Node.js 10.15 and 10.16 is required
  * install prerequisites for Node.js
``` sh
sudo apt-get update && sudo apt-get -y install python g++ gcc make clang wget
```
* build and install Node.js and npm
```
mkdir ~/build_node
cd ~/build_node

# https://github.com/nodejs/node/releases/tag/v10.16.3
wget https://github.com/nodejs/node/archive/v10.16.3.tar.gz
tar -xf v10.16.3.tar.gz
mv -i node-10.16.3 node
cd node
./configure
make -j4
make install

cd ~
rm -r build_node
```
* install prerequisites for VSCodium
``` sh
sudo apt-get update && sudo apt-get -y install git jq imagemagick curl build-essential pkg-config libx11-dev libxkbfile-dev libsecret-1-dev fakeroot rpm

npm install yarn --global
# curl -o- -L https://yarnpkg.com/install.sh | bash
# export PATH="$HOME/.yarn/bin:$PATH"
```
* clone and build
``` sh
mkdir ~/build
cd ~/build

git clone https://github.com/VSCodium/vscodium.git

cd vscodium

export TRAVIS_OS_NAME='linux'
export BUILDARCH='x64'
export CI_WINDOWS='False'

# should do nothing since everything is already installed
. install_deps.sh

# get specific version
wget https://github.com/microsoft/vscode/archive/1.39.2.tar.gz
tar -xf 1.39.2.tar.gz
mv -i vscode-1.39.2 vscode
# or the most current
# . get_repo.sh

export SHOULD_BUILD='yes'

./build.sh
```
* get package
``` sh
find .. -iname '*.deb' -or -iname '*.rpm' -or -iname '*.appimage'
```

#!/usr/bin/env bash
# 把指定版本的 latest.json 推上 feed（rockie/vslight@versions 分支）
# 用法: dev/update-feed.sh <RELEASE_VERSION> [backdate_hours]
set -e
REL="${1:?usage: dev/update-feed.sh <version> [backdate_hours]}"
BACKDATE_H="${2:-0}"

cd "$(dirname "$0")/.."

SHA1=$( awk '{print $1}' "assets/VSLight-darwin-arm64-${REL}.zip.sha1" )
SHA256=$( awk '{print $1}' "assets/VSLight-darwin-arm64-${REL}.zip.sha256" )
COMMIT=$( grep BUILD_SOURCEVERSION dev/build.env | cut -d'"' -f2 )
TS=$( node -e "console.log(Date.now() - ${BACKDATE_H} * 3600 * 1000)" )
# productVersion: 1.135.06523 -> 1.135.6523.0 (transformVersion: strip leading zeros of patch, append .0)
PV=$( echo "${REL}" | awk -F. '{printf "%s.%s.%d.0", $1, $2, $3}' )

rm -rf /tmp/vslight-feed
git clone --single-branch --branch versions "https://github.com/rockie/vslight.git" /tmp/vslight-feed
cd /tmp/vslight-feed

mkdir -p stable/darwin/arm64
jq -n \
  --arg url "https://github.com/rockie/vslight/releases/download/${REL}/VSLight-darwin-arm64-${REL}.zip" \
  --arg name "${REL}" \
  --arg version "${COMMIT}" \
  --arg productVersion "${PV}" \
  --arg hash "${SHA1}" \
  --arg timestamp "${TS}" \
  --arg sha256hash "${SHA256}" \
  '. | .url=$url | .name=$name | .version=$version | .productVersion=$productVersion | .hash=$hash | .timestamp=$timestamp | .sha256hash=$sha256hash' \
  > stable/darwin/arm64/latest.json

git add -A
git -c user.name="vslight-bot" -c user.email="noreply@localhost" commit -q -m "latest.json -> ${REL} (darwin/arm64)"
git push origin versions

echo "=== feed now serving ==="
sleep 3
curl -fsSL "https://raw.githubusercontent.com/rockie/vslight/refs/heads/versions/stable/darwin/arm64/latest.json"

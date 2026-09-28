#!/usr/bin/env bash
# 在 rockie/vslight 建仓内创建 orphan 分支 `versions` 并播种首个 latest.json
# （当前发布 1.135.06493，darwin/arm64）
set -e
cd "$(dirname "$0")/.."

TS=$( node -e 'console.log(Date.now())' )
SHA1=$( awk '{print $1}' assets/VSLight-darwin-arm64-1.135.06493.zip.sha1 )
SHA256=$( awk '{print $1}' assets/VSLight-darwin-arm64-1.135.06493.zip.sha256 )
COMMIT=$( grep BUILD_SOURCEVERSION dev/build.env | cut -d'"' -f2 )

rm -rf /tmp/vslight-feed
git clone --single-branch --branch vslight "https://github.com/rockie/vslight.git" /tmp/vslight-feed
cd /tmp/vslight-feed
git checkout --orphan versions
git rm -rf . 2>/dev/null || true

mkdir -p stable/darwin/arm64
jq -n \
  --arg url "https://github.com/rockie/vslight/releases/download/1.135.06493/VSLight-darwin-arm64-1.135.06493.zip" \
  --arg name "1.135.06493" \
  --arg version "${COMMIT}" \
  --arg productVersion "1.135.6493.0" \
  --arg hash "${SHA1}" \
  --arg timestamp "${TS}" \
  --arg sha256hash "${SHA256}" \
  '. | .url=$url | .name=$name | .version=$version | .productVersion=$productVersion | .hash=$hash | .timestamp=$timestamp | .sha256hash=$sha256hash' \
  > stable/darwin/arm64/latest.json

git add -A
git -c user.name="vslight-bot" -c user.email="noreply@localhost" commit -q -m "seed latest.json for 1.135.06493 (darwin/arm64)"
git push -u origin versions

echo "=== verify raw URL ==="
sleep 3
curl -fsSL "https://raw.githubusercontent.com/rockie/vslight/refs/heads/versions/stable/darwin/arm64/latest.json"

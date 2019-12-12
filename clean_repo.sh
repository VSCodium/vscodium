#!/bin/sh -xe

arch="${BUILDARCH}"
case "$arch" in
x64)
    arch="amd64"
    ;;
arm)
    arch="armhf"
    ;;
esac

# delete old packages for $BUILDARCH, to stay within the free tier space limitation
curl -s "https://${PACKAGECLOUD_TOKEN}:@packagecloud.io/api/v1/repos/dimkr/vscodium/packages.json" | jq -r '.[].destroy_url' | grep -F "${arch}.deb" | while read destroy_url
do
    curl -X DELETE "https://${PACKAGECLOUD_TOKEN}:@packagecloud.io${destroy_url}"
done
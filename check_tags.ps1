echo "token: $env:GITHUB_TOKEN"
echo "tag: $env:LATEST_MS_TAG"
$GITHUB_RESPONSE = curl.exe -s -H "Authorization: token $env:GITHUB_TOKEN" "https://api.github.com/repos/vscodium/vscodium/releases/tags/$env:LATEST_MS_TAG"
echo "Github response: ${GITHUB_RESPONSE}"
$VSCODIUM_ASSETS= $GITHUB_RESPONSE | jq '.assets'
echo "VSCodium assets: ${VSCODIUM_ASSETS}"

# if we just don't have the github token, get out fast
if (!$env:GITHUB_TOKEN) {
  return
}
if (!$VSCODIUM_ASSETS) {
  echo "Release assets do not exist at all, continuing build"
  $SHOULD_BUILD = 'yes'
}

$WindowsAssets = ($VSCODIUM_ASSETS | ConvertFrom-Json) | Where-Object { $_.name.Contains('exe') }
$SYSTEM_SETUP = $WindowsAssets | Where-Object { $_.name.Contains('Setup') }
$USER_SETUP = $WindowsAssets | Where-Object { $_.name.Contains('User') }
if (!$SYSTEM_SETUP) {
  echo "Building on Windows because we have no system-setup.exe";
  $SHOULD_BUILD = 'yes'
}
elseif (!$USER_SETUP) {
  echo "Building on Windows because we have no user-setup.exe";
  $SHOULD_BUILD = 'yes'
}
else {
  echo "Already have all the Windows builds"
}

Write-Host "##vso[task.setvariable variable=SHOULD_BUILD]$SHOULD_BUILD"
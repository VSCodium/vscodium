echo "tag: $env:LATEST_MS_TAG"
$REPO_URI = [uri]$env:BUILD_REPOSITORY_URI
$USER_REPO = $REPO_URI."LocalPath"
echo $USER_REPO
$GITHUB_RESPONSE = curl.exe -s -H "Authorization: token $env:MAPPED_GITHUB_TOKEN" "https://api.github.com/repos$USER_REPO/releases/tags/$env:LATEST_MS_TAG"
echo "Github response: ${GITHUB_RESPONSE}"
$VSCODIUM_ASSETS = $GITHUB_RESPONSE | jq '.assets'
echo "VSCodium assets: ${VSCODIUM_ASSETS}"

# if we just don't have the github token, get out fast
if (!$env:MAPPED_GITHUB_TOKEN -or $env:MAPPED_GITHUB_TOKEN -like "*GITHUB_TOKEN*") {
  echo "This build does not have the GH token"
  echo $env:MAPPED_GITHUB_TOKEN
  return
}

if ($VSCODIUM_ASSETS -eq "null" -or !$VSCODIUM_ASSETS) {
  echo "Release assets do not exist at all, continuing build"
  $SHOULD_BUILD = 'yes'
} else {
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
}


Write-Host "##vso[task.setvariable variable=SHOULD_BUILD]$SHOULD_BUILD"
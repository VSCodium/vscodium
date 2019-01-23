if [ "$AZURE_TOKEN" != "" ]; then
  if [[ "$SHOULD_BUILD" == "yes" ]]; then
    if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
      curl -X POST -H "Content-Type: application/json" -H "Authorization: Basic $AZURE_TOKEN" -d '{"definition":{"id":1}}' https://dev.azure.com/VSCodium/vscodium/_apis/build/builds?api-version=5.0-preview.5
    fi
  fi
fi

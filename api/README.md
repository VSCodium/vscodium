# Faking the update-API of Microsoft

There is a distinction between stable and insider for the "quality" of the version. Also there are three platforms: linux, win32 and darwin. For each version there is a subfolder. There should be a file in each of the folders called "VERSION" (uppercase).

By example of the api of MS itself (darwin/stable):
https://vscode-update.azurewebsites.net/api/update/darwin/stable/VERSION

The repo containing the version-json-files should have pages activated, see project settings. Instructions here: https://pages.github.com/

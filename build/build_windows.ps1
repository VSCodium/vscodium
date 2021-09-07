# powershell -ExecutionPolicy ByPass -File .\build\build_windows.ps1

# first so `bash` is the one installed with `git`, avoid conflict with WSL
$env:Path = "C:\Program Files\Git\bin;" + $env:Path

Remove-Item -Recurse -Force VSCode*

bash ./get_repo.sh

$Env:SHOULD_BUILD = 'yes'
$Env:CI_BUILD = 'no'
$Env:OS_NAME = 'windows'
$Env:VSCODE_ARCH = 'x64'

bash ./build.sh

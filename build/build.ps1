# powershell -ExecutionPolicy ByPass -File .\build\build.ps1

# first so `bash` is the one installed with `git`, avoid conflict with WSL
$env:Path = "C:\Program Files\Git\bin;" + $env:Path

bash ./build/build.sh

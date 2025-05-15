# How To

Create a `.env` on the root of the project with the following content:

```bash
# .env
GH_TOKEN=your_github_token
npm_config_arch=your_architecture # Options are: x64, arm64, arm, riscv64, loong64, ppc64, and s390x
VSCODE_ARCH=your_vsc_architecture # Options are: x64, arm64, armhf, riscv64, loong64, ppc64le, and s390x
#                                   note that VSC removes variables starting with VSCODE_ from the environment.
# DISABLE_QEMU=true # Uncomment this if you prefer not to use the QEMU step in postinstall.js
# DOCKER_DEFAULT_PLATFORM=linux/amd64 # Needed if building in something other than x64
# Any other environment variable you want the tasks to run with or that set the build environment to your desired output architecture
```

Done, build your devcontainer and you are ready to go.

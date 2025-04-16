export CARGO_NET_GIT_FETCH_WITH_CLI="true"
export VSCODE_CLI_APP_NAME="codex"
export VSCODE_CLI_BINARY_NAME="codex-server-insiders"
export VSCODE_CLI_DOWNLOAD_URL="https://github.com/BiblioNexus-Foundation/codex-insiders/releases"
export VSCODE_CLI_QUALITY="insider"
export VSCODE_CLI_UPDATE_URL="https://raw.githubusercontent.com/Codex/versions/refs/heads/master"

cargo build --release --target aarch64-apple-darwin --bin=code

cp target/aarch64-apple-darwin/release/code "../../VSCode-darwin-arm64/Codex - Insiders.app/Contents/Resources/app/bin/codex-tunnel-insiders"

"../../VSCode-darwin-arm64/Codex - Insiders.app/Contents/Resources/app/bin/codex-insiders" serve-web

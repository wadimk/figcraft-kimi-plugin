#!/usr/bin/env bash
# Downloads the FigCraft CLI for macOS / Linux and installs it into ~/.figcraft/bin —
# outside the plugin package, because the binary exceeds the plugin single-file size
# limit and breaks plugin registration. The manifest must keep a relative command
# (absolute paths are dropped on registration), so bin/figcraft-cli is a small
# wrapper that execs the real binary.
# Usage: bash scripts/fetch-cli.sh
set -euo pipefail
cd "$(dirname "$0")/.."

INSTALL_DIR="$HOME/.figcraft/bin"
CLI_PATH="$INSTALL_DIR/figcraft-cli"
mkdir -p "$INSTALL_DIR"

TAG=$(curl -fsSL https://api.github.com/repos/storytold/figcraft/releases/latest | grep '"tag_name"' | head -1 | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')
VER="${TAG#v}"
OS="$(uname -s)"

case "$OS" in
  Darwin)
    ASSET="figcraft-cli-${VER}-macos-universal.zip"
    TMP="$(mktemp -d)"
    curl -fsSL "https://github.com/storytold/figcraft/releases/download/${TAG}/${ASSET}" -o "$TMP/cli.zip"
    unzip -o "$TMP/cli.zip" -d "$TMP" >/dev/null
    CLI=$(find "$TMP" -name 'figcraft-cli' -type f | head -1)
    cp "$CLI" "$CLI_PATH"
    rm -rf "$TMP"
    ;;
  Linux)
    ARCH="$(uname -m)"
    [ "$ARCH" = "x86_64" ] || { echo "Unsupported arch: $ARCH (edit the script for aarch64)"; exit 1; }
    ASSET="figcraft-${VER}-linux-x86_64.tar.gz"
    TMP="$(mktemp -d)"
    curl -fsSL "https://github.com/storytold/figcraft/releases/download/${TAG}/${ASSET}" -o "$TMP/pkg.tgz"
    tar -xzf "$TMP/pkg.tgz" -C "$TMP"
    CLI=$(find "$TMP" -name 'figcraft-cli' -type f | head -1)
    cp "$CLI" "$CLI_PATH"
    rm -rf "$TMP"
    ;;
  *)
    echo "Unsupported OS: $OS — on Windows use scripts/fetch-cli.ps1"
    exit 1
    ;;
esac

chmod +x "$CLI_PATH"

# Recreate bin/ with just the wrapper (also clears the big binary left by older installs).
rm -rf bin
mkdir -p bin
cat > bin/figcraft-cli <<'EOF'
#!/usr/bin/env bash
exec "$HOME/.figcraft/bin/figcraft-cli" "$@"
EOF
chmod +x bin/figcraft-cli

# The manifest command must stay relative — absolute paths are dropped on registration.
sed -i.bak 's#"command": *"[^"]*"#"command": "./bin/figcraft-cli"#' kimi.plugin.json && rm -f kimi.plugin.json.bak
echo "Done: $CLI_PATH ($TAG)"
./bin/figcraft-cli --version

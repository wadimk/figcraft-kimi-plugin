#!/usr/bin/env bash
# Downloads the FigCraft CLI for macOS / Linux into ./bin and points the plugin manifest at it.
# Usage: bash scripts/fetch-cli.sh
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p bin

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
    cp "$CLI" bin/figcraft-cli
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
    cp "$CLI" bin/figcraft-cli
    rm -rf "$TMP"
    ;;
  *)
    echo "Unsupported OS: $OS — on Windows use scripts/fetch-cli.ps1"
    exit 1
    ;;
esac

chmod +x bin/figcraft-cli
# Point the manifest at the unix binary name.
sed -i.bak 's#\./bin/figcraft-cli\.exe#./bin/figcraft-cli#' kimi.plugin.json && rm -f kimi.plugin.json.bak
echo "Done: bin/figcraft-cli ($TAG)"
./bin/figcraft-cli --version

#!/usr/bin/env bash
# Opens the FigCraft desktop app with its control channel on 127.0.0.1:7979 so the
# plugin's figcraft-live MCP server (figcraft-cli mcp --attach 7979) drives the
# visible window and you can watch the agent work. If the app is not installed,
# downloads it into ~/.figcraft/app.
# Usage: bash scripts/open-live.sh
set -euo pipefail

PORT=7979
APP_DIR="$HOME/.figcraft/app"
OS="$(uname -s)"

TAG=$(curl -fsSL https://api.github.com/repos/storytold/figcraft/releases/latest | grep '"tag_name"' | head -1 | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/')
VER="${TAG#v}"

case "$OS" in
  Darwin)
    APP=""
    for CANDIDATE in /Applications/FigCraft.app "$HOME/Applications/FigCraft.app" "$APP_DIR/FigCraft.app"; do
      if [ -d "$CANDIDATE" ]; then APP="$CANDIDATE"; break; fi
    done
    if [ -z "$APP" ]; then
      echo "FigCraft.app not found — downloading $TAG ..."
      mkdir -p "$APP_DIR"
      TMP="$(mktemp -d)"
      curl -fsSL "https://github.com/storytold/figcraft/releases/download/${TAG}/figcraft-${VER}-macos-universal.dmg" -o "$TMP/figcraft.dmg"
      MOUNT=$(hdiutil attach -nobrowse "$TMP/figcraft.dmg" | grep -o '/Volumes/.*$' | head -1)
      cp -R "$(find "$MOUNT" -maxdepth 1 -name '*.app' | head -1)" "$APP_DIR/FigCraft.app"
      hdiutil detach -quiet "$MOUNT"
      rm -rf "$TMP"
      APP="$APP_DIR/FigCraft.app"
    fi
    open "$APP" --args --control "$PORT"
    ;;
  Linux)
    if command -v figcraft >/dev/null 2>&1; then
      nohup figcraft --control "$PORT" >/dev/null 2>&1 &
    else
      ARCH="$(uname -m)"
      BIN="$APP_DIR/figcraft-${VER}-linux-${ARCH}.AppImage"
      if [ ! -f "$BIN" ]; then
        echo "figcraft not in PATH — downloading AppImage $TAG ..."
        mkdir -p "$APP_DIR"
        curl -fsSL "https://github.com/storytold/figcraft/releases/download/${TAG}/figcraft-${VER}-linux-${ARCH}.AppImage" -o "$BIN"
        chmod +x "$BIN"
      fi
      nohup "$BIN" --control "$PORT" >/dev/null 2>&1 &
    fi
    ;;
  *)
    echo "Unsupported OS: $OS — on Windows use scripts/open-live.ps1"
    exit 1
    ;;
esac

echo "FigCraft app started with --control $PORT — the figcraft-live MCP server can now drive its window."

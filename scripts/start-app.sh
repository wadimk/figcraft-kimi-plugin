#!/usr/bin/env bash
# Starts the FigCraft desktop app with the control channel open (required for attach mode).
# Usage: bash scripts/start-app.sh
set -euo pipefail
cd "$(dirname "$0")/.."
[ -x bin/figcraft ] || { echo "bin/figcraft not found — run scripts/fetch-cli.sh first (macOS: install the app from the DMG instead)"; exit 1; }
nohup ./bin/figcraft --control 7979 >/dev/null 2>&1 &
echo "FigCraft started with --control 7979"

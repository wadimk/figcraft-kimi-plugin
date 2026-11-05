# FigCraft for Kimi

A [Kimi](https://www.kimi.com/) plugin that connects the agent to [FigCraft](https://github.com/storytold/figcraft) — an open-source, Figma-class design tool — via its local MCP server. Design interfaces, mockups, components, styles, variables and whiteboard boards from natural language, render screenshots, and export PNG/SVG/PDF.

Плагин Kimi, подключающий агента к FigCraft (открытый редактор интерфейсов уровня Figma) через локальный MCP-сервер: дизайн макетов, компонентов, стилей и досок на естественном языке, скриншоты и экспорт в PNG/SVG/PDF.

## Contents

- `kimi.plugin.json` — plugin manifest (MCP server + skill)
- `skills/figcraft/SKILL.md` — agent usage guide (tools, conventions, workflows)
- `locales/` — localized descriptions (en-US base, zh-CN)
- `scripts/fetch-cli.ps1` / `scripts/fetch-cli.sh` — download the FigCraft CLI binary for your platform into `bin/` (binaries are not committed to git)

## Install

1. Fetch the CLI binary for your platform:

   ```powershell
   # Windows
   powershell -ExecutionPolicy Bypass -File scripts\fetch-cli.ps1
   ```

   ```bash
   # macOS / Linux
   bash scripts/fetch-cli.sh
   ```

2. Start the FigCraft desktop app with its control channel open (the plugin runs in **attach mode** — the agent drives the live window):

   ```powershell
   # Windows
   powershell -ExecutionPolicy Bypass -File scripts\start-app.ps1
   ```

   ```bash
   # Linux (on macOS install the app from the DMG and run: FigCraft.app/Contents/MacOS/figcraft --control 7979)
   bash scripts/start-app.sh
   ```

3. Register the plugin into your personal market (run from the Kimi desktop bundle):

   ```cmd
   "%APPDATA%\kimi-desktop\daimon-bundle\bin\kimi-daimon.cmd" kimi-plugin register-personal "C:\path\to\figcraft-kimi-plugin"
   ```

   ```bash
   # macOS / Linux: the same CLI ships with the desktop client
   kimi-daimon kimi-plugin register-personal /path/to/figcraft-kimi-plugin
   ```

4. Open Kimi → Plugins → **Personal** tab → click ＋ on **FigCraft**. No restart needed.

## Usage

Just ask in natural language:

- "Create a mobile login screen mockup and export it as PNG"
- "Build a kanban board with stickies for my sprint retro"
- "Make a landing page from the template and save it as a .figcraft file"

The MCP server runs **attached** (`figcraft-cli mcp --attach 7979 --timeout 300`): every change appears live in the app window. Work is kept only when saved (`save_file`) or exported. If the app is not running, MCP calls fail with a connection error — start it with the control flag and retry.

Prefer headless (no window)? Remove `"--attach", "7979", "--timeout", "300"` from `mcpServers.figcraft.args` in `kimi.plugin.json` — the server then runs an in-memory document with no app needed.

## License

The plugin packaging is MIT. The bundled/downloaded FigCraft binaries belong to [storytold/figcraft](https://github.com/storytold/figcraft), dual-licensed MIT OR Apache-2.0 — see `LICENSE-APACHE`, `LICENSE-MIT`, `NOTICE`.

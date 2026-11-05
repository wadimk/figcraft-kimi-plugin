# FigCraft for Kimi

A [Kimi](https://www.kimi.com/) plugin that connects the agent to [FigCraft](https://github.com/storytold/figcraft) — an open-source, Figma-class design tool — via its local MCP server. Design interfaces, mockups, components, styles, variables and whiteboard boards from natural language, render screenshots, and export PNG/SVG/PDF.

Плагин Kimi, подключающий агента к FigCraft (открытый редактор интерфейсов уровня Figma) через локальный MCP-сервер: дизайн макетов, компонентов, стилей и досок на естественном языке, скриншоты и экспорт в PNG/SVG/PDF.

## Contents

- `kimi.plugin.json` — plugin manifest (MCP server + skill)
- `skills/figcraft/SKILL.md` — agent usage guide (tools, conventions, workflows)
- `locales/` — localized descriptions (en-US base, zh-CN)
- `scripts/fetch-cli.ps1` / `scripts/fetch-cli.sh` — download the FigCraft CLI binary for your platform into `~/.figcraft/bin` / `%LOCALAPPDATA%\FigCraft\bin` and create a small wrapper in `bin/` that the manifest points at (the real binary exceeds the plugin single-file size limit, and the manifest command must stay relative)

## Install

1. Fetch the CLI binary for your platform (installs it into `~/.figcraft/bin` / `%LOCALAPPDATA%\FigCraft\bin` and creates a wrapper in `bin/` that the manifest's MCP command points at):

   ```powershell
   # Windows
   powershell -ExecutionPolicy Bypass -File scripts\fetch-cli.ps1
   ```

   ```bash
   # macOS / Linux
   bash scripts/fetch-cli.sh
   ```

2. Register the plugin into your personal market (run from the Kimi desktop bundle):

   ```cmd
   "%APPDATA%\kimi-desktop\daimon-bundle\bin\kimi-daimon.cmd" kimi-plugin register-personal "C:\path\to\figcraft-kimi-plugin"
   ```

   ```bash
   # macOS / Linux: the same CLI ships with the desktop client
   kimi-daimon kimi-plugin register-personal /path/to/figcraft-kimi-plugin
   ```

   If `kimi-daimon` is not on your PATH on macOS, call it from the desktop bundle
   (needs the bundled Node and the daimon share dir):

   ```bash
   "/Applications/Kimi.app/Contents/Resources/resources/daimon-bundle/bin/kimi-daimon" \
     --node "/Applications/Kimi.app/Contents/Resources/resources/runtime/tool-node/bin/node" \
     kimi-plugin register-personal \
     --share-dir "$HOME/Library/Application Support/kimi-desktop/daimon-share" \
     /path/to/figcraft-kimi-plugin
   ```

3. Open Kimi → Plugins → **Personal** tab → click ＋ on **FigCraft**. No restart needed.

## Usage

Just ask in natural language:

- "Create a mobile login screen mockup and export it as PNG"
- "Build a kanban board with stickies for my sprint retro"
- "Make a landing page from the template and save it as a .figcraft file"

The MCP server runs headless (no window; work stays in memory until you ask to save/export). The registered command is the wrapper `./bin/figcraft-cli` (`./bin/figcraft-cli.cmd` on Windows), which execs the real CLI from `~/.figcraft/bin` / `%LOCALAPPDATA%\FigCraft\bin` — both fetch scripts set this up automatically.

## License

The plugin packaging is MIT. The bundled/downloaded FigCraft binaries belong to [storytold/figcraft](https://github.com/storytold/figcraft), dual-licensed MIT OR Apache-2.0 — see `LICENSE-APACHE`, `LICENSE-MIT`, `NOTICE`.

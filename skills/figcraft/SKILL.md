---
name: figcraft
description: Design in FigCraft from natural language — create UI mockups, screens, components, styles, variables and whiteboard boards, render screenshots, and export PNG/SVG/PDF. Use when the user asks to design an interface, make a wireframe/mockup, build a design file, sketch a board (sticky notes, flowcharts, retro), or convert a design to code/assets via the local FigCraft MCP server.
---

# FigCraft

FigCraft is a local, Figma-class interface design tool. This plugin registers two MCP servers, both speaking stdio via `figcraft-cli mcp`:

- **`figcraft`** — headless: an in-process engine session with one untitled document, no window, CPU-rendered. Default for all design work.
- **`figcraft-live`** — attached: drives the visible FigCraft desktop app through its control channel, so the user watches every change live in the window.

## Backend: headless by default

- The `figcraft` server runs **headless**: work happens in an in-memory document; nothing is visible on screen and nothing is saved unless you call `save_file {path}` or `export {path}`.
- Always save results into the current workspace (absolute path) — `save_file` writes `.figcraft`, `export {ids, format, path}` writes png/jpg/svg/webp/pdf.
- Use the **`figcraft-live`** server only when the user asks to watch the app live, or the app is already open. Its tools are the same, but the calls run inside the app.

## Live (attached) mode

- The live server needs the app running with its control channel: `bash scripts/open-live.sh` (macOS/Linux), `powershell -ExecutionPolicy Bypass -File scripts\open-live.ps1` (Windows), or manually `figcraft --control 7979`. If the app is not running, live-server calls fail with "request was not sent" — start the app or fall back to the headless `figcraft` server.
- While you work, the app shows your presence like a collaborator: your avatar in the people row and an outline around the layers you last touched. This is display only.
- After a transport error, the app may have applied the request — `inspect_document` before retrying an edit. The next call reconnects automatically.
- The app answers while minimised (each request then takes ~0.1 s). Only `screenshot` with `window` needs the window visible; `screenshot` without `window` renders the document and always works.
- File access is confined by the app's own automation roots, not by the CLI.

## Core tools

| Tool | Use |
|---|---|
| `list_commands {filter?}` | Discover every command (id, label, params). Filter first, e.g. `{filter: "export"}`. |
| `run_command {command, params}` | Run any menu/panel command (align, layout.add, component.create, template.list, file.newFromTemplate, board.*, data.fill, …). |
| `batch {commands, label?}` | Several commands as ONE undo step. Steps can reference earlier results: name a step `"as": "card"` and use `{"$ref": "card"}` (or `{"$step": n}`) in later params. Prefer batch for multi-step builds. |
| `create_node {type, x, y, width, height, parent?, name?, text?, props?}` | frame, rectangle, ellipse, polygon, star, line, arrow, text, vector, section, component, slice. Returns `{id, node}`. |
| `set_properties {ids, props}` | geometry, fills/strokes (hex `"#RRGGBB[AA]"`, gradients, `"none"`), effects, corner radius, auto layout, sizing, text props. |
| `inspect_document {depth, fields?, outline?}` / `get_node {id, depth, fields?, outline?}` | Read the tree as JSON. Use `outline: true` or `fields` to keep responses small. |
| `screenshot {ids?, maxSize?}` | PNG of the page or given layers — LOOK at it to verify visual quality. |
| `export {ids, format, scale?, path?}` | Write files. Without `path`, image bytes/SVG text come back inline. |
| `open_file {path}` / `save_file {path?}` | Open `.figcraft`, `.fig` (best effort), `.sketch`, `.svg`, images; save as `.figcraft`. |
| `undo` / `redo` | Step through history. |

## Conventions you must respect

- **Coordinates**: page units (1 unit = 1 px at 100% zoom), x right, **y DOWN**. `create_node`/`set_properties` take x/y **relative to the parent frame** (page coordinates when there is no parent). `inspect_document` also reports `absoluteBounds`.
- **Auto layout**: children of an auto-layout frame are positioned by the layout — set `layout`, `gap`, `padding`, `mainAlign`, `crossAlign`, `sizingH`/`sizingV` (`fixed`/`hug`/`fill`) instead of x/y.
- **Colours** are `"#RRGGBB"` or `"#RRGGBBAA"`; `fill`/`stroke` also accept `"none"`/`null`.
- **Every mutation is one undo step**; a failing command leaves the document unchanged. Programmatic calls never open dialogs.
- **Selection**: commands act on `ids` when given, else on the current selection; newly created layers become the selection.
- **Find layers** without selecting: `run_command` with `node.find` (`{root?, type?, name?, text?}`).

## Starter templates and boards

- `run_command {command: "template.list"}` lists 8 starter templates (mobile-app, landing-page, dashboard, design-system, wireframe-kit, social-posts, slides, icon-set); `file.newFromTemplate {template, name?}` builds one as a new document.
- Boards (whiteboard): `file.newBoard {name?}`, then `board.sticky`, `board.shape`, `board.connector`, `board.table`, `board.template {name: retrospective|brainstorm|weeklyPlanner|flowChart|kanban}`, `board.stamp`, etc.

## Standard workflow

1. Clarify the target (screen type, size, style); for a full screen, consider starting from a template.
2. Build with `create_node` / `run_command` / `batch` (batch related edits into one undo step).
3. **Verify before delivering**: `inspect_document {outline: true}` or `get_node` for structure/numbers, and `screenshot` to actually look at the result. Fix and re-verify if it looks wrong.
4. Deliver files: `save_file {path}` (`.figcraft`) and/or `export {format, path}` into the workspace, then show the user the saved file / inline screenshot.

## Limits

- Headless session state is per server process: long gaps between turns may start a fresh document — save early with `save_file` when the result matters.
- Keep inspection responses small (`depth`, `fields`, `outline: true`); full-depth dumps of large documents waste context.
- Font downloads (`font.download`) only work in the desktop app with user consent; headless uses built-in + system fonts.
- Full command reference: https://github.com/storytold/figcraft/blob/main/docs/mcp.md

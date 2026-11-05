---
name: figcraft
description: Design in FigCraft from natural language — create UI mockups, screens, components, styles, variables and whiteboard boards, render screenshots, and export PNG/SVG/PDF. Use when the user asks to design an interface, make a wireframe/mockup, build a design file, sketch a board (sticky notes, flowcharts, retro), or convert a design to code/assets via the local FigCraft MCP server.
---

# FigCraft

FigCraft is a local, Figma-class interface design tool. This plugin connects to its **headless MCP server** (`figcraft-cli mcp`, stdio): an in-process engine session with one untitled document, no window, CPU-rendered. All tools are exposed by the MCP server named `figcraft`.

## Backend: headless by default

- The registered server runs **headless**: work happens in an in-memory document; nothing is visible on screen and nothing is saved unless you call `save_file {path}` or `export {path}`.
- Always save results into the current workspace (absolute path) — `save_file` writes `.figcraft`, `export {ids, format, path}` writes png/jpg/svg/webp/pdf.
- **Attached mode** (driving the visible FigCraft desktop app via `figcraft --control 7979` + `mcp --attach 7979`) is NOT configured in this plugin; it requires editing the plugin's MCP config. Only do this if the user explicitly asks to watch the app live.

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

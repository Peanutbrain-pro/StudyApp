# TipTap Web Editor Source

This directory contains the full JavaScript/CSS source code for the embedded TipTap editor used by the Flutter app.

## Development & Building

1. Install dependencies:
   \ash
   npm install
   \\n
2. Build the standalone bundle into ssets/tiptap_editor/index.html:
   \ash
   npm run build
   \\n   or
   \ash
   node build.mjs
   \\n
## Structure

- src/editor.js: TipTap editor setup and Flutter WebView JS bridge
- src/style.css: Notion-style typography, task lists, and theme styling
- src/slash-command.js: Notion-style / slash commands menu
- src/source-pill.js: Google AI Mode source citations pill node extension
- src/source-modal.js: Interactive modal dialog for inserting source citations
- src/table-ui.js: Interactive right-click context menu and table manipulation
- src/custom-image.js: Custom image embed extension with click events

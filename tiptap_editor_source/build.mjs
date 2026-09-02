import * as esbuild from 'esbuild';
import fs from 'fs';
import path from 'path';

async function build() {
  console.log('Building TipTap bundle...');

  const jsResult = await esbuild.build({
    entryPoints: ['src/editor.js'],
    bundle: true,
    write: false,
    format: 'iife',
    platform: 'browser',
    target: ['es2020'],
    minify: true,
    define: {
      'process.env.NODE_ENV': '"production"',
    },
  });

  const bundledJs = jsResult.outputFiles[0].text;
  const css = fs.readFileSync('src/style.css', 'utf8');

  const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
  <title>TipTap Editor</title>
  <style>
${css}
  </style>
</head>
<body>
  <div id="editor-container"></div>
  <script>
${bundledJs}
  </script>
</body>
</html>`;

  const outputDir = path.resolve('../assets/tiptap_editor');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  const outputPath = path.join(outputDir, 'index.html');
  fs.writeFileSync(outputPath, html, 'utf8');
  console.log(`Successfully generated TipTap editor bundle at: ${outputPath}`);
  console.log(`Bundle size: ${(Buffer.byteLength(html, 'utf8') / 1024).toFixed(2)} KB`);
}

build().catch(err => {
  console.error(err);
  process.exit(1);
});

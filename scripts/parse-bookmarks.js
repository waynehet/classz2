import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const bookmarksPath = path.join(__dirname, '../src/data/bookmarks.json');
const outputPath = path.join(__dirname, '../src/content/bookmarks/links.md');

const bookmarks = JSON.parse(fs.readFileSync(bookmarksPath, 'utf-8'));

function escapeHtml(text) {
  if (!text) return '';
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function generateHtml(node, depth = 0) {
  let html = '';
  
  if (node.type === 'folder' && node.children && node.children.length > 0) {
    if (depth > 0) {
      const summaryClass = depth === 1 ? 'font-bold text-lg' : 'font-medium';
      html += `<details class="mb-2"><summary class="${summaryClass} cursor-pointer list-none">${escapeHtml(node.name)}</summary><ul class="ml-4 mt-1">\n`;
    }
    
    for (const child of node.children) {
      if (child.type === 'folder') {
        html += generateHtml(child, depth + 1);
      } else if (child.type === 'url' && child.url) {
        html += `<li><a href="${escapeHtml(child.url)}" class="text-blue-400 hover:underline" target="_blank" rel="noopener">${escapeHtml(child.name || 'Untitled')}</a></li>\n`;
      }
    }
    
    if (depth > 0) {
      html += `</ul></details>\n`;
    }
  } else if (node.type === 'url' && node.url) {
    html += `<li><a href="${escapeHtml(node.url)}" class="text-blue-400 hover:underline" target="_blank" rel="noopener">${escapeHtml(node.name || 'Untitled')}</a></li>\n`;
  }
  
  return html;
}

let html = `<!-- Bookmarks extracted: ${bookmarks.extracted} -->
<style>
details > summary { list-style: none; cursor: pointer; }
details > summary::-webkit-details-marker { display: none; }
details > summary::before { content: '📁'; margin-right: 6px; }
details[open] > summary::before { content: '📂'; }
</style>
\n\n`;

if (bookmarks.root && bookmarks.root.children) {
  for (const child of bookmarks.root.children) {
    if (child.type === 'folder') {
      html += generateHtml(child, 1);
    } else if (child.type === 'url' && child.url) {
      html += `<details class="mb-2"><summary class="font-bold text-lg cursor-pointer list-none">Other</summary><ul class="ml-4 mt-1">\n`;
      html += `<li><a href="${escapeHtml(child.url)}" class="text-blue-400 hover:underline" target="_blank" rel="noopener">${escapeHtml(child.name || 'Untitled')}</a></li>\n`;
      html += `</ul></details>\n`;
    }
  }
}

const outputDir = path.dirname(outputPath);
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

fs.writeFileSync(outputPath, html, 'utf-8');
console.log('SUCCESS: Generated bookmarks at', outputPath);
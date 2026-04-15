import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const bookmarksPath = path.join(__dirname, '../data/bookmarks.json');
const outputPath = path.join(__dirname, '../content/bookmarks/links.md');

const bookmarks = JSON.parse(fs.readFileSync(bookmarksPath, 'utf-8'));

function formatCategoryName(name) {
  if (!name) return 'Uncategorized';
  return name;
}

function generateMarkdown(node, depth = 0) {
  let md = '';
  
  if (node.type === 'folder' && node.children && node.children.length > 0) {
    if (depth > 0) {
      const headerLevel = depth === 1 ? '##' : '###';
      md += `\n${headerLevel} ${formatCategoryName(node.name)}\n`;
    }
    
    for (const child of node.children) {
      if (child.type === 'folder') {
        md += generateMarkdown(child, depth + 1);
      } else if (child.type === 'url' && child.url) {
        const title = child.name || 'Untitled';
        md += `- [${title}](${child.url})\n`;
      }
    }
  } else if (node.type === 'url' && node.url) {
    const title = node.name || 'Untitled';
    md += `- [${title}](${node.url})\n`;
  }
  
  return md;
}

let markdown = `# Links\n\n`;
markdown += `Extracted: ${bookmarks.extracted}\n\n`;

if (bookmarks.root && bookmarks.root.children) {
  for (const child of bookmarks.root.children) {
    if (child.type === 'folder') {
      markdown += generateMarkdown(child, 1);
    } else if (child.type === 'url' && child.url) {
      markdown += `\n## Other\n`;
      markdown += `- [${child.name || 'Untitled'}](${child.url})\n`;
    }
  }
}

const outputDir = path.dirname(outputPath);
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

fs.writeFileSync(outputPath, markdown, 'utf-8');
console.log('SUCCESS: Generated bookmarks at', outputPath);

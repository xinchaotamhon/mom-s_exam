const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');

const root = path.resolve(__dirname, '..', 'site');
const port = Number(process.env.PREVIEW_PORT || 8788);
const mime = {
  '.css': 'text/css; charset=utf-8',
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.webmanifest': 'application/manifest+json; charset=utf-8'
};

http.createServer((request, response) => {
  const requestPath = decodeURIComponent(new URL(request.url, `http://${request.headers.host}`).pathname);
  const relative = requestPath === '/' ? 'index.html' : requestPath.replace(/^\/+/, '');
  let resolved = path.resolve(root, relative);
  if (!resolved.startsWith(root + path.sep)) {
    response.writeHead(403).end('Forbidden');
    return;
  }
  if (!fs.existsSync(resolved) || fs.statSync(resolved).isDirectory()) resolved = path.join(root, 'index.html');
  response.setHeader('Content-Type', mime[path.extname(resolved)] || 'application/octet-stream');
  response.setHeader('Cache-Control', 'no-store');
  fs.createReadStream(resolved)
    .on('error', () => response.writeHead(500).end('Server error'))
    .pipe(response);
}).listen(port, '127.0.0.1', () => {
  console.log(`Preview ready at http://127.0.0.1:${port}`);
});

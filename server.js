'use strict';
const http = require('http');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const ROOT = __dirname;
const PORT = process.env.PORT || 3000;
const DATA = path.join(ROOT, 'data.json');

// 可选 Token 鉴权：设置环境变量 TASK_TOKEN 后，所有 /api/* 必须带 token 才放行
const REQUIRE_TOKEN = !!process.env.TASK_TOKEN;
function tokenOk(req) {
  if (!REQUIRE_TOKEN) return true;
  let urlTok = '';
  try { urlTok = new URL(req.url, 'http://localhost').searchParams.get('token') || ''; } catch (e) {}
  const hdrTok = req.headers['x-task-token'] || '';
  const got = urlTok || hdrTok || '';
  const exp = process.env.TASK_TOKEN;
  if (got.length !== exp.length) return false;
  try { return crypto.timingSafeEqual(Buffer.from(got), Buffer.from(exp)); } catch (e) { return false; }
}

function loadData() {
  try { return JSON.parse(fs.readFileSync(DATA, 'utf8')); }
  catch (e) { return { tasks: [], logs: [], deleted: [] }; }
}
function saveData(d) { fs.writeFileSync(DATA, JSON.stringify(d, null, 2)); }

// 按 updatedAt 做「后写覆盖」的逐实体合并（轻量、适合个人多端）
function mergeList(a, b) {
  const m = {};
  (a || []).forEach((x) => (m[x.id] = x));
  (b || []).forEach((x) => { const cur = m[x.id]; m[x.id] = cur && (cur.updatedAt || 0) > (x.updatedAt || 0) ? cur : x; });
  return Object.values(m);
}
function mergeLogs(a, b) {
  const m = {};
  (a || []).forEach((x) => (m[x.id] = x));
  (b || []).forEach((x) => (m[x.id] = x));
  return Object.values(m);
}
function mergeData(existing, incoming) {
  return {
    tasks: mergeList(existing.tasks, incoming.tasks),
    logs: mergeLogs(existing.logs, incoming.logs),
    deleted: mergeList(existing.deleted, incoming.deleted),
  };
}

const MIME = { '.html': 'text/html; charset=utf-8', '.css': 'text/css; charset=utf-8', '.js': 'application/javascript; charset=utf-8', '.json': 'application/json; charset=utf-8' };

function send(res, code, body, type) {
  res.writeHead(code, { 'Content-Type': type || 'application/json; charset=utf-8', 'Cache-Control': 'no-store' });
  res.end(typeof body === 'string' || Buffer.isBuffer(body) ? body : JSON.stringify(body));
}

const server = http.createServer((req, res) => {
  const url = req.url.split('?')[0];
  if (url === '/api/ping') {
    if (!tokenOk(req)) return send(res, 401, { error: 'unauthorized' });
    return send(res, 200, 'ok');
  }
  if (url === '/api/state') {
    if (!tokenOk(req)) return send(res, 401, { error: 'unauthorized' });
    if (req.method === 'GET') return send(res, 200, loadData());
    if (req.method === 'POST') {
      let buf = '';
      req.on('data', (c) => (buf += c));
      req.on('end', () => {
        try {
          const incoming = JSON.parse(buf || '{}');
          const merged = mergeData(loadData(), incoming);
          saveData(merged);
          send(res, 200, merged);
        } catch (e) { send(res, 400, { error: 'bad json' }); }
      });
      return;
    }
    return send(res, 405, { error: 'method' });
  }
  // 静态托管
  let file = url === '/' ? '/index.html' : url;
  const fp = path.join(ROOT, path.normalize(file));
  if (!fp.startsWith(ROOT)) return send(res, 403, 'forbidden', 'text/plain; charset=utf-8');
  fs.readFile(fp, (err, data) => {
    if (err) return send(res, 404, 'not found', 'text/plain; charset=utf-8');
    send(res, 200, data, MIME[path.extname(fp)] || 'application/octet-stream');
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log('四象限同步服务已启动:');
  console.log('  本机: http://127.0.0.1:' + PORT);
  console.log('  外部: http://<你的服务器IP>:' + PORT + (REQUIRE_TOKEN ? '  (已启用 Token 鉴权)' : '  (未启用 Token，仅限内网/测试)'));
});

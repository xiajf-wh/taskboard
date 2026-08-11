// 将 styles.css 与 app.js 内联进 index.html，产出可双击打开的单文件 HTML（file:// 直接可用）
const fs = require('fs');
const html = fs.readFileSync('index.html', 'utf8');
const css = fs.readFileSync('styles.css', 'utf8');
const js = fs.readFileSync('app.js', 'utf8');
const out = html
  .replace('<link rel="stylesheet" href="styles.css" />', '<style>\n' + css + '\n</style>')
  .replace('<script src="app.js"></script>', '<script>\n' + js + '\n</script>');
const name = '四象限任务管理-单机版.html';
fs.writeFileSync(name, out);
console.log('已生成单文件:', name, '(' + out.length + ' 字节)');

#!/usr/bin/env bash
# 四象限任务管理 · 云服务器一键启动脚本
# 用法：把本目录（server.js / app.js / index.html / styles.css / ecosystem.config.js）传到服务器后，
#       运行：  bash setup.sh
set -e
cd "$(dirname "$0")"

echo "== 1/4 检查 Node.js =="
if ! command -v node >/dev/null 2>&1; then
  echo "未检测到 Node.js，请先安装 Node 18+："
  echo "  Ubuntu: curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt-get install -y nodejs"
  exit 1
fi
echo "Node 版本: $(node -v)"

echo "== 2/4 安装 pm2（进程保活 / 崩溃自启）=="
if ! command -v pm2 >/dev/null 2>&1; then
  sudo npm install -g pm2
fi

echo "== 3/4 启动服务 =="
pm2 delete taskboard 2>/dev/null || true
pm2 start ecosystem.config.js
pm2 save

echo ""
echo "== 4/4 收尾提醒 =="
echo "① 开机自启（重启服务器后自动运行），执行一次："
echo "     sudo pm2 startup"
echo "     pm2 save"
echo ""
echo "② 放行端口（外部才能访问）："
echo "     sudo ufw allow 3000"
echo "     并在云控制台『安全组』里放行 入方向 3000 端口"
echo ""
echo "③ 访问地址： http://<你的服务器IP>:3000"
echo "   若 ecosystem.config.js 里设置了 TASK_TOKEN，首次打开请带参数："
echo "     http://<你的服务器IP>:3000/?token=你的密钥"
echo "完成！"

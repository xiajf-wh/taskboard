#!/usr/bin/env bash
# ============================================================
# 本地侧：一键打包 + 提交 + 推送到 GitHub
# 用法（在 Git Bash 里运行）：
#   ./deploy.sh "本次更新说明"
# 前提：
#   1) 已 git remote add origin <你的GitHub仓库地址>
#   2) 已 git push -u origin master 过一次（或首次会提示）
# ============================================================
set -u

MSG="${1:-update $(date +%Y-%m-%d_%H%M)}"

# 找 node：优先 PATH 里的 node，找不到则回退到 WorkBuddy 托管 node
NODE_BIN="node"
if ! command -v node >/dev/null 2>&1; then
  WB="/c/Users/admin/.workbuddy/binaries/node/versions/22.22.2/node.exe"
  [ -f "$WB" ] && NODE_BIN="$WB"
fi

echo "[1/3] 重新打包单文件 HTML ..."
if [ -f build-standalone.js ]; then
  if "$NODE_BIN" build-standalone.js 2>/dev/null; then
    echo "      打包完成"
  else
    echo "      [警告] node 不可用，跳过单文件打包（如需请先安装 Node.js）"
  fi
else
  echo "      [跳过] 无 build-standalone.js"
fi

echo "[2/3] 提交到 git ..."
git add -A
if git diff --cached --quiet; then
  echo "      无变更，跳过提交"
else
  git commit -m "$MSG"
fi

echo "[3/3] 推送到远程 ..."
git push

echo ""
echo "[done] 已推送到 GitHub。"
echo "       服务器若配了宝塔计划任务会自动拉取；否则远程桌面跑一次 update.bat 即可。"

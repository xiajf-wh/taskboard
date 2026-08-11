@echo off
REM 本地侧一键打包 + 提交 + 推送（Windows 资源管理器里双击运行）
REM 前提：已 git remote add origin <你的GitHub仓库地址> 且首次 push 过
cd /d %~dp0

echo [1/3] 重新打包单文件 HTML ...
node build-standalone.js 2>nul || echo [warn] 未检测到 node，跳过单文件打包

echo [2/3] 提交到 git ...
git add -A
git commit -m "update %date% %time%" 2>nul || echo [info] 无变更，跳过提交

echo [3/3] 推送到远程 ...
git push

echo [done] 已推送。服务器配了宝塔计划任务会自动拉取，或手动跑 update.bat。
pause

@echo off
REM 服务器侧一键更新：放在部署目录（如 C:\BtSoft\panel\plugin\nodejs\taskboard）下运行
REM 前提：该目录是 git 仓库（首次需 git clone 一次）
cd /d %~dp0
git pull
npx pm2 reload taskboard 2>nul || npx pm2 restart taskboard
echo [done] 已拉取最新代码并热重载 taskboard

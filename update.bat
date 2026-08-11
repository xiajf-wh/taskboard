@echo off
REM 服务器侧一键更新：放在部署目录（如 C:\BtSoft\panel\plugin\nodejs\taskboard）下运行
REM 前提：该目录是 git 仓库（首次需 git clone 一次，见说明）
cd /d %~dp0

REM 兼容计划任务环境：优先 PATH 里的 git，否则用常见安装路径
set "GIT=git"
where git >nul 2>&1 || set "GIT=C:\Program Files\Git\bin\git.exe"
if not exist "%GIT%" set "GIT=C:\Program Files (x86)\Git\bin\git.exe"

echo [1/2] 拉取最新代码 ...
"%GIT%" pull

echo [2/2] 热重载 pm2 进程 ...
npx pm2 reload taskboard 2>nul || npx pm2 restart taskboard

echo [done] 已拉取最新代码并热重载 taskboard

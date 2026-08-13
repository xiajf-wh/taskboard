@echo off
REM 服务器侧一键更新：放在部署目录（如 C:\BtSoft\panel\plugin\nodejs\taskboard）下运行
REM 前提：该目录是 git 仓库（首次需 git clone 一次，见说明）
cd /d %~dp0

REM --- git 路径（计划任务环境可能没 PATH） ---
set "GIT=git"
where git >nul 2>&1 || set "GIT=C:\Program Files\Git\bin\git.exe"
if not exist "%GIT%" set "GIT=C:\Program Files (x86)\Git\bin\git.exe"

REM --- node 路径（计划任务环境可能没 PATH） ---
set "NODEDIR="
where node >nul 2>&1 || set "NODEDIR=C:\BtSoft\nodejs\v24.19.0"
if not exist "%NODEDIR%\node.exe" set "NODEDIR=C:\BtSoft\nodejs"
if not "%NODEDIR%"=="" set "PATH=%NODEDIR%;%PATH%"

REM --- pm2 全局路径（优先直接用 pm2.cmd，避免 npx 重新下载） ---
for /f "tokens=*" %%i in ('npm prefix -g 2^>nul') do set "NPMBIN=%%i"
if exist "%NPMBIN%\pm2.cmd" ( set "PM2=%NPMBIN%\pm2.cmd" ) else ( set "PM2=npx pm2" )

echo [1/2] 拉取最新代码 ...
"%GIT%" pull

echo [2/2] 热重载 pm2 进程 ...
"%PM2%" reload taskboard 2>nul || "%PM2%" restart taskboard

echo [done] 已拉取最新代码并热重载 taskboard

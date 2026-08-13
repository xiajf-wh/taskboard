@echo off
cd /d %~dp0

:: --- git ---
set "GITEXE=git"
if not exist "C:\Program Files\Git\bin\git.exe" goto :gitok
set "GITEXE=C:\Program Files\Git\bin\git.exe"
:gitok

:: --- node (BtSoft installed path) ---
set "NODEEXE=C:\BtSoft\nodejs\v24.19.0\node.exe"
if not exist "%NODEEXE%" set "NODEEXE=node"

echo [1/2] Pulling latest code ...
"%GITEXE%" pull

echo [2/2] Restarting server (port 3000) ...
:: kill any existing node process using port 3000
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3000 " ^| findstr "LISTENING"') do (
    taskkill /PID %%a /F >nul 2>&1
)
:: wait a moment for port to free
timeout /t 1 /nobreak >nul
:: start new server in background
start /b "" "%NODEEXE%" server.js >nul 2>&1

echo [done] Code pulled, server restarted on port 3000

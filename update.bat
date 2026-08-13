@echo off
cd /d %~dp0

:: git
set "GITEXE=git"
if not exist "C:\Program Files\Git\bin\git.exe" goto :gitok
set "GITEXE=C:\Program Files\Git\bin\git.exe"
:gitok

:: node
set "NODEEXE=C:\BtSoft\nodejs\v24.19.0\node.exe"
if not exist "%NODEEXE%" set "NODEEXE=node"

:: log all output to file, keep console clean
set "LOG=%~dp0update.log"
echo [%date% %time%] === update start === >> "%LOG%"
"%GITEXE%" pull >> "%LOG%" 2>&1

:: kill old process on port 3000
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":3000 " ^| findstr "LISTENING"') do (
    taskkill /PID %%a /F >> "%LOG%" 2>&1
)
timeout /t 1 /nobreak >nul
start /b "" "%NODEEXE%" server.js >> "%LOG%" 2>&1

echo [%date% %time%] === update done, server restarted === >> "%LOG%"
echo [OK] code pulled, server restarted. See update.log for details.

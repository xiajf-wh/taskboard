@echo off
REM 本地侧一键提交并推送：改完代码后双击运行
REM 前提：已 git remote add origin <你的仓库地址>
git add -A
git commit -m "update %date% %time%"
git push
echo [done] 已推送到远程，去服务器运行 update.bat 即可更新

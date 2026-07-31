@echo off
cd /d "%~dp0"
:RESTART_GATEWAY
"C:\Program Files\nodejs\node.exe" gateway.mjs
timeout /t 5 /nobreak >nul
goto RESTART_GATEWAY

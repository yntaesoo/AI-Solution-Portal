@echo off
cd /d "%~dp0"
:GATEWAY_RESTART
"C:\Program Files\nodejs\node.exe" gateway.mjs
timeout /t 5 /nobreak >nul
goto GATEWAY_RESTART

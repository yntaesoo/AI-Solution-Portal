@echo off
setlocal
cd /d "F:\Create with Claude\ChatBot\backend"

:RESTART
"F:\Create with Claude\ChatBot\backend\.venv\Scripts\python.exe" -m uvicorn main:app --host 127.0.0.1 --port 8002
timeout /t 5 /nobreak >nul
goto RESTART

@echo off
setlocal
cd /d "F:\Create with Claude\OCR\backend"

:RESTART
"F:\Create with Claude\OCR\backend\venv311\Scripts\python.exe" -m uvicorn main:app --host 127.0.0.1 --port 8001
timeout /t 5 /nobreak >nul
goto RESTART

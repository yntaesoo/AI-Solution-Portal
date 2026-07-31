@echo off
setlocal
cd /d "F:\Create with Claude\DSUGamePortal"

:RESTART
"C:\Users\yntae\AppData\Local\Programs\Python\Python311\python.exe" -m uvicorn backend.main:app --host 127.0.0.1 --port 8080
timeout /t 5 /nobreak >nul
goto RESTART

@echo off
cd /d "F:\Create with Claude\ChatBot\backend"
call ".venv\Scripts\python.exe" -m uvicorn main:app --host 127.0.0.1 --port 8002

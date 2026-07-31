@echo off
cd /d "F:\Create with Claude\OCR\backend"
call "venv311\Scripts\python.exe" -m uvicorn main:app --host 127.0.0.1 --port 8001

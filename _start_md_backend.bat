@echo off
cd /d "%~dp0..\Idea2Real\MDConversion\backend"
call "venv\Scripts\python.exe" -m uvicorn main:app --host 127.0.0.1 --port 8089

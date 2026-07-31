@echo off
cd /d "F:\create with claude\DSUGamePortal"
"C:\Users\yntae\AppData\Local\Programs\Python\Python311\python.exe" -m uvicorn backend.main:app --host 127.0.0.1 --port 8080

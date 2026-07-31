@echo off
cd /d "F:\Create with Claude\EquipmentManagement\backend"
call "..\venv\Scripts\python.exe" -c "from main import app; app.run(host='127.0.0.1', port=8000, debug=False)"

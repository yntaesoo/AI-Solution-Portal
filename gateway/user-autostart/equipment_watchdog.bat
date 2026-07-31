@echo off
setlocal
cd /d "F:\Create with Claude\EquipmentManagement\backend"

:RESTART
"F:\Create with Claude\EquipmentManagement\venv\Scripts\python.exe" -c "from main import app; app.run(host='127.0.0.1', port=8000, debug=False)"
timeout /t 5 /nobreak >nul
goto RESTART

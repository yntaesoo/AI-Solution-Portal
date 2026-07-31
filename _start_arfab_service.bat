@echo off
cd /d "F:\create with claude\Documents\ARFab"
:ARFAB_RESTART
call "C:\Program Files\nodejs\npm.cmd" run dev
timeout /t 5 /nobreak >nul
goto ARFAB_RESTART

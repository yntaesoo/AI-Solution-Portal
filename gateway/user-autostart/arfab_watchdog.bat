@echo off
set "PATH=C:\Program Files\nodejs;%PATH%"
cd /d "F:\Create with Claude\Documents\ARFab"
:RESTART_ARFAB
call "C:\Program Files\nodejs\npm.cmd" run dev
timeout /t 5 /nobreak >nul
goto RESTART_ARFAB

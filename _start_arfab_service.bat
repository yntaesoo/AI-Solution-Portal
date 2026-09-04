@echo off
cd /d "F:\create with claude\Documents\ARFab"
:ARFAB_RESTART
call "C:\Program Files\nodejs\npm.cmd" run dev > "H:\Create with Codex\ai-solution-portal\_arfab.log" 2>&1
ping 127.0.0.1 -n 6 >nul
goto ARFAB_RESTART

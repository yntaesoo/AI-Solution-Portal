@echo off
cd /d "%~dp0"
call "C:\Program Files\nodejs\npm.cmd" run dev > _portal.log 2>&1

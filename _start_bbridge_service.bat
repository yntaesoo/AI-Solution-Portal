@echo off
setlocal
cd /d "H:\Create with Anti\B-Bridge"
call "C:\Program Files\nodejs\npm.cmd" run dev > "%~dp0_bbridge.log" 2>&1

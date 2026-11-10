@echo off
chcp 65001 >nul
title Deploy Anchor Meeting Minutes to 203.241.190.58
echo ========================================================
echo  동서대 앵커사업단 회의록 작성기 긴급 점검 및 배포 (Port 8005)
echo ========================================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0quick_fix_minutes.ps1"
echo.
pause

@echo off
chcp 65001 >nul
title Emergency Fix for Anchor Meeting Minutes (Port 8005)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0quick_fix_minutes.ps1"
echo.
pause

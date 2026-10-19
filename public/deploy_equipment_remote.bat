@echo off
chcp 65001 >nul
title Deploy Equipment Booking System to 203.241.190.58
echo ========================================================
echo  동서대 IC 장비예약시스템 원격 자동 배포 (Port 8000)
echo ========================================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy_equipment_remote.ps1"
echo.
pause

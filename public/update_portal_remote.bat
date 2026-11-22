@echo off
chcp 65001 >nul
title Update AI Solution Portal and Services
echo ========================================================
echo  AI 솔루션 포털 및 유학생 창업동아리 원클릭 업데이트
echo ========================================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0update_portal_remote.ps1"
echo.
pause

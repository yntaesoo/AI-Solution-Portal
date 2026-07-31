@echo off
setlocal

netstat -ano | findstr ":5173" | findstr "LISTENING" >nul
if not errorlevel 1 goto GATEWAY_CHECK
start "ARFab Internal Server" /min cmd.exe /c call "%~dp0arfab_watchdog.bat"

:GATEWAY_CHECK
netstat -ano | findstr ":80 " | findstr "LISTENING" >nul
if not errorlevel 1 exit /b 0
start "ARFab Central Gateway" /min cmd.exe /c call "%~dp0gateway_watchdog.bat"
exit /b 0

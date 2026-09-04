@echo off
title AI Solution Portal Task Register (Admin)

:: Check for Administrator privileges using GOTO structure
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' goto gotPrivileges

echo ============================================================
echo  ERROR: Administrator privileges are required!
echo ============================================================
echo  Please right-click this file and select 'Run as Administrator'.
echo ============================================================
pause
exit /b 1

:gotPrivileges
pushd "%~dp0"

echo Registering Scheduled Tasks (Autostart in background)...

:: 1. Register AI Solution Portal Task (Runs bootstrap launcher from C Drive)
echo [1/2] Registering AI_Solution_Portal_Autostart...
schtasks /delete /tn "AI_Solution_Portal_Autostart" /f >nul 2>&1
schtasks /create /tn "AI_Solution_Portal_Autostart" /tr "C:\Users\yntae\AppData\Local\ARFabServices\bootstrap_launcher.bat" /sc onlogon /rl highest /ru "SYSTEM" /f

:: 2. Register ARFab Web Services Task (Runs from AppData Local)
echo [2/2] Registering ARFab_Web_Services_Autostart...
schtasks /delete /tn "ARFab_Web_Services_Autostart" /f >nul 2>&1
schtasks /create /tn "ARFab_Web_Services_Autostart" /tr "C:\Users\yntae\AppData\Local\ARFabServices\launch_services.bat" /sc onlogon /rl highest /ru "SYSTEM" /f

echo.
echo Task registration successfully completed!
echo The services will now run completely hidden in the background on boot.
echo.
pause
exit

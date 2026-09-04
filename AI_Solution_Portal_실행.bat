@echo off
setlocal

:: Restore hosts entries if they were wiped on reboot
copy /y "%PORTAL_DIR%hosts.txt" "C:\Windows\System32\drivers\etc\hosts" >nul

:: Set User Profile Environment Variables for Task Scheduler Compatibility
set "USERPROFILE=C:\Users\yntae"
set "APPDATA=C:\Users\yntae\AppData\Roaming"
set "LOCALAPPDATA=C:\Users\yntae\AppData\Local"
set "PATH=%PATH%;C:\Program Files\nodejs"

set "PORTAL_DIR=%~dp0"
set "DSU_DIR=F:\create with claude\DSUGamePortal"
set "DSU_RUN=F:\create with claude\DSUGamePortal\run_server.bat"
set "NPM_CMD=C:\Program Files\nodejs\npm.cmd"

title AI Solution Portal Launcher

if exist "%DSU_RUN%" goto DSU_OK
echo ERROR: DSU Game Portal launcher was not found.
echo Expected: %DSU_RUN%
pause
exit /b 1

:DSU_OK
if exist "%NPM_CMD%" goto NODE_OK
echo ERROR: Node.js was not found.
echo Install Node.js from https://nodejs.org and try again.
pause
exit /b 1

:NODE_OK
if exist "%PORTAL_DIR%node_modules" goto READY
echo Preparing AI Solution Portal for first use...
pushd "%PORTAL_DIR%"
call "%NPM_CMD%" install
if errorlevel 1 goto INSTALL_ERROR
popd
goto READY

:INSTALL_ERROR
popd
echo ERROR: Portal setup failed.
pause
exit /b 1

:READY
cscript.exe //NoLogo "%PORTAL_DIR%run_hidden.vbs" "cmd.exe /c call ""%PORTAL_DIR%test_task.bat""" > "%PORTAL_DIR%_cscript_test.log" 2>&1
timeout /t 2 /nobreak >nul

netstat -ano | findstr ":5173" | findstr "LISTENING" >nul
if not errorlevel 1 goto ARFAB_READY
echo Starting ARFab internal service...
cscript.exe //NoLogo "%PORTAL_DIR%run_hidden.vbs" "cmd.exe /c call ""%PORTAL_DIR%_start_arfab_service.bat"""
timeout /t 2 /nobreak >nul

:ARFAB_READY
echo Starting DSU Game Portal service...
cscript.exe //NoLogo "%PORTAL_DIR%run_hidden.vbs" "cmd.exe /c call ""%PORTAL_DIR%_start_dsu_service.bat"""
timeout /t 2 /nobreak >nul

netstat -ano | findstr ":8000" | findstr "LISTENING" >nul
if not errorlevel 1 goto EQUIPMENT_READY
echo Starting VFX Equipment Management service...
cscript.exe //NoLogo "%PORTAL_DIR%run_hidden.vbs" "cmd.exe /c call ""%PORTAL_DIR%_start_equipment_service.bat"""
timeout /t 2 /nobreak >nul

:EQUIPMENT_READY
netstat -ano | findstr ":8001" | findstr "LISTENING" >nul
if not errorlevel 1 goto OCR_READY
echo Starting Army OCR service...
cscript.exe //NoLogo "%PORTAL_DIR%run_hidden.vbs" "cmd.exe /c call ""%PORTAL_DIR%_start_ocr_service.bat"""
timeout /t 2 /nobreak >nul

:OCR_READY
netstat -ano | findstr ":8002" | findstr "LISTENING" >nul
if not errorlevel 1 goto CHATBOT_READY
echo Starting Live2D ChatBot service...
cscript.exe //NoLogo "%PORTAL_DIR%run_hidden.vbs" "cmd.exe /c call ""%PORTAL_DIR%_start_chatbot_service.bat"""
timeout /t 2 /nobreak >nul

:CHATBOT_READY
netstat -ano | findstr ":3001" | findstr "LISTENING" >nul
if not errorlevel 1 goto MENTOR_READY
echo Starting Startup Mentor Matching service...
cscript.exe //NoLogo "%PORTAL_DIR%run_hidden.vbs" "cmd.exe /c call ""%PORTAL_DIR%_start_mentor_service.bat"""
timeout /t 2 /nobreak >nul

:MENTOR_READY
netstat -ano | findstr ":3004" | findstr "LISTENING" >nul
if not errorlevel 1 goto STARTUP_CLUB_READY
echo Starting Startup Club Management service...
cscript.exe //NoLogo "%PORTAL_DIR%run_hidden.vbs" "cmd.exe /c call ""%PORTAL_DIR%_start_startup_club_service.bat"""
timeout /t 2 /nobreak >nul

:STARTUP_CLUB_READY
netstat -ano | findstr ":3005" | findstr "LISTENING" >nul
if not errorlevel 1 goto BBRIDGE_READY
echo Starting B-Bridge service...
cscript.exe //NoLogo "%PORTAL_DIR%run_hidden.vbs" "cmd.exe /c call ""%PORTAL_DIR%_start_bbridge_service.bat"""
timeout /t 2 /nobreak >nul

:BBRIDGE_READY
netstat -ano | findstr ":8089" | findstr "LISTENING" >nul
if not errorlevel 1 goto MD_BACKEND_READY
echo Starting MD Document Converter Backend service...
cscript.exe //NoLogo "%PORTAL_DIR%run_hidden.vbs" "cmd.exe /c call ""%PORTAL_DIR%_start_md_backend.bat"""
timeout /t 2 /nobreak >nul

:MD_BACKEND_READY
netstat -ano | findstr ":3002" | findstr "LISTENING" >nul
if not errorlevel 1 goto MD_FRONTEND_READY
echo Starting MD Document Converter Frontend service...
cscript.exe //NoLogo "%PORTAL_DIR%run_hidden.vbs" "cmd.exe /c call ""%PORTAL_DIR%_start_md_frontend.bat"""
timeout /t 2 /nobreak >nul

:MD_FRONTEND_READY
netstat -ano | findstr ":8090" | findstr "LISTENING" >nul
if not errorlevel 1 goto MD2HTML_BACKEND_READY
echo Starting MD2HTMLDOCPDF Backend service...
cscript.exe //NoLogo "%PORTAL_DIR%run_hidden.vbs" "cmd.exe /c call ""%PORTAL_DIR%_start_md2html_backend.bat"""
timeout /t 2 /nobreak >nul

:MD2HTML_BACKEND_READY
netstat -ano | findstr ":3003" | findstr "LISTENING" >nul
if not errorlevel 1 goto MD2HTML_FRONTEND_READY
echo Starting MD2HTMLDOCPDF Frontend service...
cscript.exe //NoLogo "%PORTAL_DIR%run_hidden.vbs" "cmd.exe /c call ""%PORTAL_DIR%_start_md2html_frontend.bat"""
timeout /t 2 /nobreak >nul

:MD2HTML_FRONTEND_READY
echo Starting AI Solution Portal...
cscript.exe //NoLogo "%PORTAL_DIR%run_hidden.vbs" "cmd.exe /c call ""%PORTAL_DIR%_start_portal_service.bat"""
timeout /t 2 /nobreak >nul

netstat -ano | findstr ":80 " | findstr "LISTENING" >nul
if not errorlevel 1 goto GATEWAY_READY
echo Starting ARFab central gateway...
timeout /t 4 /nobreak >nul
cscript.exe //NoLogo "%PORTAL_DIR%run_hidden.vbs" "cmd.exe /c call ""%PORTAL_DIR%gateway\start_gateway.bat"""

:GATEWAY_READY
echo Opening AI Solution Portal...
timeout /t 7 /nobreak >nul
start "" "http://portal.arfab.kr"

echo Portal started successfully.
echo Select Project, then open DSU Game Portal.
timeout /t 3 /nobreak >nul
exit /b 0

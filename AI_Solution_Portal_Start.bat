@echo off
chcp 65001 >nul
setlocal

:: Get current directory (ASCII junction path compatible)
set "PORTAL_DIR=%~dp0"
cd /d "%PORTAL_DIR%"

:: If run by Scheduled Task, wait 20 seconds using ping to allow drive mounting
if "%1" == "/task" (
    echo Waiting 20 seconds for system drives to mount...
    ping 127.0.0.1 -n 21 >nul
)

:: Restore hosts entries if they were wiped on reboot
copy /y hosts.txt "C:\Windows\System32\drivers\etc\hosts" >nul 2>&1

:: Set User Profile Environment Variables for Task Scheduler Compatibility
set "USERPROFILE=C:\Users\yntae"
set "APPDATA=C:\Users\yntae\AppData\Roaming"
set "LOCALAPPDATA=C:\Users\yntae\AppData\Local"
set "PATH=%PATH%;C:\Program Files\nodejs"

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
if exist "node_modules" goto READY
echo Preparing AI Solution Portal for first use...
call "%NPM_CMD%" install
if errorlevel 1 goto INSTALL_ERROR
goto READY

:INSTALL_ERROR
echo ERROR: Portal setup failed.
pause
exit /b 1

:READY
:: 1. ARFab
netstat -ano | findstr ":5173" | findstr "LISTENING" >nul
if not errorlevel 1 goto ARFAB_READY
echo Starting ARFab internal service...
start "" /b cmd.exe /c "%PORTAL_DIR%_start_arfab_service.bat"
ping 127.0.0.1 -n 3 >nul

:ARFAB_READY
:: 2. DSU Game Portal
netstat -ano | findstr ":8080" | findstr "LISTENING" >nul
if not errorlevel 1 goto DSU_READY
echo Starting DSU Game Portal service...
start "" /b cmd.exe /c "%PORTAL_DIR%_start_dsu_service.bat"
ping 127.0.0.1 -n 3 >nul

:DSU_READY
:: 3. VFX Equipment
netstat -ano | findstr ":8000" | findstr "LISTENING" >nul
if not errorlevel 1 goto EQUIPMENT_READY
echo Starting VFX Equipment Management service...
start "" /b cmd.exe /c "%PORTAL_DIR%_start_equipment_service.bat"
ping 127.0.0.1 -n 3 >nul

:EQUIPMENT_READY
:: 4. Army OCR
netstat -ano | findstr ":8001" | findstr "LISTENING" >nul
if not errorlevel 1 goto OCR_READY
echo Starting Army OCR service...
start "" /b cmd.exe /c "%PORTAL_DIR%_start_ocr_service.bat"
ping 127.0.0.1 -n 3 >nul

:OCR_READY
:: 5. ChatBot
netstat -ano | findstr ":8002" | findstr "LISTENING" >nul
if not errorlevel 1 goto CHATBOT_READY
echo Starting Live2D ChatBot service...
start "" /b cmd.exe /c "%PORTAL_DIR%_start_chatbot_service.bat"
ping 127.0.0.1 -n 3 >nul

:CHATBOT_READY
:: 5b. ChatBot with RAG
netstat -ano | findstr ":8003" | findstr "LISTENING" >nul
if not errorlevel 1 goto CHATBOTRAG_READY
echo Starting ChatBot with RAG service...
start "" /b cmd.exe /c "%PORTAL_DIR%_start_chatbotrag_service.bat"
ping 127.0.0.1 -n 3 >nul

:CHATBOTRAG_READY
:: 6. Startup Mentor Matching
netstat -ano | findstr ":3001" | findstr "LISTENING" >nul
if not errorlevel 1 goto MENTOR_READY
echo Starting Startup Mentor Matching service...
start "" /b cmd.exe /c "%PORTAL_DIR%_start_mentor_service.bat"
ping 127.0.0.1 -n 3 >nul

:MENTOR_READY
:: 7. Startup Club
netstat -ano | findstr ":3004" | findstr "LISTENING" >nul
if not errorlevel 1 goto STARTUP_CLUB_READY
echo Starting Startup Club Management service...
start "" /b cmd.exe /c "%PORTAL_DIR%_start_startup_club_service.bat"
ping 127.0.0.1 -n 3 >nul

:STARTUP_CLUB_READY
:: 8. B-Bridge Network
netstat -ano | findstr ":3005" | findstr "LISTENING" >nul
if not errorlevel 1 goto BBRIDGE_READY
echo Starting B-Bridge Network service...
start "" /b cmd.exe /c "%PORTAL_DIR%_start_bbridge_service.bat"
ping 127.0.0.1 -n 3 >nul

:BBRIDGE_READY
:: 9. MD Converter Backend
netstat -ano | findstr ":8089" | findstr "LISTENING" >nul
if not errorlevel 1 goto MD_BACKEND_READY
echo Starting MD Document Converter Backend service...
start "" /b cmd.exe /c "%PORTAL_DIR%_start_md_backend.bat"
ping 127.0.0.1 -n 3 >nul

:MD_BACKEND_READY
:: 10. MD Converter Frontend
netstat -ano | findstr ":3002" | findstr "LISTENING" >nul
if not errorlevel 1 goto MD_FRONTEND_READY
echo Starting MD Document Converter Frontend service...
start "" /b cmd.exe /c "%PORTAL_DIR%_start_md_frontend.bat"
ping 127.0.0.1 -n 3 >nul

:MD_FRONTEND_READY
:: 11. MD2HTML Backend
netstat -ano | findstr ":8090" | findstr "LISTENING" >nul
if not errorlevel 1 goto MD2HTML_BACKEND_READY
echo Starting MD2HTMLDOCPDF Backend service...
start "" /b cmd.exe /c "%PORTAL_DIR%_start_md2html_backend.bat"
ping 127.0.0.1 -n 3 >nul

:MD2HTML_BACKEND_READY
:: 12. MD2HTML Frontend
netstat -ano | findstr ":3003" | findstr "LISTENING" >nul
if not errorlevel 1 goto MD2HTML_FRONTEND_READY
echo Starting MD2HTMLDOCPDF Frontend service...
start "" /b cmd.exe /c "%PORTAL_DIR%_start_md2html_frontend.bat"
ping 127.0.0.1 -n 3 >nul

:MD2HTML_FRONTEND_READY
:: 13. AI Solution Portal
netstat -ano | findstr ":3000" | findstr "LISTENING" >nul
if not errorlevel 1 goto PORTAL_READY
echo Starting AI Solution Portal...
start "" /b cmd.exe /c "%PORTAL_DIR%_start_portal_service.bat"
ping 127.0.0.1 -n 3 >nul

:PORTAL_READY
:: 14. Reverse Proxy Gateway
netstat -ano | findstr ":80 " | findstr "LISTENING" >nul
if not errorlevel 1 goto GATEWAY_READY
echo Starting ARFab central gateway...
ping 127.0.0.1 -n 5 >nul
start "" /b cmd.exe /c "%PORTAL_DIR%gateway\start_gateway.bat"

:GATEWAY_READY
echo All services successfully initiated.
if "%1" == "/task" (
    echo Task mode: keeping launcher active to prevent task termination...
    :TASK_LOOP
    ping 127.0.0.1 -n 3600 >nul
    goto TASK_LOOP
)
exit /b 0

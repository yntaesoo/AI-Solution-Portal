@echo off
setlocal

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
netstat -ano | findstr ":5173" | findstr "LISTENING" >nul
if not errorlevel 1 goto ARFAB_READY
echo Starting ARFab internal service...
start "ARFab Internal Server" /min cmd.exe /c call "%PORTAL_DIR%_start_arfab_service.bat"

:ARFAB_READY
echo Starting DSU Game Portal service...
start "DSU Game Portal Server" /min cmd.exe /c call "%PORTAL_DIR%_start_dsu_service.bat"

netstat -ano | findstr ":8000" | findstr "LISTENING" >nul
if not errorlevel 1 goto EQUIPMENT_READY
echo Starting VFX Equipment Management service...
start "VFX Equipment Management Server" /min cmd.exe /c call "%PORTAL_DIR%_start_equipment_service.bat"

:EQUIPMENT_READY
echo Starting AI Solution Portal...
start "AI Solution Portal Server" /min cmd.exe /c call "%PORTAL_DIR%_start_portal_service.bat"

netstat -ano | findstr ":80 " | findstr "LISTENING" >nul
if not errorlevel 1 goto GATEWAY_READY
echo Starting ARFab central gateway...
timeout /t 4 /nobreak >nul
start "ARFab Central Gateway" /min cmd.exe /c call "%PORTAL_DIR%gateway\start_gateway.bat"

:GATEWAY_READY
echo Opening AI Solution Portal...
timeout /t 7 /nobreak >nul
start "" "http://portal.arfab.kr"

echo Portal started successfully.
echo Select Project, then open DSU Game Portal.
timeout /t 3 /nobreak >nul
exit /b 0

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
echo Starting DSU Game Portal service...
start "DSU Game Portal Server" /min cmd.exe /c call "%PORTAL_DIR%_start_dsu_service.bat"

echo Starting AI Solution Portal...
start "AI Solution Portal Server" /min cmd.exe /c call "%PORTAL_DIR%_start_portal_service.bat"

echo Opening AI Solution Portal...
timeout /t 7 /nobreak >nul
start "" "http://localhost:3000"

echo Portal started successfully.
echo Select Project, then open DSU Game Portal.
timeout /t 3 /nobreak >nul
exit /b 0

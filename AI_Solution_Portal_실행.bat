@echo off
chcp 65001 >nul
setlocal

set "PORTAL_DIR=%~dp0"
set "DSU_DIR=F:\create with claude\DSUGamePortal"
set "DSU_RUN=%DSU_DIR%\run_server.bat"
set "NPM_CMD=C:\Program Files\nodejs\npm.cmd"

title AI Solution Portal Launcher

if not exist "%DSU_RUN%" (
  echo [오류] DSU Game Portal 실행 파일을 찾을 수 없습니다.
  echo 확인 경로: %DSU_RUN%
  pause
  exit /b 1
)

if not exist "%NPM_CMD%" (
  echo [오류] Node.js가 설치되어 있지 않습니다.
  echo https://nodejs.org 에서 Node.js를 설치한 뒤 다시 실행하세요.
  pause
  exit /b 1
)

if not exist "%PORTAL_DIR%node_modules" (
  echo AI Solution Portal을 처음 준비하고 있습니다...
  pushd "%PORTAL_DIR%"
  call "%NPM_CMD%" install
  if errorlevel 1 (
    echo [오류] 포털 준비에 실패했습니다.
    pause
    exit /b 1
  )
  popd
)

echo DSU Game Portal 서비스를 준비합니다...
start "DSU Game Portal Server" /min cmd.exe /k "cd /d ""%DSU_DIR%"" && call run_server.bat"

echo AI Solution Portal을 실행합니다...
start "AI Solution Portal Server" /min cmd.exe /k "cd /d ""%PORTAL_DIR%"" && ""%NPM_CMD%"" run dev"

echo 포털 화면을 여는 중입니다...
timeout /t 6 /nobreak >nul
start "" "http://localhost:3000"

echo.
echo AI Solution Portal이 실행되었습니다.
echo 포털에서 [프로젝트(사업화)] - [DSU Game Portal] - [포털 열기]를 선택하세요.
timeout /t 3 /nobreak >nul
exit /b 0

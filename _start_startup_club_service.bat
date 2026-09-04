@echo off
setlocal
pushd "%~dp0.."
set "PARENT_DIR=%CD%"
popd
for /d %%i in ("%PARENT_DIR%\*") do (
    for /d %%j in ("%%~i\*") do (
        if exist "%%~j\startup-club-manager" cd /d "%%~j\startup-club-manager"
    )
)
call "C:\Program Files\nodejs\npm.cmd" run dev -- -p 3004 > "%~dp0_startup_club.log" 2>&1

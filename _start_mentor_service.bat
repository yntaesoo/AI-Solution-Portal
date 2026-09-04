@echo off
setlocal
pushd "%~dp0.."
set "PARENT_DIR=%CD%"
popd
for /d %%i in ("%PARENT_DIR%\*") do (
    if exist "%%~i\mentor-matching" cd /d "%%~i\mentor-matching"
)
call "C:\Program Files\nodejs\npm.cmd" run dev > "%~dp0_mentor.log" 2>&1

@echo off
if exist "H:\Create with Codex\창업관련\유학생창업동아리\startup-club-manager" (
    cd /d "H:\Create with Codex\창업관련\유학생창업동아리\startup-club-manager"
) else if exist "C:\ARFabServices\창업관련\유학생창업동아리\startup-club-manager" (
    cd /d "C:\ARFabServices\창업관련\유학생창업동아리\startup-club-manager"
) else (
    pushd "%~dp0.."
    set "PARENT_DIR=%CD%"
    popd
    for /d %%i in ("%PARENT_DIR%\*") do (
        for /d %%j in ("%%~i\*") do (
            if exist "%%~j\startup-club-manager" cd /d "%%~j\startup-club-manager"
        )
    )
)
call "C:\Program Files\nodejs\npm.cmd" run dev > "%~dp0_startup_club.log" 2>&1

@echo off
chcp 65001 >nul
setlocal
title AI Solution Portal Stopper

echo AI Solution Portal과 DSU Game Portal을 종료합니다...

for /f "tokens=5" %%P in ('netstat -ano ^| findstr ":3000" ^| findstr "LISTENING"') do (
  taskkill /PID %%P /T /F >nul 2>&1
)

for /f "tokens=5" %%P in ('netstat -ano ^| findstr ":8080" ^| findstr "LISTENING"') do (
  taskkill /PID %%P /T /F >nul 2>&1
)

echo 종료되었습니다.
timeout /t 2 /nobreak >nul

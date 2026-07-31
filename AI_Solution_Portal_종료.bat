@echo off
setlocal
title AI Solution Portal Stopper

echo Stopping AI Solution Portal and DSU Game Portal...

for /f "tokens=5" %%P in ('netstat -ano ^| findstr ":3000" ^| findstr "LISTENING"') do taskkill /PID %%P /T /F >nul 2>&1
for /f "tokens=5" %%P in ('netstat -ano ^| findstr ":8080" ^| findstr "LISTENING"') do taskkill /PID %%P /T /F >nul 2>&1

echo Services stopped.
timeout /t 2 /nobreak >nul
exit /b 0

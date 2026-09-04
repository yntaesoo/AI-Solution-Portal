@echo off
chcp 65001 >nul
cd /d "%~dp0..\Idea2Real\MD2HTMLDOCPDF\frontend"
call "C:\Program Files\nodejs\npm.cmd" run dev

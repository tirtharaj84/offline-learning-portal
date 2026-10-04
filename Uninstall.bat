@echo off
setlocal
cd /d "%TEMP%"
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0scripts\Uninstall-Portal-GUI.ps1"
if errorlevel 1 pause

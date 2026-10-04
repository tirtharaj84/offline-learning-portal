@echo off
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "%~dp0scripts\Install-Portal-GUI.ps1"
if errorlevel 1 pause

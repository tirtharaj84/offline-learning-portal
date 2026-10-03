@echo off
setlocal EnableExtensions
TITLE Offline Learning Portal - Uninstall
REM Run this BAT from the installed portal folder as Administrator.
if not exist "%~dp0scripts\Uninstall-Portal.ps1" (
    echo [ERROR] scripts\Uninstall-Portal.ps1 is missing beside this BAT.
    pause
    exit /b 1
)
if not exist "%~dp0installation.json" (
    echo [ERROR] Run this file from the installed portal folder, normally C:\LearningPortal.
    echo The extracted ZIP is not the installed portal.
    pause
    exit /b 1
)
echo.
echo 1. Remove service and firewall rules; keep all portal files.
echo 2. Remove service, firewall rules and ALL installed portal files.
echo 3. Cancel.
echo.
echo Back up resources before choosing option 2.
choice /C 123 /N /M "Choose [1/2/3]: "
if errorlevel 3 exit /b 0
if errorlevel 2 goto DELETE_FILES
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Uninstall-Portal.ps1"
goto RESULT
:DELETE_FILES
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Uninstall-Portal.ps1" -DeleteFiles
:RESULT
REM On complete deletion, this BAT is also removed. Read the PowerShell output
REM above for confirmation or errors; no unconditional success message is printed.
pause
exit /b

@echo off
where py >nul 2>&1
if errorlevel 1 goto USE_PYTHON
py -3 "%~dp0scripts\generate_catalog.py" --web-root "%~dp0web"
goto FINISH
:USE_PYTHON
where python >nul 2>&1
if errorlevel 1 goto MISSING
python "%~dp0scripts\generate_catalog.py" --web-root "%~dp0web"
goto FINISH
:MISSING
echo Python 3 is required to regenerate the catalogue. The existing catalogue can still be browsed.
exit /b 1
:FINISH
if errorlevel 1 (
    echo Catalogue generation failed. Read the error above.
    pause
    exit /b 1
)
echo Catalogue generation completed.
pause

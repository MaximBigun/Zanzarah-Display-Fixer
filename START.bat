@echo off
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0Zanzarah_Display_Fixer.ps1"

if errorlevel 1 (
    echo.
    echo Zanzarah Display Fixer finished with an error.
    echo Press any key to close this window...
    pause >nul
)

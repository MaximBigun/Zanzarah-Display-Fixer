@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -STA -File "%~dp0Zanzarah_Display_Fixer.ps1"

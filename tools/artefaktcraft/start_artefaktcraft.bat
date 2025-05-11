
@echo off
REM ArtefaktCraft Startskript für Windows

REM Prüfen, ob Python installiert ist
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Python ist nicht installiert oder nicht im PATH. Bitte installieren Sie Python.
    pause
    exit /b 1
)

REM ArtefaktCraft-Weboberfläche starten
python artefaktcraft.py --web

REM Alternativ für CLI-Modus:
REM python artefaktcraft.py

pause

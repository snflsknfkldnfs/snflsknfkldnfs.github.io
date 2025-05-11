
@echo off
REM ArtefaktCraft Installations-Skript für Windows

echo === ArtefaktCraft Installation für Windows ===
echo Überprüfe Python-Installation...

REM Prüfen, ob Python installiert ist
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Python ist nicht installiert oder nicht im PATH.
    echo Bitte installieren Sie Python von python.org und aktivieren Sie "Add Python to PATH" während der Installation.
    echo Installation wird abgebrochen.
    pause
    exit /b 1
)

for /f "tokens=2" %%I in ('python --version 2^>^&1') do set PYTHON_VERSION=%%I
echo Python-Version: %PYTHON_VERSION%

REM Prüfen, ob pip installiert ist
pip --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo pip ist nicht installiert. Installiere pip...
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python get-pip.py
    del get-pip.py
)

echo Installiere Abhängigkeiten...
pip install -r requirements.txt

echo Erstelle log-Verzeichnis...
if not exist logs mkdir logs

echo Konfiguriere Repository...
python artefaktcraft.py init

echo.
echo === Installation abgeschlossen ===
echo ArtefaktCraft wurde erfolgreich installiert!
echo Starten Sie ArtefaktCraft mit: start_artefaktcraft.bat
echo.

pause

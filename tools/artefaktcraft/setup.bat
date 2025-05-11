@echo off
:: ArtefaktCraft Setup für Windows
:: Dieses Skript installiert ArtefaktCraft für Windows-Benutzer

setlocal enabledelayedexpansion

:: Farbige Ausgabe
set "GREEN=[92m"
set "BLUE=[94m"
set "RED=[91m"
set "YELLOW=[93m"
set "NC=[0m"

:: ArtefaktCraft Logo anzeigen
echo %BLUE%
echo     _         _       __       _    _  ____            __ _   
echo    / \   _ __^| ^|_ ___^|  ^| __  / \  ^| ^|/ ___^|_ __ __ _ / _^| ^|_ 
echo   / _ \ ^| '__^| __/ _ \ ^|/ / / _ \ ^| ^| ^|   ^| '__/ _` ^| ^|_^| __^|
echo  / ___ \^| ^|  ^| ^|^|  __/   ^< / ___ \^| ^| ^|___^| ^| ^| (_^| ^|  _^| ^|_ 
echo /_/   \_\_^|   \__\___^|_^|\\_\_/   \_\_^|\____^|_^|  \__,_^|_^|  \__^|
echo.                                                             
echo %NC%
echo Willkommen beim ArtefaktCraft-Installationsprogramm!
echo Dieses Skript richtet ArtefaktCraft für Sie ein.
echo.

:: Systempfade
set "INSTALL_DIR=%~dp0"
cd /d "%INSTALL_DIR%"

:: Systemvoraussetzungen prüfen
echo %BLUE%==^>%NC% Systemvoraussetzungen werden geprüft...

:: Git prüfen
git --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo %RED%✗%NC% Git ist nicht installiert. Bitte installieren Sie Git von https://git-scm.com/downloads
    echo.
    echo Drücken Sie eine beliebige Taste, um die Installation fortzusetzen (empfohlen: Installation abbrechen und Git installieren)
    pause >nul
) else (
    for /f "tokens=3" %%i in ('git --version') do set GIT_VERSION=%%i
    echo %GREEN%✓%NC% Git ist installiert (Version %GIT_VERSION%).
)

:: Node.js prüfen
node --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo %RED%✗%NC% Node.js ist nicht installiert. Bitte installieren Sie Node.js von https://nodejs.org/
    echo.
    echo Drücken Sie eine beliebige Taste, um die Installation fortzusetzen (empfohlen: Installation abbrechen und Node.js installieren)
    pause >nul
) else (
    for /f "tokens=1" %%i in ('node --version') do set NODE_VERSION=%%i
    echo %GREEN%✓%NC% Node.js ist installiert (Version %NODE_VERSION%).
    
    :: Versionscheck (mindestens v14.x)
    set "NODE_VERSION=!NODE_VERSION:~1!"
    for /f "tokens=1 delims=." %%i in ("!NODE_VERSION!") do set NODE_MAJOR=%%i
    if !NODE_MAJOR! lss 14 (
        echo %YELLOW%!%NC% Ihre Node.js-Version ist möglicherweise zu alt. Für optimale Leistung wird Node.js v14 oder höher empfohlen.
    )
)

:: npm prüfen
npm --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo %RED%✗%NC% npm ist nicht installiert. Es sollte mit Node.js installiert worden sein.
    echo.
    echo Drücken Sie eine beliebige Taste, um die Installation fortzusetzen (empfohlen: Installation abbrechen und Node.js neu installieren)
    pause >nul
) else (
    for /f "tokens=1" %%i in ('npm --version') do set NPM_VERSION=%%i
    echo %GREEN%✓%NC% npm ist installiert (Version %NPM_VERSION%).
)

echo.

:: Abhängigkeiten installieren
echo %BLUE%==^>%NC% Abhängigkeiten werden installiert...

call npm install --no-audit --no-fund
if %ERRORLEVEL% neq 0 (
    echo %RED%✗%NC% Fehler beim Installieren der Abhängigkeiten.
    exit /b 1
) else (
    echo %GREEN%✓%NC% Abhängigkeiten wurden erfolgreich installiert.
)

echo.

:: mcp-Server einrichten
echo %BLUE%==^>%NC% mcp-Server wird konfiguriert...

:: mcp-Server-Konfiguration prüfen
if exist "mcp-config.json" (
    echo %GREEN%✓%NC% mcp-Server-Konfiguration gefunden.
    
    :: Konfiguration an Benutzerumgebung anpassen
    set CURRENT_DIR=%INSTALL_DIR:\=\\%
    
    :: PowerShell für Dateimanipulation verwenden
    powershell -Command "(Get-Content mcp-config.json) -replace '\"repositoryRoot\": \".*\"', '\"repositoryRoot\": \"%CURRENT_DIR%\"' | Set-Content mcp-config.json"
    
    if %ERRORLEVEL% neq 0 (
        echo %YELLOW%!%NC% Konnte die mcp-Server-Konfiguration nicht automatisch anpassen. Bitte prüfen Sie die Datei mcp-config.json manuell.
    )
) else (
    echo %YELLOW%!%NC% mcp-Server-Konfigurationsdatei nicht gefunden!
    echo Eine Standard-Konfiguration wird erstellt...
    
    :: Konfigurationsdatei erstellen
    (
        echo {
        echo   "repositoryRoot": "%CURRENT_DIR%",
        echo   "resourcePaths": [
        echo     "notizen/wib",
        echo     "notizen/gpg",
        echo     "notizen/methodik",
        echo     "notizen/leitfaden"
        echo   ],
        echo   "metadataSchemas": {
        echo     "unterrichtseinheit": "./schemas/unterrichtseinheit-schema.json",
        echo     "sequenzplanung": "./schemas/sequenzplanung-schema.json",
        echo     "tafelbild": "./schemas/tafelbild-schema.json"
        echo   },
        echo   "templatePaths": [
        echo     "./templates"
        echo   ],
        echo   "server": {
        echo     "port": 3000,
        echo     "cors": true
        echo   }
        echo }
    ) > mcp-config.json
    
    echo %GREEN%✓%NC% Standard-Konfiguration erstellt.
)

:: Notwendige Verzeichnisse erstellen
echo %BLUE%==^>%NC% Verzeichnisse werden erstellt...

if not exist "data\curriculum\wib" mkdir "data\curriculum\wib"
if not exist "data\curriculum\gpg" mkdir "data\curriculum\gpg"
if not exist "logs" mkdir "logs"

echo %GREEN%✓%NC% Verzeichnisse erstellt.

echo.

:: Windows-spezifische Batch-Datei zum Starten erstellen
echo %BLUE%==^>%NC% Startdatei wird erstellt...

(
    echo @echo off
    echo :: ArtefaktCraft Starter für Windows
    echo.
    echo setlocal enabledelayedexpansion
    echo.
    echo :: Farbige Ausgabe
    echo set "BLUE=[94m"
    echo set "GREEN=[92m"
    echo set "YELLOW=[93m"
    echo set "RED=[91m"
    echo set "NC=[0m"
    echo.
    echo :: In Installationsverzeichnis wechseln
    echo cd /d "%%~dp0"
    echo.
    echo echo %%BLUE%%
    echo echo     _         _       __       _    _  ____            __ _   
    echo echo    / \   _ __^| ^|_ ___^|  ^| __  / \  ^| ^|/ ___^|_ __ __ _ / _^| ^|_ 
    echo echo   / _ \ ^| '__^| __/ _ \ ^|/ / / _ \ ^| ^| ^|   ^| '__/ _` ^| ^|_^| __^|
    echo echo  / ___ \^| ^|  ^| ^|^|  __/   ^< / ___ \^| ^| ^|___^| ^| ^| (_^| ^|  _^| ^|_ 
    echo echo /_/   \_\_^|   \__\___^|_^|\\_\_/   \_\_^|\____^|_^|  \__,_^|_^|  \__^|
    echo echo.
    echo echo %%NC%%
    echo.
    echo echo %%BLUE%%==^>%%NC%% ArtefaktCraft wird gestartet...
    echo.
    echo :: Server-Prozess-ID-Datei
    echo set "PID_FILE=.mcp-server.pid"
    echo.
    echo :: Prüfen, ob der Server bereits läuft
    echo if exist "%%PID_FILE%%" (
    echo     set /p OLD_PID=^<"%%PID_FILE%%"
    echo     wmic process where "ProcessID=%%OLD_PID%%" get CommandLine 2^>nul ^| find "node" ^>nul
    echo     if !ERRORLEVEL! equ 0 (
    echo         echo %%YELLOW%%!%%NC%% mcp-Server läuft bereits ^(PID: %%OLD_PID%%^)
    echo         echo %%YELLOW%%!%%NC%% Server wird neu gestartet...
    echo         taskkill /PID %%OLD_PID%% /F ^>nul 2^>^&1
    echo         timeout /t 1 ^>nul
    echo     ^) else (
    echo         echo %%YELLOW%%!%%NC%% Veraltete PID-Datei gefunden. Der Server wurde wahrscheinlich unsauber beendet.
    echo     ^)
    echo     del "%%PID_FILE%%"
    echo ^)
    echo.
    echo :: mcp-Server starten
    echo echo %%BLUE%%==^>%%NC%% mcp-Server wird gestartet...
    echo start /B cmd /c "node mcp-server.js 2^>^&1 ^> .mcp-server.log"
    echo.
    echo :: PID ermitteln und speichern
    echo timeout /t 1 ^>nul
    echo for /f "tokens=5" %%%%i in ^('wmic process where "CommandLine like '%%mcp-server.js%%'" get ProcessId /value'^) do ^(
    echo     set "SERVER_PID=%%%%i"
    echo     if not "!SERVER_PID!"=="" if not "!SERVER_PID!"=="ProcessId" (
    echo         echo !SERVER_PID! ^> "%%PID_FILE%%"
    echo         set /p SERVER_PID=^<"%%PID_FILE%%"
    echo         echo %%GREEN%%✓%%NC%% mcp-Server gestartet ^(PID: !SERVER_PID!^)
    echo     ^)
    echo ^)
    echo.
    echo :: Warten, bis der Server bereit ist
    echo echo %%BLUE%%==^>%%NC%% Warte auf Server-Bereitschaft...
    echo set /a "COUNTER=0"
    echo :WAIT_LOOP
    echo timeout /t 1 ^>nul
    echo findstr /c:"Server listening" .mcp-server.log ^>nul
    echo if %%ERRORLEVEL%% equ 0 (
    echo     echo %%GREEN%%✓%%NC%% mcp-Server ist bereit!
    echo     goto SERVER_READY
    echo ^)
    echo set /a "COUNTER+=1"
    echo if %%COUNTER%% lss 10 (
    echo     goto WAIT_LOOP
    echo ^) else (
    echo     echo %%YELLOW%%!%%NC%% Zeitüberschreitung beim Warten auf den Server. Versuche trotzdem fortzufahren...
    echo ^)
    echo.
    echo :SERVER_READY
    echo :: Web-GUI starten
    echo echo %%BLUE%%==^>%%NC%% Web-GUI wird gestartet...
    echo start "" "http://localhost:3000/webapp/"
    echo.
    echo echo %%GREEN%%✓%%NC%% ArtefaktCraft wurde erfolgreich gestartet!
    echo echo.
    echo echo Sie können ArtefaktCraft nun im Browser unter %%BLUE%%http://localhost:3000/webapp/%%NC%% verwenden.
    echo echo.
    echo echo %%BLUE%%==^>%%NC%% Server-Logs:
    echo echo.
    echo.
    echo :: Server-Logs anzeigen
    echo type .mcp-server.log
    echo.
    echo echo Drücken Sie STRG+C, um ArtefaktCraft zu beenden.
    echo.
    echo :: Warten auf Benutzerinteraktion
    echo pause
    echo.
    echo :: Aufräumen
    echo echo %%BLUE%%==^>%%NC%% ArtefaktCraft wird beendet...
    echo if exist "%%PID_FILE%%" (
    echo     set /p PID=^<"%%PID_FILE%%"
    echo     taskkill /PID %%PID%% /F ^>nul 2^>^&1
    echo     del "%%PID_FILE%%"
    echo ^)
    echo echo %%GREEN%%✓%%NC%% ArtefaktCraft wurde beendet!
) > start-artefaktcraft.bat

echo %GREEN%✓%NC% Startdatei erstellt.

echo.

:: Desktop-Verknüpfung erstellen
echo %BLUE%==^>%NC% Desktop-Verknüpfung wird erstellt...

:: PowerShell-Skript zur Erstellung einer .lnk-Datei
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\ArtefaktCraft.lnk'); $Shortcut.TargetPath = '%INSTALL_DIR%start-artefaktcraft.bat'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Description = 'ArtefaktCraft - Werkzeug zur standardisierten Erstellung von Unterrichtsmaterialien'; $Shortcut.Save()"

if %ERRORLEVEL% neq 0 (
    echo %YELLOW%!%NC% Konnte Desktop-Verknüpfung nicht erstellen. Sie können ArtefaktCraft manuell über die Datei start-artefaktcraft.bat starten.
) else (
    echo %GREEN%✓%NC% Desktop-Verknüpfung erstellt.
)

echo.

:: Installation abschließen
echo %GREEN%✓%NC% ArtefaktCraft wurde erfolgreich installiert!
echo.
echo Sie können ArtefaktCraft jetzt starten durch:
echo   %BLUE%start-artefaktcraft.bat%NC% (im Installationsverzeichnis)
echo   oder das Desktop-Symbol "ArtefaktCraft"
echo.
echo Nach dem Start öffnet sich ArtefaktCraft in Ihrem Browser unter:
echo   %BLUE%http://localhost:3000/webapp/%NC%
echo.
echo Für Hilfe und weitere Informationen lesen Sie die Dokumentation unter:
echo   %BLUE%docs\benutzerhandbuch.md%NC%
echo.
echo Drücken Sie eine beliebige Taste, um ArtefaktCraft jetzt zu starten...
pause >nul

:: ArtefaktCraft starten
start start-artefaktcraft.bat

endlocal
exit /b 0

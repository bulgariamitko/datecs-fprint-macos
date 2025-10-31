@echo off
setlocal enabledelayedexpansion
set "LOGFILE=%~dp0fprint_startup_%RANDOM%.log"
set "FPRINTDIR=%~dp0.."

echo ============================================ > "%LOGFILE%"
echo FPrint Startup Script - %date% %time% >> "%LOGFILE%"
echo ============================================ >> "%LOGFILE%"

echo Checking for running FPrint processes... >> "%LOGFILE%"
tasklist /FI "IMAGENAME eq FPrint.exe" 2>nul | find /i "fprint.exe" >nul
if %errorlevel% == 0 (
    echo WARNING: FPrint.exe is already running! >> "%LOGFILE%"
    echo Killing existing process... >> "%LOGFILE%"
    taskkill /F /IM "FPrint.exe" 2>nul
    timeout /t 2 /nobreak >nul
)

echo Current user: %USERNAME% >> "%LOGFILE%"
echo Script directory: %~dp0 >> "%LOGFILE%"
echo FPrint directory: "!FPRINTDIR!" >> "%LOGFILE%"

echo Checking if FPrint.exe exists... >> "%LOGFILE%"
if exist "!FPRINTDIR!\FPrint.exe" (
    echo FPrint.exe found! >> "%LOGFILE%"
) else (
    echo ERROR: FPrint.exe NOT found in "!FPRINTDIR!"! >> "%LOGFILE%"
    goto :end
)

echo Changing to FPrint directory... >> "%LOGFILE%"
pushd "!FPRINTDIR!"
if errorlevel 1 (
    echo ERROR: Cannot change to FPrint directory >> "%LOGFILE%"
    goto :end
)

echo Starting FPrint.exe... >> "%LOGFILE%"
start "" "FPrint.exe"

echo Waiting 3 seconds... >> "%LOGFILE%"
timeout /t 3 /nobreak >nul

echo Checking if FPrint started... >> "%LOGFILE%"
tasklist /FI "IMAGENAME eq FPrint.exe" 2>nul | find /i "fprint.exe" >nul
if %errorlevel% == 0 (
    echo SUCCESS: FPrint.exe is now running! >> "%LOGFILE%"
) else (
    echo ERROR: FPrint.exe failed to start! >> "%LOGFILE%"
)

popd

:end
echo Script completed >> "%LOGFILE%"
echo.
echo Log contents:
type "%LOGFILE%"
endlocal
@echo off
setlocal enabledelayedexpansion

:: Play a vectorial evolving drone in real-time
:: Usage: play_drone.bat [duration]
:: The 8 drone sources have fixed settings; vec8 crossfades between them

set TEMPLATE=evolving_drone_template.csd
set TMPFILE=%TEMP%\drone_realtime_%RANDOM%.csd

:: Duration in seconds (default: 120 for longer evolving soundscape)
if "%~1"=="" (
    set DURATION=600
) else (
    set DURATION=%~1
)

:: Generate random seed for the main mixer
set /a SEED=%RANDOM% * 32768 + %RANDOM%

echo ============================================
echo   Vectorial Evolving Drone - Real-time
echo ============================================
echo Duration: %DURATION% seconds
echo Seed:     %SEED%
echo.
echo 8 drone sources with vec8 crossfading
echo 3 LFOs control X/Y/Z morphing axes
echo ============================================
echo Press Ctrl+C to stop playback
echo.

:: Create temporary CSD file with substituted values
powershell -Command "(Get-Content '%TEMPLATE%') -replace '__DURATION__', '%DURATION%' -replace '__SEED__', '%SEED%' | Set-Content '%TMPFILE%'"

:: Play in real-time using default audio output
csound -odac "%TMPFILE%"

:: Cleanup
del "%TMPFILE%" 2>nul

echo.
echo Playback finished.

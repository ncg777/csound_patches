@echo off
setlocal enabledelayedexpansion

:: Play a vectorial evolving drone in real-time
:: Usage: play_drone.bat [duration]
:: The 8 drone sources have fixed settings; vec8 crossfades between them

set TEMPLATE=evolving_drone_template.csd
set TMPFILE=%TEMP%\drone_realtime_%RANDOM%.csd

:: Duration in seconds
if "%~1"=="" (
    set DURATION=600
) else (
    set DURATION=%~1
)

:: Generate random seed for the main mixer
set /a SEED=%RANDOM% * 32768 + %RANDOM%

echo ============================================
echo   Meta-Vectorial Evolving Drone - Real-time
echo ============================================
echo Duration: %DURATION% seconds
echo Seed:     %SEED%
echo.
echo 8 drone groups x 4 voices = 32 total voices
echo Each group: random root note + random chord
echo Ultra-slow chaotic vec8 morphing between groups
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

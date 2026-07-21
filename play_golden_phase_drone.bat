@echo off
setlocal enabledelayedexpansion

:: Play a Golden Ratio phase-inversion drone in real-time
:: Usage: play_golden_phase_drone.bat [duration]

set TEMPLATE=golden_phase_drone.csd
set TMPFILE=%TEMP%\golden_phase_drone_realtime_%RANDOM%.csd

:: Duration in seconds
if "%~1"=="" (
    set DURATION=600
) else (
    set DURATION=%~1
)

:: Generate random seed for the master mixer
set /a SEED=%RANDOM% * 32768 + %RANDOM%

echo ============================================
echo   Golden Phase Drone - Real-time
echo ============================================
echo Duration: %DURATION% seconds
echo Seed:     %SEED%
echo.
echo Golden-ratio folded harmonics
echo Bilateral phase-inverted side layers
echo Mono-safe center wash with long reverb
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
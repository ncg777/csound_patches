@echo off
setlocal

:: Usage: play_drone.bat [duration] [pitch_set] [seed]
:: Pitch set: Forte label, named alias, or a quoted comma-separated list.
if /i "%~1"=="--help" goto help
if /i "%~1"=="--list-sets" goto list
if not "%~4"=="" goto help

set "DURATION=600"
if not "%~1"=="" set "DURATION=%~1"
set "PITCH_SET=5-31A.01"
if not "%~2"=="" set "PITCH_SET=%~2"
set "SEED=%~3"
set "TMPFILE=%TEMP%\drone_realtime_%RANDOM%_%RANDOM%.csd"

echo ============================================
echo   Meta-Vectorial Evolving Drone - Real-time
echo ============================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0prepare_drone.ps1" -Duration "%DURATION%" -PitchSet "%PITCH_SET%" -Seed "%SEED%" -OutputPath "%TMPFILE%"
if errorlevel 1 exit /b 1
echo.
echo 8 drone groups x 4 voices = 32 total voices
echo Ultra-slow vec8 morphing between related groups
echo Press Ctrl+C to stop playback
echo.

csound -odac "%TMPFILE%"
set "CSOUND_STATUS=%ERRORLEVEL%"
del "%TMPFILE%" 2>nul
if not "%CSOUND_STATUS%"=="0" exit /b %CSOUND_STATUS%
echo.
echo Playback finished.
exit /b 0

:list
if "%~2"=="" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0prepare_drone.ps1" -ListSets
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0prepare_drone.ps1" -ListSets -Cardinality "%~2"
)
exit /b %ERRORLEVEL%

:help
echo Usage: play_drone.bat [duration] [pitch_set] [seed]
echo Default: 600 seconds, 5-31A.01 ^(1,2,4,7,10^), random seed
echo Examples:
echo   play_drone.bat 600 5-35 12345
echo   play_drone.bat 600 6-35 12345
echo   play_drone.bat 600 "0,1,4,6" 12345
echo   play_drone.bat --list-sets 5
echo Forte labels support A/B forms, optional Z, and .00-.11 transposition.
echo Aliases: default, pentatonic, whole-tone, octatonic, chromatic
exit /b 0

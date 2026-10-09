@echo off
setlocal enabledelayedexpansion

:: Render a vectorial evolving drone to WAV file
:: Usage: render_drone.bat [duration] [output_file] [pitch_set] [seed]
if /i "%~1"=="--help" goto help
if /i "%~1"=="--list-sets" goto list
if not "%~5"=="" goto help

set "TMPFILE=%TEMP%\drone_render_%RANDOM%_%RANDOM%.csd"

:: Duration in seconds (default 600 = 10 minutes)
if "%~1"=="" (
    set DURATION=600
) else (
    set DURATION=%~1
)

:: Output filename
if "%~2"=="" (
    for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set DATESTAMP=%%c-%%a-%%b
    for /f "tokens=1-2 delims=:. " %%a in ('time /t') do set TIMESTAMP=%%a%%b
    set OUTFILE=drone_!DATESTAMP!_!TIMESTAMP!.wav
) else (
    set OUTFILE=%~2
)

:: Select root pitch classes and optional reproducible seed.
set "PITCH_SET=5-31A.01"
if not "%~3"=="" set "PITCH_SET=%~3"
set "SEED=%~4"

echo ============================================
echo   Meta-Vectorial Evolving Drone - Render to WAV
echo ============================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0prepare_drone.ps1" -Duration "%DURATION%" -PitchSet "%PITCH_SET%" -Seed "%SEED%" -OutputPath "%TMPFILE%"
if errorlevel 1 exit /b 1
echo Output:   %OUTFILE%
echo.
echo 8 drone groups x 4 voices = 32 total voices
echo Group roots follow the selected pitch-class set
echo Ultra-slow chaotic vec8 morphing between groups
echo ============================================
echo.

:: Render to WAV file
csound -o "%OUTFILE%" "%TMPFILE%"
set "CSOUND_STATUS=!ERRORLEVEL!"

:: Cleanup
del "%TMPFILE%" 2>nul
if not "%CSOUND_STATUS%"=="0" exit /b %CSOUND_STATUS%

:: Normalize to -14 LUFS using ffmpeg (if available)
where ffmpeg >nul 2>&1
if !ERRORLEVEL! equ 0 (
    echo.
    echo Normalizing to -14 LUFS...
    set NORMFILE=%OUTFILE:.wav=_normalized.wav%
    ffmpeg -hide_banner -loglevel warning -i "%OUTFILE%" -af loudnorm=I=-14:TP=-1:LRA=11:print_format=summary -y "!NORMFILE!" 2>&1
    if !ERRORLEVEL! equ 0 (
        set "DRONE_NORMALIZED_PATH=!NORMFILE!"
        set "DRONE_OUTPUT_PATH=%OUTFILE%"
        powershell -NoProfile -Command "Move-Item -LiteralPath $env:DRONE_NORMALIZED_PATH -Destination $env:DRONE_OUTPUT_PATH -Force -ErrorAction Stop"
        if !ERRORLEVEL! equ 0 (
            echo Normalized to -14 LUFS: %OUTFILE%
        ) else (
            echo WARNING: Could not replace the WAV with its normalized version, keeping the original render.
            del "!NORMFILE!" 2>nul
        )
    ) else (
        echo WARNING: ffmpeg normalization failed, keeping original render.
        del "!NORMFILE!" 2>nul
    )
) else (
    echo.
    echo NOTE: Install ffmpeg for automatic -14 LUFS normalization.
    echo       Without ffmpeg, levels are approximate.
)

echo.
echo Render complete: %OUTFILE%
exit /b 0

:list
if "%~2"=="" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0prepare_drone.ps1" -ListSets
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0prepare_drone.ps1" -ListSets -Cardinality "%~2"
)
exit /b %ERRORLEVEL%

:help
echo Usage: render_drone.bat [duration] [output_file] [pitch_set] [seed]
echo Default: 600 seconds, generated filename, 5-31A.01, random seed
echo Example: render_drone.bat 600 "pentatonic.wav" 5-35 12345
echo List sets: render_drone.bat --list-sets 5
exit /b 0

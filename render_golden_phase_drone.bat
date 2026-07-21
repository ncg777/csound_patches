@echo off
setlocal enabledelayedexpansion

:: Render a Golden Ratio phase-inversion drone to WAV file
:: Usage: render_golden_phase_drone.bat [duration] [output_file]

set TEMPLATE=golden_phase_drone.csd
set TMPFILE=%TEMP%\golden_phase_drone_render_%RANDOM%.csd

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
    set OUTFILE=golden_phase_drone_!DATESTAMP!_!TIMESTAMP!.wav
) else (
    set OUTFILE=%~2
)

:: Generate random seed
set /a SEED=%RANDOM% * 32768 + %RANDOM%

echo ============================================
echo   Golden Phase Drone - Render to WAV
echo ============================================
echo Duration: %DURATION% seconds
echo Seed:     %SEED%
echo Output:   %OUTFILE%
echo.
echo Golden-ratio folded harmonics
echo Bilateral phase-inverted side layers
echo Mono-safe center wash with long reverb
echo ============================================
echo.

:: Create temporary CSD file with substituted values
powershell -Command "(Get-Content '%TEMPLATE%') -replace '__DURATION__', '%DURATION%' -replace '__SEED__', '%SEED%' | Set-Content '%TMPFILE%'"

:: Render to WAV file
csound -o "%OUTFILE%" "%TMPFILE%"

:: Cleanup
del "%TMPFILE%" 2>nul

:: Normalize to -14 LUFS using ffmpeg (if available)
where ffmpeg >nul 2>&1
if !ERRORLEVEL! equ 0 (
    echo.
    echo Normalizing to -14 LUFS...
    set NORMFILE=%OUTFILE:.wav=_normalized.wav%
    ffmpeg -hide_banner -loglevel warning -i "%OUTFILE%" -af loudnorm=I=-14:TP=-1:LRA=11:print_format=summary -y "!NORMFILE!" 2>&1
    if !ERRORLEVEL! equ 0 (
        move /y "!NORMFILE!" "%OUTFILE%" >nul
        echo Normalized to -14 LUFS: %OUTFILE%
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
@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: digitalkeys.bat — Render a MIDI file with the DigitalKeys patch
::
:: Usage:   digitalkeys.bat <midifile> [output.wav]
:: Example: digitalkeys.bat mypiece.mid
::          digitalkeys.bat mypiece.mid mypiece_keys.wav
::
:: Produces a Rhodes-style rendered WAV from a MIDI file.
:: ============================================================

if "%~1"=="" (
    echo.
    echo  Usage:   digitalkeys.bat ^<midifile^> [output.wav]
    echo  Example: digitalkeys.bat mypiece.mid
    echo.
    exit /b 1
)

set MIDIFILE=%~1

if not exist "%MIDIFILE%" (
    echo.
    echo  ERROR: MIDI file not found: %MIDIFILE%
    echo.
    exit /b 1
)

if "%~2"=="" (
    set OUTFILE=%~n1_digitalkeys.wav
) else (
    set OUTFILE=%~2
)

echo.
echo  ================================================
echo    DigitalKeys  ^|  Rhodes-style Renderer
echo  ================================================
echo    Input:   %MIDIFILE%
echo    Output:  %OUTFILE%
echo    Velocity shapes attack and tone
echo  ================================================
echo.

:: -T  : terminate when the MIDI file is exhausted
:: -F  : MIDI file input
csound -+rtmidi=null -T -F "%MIDIFILE%" -o "%OUTFILE%" "%~dp0digitalkeys.csd"

if !ERRORLEVEL! neq 0 (
    echo.
    echo  ERROR: Csound exited with code !ERRORLEVEL!.
    echo  Make sure csound is in your PATH.
    exit /b !ERRORLEVEL!
)

:: Optional: normalize to -14 LUFS with ffmpeg. Tail time is rendered by Csound.
where ffmpeg >nul 2>&1
if !ERRORLEVEL! equ 0 (
    echo.
    echo  Normalizing to -14 LUFS...
    set NORMFILE=%TEMP%\digitalkeys_norm_%RANDOM%.wav
    ffmpeg -hide_banner -loglevel warning ^
        -i "%OUTFILE%" ^
        -af "loudnorm=I=-14:TP=-1:LRA=11:print_format=summary" ^
        -ar 48000 ^
        -y "!NORMFILE!" 2>&1
    if !ERRORLEVEL! equ 0 (
        move /y "!NORMFILE!" "%OUTFILE%" >nul
        echo  Normalized: %OUTFILE%
    ) else (
        del "!NORMFILE!" 2>nul
        echo  WARNING: ffmpeg post-processing failed; keeping raw render.
    )
) else (
    echo.
    echo  NOTE: Install ffmpeg for optional -14 LUFS normalization.
)

echo.
echo  Done: %OUTFILE%
echo.

@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: digitalbell.bat — Render a MIDI file with the DigitalBell patch
::
:: Usage:   digitalbell.bat <midifile> [output.wav]
:: Example: digitalbell.bat mypiece.mid
::          digitalbell.bat mypiece.mid mypiece_bells.wav
::
:: The DigitalBell patch produces ambient bell-chime textures
:: with deep reverb and elaborate echoes.  Timbre morphs
:: randomly through 8 sound sources (resonant noise bell, 3-voice
:: detuned sines, 4-voice wide sines, sines+inharmonic partial,
:: crystal FM bell, Chowning-partial chorus, rich metallic FM,
:: diffuse noiseband) via the vec8 opcode — no MIDI CC required.
:: ============================================================

if "%~1"=="" (
    echo.
    echo  Usage:   digitalbell.bat ^<midifile^> [output.wav]
    echo  Example: digitalbell.bat mypiece.mid
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
    set OUTFILE=%~n1_digitalbell.wav
) else (
    set OUTFILE=%~2
)

echo.
echo  ================================================
echo    DigitalBell  ^|  Ambient Bell Chime Renderer
echo  ================================================
echo    Input:   %MIDIFILE%
echo    Output:  %OUTFILE%
echo    Timbre morphs randomly (no CC needed)
echo  ================================================
echo.

:: -T  : terminate when the MIDI file is exhausted
::       (bell notes ring out via xtratim, including the internal 10 s tail)
:: -F  : MIDI file input
csound -+rtmidi=null -T -F "%MIDIFILE%" -o "%OUTFILE%" "%~dp0digitalbell.csd"

if !ERRORLEVEL! neq 0 (
    echo.
    echo  ERROR: Csound exited with code !ERRORLEVEL!.
    echo  Make sure csound is in your PATH.
    exit /b !ERRORLEVEL!
)

:: Optional: normalize to -14 LUFS with ffmpeg (same pattern
:: as render_drone.bat in this repo). Tail time is rendered by Csound.
where ffmpeg >nul 2>&1
if !ERRORLEVEL! equ 0 (
    echo.
    echo  Normalizing to -14 LUFS...
    set NORMFILE=%TEMP%\digitalbell_norm_%RANDOM%.wav
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

@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: digitalpad.bat — Render a MIDI file with the DigitalPad patch
::
:: Usage:   digitalpad.bat <midifile> [output.wav]
:: Example: digitalpad.bat mypiece.mid
::          digitalpad.bat mypiece.mid mypiece_pad.wav
::
:: DigitalPad produces evolving, morphing pad textures with
:: 8 timbral sources (hypersaw, PWM strings, waveshaper,
:: FM crystal, shimmer, filtered noise, sub warmth, digital
:: choir) blended via vec8.  Stereo chorus and a long ambient
:: reverb are applied in the mix stage.  Timbre morphs
:: continuously via MorphController — no MIDI CC needed.
:: ============================================================

if "%~1"=="" (
    echo.
    echo  Usage:   digitalpad.bat ^<midifile^> [output.wav]
    echo  Example: digitalpad.bat mypiece.mid
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
    set OUTFILE=%~n1_digitalpad.wav
) else (
    set OUTFILE=%~2
)

echo.
echo  ================================================
echo    DigitalPad  ^|  Vectorial Pad Renderer
echo  ================================================
echo    Input:   %MIDIFILE%
echo    Output:  %OUTFILE%
echo    Timbre morphs randomly (no CC needed)
echo  ================================================
echo.

:: -T  : terminate when the MIDI file is exhausted
::       (xtratim includes the reverb tail and the internal 10 s buffer)
:: -F  : MIDI file input
csound -+rtmidi=null -T -F "%MIDIFILE%" -o "%OUTFILE%" "%~dp0digitalpad.csd"

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
    set NORMFILE=%TEMP%\digitalpad_norm_%RANDOM%.wav
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

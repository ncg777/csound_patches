@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: digitalorgan.bat — Render a MIDI file with the DigitalOrgan patch
::
:: Usage:   digitalorgan.bat <midifile> [output.wav]
:: Example: digitalorgan.bat mypiece.mid
::          digitalorgan.bat mypiece.mid mypiece_organ.wav
::
:: DigitalOrgan produces sustained, morphing organ textures with
:: 8 timbral sources (flute, principal, full drawbar, reed FM,
:: celeste, mixture, open pipe, vox humana) blended via vec8.
:: A Leslie rotating-speaker simulation and large hall reverb
:: are applied in the mix stage.  Timbre morphs continuously
:: via DigitalOrganMorphCtl — no MIDI CC needed.
:: ============================================================

if "%~1"=="" (
    echo.
    echo  Usage:   digitalorgan.bat ^<midifile^> [output.wav]
    echo  Example: digitalorgan.bat mypiece.mid
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
    set OUTFILE=%~n1_digitalorgan.wav
) else (
    set OUTFILE=%~2
)

echo.
echo  ================================================
echo    DigitalOrgan  ^|  Vectorial Organ Renderer
echo  ================================================
echo    Input:   %MIDIFILE%
echo    Output:  %OUTFILE%
echo    Timbre morphs randomly (no CC needed)
echo  ================================================
echo.

:: -T  : terminate when the MIDI file is exhausted
::       (xtratim includes the reverb tail and the internal 10 s buffer)
:: -F  : MIDI file input
csound -+rtmidi=null -T -F "%MIDIFILE%" -o "%OUTFILE%" "%~dp0digitalorgan.csd"

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
    set NORMFILE=%TEMP%\digitalorgan_norm_%RANDOM%.wav
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

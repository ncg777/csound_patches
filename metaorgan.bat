@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: metaorgan.bat — Render a MIDI file with the MetaOrgan patch
::
:: Usage:   metaorgan.bat <midifile> [output.wav]
:: Example: metaorgan.bat mypiece.mid
::          metaorgan.bat mypiece.mid mypiece_organ.wav
::
:: MetaOrgan produces sustained, morphing organ textures with
:: 8 timbral sources (flute, principal, full drawbar, reed FM,
:: celeste, mixture, open pipe, vox humana) blended via vec8.
:: A Leslie rotating-speaker simulation and large hall reverb
:: are applied in the mix stage.  Timbre morphs continuously
:: via MorphController — no MIDI CC needed.
:: ============================================================

if "%~1"=="" (
    echo.
    echo  Usage:   metaorgan.bat ^<midifile^> [output.wav]
    echo  Example: metaorgan.bat mypiece.mid
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
    set OUTFILE=%~n1_metaorgan.wav
) else (
    set OUTFILE=%~2
)

echo.
echo  ================================================
echo    MetaOrgan  ^|  Vectorial Organ Renderer
echo  ================================================
echo    Input:   %MIDIFILE%
echo    Output:  %OUTFILE%
echo    Timbre morphs randomly (no CC needed)
echo  ================================================
echo.

:: -T  : terminate when the MIDI file is exhausted
::       (xtratim = 8 s covers the reverb tail)
:: -F  : MIDI file input
csound -+rtmidi=null -T -F "%MIDIFILE%" -o "%OUTFILE%" "%~dp0metaorgan.csd"

if !ERRORLEVEL! neq 0 (
    echo.
    echo  ERROR: Csound exited with code !ERRORLEVEL!.
    echo  Make sure csound is in your PATH.
    exit /b !ERRORLEVEL!
)

:: Optional: normalize to -14 LUFS and pad 10 s of silence with ffmpeg
where ffmpeg >nul 2>&1
if !ERRORLEVEL! equ 0 (
    echo.
    echo  Normalizing to -14 LUFS and adding 10 s silence tail...
    set NORMFILE=%TEMP%\metaorgan_norm_%RANDOM%.wav
    ffmpeg -hide_banner -loglevel warning ^
        -i "%OUTFILE%" ^
        -af "loudnorm=I=-14:TP=-1:LRA=11:print_format=summary,apad=pad_dur=10" ^
        -ar 48000 ^
        -y "!NORMFILE!" 2>&1
    if !ERRORLEVEL! equ 0 (
        move /y "!NORMFILE!" "%OUTFILE%" >nul
        echo  Normalized and padded: %OUTFILE%
    ) else (
        del "!NORMFILE!" 2>nul
        echo  WARNING: ffmpeg post-processing failed; keeping raw render.
    )
) else (
    echo.
    echo  NOTE: Install ffmpeg for -14 LUFS normalization and 10 s silence padding.
)

echo.
echo  Done: %OUTFILE%
echo.

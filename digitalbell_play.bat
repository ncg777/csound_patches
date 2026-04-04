@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: digitalbell_play.bat — Play a MIDI file in real time via DigitalBell
::
:: Usage:   digitalbell_play.bat <midifile> [dac_device]
:: Example: digitalbell_play.bat mypiece.mid
::          digitalbell_play.bat mypiece.mid 1
::
:: dac_device is an optional integer audio device index.
:: Run  csound --devices  to list available output devices.
::
:: Press Ctrl+C to stop playback early.
:: ============================================================

if "%~1"=="" (
    echo.
    echo  Usage:   digitalbell_play.bat ^<midifile^> [dac_device]
    echo  Example: digitalbell_play.bat mypiece.mid
    echo           digitalbell_play.bat mypiece.mid 1
    echo.
    echo  Run  csound --devices  to list audio output devices.
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

:: Build DAC target: default (dac) or numbered device (dac:N)
if "%~2"=="" (
    set DACTGT=dac
) else (
    set DACTGT=dac:%~2
)

echo.
echo  ================================================
echo    DigitalBell  ^|  Real-time MIDI Playback
echo  ================================================
echo    Input:   %MIDIFILE%
echo    Output:  %DACTGT%
echo    Timbre morphs randomly (no CC needed)
echo    Press Ctrl+C to stop early
echo  ================================================
echo.

:: -T  : terminate when the MIDI file is exhausted
::       (bell notes ring out via xtratim, including the internal 10 s tail)
:: -F  : MIDI file input
:: -odac : real-time audio output (no file written)
csound -+rtmidi=null -T -F "%MIDIFILE%" -o %DACTGT% "%~dp0digitalbell.csd"

if !ERRORLEVEL! neq 0 (
    echo.
    echo  ERROR: Csound exited with code !ERRORLEVEL!.
    echo  Make sure csound is in your PATH.
    echo  Run  csound --devices  to check your audio device index.
    exit /b !ERRORLEVEL!
)

echo.
echo  Playback finished.
echo.

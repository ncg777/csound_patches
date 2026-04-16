@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: digitalorch20260415.bat — Render a MIDI file with the
:: DigitalOrch20260415 orchestra
::
:: Usage:   digitalorch20260415.bat <midifile> [output.wav]
:: Example: digitalorch20260415.bat mypiece.mid
::          digitalorch20260415.bat mypiece.mid mypiece_orch.wav
::
:: Three-patch orchestra rendering from a multi-channel MIDI file:
::   Channel 1 — DigitalKeys   (Rhodes-style electric piano)
::   Channel 2 — DigitalFlute  (breathy digital flute)
::   Channel 3 — DigitalPad    (evolving morphing pad)
:: ============================================================

if "%~1"=="" (
    echo.
    echo  Usage:   digitalorch20260415.bat ^<midifile^> [output.wav]
    echo  Example: digitalorch20260415.bat mypiece.mid
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
    set OUTFILE=%~n1_digitalorch20260415.wav
) else (
    set OUTFILE=%~2
)

echo.
echo  ================================================
echo    DigitalOrch20260415  ^|  Orchestra Renderer
echo  ================================================
echo    Input:   %MIDIFILE%
echo    Output:  %OUTFILE%
echo    Ch 1: DigitalKeys   (Rhodes piano)
echo    Ch 2: DigitalFlute  (Digital flute)
echo    Ch 3: DigitalPad    (Morphing pad)
echo  ================================================
echo.

:: -T  : terminate when the MIDI file is exhausted
:: -F  : MIDI file input
csound -+rtmidi=null -T -F "%MIDIFILE%" -o "%OUTFILE%" "%~dp0digitalorch20260415.csd"

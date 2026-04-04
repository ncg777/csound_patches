<CsoundSynthesizer>
<CsOptions>
; Usage: csound -T -F input.mid -o output.wav digitalbell.csd
; Companion script: digitalbell.bat input.mid [output.wav]
; 32-bit float WAV avoids int16 scaling issues with 0dbfs=1
--format=float
</CsOptions>

<CsInstruments>

sr     = 48000
ksmps  = 64
nchnls = 2
0dbfs  = 1
A4     = 432

#include "digitalbell.inc"

</CsInstruments>

<CsScore>
; DigitalBellMorphCtl and DigitalBellMix run for up to 2 hours.
; With -T flag the performance ends after the last MIDI note
; rings out, including the internal 10 s render buffer.
i "DigitalBellMorphCtl" 0 7200
i "DigitalBellMix"      0 7200

; Keep score alive; -T in the bat script governs actual end time
f 0 7200

e
</CsScore>

</CsoundSynthesizer>

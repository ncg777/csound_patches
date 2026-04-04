<CsoundSynthesizer>
<CsOptions>
; Usage: csound -T -F input.mid -o output.wav digitalpad.csd
; Companion script: digitalpad.bat input.mid [output.wav]
; 32-bit float WAV avoids int16 scaling issues with 0dbfs=1
--format=float
</CsOptions>

<CsInstruments>

sr     = 48000
ksmps  = 64
nchnls = 2
0dbfs  = 1
A4     = 432

#include "digitalpad.inc"

</CsInstruments>

<CsScore>
; DigitalPadMorphCtl and DigitalPadMix run for up to 2 hours.
; With -T the performance ends once the last MIDI note
; rings out, including the internal 10 s render buffer.
i "DigitalPadMorphCtl"  0  7200
i "DigitalPadMix"       0  7200

; Keep score alive; -T governs actual end time
f 0 7200

e
</CsScore>

</CsoundSynthesizer>

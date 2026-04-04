<CsoundSynthesizer>
<CsOptions>
; Usage: csound -T -F input.mid -o output.wav digitalorgan.csd
; Companion script: digitalorgan.bat input.mid [output.wav]
; 32-bit float WAV avoids int16 scaling issues with 0dbfs=1
--format=float
</CsOptions>

<CsInstruments>

sr     = 48000
ksmps  = 64
nchnls = 2
0dbfs  = 1

#include "digitalorgan.inc"

</CsInstruments>

<CsScore>
; DigitalOrganMorphCtl and DigitalOrganMix run for up to 2 hours.
; With -T the performance ends once the last MIDI note
; rings out, including the internal 10 s render buffer.
i "DigitalOrganMorphCtl"  0  7200
i "DigitalOrganMix"       0  7200

; Keep score alive; -T governs actual end time
f 0 7200

e
</CsScore>

</CsoundSynthesizer>

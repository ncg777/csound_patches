<CsoundSynthesizer>
<CsOptions>
; Usage: csound -T -F input.mid -o output.wav digitalkeys.csd
; Companion script: digitalkeys.bat input.mid [output.wav]
--format=float
</CsOptions>

<CsInstruments>

sr     = 48000
ksmps  = 64
nchnls = 2
0dbfs  = 1

#include "digitalkeys.inc"

</CsInstruments>

<CsScore>
; DigitalKeysModCtl and DigitalKeysMix run as background processes
i "DigitalKeysModCtl"  0  7200
i "DigitalKeysMix"     0  7200

f 0 7200

e
</CsScore>

</CsoundSynthesizer>

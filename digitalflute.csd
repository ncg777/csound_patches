<CsoundSynthesizer>
<CsOptions>
; Usage: csound -T -F input.mid -o output.wav digitalflute.csd
; Companion script: digitalflute.bat input.mid [output.wav]
--format=float
</CsOptions>

<CsInstruments>

sr     = 48000
ksmps  = 64
nchnls = 2
0dbfs  = 1

#include "digitalflute.inc"

</CsInstruments>

<CsScore>
; DigitalFluteModCtl and DigitalFluteMix run as background processes
i "DigitalFluteModCtl"  0  7200
i "DigitalFluteMix"     0  7200

f 0 7200

e
</CsScore>

</CsoundSynthesizer>

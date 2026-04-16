<CsoundSynthesizer>
<CsOptions>
; Usage: csound -T -F input.mid -o output.wav digitalorch20260415.csd
; Companion script: digitalorch20260415.bat input.mid [output.wav]
;
; MIDI channel assignment:
;   Channel 1 — DigitalKeys   (Rhodes-style electric piano)
;   Channel 2 — DigitalFlute  (breathy digital flute)
;   Channel 3 — DigitalPad    (evolving morphing pad)
;
--format=float
</CsOptions>

<CsInstruments>

sr     = 48000
ksmps  = 64
nchnls = 2
0dbfs  = 0.5
A4     = 432

; -- Channel assignments --
#define DIGITALKEYS_CHANNEL  #1#
#define DIGITALFLUTE_CHANNEL #2#
#define DIGITALPAD_CHANNEL   #3#

#include "digitalkeys.inc"
#include "digitalflute.inc"
#include "digitalpad.inc"

</CsInstruments>

<CsScore>
; Background control and mix instruments for each patch
i "DigitalKeysModCtl"   0  7200
i "DigitalKeysMix"      0  7200

i "DigitalFluteModCtl"  0  7200
i "DigitalFluteMix"     0  7200

i "DigitalPadMorphCtl"  0  7200
i "DigitalPadMix"       0  7200

f 0 7200

e
</CsScore>

</CsoundSynthesizer>

<CsoundSynthesizer>


<CsOptions>
-o e:\tmp.wav
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2

#include "D:/Music making/mus_csound/my_udos.inc"

	instr 1
		
		a1 PAF 0dbfs,400,400,1,50,1
		
		outs a1, a1
	endin


</CsInstruments>


<CsScore>
f 1 0 16384 10 1

i 1 0 2
</CsScore>


</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacGUI>
ioView nobackground {65535, 65535, 65535}
</MacGUI>

<CsoundSynthesizer>


<CsOptions>
 
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2

#include "my_udos.inc"

	instr 1

		ao lfo 1, 0.25, 0
		atr triv a(k(50)), ao
		atr = atr*0dbfs/4
		outs atr, atr
	endin


</CsInstruments>


<CsScore>
	f 1 0 16384 10 1
	i 1 0 5
</CsScore>


</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>400</width>
 <height>354</height>
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

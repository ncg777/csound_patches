<CsoundSynthesizer>


<CsOptions>
-o DAC

</CsOptions>


<CsInstruments>

	sr     = 192000
	kr     = 19200
	ksmps  = 10
	nchnls = 2

#include "D:/Music making/mus_csound/my_udos.inc"

	instr 1
		ifreq=p4
		ilfofreq=p5
		alfo oscil 1, ilfofreq, 2
		alfo pow alfo, 0.5
		a1 oscil 0dbfs, ifreq, 1
		al=a1*alfo
		ar=a1*alfo

		outs al, -ar
	endin


</CsInstruments>


<CsScore>
f 1 0 16384 10 16 8 4 2
f 2 0 2048 27 0 0 20 1 2048 0

i 1 0 9 14700 18

</CsScore>


</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1280</x>
 <y>616</y>
 <width>400</width>
 <height>140</height>
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

<CsoundSynthesizer>


<CsOptions>
-o d:/t.wav

</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2

#include "my_udos.inc"

	instr 1
		ifreq=p4
		ilfofreq=p5
		iamp = p6
		alfo oscil 1, ilfofreq, 2
		alfo = alfo*alfo*alfo
		/* a1 noiseband ifreq, iband */
		a1 oscil3 iamp, ifreq, 1
		al=a1*alfo
		ar=a1*alfo

		outs al, ar
	endin


</CsInstruments>


<CsScore>
f 1 0 513 10 1
f 2 0 2049 27 0 0 500 1 2048 0
i 1 0 300 111 5.8 11000
i 1 0 300 777 19.00333 6000
i 1 0 300 777 19 6000
i 1 0 300 77 19 7000
i 1 0 300 77 19.00333 7000
</CsScore>


</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>0</width>
 <height>0</height>
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

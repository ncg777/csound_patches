<CsoundSynthesizer>


<CsOptions>
-o DAC
</CsOptions>


<CsInstruments>
	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2
	
#include "D:/Music making/mus_csound/my_udos.inc"

	instr 1
		aamp = 0dbfs
		alfo oscil 110,27.5, 4
		alfo1 oscil 0.02,55, 4

		afreq =110+ alfo
		apitch = 0.25 + alfo1
		
		aout1 syncg aamp, afreq, apitch, 1,2
		aout2 syncg aamp, afreq, apitch, 1,3
		
		outs aout1, aout2
	endin
</CsInstruments>


<CsScore>
	f 1 0 16384 20 1 1
	f 2 0 0 1 "mmmoi.wav" 0 0 1
	f 3 0 0 1 "mmmoi.wav" 0 0 2
	f 4 0 16384 10 16 8 4 2
	i 1 0 2700 330 10
	e
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

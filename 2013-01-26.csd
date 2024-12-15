<CsoundSynthesizer>


<CsOptions>
-o "d:\40.wav"
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2

	
#include "my_udos.inc"

	instr 1
		iam = 1000
		amod gauss 1
		am1 lpf18 amod, 25,0.98,0.15
		am2 oscil 50,50,1
		am3 = -am2
		a0 oscil 1, am3+(am1*iam), 1
		a1 oscil 1, am2-(am1*iam), 1
		outs a0*0dbfs, a1*0dbfs
	endin


</CsInstruments>


<CsScore>
	f 1 0 16384 10 1

	f 2 3600
	i 1 0 3600
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

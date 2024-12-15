<CsoundSynthesizer>


<CsOptions>
-o "f:/2016.05.08 2016.04.19.wav"
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2
#include "my_udos.inc"

	instr 1
	  aenv adsr p3*p7,0,1.0,p3*p8
	  aL, aR diskin p5, p4, p6, 1
	  outs aL*aenv,aR*aenv
	endin

</CsInstruments>


<CsScore>
#define W #"F:/mixettes/2016.04.19/wav/2016.04.19.wav"#
#define LEN #4776#

	f 1 0 16384 10 1

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

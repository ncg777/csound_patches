<CsoundSynthesizer>


<CsOptions>
-o "d:\20131221.wav"
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2
	
	
#include "my_udos.inc"

	instr 1
		/* 
		aosc0 poscil 1.0,p4-p5,1
		aosc1 poscil 1.0,p4+p5,1
		ishape = 0.1
		aosc0p powershape aosc0, ishape
		aosc1p powershape aosc1, ishape */
		anoi0 unirand 1.0
		anoi1 unirand 1.0
		/*
		aosc0p = p6*aosc0*0dbfs
		aosc1p = -p6*aosc1*0dbfs */
		anoi0 = anoi0*0dbfs
		anoi1 = anoi1*0dbfs
		/*
		aol=aosc0p+anoi0
		aor=aosc1p+anoi1 */
		/*
		ifreq = 1900
		iband = 900
		aol butterbp anoi0, ifreq, iband
		aor butterbp anoi1, ifreq, iband
		*/
		aol = anoi0
		aor = anoi1
		outs aol,aor
	endin


</CsInstruments>


<CsScore>
	f 1 0 16384 10 1
	f 2 0 16384 "tanh" -1 1 1
	f 3 0 16384 7 -1 16384 1
	f 4 17
	
	i1 0 600
</CsScore>


</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
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

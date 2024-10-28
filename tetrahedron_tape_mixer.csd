<CsoundSynthesizer>

<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2
	
#include "D:/Music making/mus_csound/my_udos.inc"

	instr 1
	  
	  al1,ar1 soundin p4
	  al2,ar2 soundin p5
	  al3,ar3 soundin p6
	  al4,ar4 soundin p7
	  
	  itfreq = p8
	  itamp = p9
	  
	  ipfreq = p10
	  ipamp = p11
	  
	  kt oscil itamp/2.0, itfreq, 1
	  kp oscil ipamp, ipfreq,  1
	  iamp = 0.8
	  aml tetrahedron_mixer al1,al2,al3,al4, kt+0.5, kp
	  amr tetrahedron_mixer ar1,ar2,ar3,ar4, kt+0.5, -kp
	  	
	  outs aml*iamp, amr*iamp
	endin

</CsInstruments>


<CsScore>

	f 1 0 16384 10 1
	f 2 0 16384 27 0 -1 16384 1
	f 3 0 16384 27 0 1 8192 -1 16384 1
	f 4 0 16384 27 0 1 8191 1 8192 -1 16384 -1
	
	i 1 0 $length "$prefix1.wav" "$prefix2.wav" "$prefix3.wav" "$prefix4.wav" [1.0/$th] 1 [1.0/$ph] 1
             
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

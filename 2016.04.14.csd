<CsoundSynthesizer>


<CsOptions>
-o "d:/2016.04.14/3.wav"
</CsOptions>


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
	  al5,ar5 soundin p8
	  al6,ar6 soundin p9
	  
	  itfreq = p10
	  itamp = p11
	  
	  ipfreq = p12
	  ipamp = p13
	  
	  kt oscil itamp/2.0, itfreq, 1
	  kp oscil ipamp, ipfreq,  1
	  
	  aml octahedron_mixer al1,al2,al3,al4,al5,al6, kt+0.5, kp
	  amr octahedron_mixer	ar1,ar2,ar3,ar4,ar5,ar6, kt+0.5, kp
	  	
	  outs aml, amr
	endin

</CsInstruments>


<CsScore>
#define V30 #1.8834#
#define V31 #1.9042742#
#define V32 #1.9253376#
#define V33 #1.9468614#
#define V34 #1.9691168#
#define V35 #1.992375#
#define V36 #2.0169072#
#define V37 #2.0429846#
#define V38 #2.0708784#
#define V39 #2.1008598#
#define V40 #2.1332#
#define length #2883#

	f 1 0 16384 10 1
	f 2 0 16384 27 0 -1 16384 1
	f 3 0 16384 27 0 1 8192 -1 16384 1
	f 4 0 16384 27 0 1 8191 1 8192 -1 16384 -1
	
	i 1 0 $length "d:/2016.04.14/31.wav" "d:/2016.04.14/32.wav" "d:/2016.04.14/33.wav" "d:/2016.04.14/34.wav" "d:/2016.04.14/35.wav" "d:/2016.04.14/36.wav" [1.0/7.0] 1 [1.0/300.0] 1
             
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

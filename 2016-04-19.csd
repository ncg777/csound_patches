<CsoundSynthesizer>


<CsOptions>
-Z -o "d:/2016.04.19.wav"
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2
#include "my_udos.inc"
	
	instr 1
   	             imodfreq=p4
		ifreq=p5
		
		kband=p6
		ideramp = p7
		iamp=ampdb(p8)
	    
	             amod oscil 1,  imodfreq,2
	             amod = (amod*0.5)+0.5
	             
	             awnoise noise ideramp, 0
	             abnoise0 integ awnoise
	             abnoise1 integ -awnoise
	             abnoiseL mirror abnoise0, -1, 1
	             abnoiseR mirror abnoise1, -1, 1

	             anL0,anL1 strat amod*abnoiseL, a(8), a(2)
	             anR0,anR1 strat amod*abnoiseR, a(8), a(2)
	             anL = anL0*anL1
	             anR = anR0*anR1
		afL butbp anL, ifreq, kband
		afR butbp anR, ifreq, kband
		
		outs afL*iamp, afR*iamp
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
#define length #3600#
#define n #2#
#define amp #114#
#define wave #1#

	f 1 0 16384 10 1
	f 2 0 16384 27 0 1 16384 -1
	f 3 0 16384 27 0 1 8192 -1 16384 1
	f 4 0 16384 27 0 1 8191 1 8192 -1 16384 -1
	i 1 0 $length $V40  100 40 0.09 [$amp]
             i 1 0 $length [4*$V40]  700 100 0.05 [$amp-10]
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

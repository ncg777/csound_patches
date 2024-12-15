<CsoundSynthesizer>


<CsOptions>

</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2
	
	massign 1,1
	
#include "my_udos.inc"

	instr 1
		ivel veloc 0, 1
		iamp = ivel*0dbfs

		aenv madsr 0.001, 0, 1, 0.5
		
		ifreq cpsmidi

		imfreq = ifreq/4
		km0 oscil ivel, imfreq, 1
		km0 = (km0+1)/2
		km table3 km0, 2, 1
		km = (km+1)/2
		
		ax oscil 1, ifreq, 3
		ax = (ax+1)/2

		
		a0 circle ax, km
		a0 = (a0*2)-1
		ao = aenv*a0*0dbfs*0.95
		
		outs ao,ao
	endin


</CsInstruments>


<CsScore>
	f 1 0 16384 10 1
	f 2 0 16384 "tanh" -1 1 1
	f 3 0 16384 7 -1 16384 1
	f 4 17
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

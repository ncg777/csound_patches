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
		idur = 0.5
		
		aenv madsr 0.001, idur, 0, 0.01

		inotn pchmidi

		ktheta, kphi, krho notnum_to_spherical inotn
		kx, ky, kz spher_to_cart ktheta, kphi, krho
		
		al line 1.0, idur, 0.0

		
		ifreq = 2000
		

		
		a1 oscil 1.0, af1, 3
		a2 oscil 1.0, af2, 3
		a3 oscil 1.0, af3, 3
		a4 oscil 1.0, af4, 3
		a5 oscil 1.0, af5, 3
		a6 oscil 1.0, af6, 3
		a7 oscil 1.0, af7, 3
		a8 oscil 1.0, af8, 3
		
		a0 vec8 a1, a2, a3, a4, a5, a6, a7, a8, kx,ky, kz
		
		ao = aenv*a0*0dbfs
		
		outs ao,ao
	endin


</CsInstruments>


<CsScore>
	f 1 0 16384 10 1
	f 2 0 16384 "tanh" -1 1 1
	f 3 0 16384 7 -1 16384 1
	f 4 1
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

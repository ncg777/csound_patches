<CsoundSynthesizer>


<CsOptions>
-o dac
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2
#include "D:/Music making/mus_csound/my_udos.inc"
	instr 1
		al init 0
		ar init 0
		iamp=p6
		ifmi=(85/100)
		kf=1500

		ifr1=p4
		ifr2=p5

		afm oscil 1, ifr2,1
		afm=afm
		al oscil 1, ifr1+(afm*ifmi*ifr1)+(p5/2),1
		ar oscil 1, ifr1+(afm*ifmi*ifr1)-(p5/2),1
		
		amixl=(al)*iamp
		amixr=(ar)*iamp

		amixl butterlp amixl, kf
		amixr butterlp amixr, kf	

		outs amixl, amixr
	endin

	instr 2

		iamp=p6/5
		


		kfr1=p4
		kfr2=(p4)*(2^(2/12))
		kfr3=(p4)*(2^(4/12))
		kfr4=(p4)*(2^(7/12))
		kfr5=(p4)*(2^(9/12))

		a1l oscil 1, kfr1-(p5/2),1
		a1r oscil 1, kfr1+(p5/2),1

		a2l oscil 1, kfr2-(p5/2),1
		a2r oscil 1, kfr2+(p5/2),1

		a3l oscil 1, kfr3-(p5/2),1
		a3r oscil 1, kfr3+(p5/2),1

		a4l oscil 1, kfr4-(p5/2),1
		a4r oscil 1, kfr4+(p5/2),1

		a5l oscil 1, kfr5-(p5/2),1
		a5r oscil 1, kfr5+(p5/2),1

		amixl=(a1l+a2l+a3l+a4l+a5l)*iamp
		amixr=(a1r+a2r+a3r+a4r+a5r)*iamp
		/*
		amixl butterlp amixl, kf
		amixr butterlp amixr, kf	
		*/
		outs amixl, amixr

	endin
	
	instr 3
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
	

	instr 4

		a1 noiseband p4-p6, p5
		a2 noiseband p4+p6, p5

		a1=a1*p7
		a2=a2*p7

		outs a1, a2
	endin


</CsInstruments>


<CsScore>
	f 1 0 16384 10 16 8 4 2
	f 2 0 2049 27 0 0 500 1 2048 0
	i 2 0 3600 110 2 10000
	i 2 0 3600 330 2 10000
	i 4 0 3600 880 220 8 11000
	i 4 0 3600 220 55 4 11000
	i 4 0 3600 440 110 -4 11000
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

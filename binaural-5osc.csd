<CsoundSynthesizer>


<CsOptions>
-o DAC
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2

	instr 1

		iamp=0dbfs/5
		
		/* kf=700 */


		
		kj jitter 1.0, 0.01, 0.1
		kj=(kj^3)*p4/2.0
		
		kjb jitter 1.0, 0.01,0.1
		kjb=((kjb^3)*0.75)+1.0

		ks lfo 0.2, (p5/128)*kjb, 1
		ks=ks+1	

		kfr1=kj+p4
		kfr2=(kj+p4)*(2^(2/8))
		kfr3=(kj+p4)*(2^(6/8))
		kfr4=(kj+p4)*(2^(9/8))
		kfr5=(kj+p4)*(2^(13/8))

		a1l oscil 1, kfr1-(p5/2),1
		a1l powershape a1l, ks
		a1r oscil 1, kfr1+(p5/2),1
		a1r powershape a1r, ks

		a2l oscil 1, kfr2-(p5/2),1
		a2l powershape a2l, ks
		a2r oscil 1, kfr2+(p5/2),1
		a2r powershape a2r, ks

		a3l oscil 1, kfr3-(p5/2),1
		a3l powershape a3l, ks
		a3r oscil 1, kfr3+(p5/2),1
		a3r powershape a3r, ks

		a4l oscil 1, kfr4-(p5/2),1
		a4l powershape a4l, ks
		a4r oscil 1, kfr4+(p5/2),1
		a4r powershape a4r, ks

		a5l oscil 1, kfr5-(p5/2),1
		a5l powershape a5l, ks
		a5r oscil 1, kfr5+(p5/2),1
		a5r powershape a5r, ks

		amixl=(a1l+a2l+a3l+a4l+a5l)*iamp
		amixr=(a1r+a2r+a3r+a4r+a5r)*iamp
		/*
		amixl butterlp amixl, kf
		amixr butterlp amixr, kf	
		*/
		outs amixl, amixr

	endin


</CsInstruments>


<CsScore>
	f 1 0 16384 10 1

	i 1 0 2700 330 10
	e
</CsScore>


</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1280</x>
 <y>498</y>
 <width>400</width>
 <height>248</height>
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

<CsoundSynthesizer>


<CsOptions>
-o "d:/2016.02.28.wav"
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2

	instr 1
		ifreq=p4
		iwave=p5
		iffreq=p6
		ifq=p7
		
		iamp=ampdb(p8)
	      afmod lfo 1, 2.0625, 5   
	      afmod1 powershape afmod, 12   						
		a0 oscil 1, 30 + afmod1*ifreq, iwave
		
		af0 lowpass2 a0, iffreq, ifq
		outs a0*iamp, a0*iamp
	endin

	
	instr 2	
	             iamp = ampdb(p5)	
		a0 noise 1, 0.5
		a1 noise 1, 0.5
		af0 lowpass2 a0, p4, 100
		af1 lowpass2 a1, p4, 100

		outs af0*iamp, af1*iamp
	endin


</CsInstruments>


<CsScore>
	f 1 0 16384 10 1
	f 2 0 16384 27 0 1 8191 1 8192 -1 16384 -1
	f 3 0 16384 27 0 1 8192 -1 16384 1
	f 4 0 16384 27 0 -1 16384 1
	i 1 0 1800 800 2 500 20 50
	i 1 0 1800 1600 2 750 20 30
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

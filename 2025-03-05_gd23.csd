<CsoundSynthesizer>
	<CsOptions>
	-o "d:/2023-03-05_gd23-2.wav"
	</CsOptions>
	<CsInstruments>
		sr     = 48000
		kr     = 4800
		ksmps  = 10
		nchnls = 1
			
		instr 1
			ifreq=p4
			iamp = ampdb(79)
			a1 oscil3 iamp, ifreq, 1
	
			out a1
		endin
	</CsInstruments>
	<CsScore>
		f 1 0 16384 10 1
		i 1 0 3600 6.24609375
		i 1 0 3600 9.3359375
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

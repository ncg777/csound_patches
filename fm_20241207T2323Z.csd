<CsoundSynthesizer>
	<CsOptions>
	-o d:/fm_20241207T2323Z.wav
	</CsOptions>
	<CsInstruments>
		sr     = 48000
		kr     = 4800
		ksmps  = 10
		nchnls = 1
			
		instr 1
			ifreq=p4
			ilfofreq=p5
			iamp = ampdb(89)
			alfo oscil 1, ilfofreq, 1
			a1 oscil3 iamp, ifreq*(1+((0.5+(alfo*0.498)))), 1
	
			out a1
		endin
	</CsInstruments>
	<CsScore>
		f 1 0 16384 10 2 1
		i 1 0 3601 27.5 1.041666666666666666666
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

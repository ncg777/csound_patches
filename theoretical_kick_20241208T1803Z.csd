<CsoundSynthesizer>
	<CsOptions>
	-o "90 bpm 1 bar theoretical kick loop.wav"
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
			klfo oscil 1, ilfofreq, 2
			alfo1 pow a(2.0), 3*klfo
			a1 oscil3 iamp, ifreq*alfo1, 1
	
			out a1
		endin
	</CsInstruments>
	<CsScore>
		f 1 0 16384 10 1
		f 2 0 16384 7 1 16384 -1
		i 1 0 2.66666666667 30 1.5
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

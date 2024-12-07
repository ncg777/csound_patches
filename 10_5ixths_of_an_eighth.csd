<CsoundSynthesizer>
	<CsOptions>
	-o d:/10_5ixths_of_an_eighth.ogg
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
			alfo = alfo*alfo*alfo
			a1 oscil3 iamp, ifreq, 1

			out a1*alfo
		endin
	</CsInstruments>

	<CsScore>
		f 1 0 16384 10 16 8 4 2
		i 1 0 3601 27.5 1.6666666666666666
		e
	</CsScore>
</CsoundSynthesizer>

<MacGUI>
ioView nobackground {65535, 65535, 65535}
</MacGUI>














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

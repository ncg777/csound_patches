<CsoundSynthesizer>


<CsOptions>
-o d:/5ixth.wav
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
		a0 oscil3 iamp, ifreq, 1

		out a0*alfo
	endin
	

</CsInstruments>


<CsScore>
	f 1 0 16384 10 1 0 0 0
	i 1 0 1800 27.5 0.8333333333333333333
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

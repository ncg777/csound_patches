<CsoundSynthesizer>
<CsOptions>

-o "d:/alarme.wav"

</CsOptions>
<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 1

	instr 1
		ifreq=p4
		ilfofreq=p5
		alfo oscil 1100, ilfofreq, 2
		a1 oscil 0dbfs, ifreq+alfo, 1

		outs a1
	endin

</CsInstruments>
<CsScore>
f 1 0 1024 7 1 512 1 0 -1 512 -1
f 2 0 1024 7 -1 1024 1

i 1 0 5 1300 3


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

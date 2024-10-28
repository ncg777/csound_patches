<CsoundSynthesizer>


<CsOptions>
-o c:\noise.wav
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2

	instr 1
		a1 noise 32767, p4
		a2 noise 32767, p4
		outs a1, a2
	endin

</CsInstruments>


<CsScore>
	i 1 0 5 0.8
</CsScore>


</CsoundSynthesizer>
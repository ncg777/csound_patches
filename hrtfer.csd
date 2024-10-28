<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>
	sr     = 44100
	kr     = 44100
	ksmps  = 1
	nchnls = 2
	instr 1

		a1 oscil 32767, 500, 1
		al, ar hrtfer a1,p4, p5, "HRTFcompact"

		outs al, ar
	endin
</CsInstruments>

<CsScore>
	f 1 0 16384 10 1

	i 1 0 1 0 0
	i 1 1 1 < 0
	i 1 2 1 < 0
	i 1 3 1 < 0
	i 1 4 1 < 0
	i 1 5 1 < 0
	i 1 6 1 < 0
	i 1 7 1 < 0
	i 1 8 1 < 0
	i 1 9 1 45 0
		

</CsScore>
</CsoundSynthesizer>

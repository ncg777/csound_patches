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
		kenv loopseg p7, 0, 0, 1, 0.5, 1, 0.08, 0, 0.5, 0, 0.08,1

		klfo lfo 1, p8

		iamp=0.96

		al buzz 0dbfs*iamp, p4+(p5*klfo), p6, 1
		ar buzz 0dbfs*iamp, p4-(p5*klfo), p6, 1
		
		al=al*kenv
		ar=ar*kenv

		outs al, ar

	endin

</CsInstruments>


<CsScore>
	f 1 0 16384 10 1

	i 1 0 8 2000 4 1 10 0.0083
	e
</CsScore>


</CsoundSynthesizer>
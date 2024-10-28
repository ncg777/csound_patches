<CsoundSynthesizer>


<CsOptions>
-o dac
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 1


	instr 1
		a1 oscil 1, p4, 1
		a2 table a1, 2, 1
		a2=a2*32767
		out a2
	endin

</CsInstruments>


<CsScore>
	f 1 0 2049 10 1
	f 2 0 65536 13 1 1 0 0 1 0 0 1 0 0 1

	i 1 0 1 440
	i 1 2 1 660
	i 1 4 1 880

</CsScore>


</CsoundSynthesizer>
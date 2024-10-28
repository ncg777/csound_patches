<CsoundSynthesizer>


<CsOptions>
-o dac -M0
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2
	massign 1,1

	instr 1
		kctl midictrl 1
		gkctl=((kctl/127)*2)-0.99999
		icps cpsmidi
		aenv madsr 0.1,0.01,1,0.2
		aout oscil 1, icps,1
		ga1=aout*0dbfs*aenv
	
	endin

	instr 2
		aout init 0
		aout delay ga1+(0.99*aout), 0.05
		
		outs (aout+ga1)*gkctl, (aout+ga1)*gkctl
	endin

</CsInstruments>


<CsScore>
f 1 0 16384 10 1
i 2 0 10
</CsScore>


</CsoundSynthesizer>
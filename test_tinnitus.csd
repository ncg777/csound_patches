<CsoundSynthesizer>


<CsOptions>
-o dac

</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2

#include "my_udos.inc"

	instr 1

		a1 noiseband p4-p6, p5
		a2 noiseband p4+p6, p5

		a1=a1*0dbfs
		a2=a2*0dbfs

		outs a1, a2
	endin


</CsInstruments>


<CsScore>

i 1 0 880 110 480 2.3

</CsScore>


</CsoundSynthesizer>
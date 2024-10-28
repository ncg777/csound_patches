<CsoundSynthesizer>


<CsOptions>
-o dac -M0
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 44100
	ksmps  = 1
	nchnls = 2

	massign 1,1
#include "my_udos.inc"

instr 1

	aenv madsr 0.01, 0, 1, 0.5

	ifreq cpsmidi
	imfreq = ifreq/4

	iamp= 0dbfs*(8/8)
	amod oscil 0.3, imfreq,2

	amod = amod+0.5

	aa =amod
	ab =1-amod

	apw = ab

	ap phasor ifreq
	ap1 wrap ap+apw, 0, 1

	as = ap-ap1+apw

	ama = ifreq*0.5/aa
	amb = ifreq*0.5/ab

	ad = (amb-ama)*as+ama
	ao integ ad/sr
	ao wrap ao, 0, 1

	aout tablei ao, 1,1

	al = aout*iamp*aenv
	ar = -aout*iamp*aenv

	outs ar,al
endin
</CsInstruments>


<CsScore>
f 1 0 16385 10 1
f 2 0 16385 7 -1 8192 1 8192 -1 

f 0 400


</CsScore>


</CsoundSynthesizer>
<CsoundSynthesizer>


<CsOptions>
0 -Z -3 -b 2048
</CsOptions>


<CsInstruments>

sr = 44100
kr = 44100
ksmps = 1
nchnls = 2

massign 1,1

opcode train, a, aaaa
	afreq, apw, aph, async xin
	ap, apipi syncphasor -afreq, async
	ap wrap ap+aph, 0, 1
	ap1 wrap ap+apw, 0,  1
	aout clip (ap-ap1)+apw, 0, 1
	xout aout

endop

instr 1
	iamp ampmidi 1
	aenv madsr 0.01, 0, 1, 0.1

	ifreq cpsmidi
	
	imfreq = ifreq/16

	apipi, as syncphasor ifreq, a(k(0)),0

	aap phasor imfreq, 0
	abp phasor imfreq, 0.25
	acp phasor imfreq, 0.5
	adp phasor imfreq, 0.75

	aa tablei aap, 5,1
	ab tablei abp, 5,1
	ac tablei acp, 5,1
	ad tablei adp, 5,1



	apa train a(k(ifreq)), aa, a(k(0)), as
	apb train a(k(ifreq)), ab, aa, as
	apc train a(k(ifreq)), ac, aa+ab, as
	apd train a(k(ifreq)), ad, aa+ab+ac, as

	apa = apa*ifreq*0.25/aa
	apb = apb*ifreq*0.25/ab
	apc = apc*ifreq*0.25/ac
	apd = apd*ifreq*0.25/ad



	ao, apipi syncphasor (apa+apb+apc+apd), as


	
	aout = ((ao*2)-1)*iamp
	aout tablei (aout/2),6, 1,0.5,1

	al = aout*0dbfs*(4/8)*aenv
	ar = aout*0dbfs*(4/8)*aenv

	outs al,ar

endin

</CsInstruments>


<CsScore>
f 1 0 16385 10 1
f 2 0 16385 7 0.2 8192 0.8 8192 0.2 
f 3 0 16385 8 1 8 -1 8 1 16 -1 32 1 64 -1 128 1 256 -1 512 1 1024 -1 2048 1 4096 0 4096 -1 2048 1 1024 -1 512 1 256 -1 128 1 64 -1 32 1 16 -1 8 1 8 -1   
f 4 0 16385 10 1 1 0 1 0 1
f 5 0 16385 7 0.01 8192 0.99 8192 0.01 
f 6 0 16385 7 -1 8192 1 8192 -1 
f 7 9

</CsScore>


</CsoundSynthesizer>
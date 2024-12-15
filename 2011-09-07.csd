<CsoundSynthesizer>


<CsOptions>
-o dac -M0 -Z -3
</CsOptions>


<CsInstruments>

sr = 44100
kr = 4410
ksmps = 10
nchnls = 2

massign 1,1

#include "my_udos.inc"



instr 1
	iamp ampmidi 1
	aenv madsr 0.01, 0, 1, 0.01

	ifreq cpsmidi
	ifreq = ifreq/2
	
	aa init 0.125
	ab init 0.25
	ac init 0.0625
	ad init 0.5625


	apa train a(k(ifreq)), aa, a(k(0))
	apb train a(k(ifreq)), ab, aa
	apc train a(k(ifreq)), ac, aa+ab
	apd train a(k(ifreq)), ad, aa+ab+ac

	apa = apa*ifreq*0.25/aa
	apb = apb*ifreq*0.25/ab
	apc = apc*ifreq*0.25/ac
	apd = apd*ifreq*0.25/ad

	apipi, as1 syncphasor ifreq*4, a(k(0))
	apipi, as2 syncphasor ifreq*2, a(k(0))
	apipi, as3 syncphasor ifreq*3, a(k(0))

	ao1, adummy syncphasor (apa+apb+apc+apd), as1
	ao2, adummy syncphasor (apa+apb+apc+apd), as2
	ao3, adummy syncphasor (apa+apb+apc+apd), as3

	
	aout1 = ((ao1*2)-1)*iamp
	aout1 tablei (aout1/2),1, 3,0.5,1

	aout2 = ((ao2*2)-1)*iamp
	aout2 tablei (aout2/2),1, 3,0.5,1

	aout3 = ((ao3*2)-1)*iamp
	aout3 tablei (aout3/2),4, 3,0.5,1
	aout3=(aout3+1)/2

	aout = (aout1+aout2)*aout3
	
	amodl oscil 1, ifreq/128, 1
	amodl = (amodl+2)/3
	amodr oscil 1, ifreq/128, 1,0.5
	amodr = (amodr+2)/3

	aoutl flanger (aout1+aout2), amodl/1000, 0, 2
	aoutr flanger (aout1+aout2), amodr/1000, 0, 2
	aoutl = aoutl*aout3
	aoutr = aoutr*aout3

	aoutl = aoutl+0.2*aoutr
	aoutr = aoutr+0.2*aoutl

	aoutl clip aoutl, 2, 1
	aoutr clip aoutr, 2, 1
	al = aoutl*0dbfs*(4/8)
	ar = aoutr*0dbfs*(4/8)

	outs al,ar

endin

</CsInstruments>


<CsScore>
f 1 0 16385 10 1
f 2 0 16385 7 0.2 8192 0.8 8192 0.2 
f 3 0 16385 8 1 8 -1 8 1 16 -1 32 1 64 -1 128 1 256 -1 512 1 1024 -1 2048 1 4096 0 4096 -1 2048 1 1024 -1 512 1 256 -1 128 1 64 -1 32 1 16 -1 8 1 8 -1   
f 4 0 16385 10 1 1 0 1 0 1
f 5 5000

</CsScore>


</CsoundSynthesizer>
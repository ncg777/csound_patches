<CsoundSynthesizer>


<CsOptions>
-o d:/20110911.wav --midi-key-oct=4 --midi-velocity=5 -F 8oct.mid -Z -3 
</CsOptions>


<CsInstruments>

sr = 44100
kr = 44100
ksmps = 1
nchnls = 2

massign 1,1

#include "d:/musique/mus_csound/my_udos.inc"

instr 1
	iamp = p5/127

	aenv madsr 0.01, 0, 1, 0.1

	ifreq = cpsoct(p4)
	
	imfreq = ifreq/2
	
	ab1 buzz 1, ifreq, 16, 1
	ab2 buzz 1, ifreq*2, 8, 1
	ab3 buzz 1, ifreq*3, 5, 1
	ab4 buzz 1, ifreq/4, 4, 1

	ab3 = (ab3+1)/2
	ab=(ab1-ab2)*ab3+ab4

	kmod oscil 1, imfreq, 1

	kmod = kmod

	abp pdhalf ab,kmod, 1
 
	ab=ab-abp
	ab = (ab+1)/2
	ab table ab, 2, 1, 0.5, 1

	al = ab*aenv*(7/8)*0dbfs
	ar=al

	outs al, ar

endin



</CsInstruments>

<CsScore>
f 1 0 16385 10 1
f 2 0 16384 6 -1 2048 0.25 2048 -1 4096 0 4096 1 2048 -0.25 2048 1
f 3 62

</CsScore>


</CsoundSynthesizer>
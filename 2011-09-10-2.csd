<CsoundSynthesizer>


<CsOptions>
-o dac -+rtmidi=null -M0 -n -d --midi-key-oct=4 --midi-velocity=5
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
	kmod1 lfo 0.5, imfreq
	kmod2 lfo 0.5, imfreq/2
	kmod3 lfo 0.5, imfreq/4

	kmod1=kmod1+0.5
	kmod2=kmod2+0.5
	kmod3=kmod3+0.5

	aph1 phasor ifreq
	aph2 phasor ifreq, 0.5

	at1 table aph1, 7, 1
	at2 table aph2, 7, 1
	
	at1 pdhalf at1, kmod1
	at2 pdhalf at2, kmod2

	at1 = at1*0.5
	at2 = (at2*0.5)+0.5

	ao pdhalf at1+at2, kmod3
	aout1 tablei ao, 1,1,0.5,1
	aout2 tablei ao, 8,1,0.5,1

	al = (aout1+aout2)*0dbfs*(4/8)*aenv
	ar = (aout1+aout2)*0dbfs*(4/8)*aenv

	outs al, ar

endin



</CsInstruments>

<CsScore>
f 1 0 16385 10 1
f 2 0 16385 7 0.2 8192 0.8 8192 0.2 
f 3 0 16385 8 1 8 -1 8 1 16 -1 32 1 64 -1 128 1 256 -1 512 1 1024 -1 2048 1 4096 0 4096 -1 2048 1 1024 -1 512 1 256 -1 128 1 64 -1 32 1 16 -1 8 1 8 -1   
f 4 0 16385 10 1 1 0 1 0 1
f 5 0 16385 7 0.01 8192 0.99 8192 0.01 
f 6 0 16385 7 -1 8192 1 8192 -1 
f 7 0 16385 7 0 8192 1 0 0 8192 0 
f 8 0 16385 10 0 1


</CsScore>


</CsoundSynthesizer>
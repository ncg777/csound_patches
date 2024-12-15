<CsoundSynthesizer>


<CsOptions>
-o d:/20110910.wav -F 8oct.mid -Z -3
</CsOptions>


<CsInstruments>

sr = 44100
kr = 44100
ksmps = 1
nchnls = 2

massign 1,1

instr 1
	iamp ampmidi 1
	aenv madsr 0.01, 0, 1, 0.1

	ifreq cpsmidi

	imfreq = ifreq/4

	kmodf lfo 3, imfreq/2,4

	kmodf = kmodf+4
	kmod1 lfo 0.5, kmodf*imfreq,4
	kmod2 lfo 0.5, imfreq,4

	kmod1 = kmod1+0.5
	kmod2 = kmod2+0.5

	kmod1=kmod1*kmod2

	aph1 phasor ifreq

	ao pdhalf aph1, kmod1

	aout1 tablei ao, 1, 1,0.5,1
	aout2 tablei ao, 2, 1,0.5,1
	aout3 tablei ao, 3, 1,0.5,1
	aout = (((aout2+1)/2)*aout1)

	aout reson aout+aout1+aout2, k(ifreq), ifreq/2, 1
	aout = aout3*((aout+1)/2)

	aout = (aout+1)/2

	aout pdhalf aout, kmod1
	aout tablei aout, 1, 1, 0.5, 1
	aout4 tablei aout, 2, 1, 0.5, 1	

	aout reson aout+aout1+aout2+aout4, k(ifreq), ifreq/2, 1

	aout balance aout, aout3
	aout clip aout, 0, 1/4

	aout = ((aout*4)+1)/2

	aout tablei aout, 1, 1, 0.5, 1
	aout tablei (aout+1)/2, 1, 1, 0.5, 1
	aout tablei (aout+1)/2, 2, 1, 0.5, 1
	aout tablei (aout+1)/2, 3, 1, 0.5, 1
	aout tablei (aout+1)/2, 2, 1, 0.5, 1
	aout tablei (aout+1)/2, 1, 1, 0.5, 1
	
	aout reson aout, k(ifreq), ifreq/2, 1
		
	al = aout*(8/8)*aenv*0dbfs
	ar = aout*(8/8)*aenv*0dbfs

	outs al,ar

endin



</CsInstruments>

<CsScore>
f 1 0 16385 10 1
f 2 0 16385 10 0 1
f 3 0 16385 7 -1 16384 1 


f 9 60

</CsScore>


</CsoundSynthesizer>
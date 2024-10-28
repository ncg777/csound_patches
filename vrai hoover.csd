<CsoundSynthesizer>


<CsOptions>

</CsOptions>


<CsInstruments>

sr = 44100
kr = 4410
ksmps = 10
nchnls = 2

massign 1,1

#include "my_udos.inc"



instr 1
	ivel veloc 0, 1
	iamp = ivel*0dbfs

	aenv madsr 0.01, 0, 1, 0.5

	ifreq cpsmidi
	imfreq = ifreq/2

	aa oscil 0.5, imfreq, 5, 0
	ab oscil 0.5, imfreq, 5, 0.25
	ac oscil 0.5, imfreq, 5, 0.5
	ad oscil 0.5, imfreq, 5, 0.75


	apa train a(k(ifreq)), aa, a(k(0))
	apb train a(k(ifreq)), ab, aa
	apc train a(k(ifreq)), ac, aa+ab
	apd train a(k(ifreq)), ad, aa+ab+ac

	apa = apa*ifreq*0.25/aa
	apb = apb*ifreq*0.25/ab
	apc = apc*ifreq*0.25/ac
	apd = apd*ifreq*0.25/ad

	apipi, as syncphasor ifreq, a(k(0))

	ao, adummy syncphasor (apa+apb+apc+apd), as

	aout tablei ao,4, 1


	al = (aout)*iamp
	ar=al

	outs al,ar

endin

</CsInstruments>


<CsScore>
f 1 0 16385 10 1
f 2 0 16385 7 0.2 8192 0.8 8192 0.2 
f 3 0 16385 7 -1 16384 1 
f 4 0 16385 "tanh" -2 2 0
f 5 0 16385 -24 4 0.1 0.9
f 6 17
</CsScore>


</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1280</x>
 <y>618</y>
 <width>400</width>
 <height>354</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacGUI>
ioView nobackground {65535, 65535, 65535}
</MacGUI>

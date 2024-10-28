<CsoundSynthesizer>


<CsOptions>

</CsOptions>

<CsInstruments>

	sr     = 44100
	kr     = 44100
	ksmps  = 1
	nchnls = 2
	
	instr 1
	
	kpitch1 linseg 0.0, p3, 1.0
	kamp1 linseg 1.0, p3, 1.0
	
	anoise1l unirand 2.0
	anoise1l = anoise1l - 1.0
	anoise2l pinkish anoise1l
	anoise2l = anoise2l*p9
	
	anoise1r unirand 2.0
	anoise1r = anoise1r- 1.0
	anoise2r pinkish anoise1r
	anoise2r = anoise2r*p9
	
	kpitch2 expcurve kpitch1, p10
	kpitch3 = ((kpitch2*(p5-p4)) + p4)
	
	kamp2 expcurve kamp1, p11
	kamp3l = kamp2
	kamp3r = kamp2
	
	aL foscili kamp3l, k(anoise2l)*kpitch3+kpitch3, p6, p7, p8, 1
	aR foscili kamp3r, k(anoise2r)*kpitch3+kpitch3, p6, p7, p8, 1
	outs aL*0dbfs, aR*0dbfs
	
	endin

</CsInstruments>


<CsScore>
f 1 0 16384 10 1

i 1 0 $dur $startfreq $endfreq $carfreq $modfreq $modindex $noiseamp $steeppch $steepamp

e

</CsScore>


</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
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

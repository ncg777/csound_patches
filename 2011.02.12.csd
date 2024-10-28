<CsoundSynthesizer>


<CsOptions>
-o dac
</CsOptions>


<CsInstruments>

sr = 44100
kr = 44100
ksmps = 1
nchnls = 2
#include "my_udos.inc"

instr 1
	iamp=ampdbfs(p4)
	ifreq=p5
	ipitch=p6
	idiff=p7
	ifn1=p8
	amod oscil3 1, 1/60, 1
	afmod oscil3 1, idiff,1
	al syncg a(k(1)), a(k(ifreq+idiff/2))+afmod*ifreq, a(k(ipitch))+amod*(ipitch/2), ifn1, 2
	ar syncg a(k(1)), a(k(ifreq-idiff/2))+afmod*ifreq, a(k(ipitch))+amod*(ipitch/2), ifn1, 2

	outs al*ar*iamp/2 +al*iamp/2, -ar*al*iamp/2+ar*iamp/2	
endin

</CsInstruments>


<CsScore>
f 1 0 16385 10 1 8 1
f 2 0 16385 20 6 1 1
f 3 0 4097 1 "D:\Music making\mus_samples\Drum Samples\Sequential Circuits TOM\Hat closed.wav" 0 4 1
f 4 0 4097 1 "D:\Music making\mus_samples\Drum Samples\Sequential Circuits TOM\Bassdrum.wav" 0 4 1
i 1 0 60 -5 11	 1 0.25 1
i 1 0 60 -5 4	 1 0.5 3
i 1 0 60 -5 2	 4 0.001 4
i 1 0 60 -5 0.5	 8 0.001 4

</CsScore>


</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>1280</x>
 <y>498</y>
 <width>400</width>
 <height>248</height>
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

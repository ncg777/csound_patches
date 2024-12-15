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
	ifreq=cpspch(p5)
	ipitch=p6
	a2 oscil3 1, 0.25, 1
	a2 = a2+1
	ap=1
	a1 syncg a(k(1)), a(k(ifreq)), a(k(ipitch)), 3, 2

	outs a1*iamp, a1*iamp
endin

</CsInstruments>


<CsScore>
f 1 0 16385 10 1
f 2 0 16385 20 1 1
f 3 0 1025 1 "d:/Music making/mus_samples/CPU/20030620-06-cpu.wav" 0 4 0


t 0 100
i 1 0 8 0 4.00 1.5


e
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

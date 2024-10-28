<CsoundSynthesizer>


<CsOptions>
-o dac -i adc
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 1
	inchnls=1
             alwayson "RealtimeEcho"
             
	instr RealtimeEcho
               adel init 0
	  ain in
	  adel delay ain+(adel*0.5), 0.1
	  out adel
	endin

</CsInstruments>


<CsScore>
  f 0 3600

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

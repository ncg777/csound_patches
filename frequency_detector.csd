<CsoundSynthesizer>

<CsOptions>
-i adc -o dac
</CsOptions>

<CsInstruments>

	sr     = 22050
	kr     = 50
	ksmps  = 441
	nchnls = 1
  nchnls_i = 1
  
	alwayson "MonoIn"
  alwayson "FrequencyActivation", 1400, 20, 1000
  alwayson "PlaySample", 1
  
  connect "MonoIn", "INPUT", "FrequencyActivation", "INPUT"
  connect "FrequencyActivation", "TRIGGER", "PlaySample", "TRIGGER"
  
	#include "instruments.inc"

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

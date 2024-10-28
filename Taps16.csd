<CsoundSynthesizer>

<CsOptions>
-o dac  -i adc
</CsOptions>

<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 1
	inchnls=1
	alwayson "Taps16"
             
	instr Taps16
	   a_in in
	   a_out init 0
	   i_div = 8
	   a0 = a_in * 0.3
	   a1 delay a0, 1/i_div
	   a2 delay a0+a1, 2/i_div
	   a3 delay a0+a1+a2, 4/i_div
	   a4 delay a0+a1+a2+a3, 8/i_div
	   a_out = a0+a1+a2+a3+a4
	    out a_out
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

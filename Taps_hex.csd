<CsoundSynthesizer>

<CsOptions>
-o "g:/ppl_loop.wav"
</CsOptions>

<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 1
	inchnls=1
	connect "Sampler", "O1", "Taps_hex", "I1"
	alwayson "Taps_hex"
	
             instr Sampler
	  a0 diskin "g:/ppl.wav", 1, 0, 1
	  outleta "O1", a0	             
             endin
             
	instr Taps_hex
	   a_in inleta "I1"
	   a_out init 0
	   i_div = 8
	   a0 = a_in * 0.15
	   a1 delay a0, 1/i_div
	   a2 delay a0, 5/i_div
	   a3 delay a0, 9/i_div
	   a4 delay a0, 10/i_div

	   a_out = a0+a1+a2+a3+a4
	    out a_out
	endin

</CsInstruments>


<CsScore>
	f 0 3600
	#define W #"g:/ppl.wav"#	
	i "Sampler" 0 3600
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

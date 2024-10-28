<CsoundSynthesizer>


<CsOptions>
-o dac
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2

  gihandle OSCinit 8000
  
  alwayson "osc_input"
  
  instr osc_input
    
    kf1 init 0
    kf2 init 0
    kk  OSClisten gihandle, "/1/rotary1", "f", kf1
    if kk == 1 then
      printk 0,kf1
    endif

  endin
  
</CsInstruments>


<CsScore>
  f 0 3600
	f 1 0 16384 10 1
	f 2 0 16384 27 0 1 16384 -1
	f 3 0 16384 27 0 1 8192 -1 16384 1
	f 4 0 16384 27 0 1 8191 1 8192 -1 16384 -1

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

<CsoundSynthesizer>
<CsOptions>
-b 4096 -o dac
</CsOptions>
<CsInstruments>

  sr     = 22050
  kr     = 50
  ksmps  = 441
  nchnls = 1

  gihandle OSCinit 8000
  alwayson "A1" 
  
  #include "./my_udos.inc"
  
  instr A1
    k_amp init -6
    k_ratio init 1
    i_period = 2
    a_p1 mpulse 1, i_period, 0
    a_p2 mpulse 1, i_period, i_period/2
    a_index0 trigger_counter a_p1, 2*($N-1)
    a_index mirror a_index0, 0, $N-1
    
    k_dummy0  OSClisten gihandle, "/1/fader1", "f", k_amp
    k_dummy1  OSClisten gihandle, "/1/fader2", "f", k_ratio
    
    idur = 4*i_period
    schedkwhen k(a_p1), k(-1), k(-1), "tone1", 0, idur,  k(a_index), k_amp, k_ratio/1000

  endin


  instr tone1
    iC1 = $C1
    iC2 = $C2
    ip pow 2, p4
    icfreq = (ip*iC1)+iC2
    
    aenv expseg 0.001,p6*p3,1.0,(1.0-p6)*p3,0.001
    a_mod oscil3 0.1, 1,1
    a0 oscil3 1, icfreq, 6
    
    out a0*0dbfs*aenv*(0.9+a_mod)*ampdb(p5)
  endin

</CsInstruments>


<CsScore>
  f 0 36000
  f 1 0 16384 10 1
  f 2 0 16384 27 0 1 16384 -1
  f 3 0 16384 27 0 1 8192 -1 16384 1
  f 4 0 16384 27 0 1 8191 1 8192 -1 16384 -1
  f 5 0 16384 10 1
  f 6 0 16384 10 1
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

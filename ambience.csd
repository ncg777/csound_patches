<CsoundSynthesizer>
<CsOptions>
-b 1024 -o dac
</CsOptions>
<CsInstruments>
  #define FADEIN #60#
  #define SUSTAIN #600#
  #define FADEOUT #60#
  
	sr     = 22050
	kr     = 50
	ksmps  = 441
	nchnls = 1
  
  alwayson "Trigger", $FADEIN, $SUSTAIN, $FADEOUT
  
  instr Trigger
    a_pulse mpulse 1, p4+p5
    schedkwhen k(a_pulse), k(-1), k(-1), "Sequencer", 0, p4+p5+p6, p4, p5, p6
  endin
  
  instr Sequencer
    k_amp linseg 0, p4, 1, p5, 1, p6, 0

    kosc_z oscil3 1, 0.01, 5
    kosc = (sininv(kosc_z)/$M_PI_2)
    i_k = $N
    i_k_h = i_k/2.0
    i_k_d = i_k*2.0
    kosc0 = (kosc*i_k_h)+i_k_h
    kosc1 = (kosc*i_k_d)+i_k_d
    ktrigger0 trigger kosc0-floor(kosc0), 0.5, 1
    ktrigger1 trigger kosc1-floor(kosc1), 0.5, 1
    
    idur = 0.25
    schedkwhen ktrigger0, k(-1), k(-1), "tone1", 0, idur, floor(kosc0), k_amp
    schedkwhen ktrigger1, k(-1), k(-1), "tone1", 0, idur, floor(kosc1%i_k), k_amp
  endin


  instr tone1
    i_e1 unirand 2
    i_e2 unirand 2
    iC1 = $C1 + i_e1 -1
    iC2 = $C2 + i_e2 -1
    ip pow 2, p4
    icfreq = (ip*iC1)+iC2
    
    aenv expseg 0.001,0.01*p3,1.0,0.99*p3,0.001
    a_mod oscil3 0.15, 15, 1
    a0 oscil3 1, icfreq, 6
    
    out a0*aenv*(0.85+a_mod)*p5*ampdb(-12)*0dbfs
  endin
</CsInstruments>


<CsScore>

  f 0 36000
	f 1 0 16384 10 1
	f 2 0 16384 27 0 1 16384 -1
	f 3 0 16384 27 0 1 8192 -1 16384 1
	f 4 0 16384 27 0 1 8191 1 8192 -1 16384 -1
  f 5 0 16384 10 1 1 0 1
  f 6 0 16384 10 3 0 2 0 1
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

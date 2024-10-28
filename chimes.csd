<CsoundSynthesizer>
<CsOptions>
-b 1024 -o dac
</CsOptions>
<CsInstruments>

	sr     = 22050
	kr     = 50
	ksmps  = 441
	nchnls = 1

  alwayson "Chimes" 
  
  instr Chimes
    seed 0
    i_ubound = 8
    ktrigger init 0
    k_exp init 0
    k_x init 0

    krnd unirand 1.0
    
    i_mean_delay = 7
    i_lambda = 1.0/(i_mean_delay)
    i_len = 6
    
    k_exp = (1.0/i_lambda)*(exp(-i_lambda*(k_x+1.0/kr)) - exp(-i_lambda*k_x))+(1.0/kr)
    
    ktrigger = (krnd < k_exp ? 1 : 0)
    
    k_x = (k_x+(1.0/kr))*((1.0-ktrigger))
    k_pitch_index unirand i_ubound+1
    schedkwhen ktrigger, k(-1), k(-1), "tone1", 0, i_len, floor(k_pitch_index)
    
  endin


	instr tone1
    iC1 = 4.6875
    iC2 = 235.3125
    ip pow 2, p4
    icfreq = (ip*iC1)+iC2
    
    aenv expseg 0.001,0.001*p3,1.0,0.999*p3,0.001
    a_mod oscil3 0.3, 5,1
    a0 oscil3 1, icfreq, 1
    
    out a0*0dbfs*aenv*(0.7+a_mod)*ampdb(-12)
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

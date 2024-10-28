<CsoundSynthesizer>


<CsOptions>
-o dac
</CsOptions>


<CsInstruments>

	sr     = 22050
	kr     = 50
	ksmps  = 441
	nchnls = 1
  alwayson "AO" 
  
  instr AO
    seed 0
    ktrigger init 0
    k_exp init 0
    k_x init 0

    krnd unirand 1.0
    
    i_mean_delay = 1800
    i_lambda = 1.0/(i_mean_delay)
    ilen filelen $MONOWAVE
    
    k_exp = (1.0/i_lambda)*(exp(-i_lambda*(k_x+1.0/kr)) - exp(-i_lambda*k_x))+(1.0/kr)
    
    ktrigger = (krnd < k_exp ? 1 : 0)
    
    k_x = (k_x+(1.0/kr))*((1.0-ktrigger))
    schedkwhen ktrigger, k(-1), k(-1), "Player", 0, ilen
    
  endin

	instr Player
	  aenv expseg 0.0001, p3*0.05,1,p3*0.9, 1, p3*0.05,0.0001
	  ao diskin $MONOWAVE, 1.0
	  out ao*aenv
	endin
  

</CsInstruments>


<CsScore>

  f 0 14400
  f 1 0 16384 10 1
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

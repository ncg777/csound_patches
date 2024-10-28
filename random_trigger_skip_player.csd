<CsoundSynthesizer>


<CsOptions>
-o dac
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 100
	ksmps  = 441
	nchnls = 2
  alwayson "AO" 
  
  instr AO
    seed 0
    ktrigger init 0
    k_exp init 0
    k_x init 0

    krnd unirand 1.0
    
    i_mean_delay = 90
    i_lambda = 1.0/(i_mean_delay)
    i_len filelen $STEREOWAVE
    
    k_exp = (1.0/i_lambda)*(exp(-i_lambda*(k_x+1.0/kr)) - exp(-i_lambda*k_x))+(1.0/kr)
    
    ktrigger = (krnd < k_exp ? 1 : 0)
    
    k_x = (k_x+(1.0/kr))*((1.0-ktrigger))
    k_dur unirand 10
    schedkwhen ktrigger, k(-1), k(-1), "SkipPlayer", 0, k_dur+1, i_len
    
  endin
  
 
  instr SkipPlayer
    i_skiptime unirand p4-i(p3)
	  aenv expseg 0.0001, p3*0.1,1,p3*0.8, 1, p3*0.1,0.0001
	  aL, aR diskin $STEREOWAVE, 1.0, i_skiptime
	  
	  kmax = ampdbfs(-1)
	  kpeak1 peak aL
	  kpeak2 peak aR
	  kpeak max kpeak1, kpeak2
	  kcoeff = kmax/kpeak
	  
	  out kcoeff*aL*aenv,kcoeff*aR*aenv
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

<CsoundSynthesizer>


<CsOptions>
-o dac

</CsOptions>


<CsInstruments>

	sr     = 22050
	kr     = 441
	ksmps  = 50
	nchnls = 1

opcode brownian_noise, a, a
  aderamp xin
  awnoise0 noise aderamp, 0
  abnoise1 integ awnoise0
  abnoise mirror abnoise1, -1, 1
  xout abnoise
endop
  alwayson "AO" 
  instr AO
    krnd rand 1,2
    i_dur = 10
    ktrigger trigger krnd, 0.995, 0
    schedkwhen ktrigger, k(-1), k(-1), "Flat", 0, i_dur
  endin
  
	instr Flat
    i_a random 10,50
    i_b random 1,10
    i_dur random 1, 3
    a_noise0 brownian_noise a(0.01)
    a_noise butterbp a_noise0, 1000,1000
    
    a_exp expseg 1, i_dur, 0.001
    a_freq = i_a+(i_b-i_a)*a_exp
    a_mod oscil3 0.5, a_freq, 2
    a_mod = a_mod+0.5
    a_out = a_mod*a_noise*0dbfs*a_exp
    
		out a_out
	endin


</CsInstruments>


<CsScore>
	f 1 0 16384 10 1
	f 2 0 16384 27 0 1 16384 -1
	f 3 0 16384 27 0 1 8192 -1 16384 1
	f 4 0 16384 27 0 1 8191 1 8192 -1 16384 -1
  
  i 1 0 3600

</CsScore>


</CsoundSynthesizer>

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
    kosc oscil3 1, 0.06, 3
    ktrigger0 trigger kosc, 0.99, 1
    ktrigger1 trigger kosc, 0, 2
    ktrigger2 trigger kosc, -0.99, 0
    ktrigger3 trigger kosc, 0.5,2
    idur = 8
    schedkwhen ktrigger0, k(-1), k(-1), "tone", 0, idur, 400
    schedkwhen ktrigger1, k(-1), k(-1), "tone", 0, idur*0.5, 360
    schedkwhen ktrigger2, k(-1), k(-1), "tone", 0, idur, 320
    schedkwhen ktrigger3, k(-1), k(-1), "tone", 0, idur*0.25, 1600
  endin
  
	instr tone
    aenv expseg 0.001,0.001*p3,1.0,0.999*p3,0.001
    a_mod oscil3 0.3, 3,1
    a0 oscil3 1, p4, 1
    
    out a0*0dbfs*aenv*(0.7+a_mod)
  endin


</CsInstruments>


<CsScore>
        f 0 360000
	f 1 0 16384 10 1
	f 2 0 16384 27 0 1 16384 -1
	f 3 0 16384 27 0 1 8192 -1 16384 1
	f 4 0 16384 27 0 1 8191 1 8192 -1 16384 -1
 

</CsScore>


</CsoundSynthesizer>

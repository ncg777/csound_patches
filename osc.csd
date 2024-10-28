<CsoundSynthesizer>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2

	instr 1

		iamp=0dbfs
    a0 oscil3 1, p4, p5
    aL = a0
    aR = a0
		outs aL*iamp, aR*iamp

	endin


</CsInstruments>


<CsScore>
	f 1 0 16384 10 1
	f 2 0 16384 27 0 1 16384 -1
	f 3 0 16384 27 0 1 8192 -1 16384 1
	f 4 0 16384 27 0 1 8191 1 8192 -1 16384 -1
  
	i 1 0 $DUR $FREQ $FN
	e
</CsScore>


</CsoundSynthesizer>


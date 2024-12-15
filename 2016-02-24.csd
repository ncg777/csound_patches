<CsoundSynthesizer>
<CsOptions>
-o "d:/2.13337 2.wav"
</CsOptions>
<CsInstruments>
	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 1

	instr 1
		ifreq=p4
		iwave=p5
		iamp=ampdb(p6)
	             						
		a0 oscil 1, ifreq, iwave

		outs a0*iamp, a0*iamp
	endin

	instr 2	
	             iamp = ampdb(p5)	
		a0 noise 1, 0
		a1 noise 1, 0
		af0 lowpass2 a0, p4, 400
		af1 lowpass2 a1, p4, 400

		outs af0*iamp, af1*iamp
	endin
	
	instr 3
	     ifreq = p4
	     ioffset = p5
	     iamp = ampdb(p6)	
	     a0 mpulse 1, 1/ifreq,ioffset/ifreq
	     outs a0*iamp,a0*iamp			
	endin
</CsInstruments>
<CsScore>
	f 1 0 16384 10 1
	f 2 0 16384 27 0 -1 16384 1
	f 3 0 16384 27 0 1 8192 -1 16384 1
	f 4 0 16384 27 0 1 8191 1 8192 -1 16384 -1
	i 1 0 7200 22 1 75
	i 1 0 7200 24.13337 1 75
      i 1 0 7200 88 4 50
	i 1 0 7200 90.13337 4 50
	i 1 0 7200 176 2 45
	i 1 0 7200 178.13337 2 45
	i 1 0 7200 352 3 40
	i 1 0 7200 354.13337 3 40
	
	i 3 0 7200 2.13337 0 75
	i 3 0 7200 4.26674 0 70
	i 3 0 7200 8.53348 0 70
      i 3 0 7200 17.06696 0.125 65
	e
</CsScore>
</CsoundSynthesizer>
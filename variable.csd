<CsoundSynthesizer>
<CsOptions>
-b 1024 -o dac
</CsOptions>
<CsInstruments>

	sr     = 22050
	kr     = 50
	ksmps  = 441
	nchnls = 1

  instr Sequencer
    k_amp linseg 0, p4, 1, p5, 1, p6, 0

    kosc oscil3 1, 0.05, 2
    i_k = $N
    i_k_h = i_k/2.0
    i_k_d = i_k*2.0
    kosc0 = (kosc*i_k_h)+i_k_h
    kosc1 = (kosc*i_k_d)+i_k_d
    ktrigger0 trigger kosc0-floor(kosc0), 0.5, 1
    ktrigger1 trigger kosc1-floor(kosc1), 0.5, 1
    
    idur = 2
    schedkwhen ktrigger0, k(-1), k(-1), "tone1", 0, idur, floor(kosc0), k_amp
    schedkwhen ktrigger1, k(-1), k(-1), "tone1", 0, idur, floor(kosc1%i_k), k_amp
  endin

  instr tone1
    iC1 = $C1
    iC2 = $C2
    ip pow 2, p4
    icfreq = (ip*iC1)+iC2
    
    aenv expseg 0.001,0.001*p3,1.0,0.999*p3,0.001
    a_mod oscil3 0.3, 10,1
    a0 oscil3 1, icfreq, 1
    
    out a0*aenv*(0.7+a_mod)*p5*ampdb(-12)*0dbfs
  endin
</CsInstruments>
<CsScore>
  
	f 1 0 16384 10 1
	f 2 0 16384 27 0 1 16384 -1
	f 3 0 16384 27 0 1 8192 -1 16384 1
	f 4 0 16384 27 0 1 8191 1 8192 -1 16384 -1
  
        i "Sequencer" 0 [$FADEIN+$SUSTAIN+$FADEOUT] $FADEIN $SUSTAIN $FADEOUT
	e
</CsScore>
</CsoundSynthesizer>
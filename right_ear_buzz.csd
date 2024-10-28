<CsoundSynthesizer>


<CsOptions>
-o "d:/right_ear_buzz.wav"

</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2

#include "my_udos.inc"

	instr 1
    a_flat init 0
		a_noise brownian_noise a(0.1)
    a_tone oscil3 1, 4000, 1
		a_low oscil3 1, 40, 2

    a_filtered_noise butterbp a_noise, 400, 40
    a_out = a_filtered_noise+a_tone+a_low
    
		outs a_flat, a_out*0dbfs
	endin


</CsInstruments>


<CsScore>
	f 1 0 16384 10 1
	f 2 0 16384 27 0 -1 16384 1
	f 3 0 16384 27 0 1 8192 -1 16384 1
	f 4 0 16384 27 0 1 8191 1 8192 -1 16384 -1
  
  i 1 0 3600

</CsScore>


</CsoundSynthesizer>
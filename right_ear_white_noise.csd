<CsoundSynthesizer>


<CsOptions>
-o "d:/right_ear_white_noise_03.wav"

</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2

#include "my_udos.inc"

	instr 1
    a_flat init 0
    
		a_noise noise 1, 0
    a_band butterbp a_noise, 880, 110
    a_hp butterhp a_noise, 7040
    a_low oscil3 1, 55, 4
    a_out = (a_band*90)+(a_hp*8)+(a_noise*0)+(a_low*0.75)
    
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
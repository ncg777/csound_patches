<CsoundSynthesizer>


<CsOptions>
-o e:\test.wav
</CsOptions>


<CsInstruments>

sr = 44100
kr = 44100
ksmps = 1
nchnls = 2

instr 1
	a1 phasor 1, 0
	a1=(a1+0.5)%1
	a1 = a1*0dbfs
	outs a1, a1
endin

</CsInstruments>


<CsScore>
i 1 0 3
</CsScore>


</CsoundSynthesizer>
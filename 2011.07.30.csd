<CsoundSynthesizer>


<CsOptions>
-o d:/20110730-2.15Hz.wav
</CsOptions>


<CsInstruments>

sr = 44100
kr = 4410
ksmps = 10
nchnls = 2

instr 1
	ifr 	= p4
	ifmf	= p5
	iamp	= ampdb(p6)

	afm oscil 1, ifmf, 1
	
	amixl oscil iamp, (afm*0.5)*ifr-(ifmf/2), 1
	amixr oscil iamp, (afm*0.5)*ifr+(ifmf/2), 1
	
	outs amixl, amixr
endin



</CsInstruments>


<CsScore>
f 1 0 16384 10 1


i 1 0 3600 24 2.15 60
i 1 0 3600 48 2.15 60
i 1 0 3600 96 2.15 60
i 1 0 3600 120 2.15 60
i 1 0 3600 240 2.15 60
i 1 0 3600 480 2.15 60
i 1 0 3600 720 2.15 60
i 1 0 3600 1440 2.15 60
i 1 0 3600 2880 2.15 60




</CsScore>


</CsoundSynthesizer>
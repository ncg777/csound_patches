<CsoundSynthesizer>


<CsOptions>
-o dac -M0
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2

	massign 1,1

instr 1
	aenv madsr 0.01, 0, 1, 0.4

	ifreq cpsmidi
	iamp= 0dbfs*(8/8)
	ap oscili 1, ifreq,1

	a1 tablei ap, 6, 1,0,1
	a2 tablei ap, 11, 1 ,0,1

	alfo oscili 1, ifreq*0.25, 1
	alfop powershape alfo, 2

	am1=alfop*a1 + (1.0-alfop)*a2
	am2=alfop*a2 + (1.0-alfop)*a1

	al tablei am1,1,1,0,1
	ar tablei am2,1,1,0,1

	al=al*iamp
	ar=ar*iamp


	outs al, ar

endin
</CsInstruments>


<CsScore>
f 1 0 16385 10 1

f 2 0 4096 16 0 	4096 -5 0.25
f 3 0 4096 16 0.25 	4096 -5 0.5
f 4 0 4096 16 0.5 	4096 -5 0.75
f 5 0 4096 16 0.75 	4096 -5 1

f 6 0 16384 18 2 0.25 0 4096 3 0.5 4096 8192 4 0.75 8192 12288 5 1 12288 16383

f 7 0 4096 16 0 	4096 5 0.25
f 8 0 4096 16 0.25 	4096 5 0.5
f 9 0 4096 16 0.5 	4096 5 0.75
f 10 0 4097 16 0.75 4096 5 1.0

f 11 0 16384 18 7 0.25 0 4096 8 0.5 4096 8192 9 0.75 8192 12288 10 1 12288 16383
f 12 0 16385 7 -1 16384 1 

f 0 100


</CsScore>


</CsoundSynthesizer>
<CsoundSynthesizer>


<CsOptions>
-F testcsound.mid -o C:\test.wav 
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2

	massign 1,1

	instr 1
		kamp=30000
		aenv madsr 0.01, 0, 1, 0.4
		ar1, ar2 loscil kamp, 1, 1, 1
		ar1=ar1*aenv
		ar2=ar2*aenv
		
		gar1=ar1
		gar2=ar2

	endin

	instr 2
	
		ar1, ar2 freeverb gar1, gar2, 0.9, 0.3
		outs ar1, ar2
	endin

</CsInstruments>


<CsScore>
f 1 0 0 1 "Cowbell.wav" 0 0 0
f 0 10
i 2 0 10

</CsScore>


</CsoundSynthesizer>
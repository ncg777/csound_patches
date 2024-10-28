<CsoundSynthesizer>


<CsOptions>
-F test.mid -Q 14;-iadc
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2

	massign 1, 1

	instr 1
		kstatus, kchan, kdata1, kdata2 midiin
		midiout kstatus, kchan, kdata1, kdata2
	endin
</CsInstruments>


<CsScore>
f 0 2
</CsScore>


</CsoundSynthesizer>
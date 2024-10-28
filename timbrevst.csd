<CsoundSynthesizer>
<CsOptions>
csound -m3 -f -h -+rtmidi=null -M0 --midi-key-oct=4 --midi-velocity=5 -d -n temp.orc temp.sco
</CsOptions>
<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2

	massign 1,1

	instr 1
		iamp=0dbfs/3
		iatt=0.01
		idec=0
		islev=1
		irel=0.2
		ifn=1
		icps cpsmidi
		kctl1 midictrl 1

		aenv madsr iatt, idec, islev, irel


		aph phasor icps
		aph=aph*(((3*kctl1)/127)+1)
		aout table aph, ifn, 1
		aout=aout*aenv*iamp
		outs aout, aout
	endin
</CsInstruments>
<CsScore>
f 0 17
f 1 0 16384 10 1



</CsScore>
</CsoundSynthesizer>

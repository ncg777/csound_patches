<CsoundSynthesizer>


<CsOptions>
-o dac
</CsOptions>


<CsInstruments>

sr = 44100
kr = 44100
ksmps = 1
nchnls = 2

instr 1
	iamp = p4
	ipch = cpspch(p5)
	ilfofreq = p6
	ilfoamp = p7
	kf lfo ilfoamp, ilfofreq,1
	kf table kf+1, 2,1
	kf=kf+1
	al vco 0.5, ipch*kf+ilfofreq/2.0, 3, 0.15
	ar vco 0.5, ipch*kf-ilfofreq/2.0, 3, 0.15
	al table 0.5+al, 2, 1
	ar table 0.5+ar, 2, 1
	al=al*iamp
	ar=ar*iamp
	ifilfreq = cpspch(p8)
	ifilband = cpspch(p9)
	al butterbp al, ifilfreq,ifilband
	ar butterbp ar, ifilfreq,ifilband

	outs al, ar
endin


</CsInstruments>


<CsScore>
f 1 0 16384 10 1
f 2 0 16384 3 -1 1 0 0 0 1.33333333333 -0.33333333333 /*(1.25) (-0.25)*/
/*f 2 0 16384 10 5 5 6 2 3 3*/

i 1 0 3600 12000 4.00 0.575 0.9 8.00 7.00
i 1 0 3600 12000 5.03 -0.575 0.9 8.00 7.00
i 1 0 3600 12000 5.06 1.15 0.9 7.00 7.00
i 1 0 3600 12000 6.09 -1.15 0.9 7.00 7.00
i 1 0 3600 15000 6.00 -2.3 0.9 8.00 7.00
i 1 0 3600 15000 7.03 2.3 0.9 8.00 7.00
i 1 0 3600 10000 7.06 -4.6 0.9 8.00 6.00
i 1 0 3600 10000 8.09 4.6 0.9 8.00 6.00
i 1 0 3600 10000 8.06 -9.2 0.9 9.00 6.00
i 1 0 3600 10000 9.09 9.2 0.9 9.00 6.00
e
</CsScore>


</CsoundSynthesizer>
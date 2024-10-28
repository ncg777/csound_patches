<CsoundSynthesizer>


<CsOptions>
-o e:\test.wav

</CsOptions>


<CsInstruments>

sr = 44100
kr = 44100
ksmps = 1
nchnls = 2

opcode Func,a,a
  asig xin
  xout  1/(1+asig^2)
endop


/* ar PAF kamp,kfun,kcf,kfshift,kbw,ifn
   ifn is a sine wave
*/
opcode PAF,a,kkkkki
  kamp,kfo,kfc,kfsh,kbw,itb xin
  kn = int(kfc/kfo)
  ka = (kfc - kfsh - kn*kfo)/kfo
  kg = exp(-kfo/kbw)
  afsh phasor kfsh
  aphs phasor  kfo/2
  a1 tablei 2*aphs*kn+afsh,itb,1,0.25,1
  a2 tablei 2*aphs*(kn+1)+afsh,itb,1,0.25,1
  asin tablei aphs, 1, 1, 0, 1
  amod Func 2*sqrt(kg)*asin/(1-kg)
  kscl = (1+kg)/(1-kg)
  acar = ka*a2+(1-ka)*a1       
  asig = kscl*amod*acar
  xout asig*kamp
endop

instr 1
	
	iamp = ampdbfs(p4)
	ifreq = cpspch(p5)
	ipitch = p6
	a1 PAF iamp,ifreq,ifreq*ipitch,0,100,1
	outs a1, a1
endin

</CsInstruments>


<CsScore>
f 1 0 16384 10 1
f 2 0 16384 20 1 1

i 1 0 3 -5 6.00 4

</CsScore>


</CsoundSynthesizer>
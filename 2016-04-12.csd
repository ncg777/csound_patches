<CsoundSynthesizer>
<CsOptions>
-o "d:/4mph 1.wav"
</CsOptions>
<CsInstruments>
	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 1

	instr 1
		ifreq=p4
		iwave=p5
		idelta=p6
		iamp=ampdb(p7)
	             						
		a0 oscil 1, ifreq, iwave
           a1 oscil 1, ifreq+idelta, iwave
		outs (a0+a1)*iamp, (a0+a1)*iamp
	endin

	
	instr 2	
	             iamp = ampdb(p5)	
		a0 noise 1, 0
		a1 noise 1, 0
		af0 lowpass2 a0, p4, 400
		af1 lowpass2 a1, p4, 400

		outs af0*iamp, af1*iamp
	endin
	
	instr 3
	     ifreq = p4
	     ioffset = p5
	     iamp = ampdb(p6)	
	     a0 mpulse 1, 1/ifreq,ioffset/ifreq
	     outs a0*iamp,a0*iamp			
	endin

</CsInstruments>
<CsScore>
#define V30 #1.8834#
#define V31 #1.9042742#
#define V32 #1.9253376#
#define V33 #1.9468614#
#define V34 #1.9691168#
#define V35 #1.992375#
#define V36 #2.0169072#
#define V37 #2.0429846#
#define V38 #2.0708784#
#define V39 #2.1008598#
#define V40 #2.1332#
#define length #10#

	f 1 0 16384 10 1
	f 2 0 16384 27 0 -1 16384 1
	f 3 0 16384 27 0 1 8192 -1 16384 1
	f 4 0 16384 27 0 1 8191 1 8192 -1 16384 -1
	i 1 0 $length 22 1 $V40 75
	i 1 0 $length 88 4 $V40 50
	i 1 0 $length 176 2 $V40 45
	i 1 0 $length 352 3 $V40 40

	
	i 3 0 $length $V40 0 75
	i 3 0 $length [2*$V40] 0 70
	i 3 0 $length [4*$V40] 0 70
      i 3 0 $length [8*$V40] 0.125 65
	e
</CsScore>

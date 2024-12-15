<CsoundSynthesizer>


<CsOptions>
-o "F:/2016.05.05 TM.wav"
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2
#include "my_udos.inc"

	instr 1
		ifreq=p4
		imodfreq=p5
		iwave=p6
		iamp=ampdb(p7)
		
		a0 oscil 0.5, ifreq, iwave

		alfo1 oscil 1.0, imodfreq, iwave
		
		ioffset = 4
		iindex = 99
		
	      alfo = alfo1*ioffset*(iindex)/100					

	      a1,a2 strat a0, a(ioffset)+alfo,a(ioffset)+alfo
	      a3,a4 strat a2, a(ioffset)+alfo,a(ioffset)+alfo
	      a5,a6 strat a4, a(ioffset)+alfo,a(ioffset)+alfo
	      a7,a8 strat a6, a(ioffset)+alfo,a(ioffset)+alfo
	      
	      aAdd = a1+a2+a3+a4+a5+a6+a7+a8
	      
            aL = aAdd
            aR = aAdd
            
		outs aL*iamp, aR*iamp
	endin

</CsInstruments>


<CsScore>
#define V #2.26#
#define length #7200#
#define n #5#
#define amp #70#
#define wave #2#

	f 1 0 16384 10 1
	f 2 0 16384 27 0 1 16384 -1
	f 3 0 16384 27 0 1 8192 -1 16384 1
	f 4 0 16384 27 0 1 8191 1 8192 -1 16384 -1
	i 1 0 $length [1*$n*$V]  $V $wave $amp
	i 1 0 $length [4*$n*$V]  [2*$V] $wave [$amp]
	e
</CsScore>


</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacGUI>
ioView nobackground {65535, 65535, 65535}
</MacGUI>

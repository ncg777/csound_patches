<CsoundSynthesizer>


<CsOptions>
-o "d:/4mph 2.wav"
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
	
	instr 4
	    iamp = ampdb(p4)
	    ideramp = p5
	    ilowfreq = p6
	    ihighfreq = p7
	    ilfofreq = p8
	    
	    klfo oscil 1, ilfofreq, 2
	    amod oscil 1,  ilowfreq+(klfo*(ihighfreq-ilowfreq)),1
	    
	    awnoise noise ideramp, 0
	    abnoise0 integ awnoise
	    abnoise1 integ -awnoise
	    abnoiseL mirror abnoise0, -1, 1
	    abnoiseR mirror abnoise1, -1, 1
	    
	    aoutL = amod*abnoiseL
	    aoutR = amod*abnoiseR
	    outs aoutL*iamp, aoutR*iamp
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
#define length #7200#

	f 1 0 16384 10 1
	f 2 0 16384 27 0 -1 16384 1
	f 3 0 16384 27 0 1 8192 -1 16384 1
	f 4 0 16384 27 0 1 8191 1 8192 -1 16384 -1
	i 4 0 $length 40 0.1 20 200 [$V40*8]
	i 4 0 $length 45 0.1 20 200 [$V40*4]
	i 4 0 $length 55 0.1 20 200 [$V40*2]
	i 4 0 $length 95 0.1 20 200 [$V40*1]
	i 4 0 $length 55 0.1 20 200 [$V40/2]
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

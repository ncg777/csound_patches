<CsoundSynthesizer>

<CsOptions>
-o "g:/2016.05.24-1.wav"
</CsOptions>

<CsInstruments>

	sr     = 44100
	kr     = 2205
	ksmps  = 20
	nchnls = 2
	
#include "my_udos.inc"

	instr 1
	  
	  ab brownian_noise a(p4)
	  ab1 butbp ab, p5, p6
	  ab2 butbp ab, p7, p8
	  ab3 butbp ab, p9, p10
	  ab4 butbp ab, p11, p12
	  ab5 butbp ab, p13, p14
	  ab6 butbp ab, p15, p16
	  
	  itfreq = p17
	  itamp = p18
	  
	  ipfreq = p19
	  ipamp = p20
	  
	  kt oscil3 itamp/2.0, itfreq, 1
	  kp oscil3 ipamp, ipfreq,  1
	  
	  aml octahedron_mixer ab1,ab2,ab3,ab4,ab5,ab6, kt+0.5, kp
	  out aml*ampdb(p21)
	endin
	instr 2
	   abL subinstr 1, p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21
	   abR subinstr 1, p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21
	   outs abL, abR
	endin
	
	instr 3
	      i_b = p4
	      i_f = p5
	      i_w = p6
	      i_tf = p7
	      i_pf = p8
	      i_amp = p9
	      
		aL, aR subinstr 2, i_b, i_f * 1, i_w * (i_f * 1), i_f * 2, i_w * (i_f * 2), i_f * 3, i_w * (i_f * 3), i_f * 4, i_w * (i_f * 4), i_f * 5, i_w * (i_f * 5), i_f * 6, i_w * (i_f * 6), i_tf, 1.0, i_pf, 1.0, i_amp
		
		outs aL, aR
	endin
	
	instr 4
	      ab subinstr 1, p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21
	      out ab
	endin
	
	instr 5
	      i_b = p4
	      i_f = p5
	      i_w = p6
	      i_tf = p7
	      i_pf = p8
	      i_amp = p9
	      
		a0 subinstr 4, i_b, i_f * 1, i_w * (i_f * 1), i_f * 2, i_w * (i_f * 2), i_f * 3, i_w * (i_f * 3), i_f * 4, i_w * (i_f * 4), i_f * 5, i_w * (i_f * 5), i_f * 6, i_w * (i_f * 6), i_tf, 1.0, i_pf, 1.0, i_amp
		
		out a0
	endin

</CsInstruments>


<CsScore>
#define length #3600#
#define f #40#
#define b #0.35#
#define w #0.04#
#define tp #0.001#

#define amp #86#

	f 1 0 16384 10 1
	f 2 0 16384 27 0 -1 16384 1
	f 3 0 16384 27 0 1 8192 -1 16384 1
	f 4 0 16384 27 0 1 8191 1 8192 -1 16384 -1
	
	{8 MULT									  				
		i 3 0 $length $b [$f * ($MULT + 1)] $w $tp [$tp * 4] $amp
	}	
      
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

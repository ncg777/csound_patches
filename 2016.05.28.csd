<CsoundSynthesizer>

<CsOptions>
-o dac  -i adc
</CsOptions>

<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 1
	 inchnls=1
#include "my_udos.inc"
             alwayson "PowerOf2Taps"
	instr PowerOf2Taps
	   a_in in
	   a_out init 0
	   i_power_taps = p4
	   a_out = a_in
	    i_upper_bound = 4
	    i_del pow 2, i_upper_bound
	    i_index init 0
	    label:
	       i_del = i_del/2
	       a_out delay a_out, i_del
	    loop_lt i_index, 1, 4, label
	    out a_out
	endin

</CsInstruments>


<CsScore>
#define length #1800#
#define f #50#
#define b #0.025#
#define w #0.0075#
#define tp #22.05#
#define pp #600#
#define amp #105#
#define ADDF #4#
	f 0 3600
		
      
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

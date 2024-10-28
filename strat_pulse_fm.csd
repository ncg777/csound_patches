<CsoundSynthesizer>


<CsOptions>

</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2
#include "D:/Music making/mus_csound/my_udos.inc"

	instr 1
		ifreq=p4
		imodfreq=p5
		iwave=p6
		iamp=ampdb(p7)
		
		a0 oscil 0.5, ifreq, iwave

		alfo1 oscil 1.0, imodfreq, iwave
		
		ioffset = p8
		iindex = p9
		i_carrier_freq = p10
    i_mod_index = p11
    i_fm_wave = p12
    alfo = alfo1*ioffset*(iindex)/100					

    a1,a2 strat a0, a(ioffset)+alfo,a(ioffset)+alfo
    a3,a4 strat a2, a(ioffset)+alfo,a(ioffset)+alfo
    a5,a6 strat a4, a(ioffset)+alfo,a(ioffset)+alfo
    a7,a8 strat a6, a(ioffset)+alfo,a(ioffset)+alfo
    
    aAdd = a1+a2+a3+a4+a5+a6+a7+a8
    
    a_fm1 oscil3 1.0, i_carrier_freq+(a1*i_carrier_freq*i_mod_index/100.0), i_fm_wave
    a_fm2 oscil3 1.0, i_carrier_freq+(a2*i_carrier_freq*i_mod_index/100.0), i_fm_wave
    a_fm3 oscil3 1.0, i_carrier_freq+(a3*i_carrier_freq*i_mod_index/100.0), i_fm_wave
    a_fm4 oscil3 1.0, i_carrier_freq+(a4*i_carrier_freq*i_mod_index/100.0), i_fm_wave 
    a_fm5 oscil3 1.0, i_carrier_freq+(a5*i_carrier_freq*i_mod_index/100.0), i_fm_wave
    a_fm6 oscil3 1.0, i_carrier_freq+(a6*i_carrier_freq*i_mod_index/100.0), i_fm_wave
    a_fm7 oscil3 1.0, i_carrier_freq+(a7*i_carrier_freq*i_mod_index/100.0), i_fm_wave
    a_fm8 oscil3 1.0, i_carrier_freq+(a8*i_carrier_freq*i_mod_index/100.0), i_fm_wave  
    
    aL = (a_fm1+a_fm2+a_fm3+a_fm4+a_fm5+a_fm6+a_fm7+a_fm8)/8
    aR = (a_fm1+a_fm2+a_fm3+a_fm4+a_fm5+a_fm6+a_fm7+a_fm8)/8
            
		outs aL*iamp, aR*iamp
	endin

</CsInstruments>


<CsScore>


	f 1 0 16384 10 1
	f 2 0 16384 10 1 0 0 1 0 0 1 
	f 3 0 16384 10 1 0 1 0 1
	f 4 0 16384 10 1 0 0 0 1 0 0 0 1
	i 1 0 $length [1*$n*$freq]  $freq $wave $amp $offset $index $carrier_freq $mod_index $fm_wave
	
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

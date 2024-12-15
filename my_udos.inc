opcode noiseband, a, kk
	kfreq, kbw xin
	anoise noise 1.0, 0.0
	af butbp anoise, kfreq, kbw
	xout af
endop

opcode trigger_counter, a, ai
    a_trigger, i_n xin
    a_i init 0
    a_n init 0
    a_n = limit(diff(((a_i/(i_n))-frac(a_i/(i_n)))*(i_n)),0,i_n)
    a_i = integ(a_trigger - a_n)  
    a_index = wrap(a_i,0,i_n)
    xout a_index
endop

opcode brownian_noise, a, a
  aderamp xin
  awnoise0 noise aderamp, 0
  abnoise1 integ awnoise0
  abnoise mirror abnoise1, -1, 1
  xout abnoise
endop

opcode spherical_distance_amplitude, a, kkkka
 ktheta_listener, kphi_listener, ktheta_signal, kphi_signal, asignal xin
 kx_listener = cos(ktheta_listener*$M_PI)*sin(kphi_listener*$M_PI)
 ky_listener = sin(ktheta_listener*$M_PI)*sin(kphi_listener*$M_PI)
 kz_listener = cos(kphi_listener*$M_PI)
 
 kx_signal = cos(ktheta_signal*$M_PI)*sin(kphi_signal*$M_PI)
 ky_signal = sin(ktheta_signal*$M_PI)*sin(kphi_signal*$M_PI)
 kz_signal = cos(kphi_signal*$M_PI)
 
 aout = asignal*(cosinv(kx_listener*kx_signal+ky_listener*ky_signal+kz_listener*kz_signal)/$M_PI)
 xout aout
endop

opcode octahedron_mixer, a, aaaaaakk
  a1, a2, a3, a4, a5, a6, ktheta, kphi xin
  am1 spherical_distance_amplitude 0.0, 0.0, ktheta, kphi, a1
  am2 spherical_distance_amplitude 1.0, 1.0, ktheta, kphi, a2
  am3 spherical_distance_amplitude 0.5, 0.5, ktheta, kphi, a3
  am4 spherical_distance_amplitude 0.0, 0.5, ktheta, kphi, a4
  am5 spherical_distance_amplitude 0.5, -0.5, ktheta, kphi, a5
  am6 spherical_distance_amplitude 1.0, 0.5, ktheta, kphi, a6
  aout = am1+am2+am3+am4+am5+am6
  xout aout
endop

opcode tetrahedron_mixer, a, aaaakk
  a1, a2, a3, a4, ktheta, kphi xin
  am1 spherical_distance_amplitude 1.0/6.0,  2.0/3.0, ktheta, kphi, a1
  am2 spherical_distance_amplitude 5.0/6.0, -2.0/3.0, ktheta, kphi, a2
  am3 spherical_distance_amplitude 1.0/2.0,  2.0/3.0, ktheta, kphi, a3
  am4 spherical_distance_amplitude 0.0, 0, ktheta, kphi, a4
  aout = am1+am2+am3+am4
  xout aout
endop

opcode syncg, a, aaaii
	aamp, afreq, apitch, ifn1, ifn2 xin
	
	ap1 phasor afreq/8, 0
	ap2 phasor afreq/8, 0.125
	ap3 phasor afreq/8, 0.25
	ap4 phasor afreq/8, 0.375
	ap5 phasor afreq/8, 0.5
	ap6 phasor afreq/8, 0.625
	ap7 phasor afreq/8, 0.75
	ap8 phasor afreq/8, 0.875
	
	ap1=(ap1*apitch*8 + apitch*8 +0.5) % (apitch*8)
	ap2=(ap2*apitch*8 + apitch*8 +0.5) % (apitch*8)
	ap3=(ap3*apitch*8 + apitch*8 +0.5) % (apitch*8)
	ap4=(ap4*apitch*8 + apitch*8 +0.5) % (apitch*8)
	ap5=(ap5*apitch*8 + apitch*8 +0.5) % (apitch*8)
	ap6=(ap6*apitch*8 + apitch*8 +0.5) % (apitch*8)
	ap7=(ap7*apitch*8 + apitch*8 +0.5) % (apitch*8)
	ap8=(ap8*apitch*8 + apitch*8 +0.5) % (apitch*8)

	atb11 table3 ap1, ifn1, 1
	atb21 table3 ap1, ifn2, 1
	atb12 table3 ap2, ifn1, 1
	atb22 table3 ap2, ifn2, 1
	atb13 table3 ap3, ifn1, 1
	atb23 table3 ap3, ifn2, 1
	atb14 table3 ap4, ifn1, 1
	atb24 table3 ap4, ifn2, 1
	atb15 table3 ap5, ifn1, 1
	atb25 table3 ap5, ifn2, 1
	atb16 table3 ap6, ifn1, 1
	atb26 table3 ap6, ifn2, 1
	atb17 table3 ap7, ifn1, 1
	atb27 table3 ap7, ifn2, 1
	atb18 table3 ap8, ifn1, 1
	atb28 table3 ap8, ifn2, 1
	
	aout = 	(atb11*atb21)+(atb12*atb22)+(atb13*atb23)+(atb14*atb24)+(atb15*atb25)+(atb16*atb26)+(atb17*atb27)+(atb18*atb28)
	aout=aout*aamp
	xout aout
endop

opcode fm, a, aaai
	afreq, amod, aindex, ifn xin
	aout oscil3 1, afreq+(afreq*aindex*amod), ifn
	xout aout
endop

opcode vec2, a, aak
	a1, a2, kx xin
	kx1=((kx*0.5)+0.5)
	xout ((1-kx1)*a1)+((kx1)*a2)
endop

opcode vec4, a, aaaakk
	a1, a2, a3, a4, kx, ky xin
	kx1=((kx*0.5)+0.5)
	ky1=((ky*0.5)+0.5)
	xout (1-ky1)*(((1-kx1)*a1)+(kx1*a2))+(ky1)*(((1-kx1)*a3)+(kx1*a4))
endop

opcode vec8, a, aaaaaaaakkk
	a1, a2, a3, a4, a5, a6, a7, a8, kx, ky, kz xin
	kx1=((kx*0.5)+0.5)
	ky1=((ky*0.5)+0.5)
	kz1=((kz*0.5)+0.5)
	xout (1-kz1)*((1-ky1)*(((1-kx1)*a1)+(kx1*a2))+(ky1)*(((1-kx1)*a3)+(kx1*a4)))+(kz1)*((1-ky1)*(((1-kx1)*a5)+(kx1*a6))+(ky1)*(((1-kx1)*a7)+(kx1*a8)))
endop

opcode triv, a, aa
	afreq, am xin
	ap phasor afreq

	as min ap*((am+1)/2), (-1)*ap*(((-1)*(am+1)/2)+1) + (((-1)*(am+1)/2)+1)
	
	ax pow ((am+1)/2)* (-1+((am+1)/2)),-1

	xout ax*as*2+1
endop

opcode square, a, aaa
	afreq, apw, aph xin
	ap phasor -afreq
	ap wrap ap+aph, 0, 1
	ap1 wrap ap+apw, 0,  1
	xout ((ap-ap1)+apw)*2-1
endop

opcode train, a, aaa
	afreq, apw, aph xin
	ap phasor -afreq
	ap wrap ap+aph, 0, 1
	ap1 wrap ap+apw, 0,  1
	aout mirror (ap-ap1)+apw, 0, 1
	xout aout
endop

opcode circle, a, ak
	ax, kt xin
	k0 pow kt, (1/2)
	k1 pow (1-kt), (1/2)
	a2 pow ax, k0/k1
	a2 = 1 - a2
	a3 pow a2, k1/k0
	a3 = 1 - a3
	xout a3
endop

opcode strat, aa, aaa
	ain, a1_d, a2_d xin ; ain in [0,1], a1_d != 0 and a2_d != 0
	a1 = frac(ain * a1_d)
	a2 = frac(a1 * a2_d)
	
	xout a1, a2 ; a1 and a2 in [0,1]
endop

opcode spher_to_cart, kkk, kkk
	ktheta, kphi, krho xin
	kx = krho*sin(ktheta)*cos(kphi)
	ky = krho*sin(ktheta)*sin(kphi)
	kz = krho*cos(ktheta)
	xout kx, ky, kz
endop

opcode frequency_activation, k, aiiii
    a_in, i_freq, i_band, i_feedback, i_amplitude xin
    
    a_in_bp init 0.0
    
    a_in_bp = butterbp(a_in + i_feedback*a_in_bp, i_freq, i_band)
    k_env = k(follow2(a_in_bp,0.1,0.1))
    
    k_trigger trigger k_env, i_amplitude, 0
    
    xout k_trigger
endop

opcode trigger_monitor, kkkk, ki
  k_trigger0, i_active_duration xin

  k_x init 0.0
  k_x_del init 0.0
  k_active init 0

  k_x0 diff k_trigger0
  k_x = (k_x0 > 0 ? 1.0 : 0.0)
  k_x_del = delayk(k_x,i_active_duration)
  k_monitor integ k_x - k_x_del
  k_active = k_monitor > 0 ? 1 : 0
  k_active_diff diff k_active
  k_activation limit k_active_diff, 0.0, 1.0
  k_deactivation limit -k_active_diff, 0.0, 1.0
  
  xout k_monitor, k_activation, k_active, k_deactivation
endop

opcode trigger_activated_switch, k, k
  k_trigger xin
  k_switch init 0.0
  k_monitor, k_activation, k_active, k_deactivation trigger_monitor k_trigger, 0.1
  
  k_switch integ ((1.0-k_switch)*k_activation) -(k_switch*k_activation)
  xout k_switch
endop
; -------------------------------------------------------
; digitalpad.inc — DigitalPad patch (importable)
;
; Evolving, morphing pad textures with 8 timbral sources
; (hypersaw, PWM strings, waveshaper, FM crystal, shimmer,
; filtered noise, sub warmth, digital choir) blended via
; vec8.  Stereo chorus and a long ambient reverb are
; applied in the mix stage.
;
; Standalone (all MIDI channels routed to this patch):
;   #include "digitalpad.inc"
;
; Multi-patch (route a specific MIDI channel):
;   #define DIGITALPAD_CHANNEL #2#
;   #include "digitalpad.inc"
;
; Score lines required:
;   i "DigitalPadMorphCtl"  0  <duration>
;   i "DigitalPadMix"       0  <duration>
; -------------------------------------------------------

; -- Shared dependencies (include-guarded) --
#ifndef __MY_UDOS__
#define __MY_UDOS__ ##
#include "my_udos.inc"
#end

#ifndef __GISINE__
#define __GISINE__ ##
giSine ftgen 0, 0, 65536, 10, 1
#end

; -- Patch-specific globals --
giDigitalPadRenderTail = 10

gkDigitalPadMX init 0
gkDigitalPadMY init 0
gkDigitalPadMZ init 0

gaDigitalPadAccL init 0
gaDigitalPadAccR init 0

; =======================================================
; DigitalPadMorphCtl
; Slower, more sweeping movement than DigitalOrgan — suited
; to long evolving pad textures.  Three-scale jspline orbit
; with glacial drift rates for deep ambient evolution.
; =======================================================
instr DigitalPadMorphCtl
  seed 0

  ; Glacial drift layer — very slow tidal movement
  kG1  jspline  0.70, 0.0008, 0.006
  kG2  jspline  0.70, 0.0010, 0.005
  kG3  jspline  0.70, 0.0007, 0.007

  ; Medium sweep layer
  kS1  jspline  0.40, 0.006,  0.030
  kS2  jspline  0.40, 0.005,  0.025
  kS3  jspline  0.40, 0.007,  0.035

  ; Faster shimmer layer
  kW1  jspline  0.15, 0.025,  0.120
  kW2  jspline  0.15, 0.020,  0.100
  kW3  jspline  0.15, 0.030,  0.140

  ; Cross-coupling for non-repeating chaotic orbit
  kRX  =  kG1 + kS1 + kW1 + tanh(kG2*kS3)*0.25 + tanh(kG3*kW2)*0.12
  kRY  =  kG2 + kS2 + kW2 + tanh(kG3*kS1)*0.25 + tanh(kG1*kW3)*0.12
  kRZ  =  kG3 + kS3 + kW3 + tanh(kG1*kS2)*0.25 + tanh(kG2*kW1)*0.12

  gkDigitalPadMX  =  tanh(kRX)
  gkDigitalPadMY  =  tanh(kRY)
  gkDigitalPadMZ  =  tanh(kRZ)
endin

; =======================================================
; DigitalPad
; MIDI-triggered pad with 8 morphing timbres via vec8.
; Designed for space ambient, berlin school, and liquid DnB.
;
;   • Velocity → attack time (80 ms ff to 600 ms pp)
;   • Long 800 ms release tail
;   • Per-note drift and stereo placement
;   • Slow vibrato and filter sweep LFOs
;
; Source timbres:
;   S1 - Hypersaw: 7 detuned saws — supersaw wall of sound
;   S2 - PWM Strings: pulse-width swept string machine
;   S3 - Waveshaper Sweep: sine→rich via dynamic saturation
;   S4 - FM Crystal: high-ratio FM for glassy bell texture
;   S5 - Shimmer: octave/fifth-up detuned partials
;   S6 - Filtered Noise: resonant swept noise bed
;   S7 - Sub Warmth: deep sine with gentle saturation
;   S8 - Digital Choir: formant-filtered detuned voices
;
; Blend: 50% per-note random cube + 50% DigitalPadMorphCtl
; =======================================================
instr DigitalPad
  ; ---- MIDI input ----
  iVel   veloc
  ifreq  cpsmidi
  iamp   = (iVel / 127.0) * 0.30

  ; ---- Release and render tail ----
  iRelTime  =  0.800
  xtratim  iRelTime + 8 + giDigitalPadRenderTail

  seed 0

  ; ---- Attack: velocity mapped ----
  ; pp (vel=1) → 600 ms slow pad swell   ff (vel=127) → 80 ms crisp
  iAtt  =  0.080 + (1 - iVel/127.0) * 0.520

  ; ---- Per-note stereo pan ----
  iPan  random  -0.60, 0.60
  kPL   =  0.5 - iPan * 0.5
  kPR   =  0.5 + iPan * 0.5

  ; ---- Main envelope ----
  aEnvMain  linsegr  0, iAtt, 1, iRelTime, 0
  ; Secondary: slightly slower for layered voices
  aEnvSub   linsegr  0, iAtt*1.5, 0.92, iRelTime*1.3, 0

  ; ---- Slow LFO modulations ----
  ; Glacial vibrato — subliminal pitch drift
  iVibRate   random  0.08, 0.35
  iVibDepth  random  0.0008, 0.0025
  kVibLFO    oscili  1, iVibRate, giSine
  kVib       =  1 + kVibLFO * iVibDepth

  ; Filter sweep LFO — drives brightness modulation on some sources
  iFiltRate  random  0.04, 0.15
  kFiltLFO   oscili  1, iFiltRate, giSine

  ; ==============================================================
  ; SOURCE 1: Hypersaw
  ; 7 detuned sawtooth oscillators — the JP supersaw.
  ; Central saw plus 3 pairs detuned symmetrically.  Heavy
  ; detuning creates the thick shimmering wall of sound that
  ; defines modern digital pads.
  ; ==============================================================
  iDt1a  random  0.006, 0.012
  iDt1b  random  0.012, 0.022
  iDt1c  random  0.020, 0.035
  aS1_0  vco2  1,  ifreq*kVib
  aS1_1  vco2  1,  ifreq*(1+iDt1a)*kVib
  aS1_2  vco2  1,  ifreq*(1-iDt1a)*kVib
  aS1_3  vco2  1,  ifreq*(1+iDt1b)*kVib
  aS1_4  vco2  1,  ifreq*(1-iDt1b)*kVib
  aS1_5  vco2  1,  ifreq*(1+iDt1c)*kVib
  aS1_6  vco2  1,  ifreq*(1-iDt1c)*kVib
  aS1raw = aS1_0*0.22 + aS1_1*0.18 + aS1_2*0.18 + aS1_3*0.15 + aS1_4*0.15 + aS1_5*0.12 + aS1_6*0.12
  aS1raw = aS1raw * aEnvMain
  ; LP to tame top-end harshness
  aS1  butlp  aS1raw, 6000 + kFiltLFO*2000
  aS1  =  aS1 * iamp * 0.38

  ; ==============================================================
  ; SOURCE 2: PWM Strings
  ; Pulse waves with slowly sweeping pulse width — classic
  ; string machine sound.  Two ranks at 8' and 4' with
  ; independent PWM rates for thick beating texture.
  ; Berlin school staple (Jarre, Tangerine Dream).
  ; ==============================================================
  iPWMRate1  random  0.08, 0.20
  iPWMRate2  random  0.06, 0.18
  kPW1  =  0.35 + oscili:k(0.14, iPWMRate1, giSine)
  kPW2  =  0.40 + oscili:k(0.12, iPWMRate2, giSine)
  iDtPW  random  0.003, 0.008
  aS2a  vco2  1,  ifreq*kVib,                 2, kPW1
  aS2b  vco2  1,  ifreq*(1+iDtPW)*kVib,       2, kPW2
  aS2c  vco2  1,  ifreq*2*(1-iDtPW*0.5)*kVib, 2, kPW1
  aS2d  vco2  1,  ifreq*2*(1+iDtPW*0.3)*kVib, 2, kPW2
  aS2raw = aS2a*aEnvMain + aS2b*aEnvMain*0.85 + aS2c*aEnvSub*0.55 + aS2d*aEnvSub*0.45
  aS2  butlp  aS2raw, 5000 + kFiltLFO*1500
  aS2  =  aS2 * iamp * 0.30

  ; ==============================================================
  ; SOURCE 3: Waveshaper Sweep
  ; A sine through dynamic tanh saturation — sweeps from pure
  ; to harmonically rich.  Creates a living, breathing timbre
  ; that moves from glassy clarity to growling warmth.
  ; Think wavetable sweep without needing actual wavetables.
  ; ==============================================================
  iWSRate  random  0.03, 0.10
  kWSIdx   =  0.3 + oscili:k(0.6, iWSRate, giSine)
  iDtWS    random  0.001, 0.004
  aWS_sin   oscili  1, ifreq*kVib,                giSine
  aWS_sin2  oscili  1, ifreq*2*(1+iDtWS)*kVib,    giSine
  ; Dynamic saturation: drive sweeps from 1.3 to 6.9
  aS3a  =  tanh(aWS_sin  * (1 + kWSIdx*6))
  aS3b  =  tanh(aWS_sin2 * (1 + kWSIdx*4))
  aS3raw  =  aS3a*0.65 + aS3b*0.35
  aS3  butlp  aS3raw * aEnvMain, 4500 + kFiltLFO*2500
  aS3  =  aS3 * iamp * 0.34

  ; ==============================================================
  ; SOURCE 4: FM Crystal
  ; High-ratio FM synthesis (C:M ratios 1:7.01 and 1:3.01)
  ; producing glassy, bell-like inharmonic partials.  The
  ; modulation index decays slowly so the crystalline shimmer
  ; fades into warmth over time.  Space ambient texture.
  ; ==============================================================
  iMDet4    random  -0.003, 0.003
  kFMIdx4a  linseg  3.5, iAtt*2, 1.8, 20, 0.8
  kFMIdx4b  linseg  2.0, iAtt*2, 1.0, 20, 0.5
  aFM4modA  oscili  kFMIdx4a * ifreq,  ifreq*7.01*(1+iMDet4),  giSine
  aFM4modB  oscili  kFMIdx4b * ifreq,  ifreq*3.01*(1-iMDet4),  giSine
  aS4a  oscili  aEnvMain,       ifreq*kVib     + aFM4modA,        giSine
  aS4b  oscili  aEnvMain*0.55,  ifreq*2*kVib   + aFM4modB,        giSine
  aS4c  oscili  aEnvSub*0.30,   ifreq*0.5*kVib + aFM4modA*0.2,    giSine
  aS4  =  (aS4a + aS4b + aS4c) * iamp * 0.32

  ; ==============================================================
  ; SOURCE 5: Shimmer
  ; Fundamental with octave-up, fifth-up, and two-octave-up
  ; partials — all with heavy detuning.  Multiple voices per
  ; layer for ethereal diffusion.  Creates the iconic shimmer
  ; texture used extensively in ambient music.
  ; ==============================================================
  iDtSh5a  random  0.004, 0.010
  iDtSh5b  random  0.005, 0.012
  iDtSh5c  random  0.006, 0.014
  ; Fundamental pair
  aSh5_1a  oscili  aEnvMain*0.45,  ifreq*(1+iDtSh5a*0.3)*kVib,  giSine
  aSh5_1b  oscili  aEnvMain*0.40,  ifreq*(1-iDtSh5a*0.3)*kVib,  giSine
  ; Octave up pair
  aSh5_2a  oscili  aEnvSub*0.55,   ifreq*2*(1+iDtSh5a)*kVib,    giSine
  aSh5_2b  oscili  aEnvSub*0.50,   ifreq*2*(1-iDtSh5a)*kVib,    giSine
  ; Fifth up (3x) pair
  aSh5_3a  oscili  aEnvSub*0.35,   ifreq*3*(1+iDtSh5b)*kVib,    giSine
  aSh5_3b  oscili  aEnvSub*0.30,   ifreq*3*(1-iDtSh5b)*kVib,    giSine
  ; Two octaves up pair
  aSh5_4a  oscili  aEnvSub*0.20,   ifreq*4*(1+iDtSh5c)*kVib,    giSine
  aSh5_4b  oscili  aEnvSub*0.18,   ifreq*4*(1-iDtSh5c)*kVib,    giSine
  aS5  =  (aSh5_1a+aSh5_1b+aSh5_2a+aSh5_2b+aSh5_3a+aSh5_3b+aSh5_4a+aSh5_4b) * iamp * 0.26

  ; ==============================================================
  ; SOURCE 6: Filtered Noise Texture
  ; Band-passed noise with slowly sweeping center frequency.
  ; Two resonant bands at different sweep rates for complex
  ; oceanic movement — the textural "air" component.
  ; Essential for liquid DnB pad atmospheres.
  ; ==============================================================
  iNoiseRate1  random  0.02, 0.08
  iNoiseRate2  random  0.03, 0.10
  aNoise6  rand  1
  kCF1  =  ifreq*2 + oscili:k(ifreq*1.5, iNoiseRate1, giSine)
  kCF2  =  ifreq*4 + oscili:k(ifreq*2.0, iNoiseRate2, giSine)
  aN6a  reson  aNoise6, kCF1, ifreq*0.8, 1
  aN6b  reson  aNoise6, kCF2, ifreq*0.5, 1
  aS6  =  (aN6a*0.60 + aN6b*0.40) * aEnvMain * iamp * 0.22

  ; ==============================================================
  ; SOURCE 7: Sub Warmth
  ; Deep sine at fundamental and sub-octave with gentle
  ; saturation harmonics from tanh.  Provides the weighty
  ; low-end foundation for DnB and deep ambient.
  ; A touch of second harmonic adds presence.
  ; ==============================================================
  iDtSub7  random  0.0005, 0.0020
  aSub7a   oscili  1,     ifreq*kVib,                    giSine
  aSub7b   oscili  0.60,  ifreq*0.5*(1+iDtSub7)*kVib,   giSine
  aSub7c   oscili  0.25,  ifreq*2*kVib,                  giSine
  aS7raw   =  aSub7a + aSub7b + aSub7c
  ; Gentle saturation for warmth
  aS7  =  tanh(aS7raw * 1.8) * aEnvMain * iamp * 0.42

  ; ==============================================================
  ; SOURCE 8: Digital Choir
  ; Multiple heavily-detuned sine voices through formant-like
  ; resonant bandpass filters.  Creates a synthetic "aah" choir.
  ; Five voices with wide detuning beat slowly against each other;
  ; two sweeping resonant peaks near 600 Hz and 1200 Hz (open "ah"
  ; formant) give the vowel quality.  The most expressive source.
  ; ==============================================================
  iDtCh8a   random  0.008, 0.018
  iDtCh8b   random  0.006, 0.014
  iFormRate  random  0.05, 0.12
  kForm1  =  600 + oscili:k(150, iFormRate, giSine)
  kForm2  =  1200 + oscili:k(200, iFormRate*0.7, giSine)
  aCh8a  oscili  aEnvMain,        ifreq*(1+iDtCh8a)*kVib,       giSine
  aCh8b  oscili  aEnvMain*0.90,   ifreq*(1-iDtCh8a)*kVib,       giSine
  aCh8c  oscili  aEnvSub*0.70,    ifreq*(1+iDtCh8b*0.5)*kVib,   giSine
  aCh8d  oscili  aEnvSub*0.55,    ifreq*2*(1+iDtCh8b)*kVib,     giSine
  aCh8e  oscili  aEnvSub*0.40,    ifreq*2*(1-iDtCh8b)*kVib,     giSine
  aCh8raw = aCh8a + aCh8b + aCh8c + aCh8d + aCh8e
  ; Formant filtering — blended with dry for naturalness
  aCh8f1  reson  aCh8raw, kForm1, 120, 1
  aCh8f2  reson  aCh8raw, kForm2, 180, 1
  aS8  =  (aCh8raw*0.40 + aCh8f1*0.35 + aCh8f2*0.25) * iamp * 0.30

  ; ==============================================================
  ; VEC8 BLEND — continuous per-note timbral drift
  ; Slower drift rates than DigitalOrgan for gradual evolution.
  ; 50% per-note drift + 50% global DigitalPadMorphCtl.
  ; ==============================================================
  iMRa  random  0.025, 0.080
  iMRb  random  0.020, 0.070
  iMRc  random  0.028, 0.085
  kDriftX  jspline  0.9, iMRa*0.5, iMRa
  kDriftY  jspline  0.9, iMRb*0.5, iMRb
  kDriftZ  jspline  0.9, iMRc*0.5, iMRc
  kLocalX  =  tanh(kDriftX)
  kLocalY  =  tanh(kDriftY)
  kLocalZ  =  tanh(kDriftZ)

  kBlendX  =  kLocalX*0.5 + gkDigitalPadMX*0.5
  kBlendY  =  kLocalY*0.5 + gkDigitalPadMY*0.5
  kBlendZ  =  kLocalZ*0.5 + gkDigitalPadMZ*0.5

  aMixL  vec8  aS1,aS2,aS3,aS4,aS5,aS6,aS7,aS8,  kBlendX,        kBlendY,        kBlendZ
  aMixR  vec8  aS1,aS2,aS3,aS4,aS5,aS6,aS7,aS8,  kBlendX+0.018,  kBlendY-0.012,  kBlendZ+0.015

  ; Stereo pan
  aOutL  =  aMixL * kPL
  aOutR  =  aMixR * kPR

  gaDigitalPadAccL  =  gaDigitalPadAccL + aOutL
  gaDigitalPadAccR  =  gaDigitalPadAccR + aOutR
endin

; =======================================================
; DigitalPadMix
; Effects chain designed for spacious digital pads:
;
;   1. Stereo chorus — 3-tap modulated delay for width
;      and shimmer; slow LFO rates keep it transparent
;
;   2. Large spacious reverb — very long tail (0.920
;      feedback) with bright 10 kHz cutoff for ambient wash
;
;   3. Gentle low-pass at 10 kHz — warms the top end
;
;   4. Soft tanh(1.4x) limiter
; =======================================================
instr DigitalPadMix
  seed 0

  ; ---- Stereo chorus: 3-tap modulated delay per channel ----
  kCh1  oscili  1, 0.18,  giSine, 0.00
  kCh2  oscili  1, 0.23,  giSine, 0.33
  kCh3  oscili  1, 0.29,  giSine, 0.67

  aBufL  delayr  0.060
  aTapL1  deltap3  0.012 + kCh1*0.004
  aTapL2  deltap3  0.020 + kCh2*0.005
  aTapL3  deltap3  0.030 + kCh3*0.003
  delayw gaDigitalPadAccL

  aBufR  delayr  0.060
  aTapR1  deltap3  0.014 + kCh2*0.004
  aTapR2  deltap3  0.022 + kCh3*0.005
  aTapR3  deltap3  0.028 + kCh1*0.003
  delayw gaDigitalPadAccR

  ; 55% dry + 45% chorus
  aChrL  =  gaDigitalPadAccL*0.55 + (aTapL1+aTapL2+aTapL3)*0.15
  aChrR  =  gaDigitalPadAccR*0.55 + (aTapR1+aTapR2+aTapR3)*0.15

  ; ---- Large spacious reverb — ambient wash ----
  aRevL, aRevR  reverbsc  aChrL, aChrR, 0.920, 10000

  ; 45% direct + 55% reverb — reverb-dominant for ambient depth
  aMixL  =  aChrL*0.45 + aRevL*0.55
  aMixR  =  aChrR*0.45 + aRevR*0.55

  ; ---- Warmth: gentle low-pass ----
  aMixL  butlp  aMixL, 10000
  aMixR  butlp  aMixR, 10000

  ; ---- Soft limiter ----
  aOutL  =  tanh(aMixL * 1.4)
  aOutR  =  tanh(aMixR * 1.4)

  outs  aOutL, aOutR

  ; Clear global bus each k-cycle
  gaDigitalPadAccL  =  0
  gaDigitalPadAccR  =  0
endin

; -- MIDI channel routing --
#ifdef DIGITALPAD_CHANNEL
massign $DIGITALPAD_CHANNEL, "DigitalPad"
#else
massign 0, "DigitalPad"
pgmassign 0, "DigitalPad"
#end

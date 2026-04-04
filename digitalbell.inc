; -------------------------------------------------------
; digitalbell.inc — DigitalBell patch (importable)
;
; Ambient bell chime with 8 morphing sound sources,
; 4-voice dynamic unison, per-note free-running LFOs, and
; resonant noiseband components.  Multi-tap modulated echo
; and deep reverb create elaborate shimmer tails.
;
; Standalone (all MIDI channels routed to this patch):
;   #include "digitalbell.inc"
;
; Multi-patch (route a specific MIDI channel):
;   #define DIGITALBELL_CHANNEL #3#
;   #include "digitalbell.inc"
;
; Score lines required:
;   i "DigitalBellMorphCtl"  0  <duration>
;   i "DigitalBellMix"       0  <duration>
; -------------------------------------------------------

; -- Shared dependencies (include-guarded) --
#ifndef __MY_UDOS__
#define __MY_UDOS__
#include "my_udos.inc"
#end

#ifndef __GISINE__
#define __GISINE__
giSine ftgen 0, 0, 65536, 10, 1
#end

; -- Patch-specific globals --
giDigitalBellRenderTail = 10

gkDigitalBellMX init 0
gkDigitalBellMY init 0
gkDigitalBellMZ init 0

gaDigitalBellRevL init 0
gaDigitalBellRevR init 0

; =======================================================
; DigitalBellMorphCtl
; Drives gkDigitalBellMX/Y/Z with three-scale jspline chaos
; so the timbre morphs continuously without any MIDI CC
; input.  The cross-coupled tanh terms create orbital
; trajectories that never repeat.
; =======================================================
instr DigitalBellMorphCtl
  seed 0                              ; time-seeded — unique every run

  ; Glacial layer: ~100-700 s per cycle
  kG1 jspline 0.65, 0.0015, 0.010
  kG2 jspline 0.65, 0.0012, 0.009
  kG3 jspline 0.65, 0.0018, 0.011

  ; Slow layer: ~20-80 s
  kS1 jspline 0.38, 0.012, 0.050
  kS2 jspline 0.38, 0.010, 0.045
  kS3 jspline 0.38, 0.014, 0.055

  ; Wander layer: ~5-25 s
  kW1 jspline 0.18, 0.040, 0.200
  kW2 jspline 0.18, 0.035, 0.180
  kW3 jspline 0.18, 0.045, 0.220

  ; Cross-coupled sum for chaotic orbital movement
  kRX = kG1 + kS1 + kW1 + tanh(kG2*kS3)*0.30 + tanh(kG3*kW2)*0.15
  kRY = kG2 + kS2 + kW2 + tanh(kG3*kS1)*0.30 + tanh(kG1*kW3)*0.15
  kRZ = kG3 + kS3 + kW3 + tanh(kG1*kS2)*0.30 + tanh(kG2*kW1)*0.15

  ; Soft-clip to [-1, 1]
  gkDigitalBellMX = tanh(kRX)
  gkDigitalBellMY = tanh(kRY)
  gkDigitalBellMZ = tanh(kRZ)
endin

; =======================================================
; DigitalBell
; MIDI-triggered bell chime with 8 morphing sound sources,
; 4-voice dynamic unison, per-note free-running LFOs, and
; resonant noiseband components.  Each note picks two random
; corners of the vec8 cube and crossfades A→B on attack,
; sustains at B, then releases back to A on note-off.
;
; Source timbres:
;   S1 - Resonant noise bell (short noise burst → 4 reson filters at bell partials)
;   S2 - 3-voice detuned sines, moderate detune
;   S3 - 4-voice detuned sines, wide detune
;   S4 - 2-voice detuned sines + quiet inharmonic partial
;   S5 - Crystal FM bell (2:1 ratio, two detuned free-running modulators)
;   S6 - Sine chorus at 2.756x + root, per-source vibrato/tremolo LFOs
;   S7 - Rich metallic FM (3.5x + sqrt(2) modulators, stacked operators)
;   S8 - Wide diffuse noiseband at fundamental (airy wash)
; Blend: 50% per-note random cube coords + 50% global DigitalBellMorphCtl
; Attack: humanized per-note (iHardness 0=silky smooth, 1=hard percussive)
; =======================================================
instr DigitalBell
  ; ---- MIDI input ----
  iVel   veloc
  ifreq  cpsmidi
  iamp   = (iVel / 127.0) * 0.42

  ; ---- Bell ring extends well beyond the MIDI note-off ----
  ; xtratim covers: bell decay (iRing) + delay echo tail (~6 s max tap)
  ; + reverbsc tail + an extra 10 s render buffer inside Csound
  iRing   = 16.0
  xtratim iRing + 50 + giDigitalBellRenderTail

  ; ---- Per-note random seed (time-based: each note differs) ----
  seed 0

  ; ---- Dynamic unison: 4 detuned voice frequencies ----
  iDt1 random -0.009,  0.009
  iDt2 random -0.009,  0.009
  iDt3 random -0.006,  0.006
  iDt4 random -0.006,  0.006
  iFq1 = ifreq * (1 + iDt1)
  iFq2 = ifreq * (1 + iDt2)
  iFq3 = ifreq * (1 + iDt3)
  iFq4 = ifreq * (1 + iDt4)

  ; ---- Humanized attack: 0 = silky smooth, 1 = hard percussive ----
  iHardness  random  0, 1
  iAttBase   = 0.003 + (1 - iHardness) * 0.022   ; 3 ms (hard) -> 25 ms (smooth)
  iAmpScale  = 0.85 + iHardness * 0.30            ; harder hits punch slightly louder

  ; ---- Staggered per-voice envelopes with humanized attack ----
  ; Successively delayed attacks create a shimmering phasing effect
  aEnv1 expseg 0.001, iAttBase,         iAmpScale,         0.040, 0.90, iRing, 0.0001
  aEnv2 expseg 0.001, iAttBase*1.8,     iAmpScale*0.90,    0.050, 0.84, iRing, 0.0001
  aEnv3 expseg 0.001, iAttBase*2.6,     iAmpScale*0.80,    0.060, 0.78, iRing, 0.0001
  aEnv4 expseg 0.001, iAttBase*3.4,     iAmpScale*0.70,    0.070, 0.72, iRing, 0.0001

  ; ---- Free-running per-note LFOs (independent of MIDI CC) ----
  iLR1 random 0.12, 3.50   ; vibrato rate
  iLR2 random 0.08, 2.00   ; tremolo rate
  iLR3 random 0.05, 1.50   ; filter-sweep / noiseband wobble rate

  kVibLFO  oscili 1, iLR1, giSine
  kTremLFO oscili 1, iLR2, giSine
  kFiltLFO oscili 1, iLR3, giSine

  ; Vibrato factor (subtle pitch wobble)
  iVibD random 0.002, 0.007
  kVib  = 1 + kVibLFO * iVibD

  ; Amplitude tremolo (soft, 12% depth)
  kTrem = 1 + kTremLFO * 0.12

  ; ---- Per-note stereo pan ----
  iPan random -0.65, 0.65
  kPL  = 0.5 - iPan * 0.5
  kPR  = 0.5 + iPan * 0.5

  ; ==============================================================
  ; SOURCE 1: Resonant noise bell
  ; A brief noise burst excites four narrow-band reson filters tuned
  ; at Chowning bell-partial ratios (1x, 2.756x, 5.404x, 8.933x).
  ; The filters ring freely after the burst for a natural struck-bell
  ; texture.  Higher iHardness → higher Q (sharper, longer ring).
  ; ==============================================================
  aNoise1  rand    1
  aExcEnv1 linseg  0, iAttBase*0.5, 1.0, iAttBase*1.5, 0
  aExcite1 = aNoise1 * aExcEnv1
  iRNBQ1 = 500 + iHardness * 300
  iRNBQ2 = 300 + iHardness * 200
  iRNBQ3 = 150 + iHardness * 100
  iRNBQ4 =  80 + iHardness *  60
  aR1   reson aExcite1, ifreq,        ifreq/iRNBQ1, 1
  aR2   reson aExcite1, ifreq*2.756,  ifreq*2.756/iRNBQ2, 1
  aR3   reson aExcite1, ifreq*5.404,  ifreq*5.404/iRNBQ3, 1
  aR4   reson aExcite1, ifreq*8.933,  ifreq*8.933/iRNBQ4, 1
  aS1 = (aR1 + aR2*0.50 + aR3*0.28 + aR4*0.12) * iamp * 0.38

  ; ==============================================================
  ; SOURCE 2: 3-voice detuned sines — moderate detune
  ; Richer chorus with a gentle spreading of pitch
  ; ==============================================================
  iDtS2   random  0.003, 0.007
  aSin2a  oscili aEnv1, iFq1*(1+iDtS2)*kVib, giSine
  aSin2b  oscili aEnv2, iFq2*kVib,            giSine
  aSin2c  oscili aEnv3, iFq3*(1-iDtS2)*kVib, giSine
  aS2 = (aSin2a + aSin2b + aSin2c) * iamp * 0.26

  ; ==============================================================
  ; SOURCE 3: 4-voice detuned sines — wide detune
  ; Lush, slow-beating cluster across the 4 unison voices
  ; ==============================================================
  iDtS3   random  0.006, 0.012
  aSin3a  oscili aEnv1, iFq1*(1+iDtS3    )*kVib, giSine
  aSin3b  oscili aEnv2, iFq2*(1+iDtS3/3  )*kVib, giSine
  aSin3c  oscili aEnv3, iFq3*(1-iDtS3/3  )*kVib, giSine
  aSin3d  oscili aEnv4, iFq4*(1-iDtS3    )*kVib, giSine
  aS3 = (aSin3a + aSin3b + aSin3c + aSin3d) * iamp * 0.20

  ; ==============================================================
  ; SOURCE 4: 2-voice detuned sines + quiet inharmonic partial
  ; Adds one Chowning 2.756x overtone for very subtle bell colour
  ; The partial decays faster to stay in the background
  ; ==============================================================
  iDtS4    random  0.002, 0.005
  aSin4a   oscili aEnv1, iFq1*(1+iDtS4)*kVib, giSine
  aSin4b   oscili aEnv2, iFq2*(1-iDtS4)*kVib, giSine
  aP4env   expseg 0.001, 0.004, 0.45, iRing*0.40, 0.0001
  aSin4p   oscili aP4env, iFq1*2.756*kVib,     giSine
  aS4 = (aSin4a + aSin4b + aSin4p*0.40) * iamp * 0.28

  ; ==============================================================
  ; SOURCE 5: Crystal FM bell — carrier at fundamental, two
  ; detuned free-running modulators at 2:1 ratio, plus a third
  ; shimmer operator.  Index decays bright -> crystal -> shimmer.
  ; ==============================================================
  iMDet5   random   -0.004, 0.004           ; modulator detuning
  iMFreq5a = ifreq * 2.000 * (1 + iMDet5)
  iMFreq5b = ifreq * 2.000 * (1 - iMDet5 * 0.7)
  iMFreq5c = ifreq * 2.003                  ; extra shimmer operator
  kFMIdx5  linseg   6.0 + iHardness*2.5, iAttBase*5, 1.8, iRing*0.35, 0.28
  aFMMod5a oscili   kFMIdx5 * iMFreq5a,             iMFreq5a, giSine
  aFMMod5b oscili   kFMIdx5 * 0.55 * iMFreq5b,      iMFreq5b, giSine
  aFMMod5c oscili   kFMIdx5 * 0.28 * iMFreq5c,      iMFreq5c, giSine
  aS5env   expseg   0.001, iAttBase, 1.0, 0.06, 0.55, iRing, 0.0001
  aS5a     oscili   aS5env,        ifreq * kVib + aFMMod5a + aFMMod5c, giSine
  aS5b     oscili   aS5env * 0.60, ifreq * kVib + aFMMod5b,            giSine
  aS5 = (aS5a + aS5b) * iamp * 0.44

  ; ==============================================================
  ; SOURCE 6: Sine chorus at the 2.756x Chowning partial + root.
  ; Three voices with independent free-running vibrato and a
  ; separate per-source tremolo oscillator — each note sounds
  ; uniquely alive with organic pitch and amplitude movement.
  ; ==============================================================
  iVibR6a  random   0.15, 0.80
  iVibR6b  random   0.09, 0.55
  iTremR6  random   0.20, 1.20
  iVibD6   random   0.003, 0.009
  kVib6a   oscili   1, iVibR6a, giSine
  kVib6b   oscili   1, iVibR6b, giSine
  kTrem6   oscili   1, iTremR6, giSine
  aS6env   expseg   0.001, iAttBase*1.2, 0.90, 0.045, 0.35, iRing*0.35, 0.0001
  aSin6a   oscili   aS6env,        ifreq * 2.756 * (1 + kVib6a * iVibD6),        giSine
  aSin6b   oscili   aS6env * 0.65, ifreq * 2.758 * (1 + kVib6b * iVibD6 * 0.8),  giSine
  aSin6c   oscili   aS6env * 0.45, ifreq          * (1 + kVib6a * iVibD6 * 0.5),  giSine
  aS6 = (aSin6a + aSin6b + aSin6c) * (1 + kTrem6 * 0.14) * iamp * 0.40

  ; ==============================================================
  ; SOURCE 7: Rich metallic FM — two detuned carriers fed by a
  ; pair of free-running modulators at inharmonic ratios (~3.5x
  ; and sqrt(2)x), plus a stacked modulator for dense harmonics.
  ; Index decays from percussive brightness to warm metallic ring.
  ; ==============================================================
  iMDet7   random   -0.005, 0.005
  iMFreq7a = ifreq * 3.502 * (1 + iMDet7)
  iMFreq7b = ifreq * 3.498 * (1 - iMDet7)
  iMFreq7c = ifreq * 1.41421356              ; sqrt(2) metallic colour
  kFMIdx7  linseg   4.5 + iHardness*2.0, iAttBase*4, 1.5, iRing*0.40, 0.16
  aFMMod7a oscili   kFMIdx7 * iMFreq7a,              iMFreq7a,     giSine
  aFMMod7b oscili   kFMIdx7 * 0.75 * iMFreq7b,       iMFreq7b,     giSine
  aFMMod7c oscili   kFMIdx7 * 0.40 * iMFreq7c,       iMFreq7c,     giSine
  aFMMod7d oscili   kFMIdx7 * 0.28 * iMFreq7a*0.5,   iMFreq7a*0.5, giSine
  aS7env   expseg   0.001, iAttBase*0.8, 0.80, 0.055, 0.38, iRing, 0.0001
  aS7a     oscili   aS7env,        ifreq * (1 + iMDet7) + aFMMod7a + aFMMod7c, giSine
  aS7b     oscili   aS7env * 0.75, ifreq * (1 - iMDet7) + aFMMod7b,            giSine
  aS7c     oscili   aS7env * 0.45, ifreq                + aFMMod7d,             giSine
  aS7 = (aS7a + aS7b + aS7c) * iamp * 0.36

  ; ==============================================================
  ; SOURCE 8: Wide diffuse noiseband at fundamental
  ; BW ~18% of fundamental — airy wash, like a bowed wine glass
  ; Slow attack for a gentle swell character
  ; ==============================================================
  kNB8f   = ifreq * (1 + kFiltLFO * 0.015)
  kNB8bw  = ifreq * 0.180
  aNB8    noiseband kNB8f, kNB8bw
  aNB8env expseg 0.001, 0.020, 0.60, 0.10, 0.25, iRing*0.55, 0.0001
  aS8 = aNB8 * aNB8env * iamp * 0.38

  ; ==============================================================
  ; VEC8 BLEND — per-note random corner crossfade
  ; Two cube corners (each coord ±1) are chosen at note-on.
  ; linsegr drives an ASR envelope: attack A→B, sustain at B,
  ; release B→A on note-off.  Tiny L/R offsets add stereo width.
  ; ==============================================================

  ; Pick corner A (coords: one of ±1 per axis)
  iRxA  random  0, 2
  iRyA  random  0, 2
  iRzA  random  0, 2
  iCxA  =  (iRxA < 1 ? -1 : 1)
  iCyA  =  (iRyA < 1 ? -1 : 1)
  iCzA  =  (iRzA < 1 ? -1 : 1)

  ; Pick corner B (independently random)
  iRxB  random  0, 2
  iRyB  random  0, 2
  iRzB  random  0, 2
  iCxB  =  (iRxB < 1 ? -1 : 1)
  iCyB  =  (iRyB < 1 ? -1 : 1)
  iCzB  =  (iRzB < 1 ? -1 : 1)

  ; ASR morph envelope (0 = corner A, 1 = corner B)
  ; linsegr sustains at 1 until MIDI note-off, then releases to 0
  iMorphAtt  random  0.4, 2.5
  iMorphRel  random  0.8, 4.0
  kMorphEnv  linsegr  0, iMorphAtt, 1, iMorphRel, 0

  ; Interpolate each axis between the two corners
  kLocalX  =  iCxA + (iCxB - iCxA) * kMorphEnv
  kLocalY  =  iCyA + (iCyB - iCyA) * kMorphEnv
  kLocalZ  =  iCzA + (iCzB - iCzA) * kMorphEnv

  ; Blend per-note cube coords (50%) with global DigitalBellMorphCtl (50%)
  kBlendX = kLocalX * 0.5 + gkDigitalBellMX * 0.5
  kBlendY = kLocalY * 0.5 + gkDigitalBellMY * 0.5
  kBlendZ = kLocalZ * 0.5 + gkDigitalBellMZ * 0.5

  aMixL vec8 aS1, aS2, aS3, aS4, aS5, aS6, aS7, aS8, kBlendX,        kBlendY,        kBlendZ
  aMixR vec8 aS1, aS2, aS3, aS4, aS5, aS6, aS7, aS8, kBlendX+0.015,  kBlendY-0.010,  kBlendZ+0.012

  ; Apply tremolo and stereo pan
  aOutL  = aMixL * kTrem * kPL
  aOutR  = aMixR * kTrem * kPR

  ; Accumulate into global bus for DigitalBellMix
  gaDigitalBellRevL = gaDigitalBellRevL + aOutL
  gaDigitalBellRevR = gaDigitalBellRevR + aOutR
endin

; =======================================================
; DigitalBellMix
; Reads the global accumulation bus, applies a 5-tap
; dynamically modulated echo (elaborate shimmer), a deep
; reverbsc, master filtering, soft limiting, and outputs.
; Running continuously alongside all bell notes.
; =======================================================
instr DigitalBellMix
  seed 0

  ; Slow LFOs for modulating echo tap times (creates shimmer)
  kEL1 oscili 1, 0.130, giSine
  kEL2 oscili 1, 0.170, giSine
  kEL3 oscili 1, 0.110, giSine
  kEL4 oscili 1, 0.230, giSine
  kEL5 oscili 1, 0.071, giSine

  ; ---- Multi-tap modulated delay — Left channel ----
  ; Tap spacing follows near-Fibonacci ratios (avoids comb peaks)
  aBufL  delayr 6.5
  aTL1   deltap3 0.317 + kEL1 * 0.012
  aTL2   deltap3 0.721 + kEL2 * 0.018
  aTL3   deltap3 1.331 + kEL3 * 0.025
  aTL4   deltap3 2.618 + kEL4 * 0.030
  aTL5   deltap3 4.236 + kEL5 * 0.020
  ; Low-pass the feedback path to simulate air absorption
  aFbkL  butlp aTL1, 6000
  delayw gaDigitalBellRevL + aFbkL * 0.14

  ; ---- Multi-tap modulated delay — Right channel ----
  ; Offset tap times for natural stereo spread
  aBufR  delayr 6.5
  aTR1   deltap3 0.423 + kEL2 * 0.015
  aTR2   deltap3 0.891 + kEL3 * 0.020
  aTR3   deltap3 1.618 + kEL4 * 0.028
  aTR4   deltap3 3.141 + kEL5 * 0.035
  aTR5   deltap3 5.000 + kEL1 * 0.022
  aFbkR  butlp aTR1, 6000
  delayw gaDigitalBellRevR + aFbkR * 0.14

  ; Weighted tap sum (amplitude decreases with each tap)
  aEchoL = gaDigitalBellRevL + aTL1*0.16 + aTL2*0.10 + aTL3*0.06 + aTL4*0.03 + aTL5*0.02
  aEchoR = gaDigitalBellRevR + aTR1*0.16 + aTR2*0.10 + aTR3*0.06 + aTR4*0.03 + aTR5*0.02

  ; ---- Deep plate reverb (moderate tail) ----
  aRevL, aRevR reverbsc aEchoL, aEchoR, 0.920, 7000

  ; Wet/dry blend: 72% direct echo + 28% reverb
  aMixL = aEchoL * 0.72 + aRevL * 0.28
  aMixR = aEchoR * 0.72 + aRevR * 0.28

  ; ---- Master lowpass to tame high-frequency harshness ----
  aMixL butlp aMixL, 9000
  aMixR butlp aMixR, 9000

  ; ---- Soft limiter ----
  aOutL = tanh(aMixL * 1.5)
  aOutR = tanh(aMixR * 1.5)

  outs aOutL, aOutR

  ; Clear global bus each k-cycle
  gaDigitalBellRevL = 0
  gaDigitalBellRevR = 0
endin

; -- MIDI channel routing --
#ifdef DIGITALBELL_CHANNEL
massign $DIGITALBELL_CHANNEL, "DigitalBell"
#else
massign 0, "DigitalBell"
pgmassign 0, "DigitalBell"
#end

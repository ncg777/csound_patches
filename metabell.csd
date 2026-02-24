<CsoundSynthesizer>
<CsOptions>
; Usage: csound -T -F input.mid -o output.wav metabell.csd
; Companion script: metabell.bat input.mid [output.wav]
; 32-bit float WAV avoids int16 scaling issues with 0dbfs=1
--format=float
</CsOptions>

<CsInstruments>

sr     = 48000
ksmps  = 64
nchnls = 2
0dbfs  = 1

; Route all MIDI channels to MetaBell (use numeric instr number for Csound 6 compatibility)
; MetaBell is instr 2 (defined after MorphController)
massign 0, 2
; Lock program-change routing to MetaBell so program-change events in the
; MIDI file (e.g. "C0 00") cannot silently redirect notes to instr 1.
pgmassign 0, 2

#include "my_udos.inc"

; Sine wave table (referenced by name giSine)
giSine ftgen 0, 0, 65536, 10, 1

; -------------------------------------------------------
; Global morph coordinates for vec8 (updated each k-period
; by MorphController, consumed by every MetaBell instance)
; -------------------------------------------------------
gkMX init 0
gkMY init 0
gkMZ init 0

; -------------------------------------------------------
; Global stereo accumulation bus
; MetaBell instances write here; MasterMix reads and clears
; -------------------------------------------------------
gaRevL init 0
gaRevR init 0

; =======================================================
; MorphController
; Drives gkMX/Y/Z with three-scale jspline chaos so the
; timbre morphs continuously without any MIDI CC input.
; The cross-coupled tanh terms create orbital trajectories
; that never repeat.
; =======================================================
instr MorphController
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
  gkMX = tanh(kRX)
  gkMY = tanh(kRY)
  gkMZ = tanh(kRZ)
endin

; =======================================================
; MetaBell
; MIDI-triggered bell chime with 8 morphing sound sources,
; 4-voice dynamic unison, per-note free-running LFOs, and
; resonant noiseband components.  Each note picks two random
; corners of the vec8 cube and crossfades A→B on attack,
; sustains at B, then releases back to A on note-off.
;
; Source timbres:
;   S1 - 2-voice detuned sines, very narrow detune
;   S2 - 3-voice detuned sines, moderate detune
;   S3 - 4-voice detuned sines, wide detune
;   S4 - 2-voice detuned sines + quiet inharmonic partial
;   S5 - Narrow noiseband at fundamental
;   S6 - Narrow noiseband at 2.756x partial
;   S7 - Dual noiseband: fundamental + 5.404x partial
;   S8 - Wide diffuse noiseband at fundamental
; =======================================================
instr MetaBell
  ; ---- MIDI input ----
  iVel   veloc
  ifreq  cpsmidi
  iamp   = (iVel / 127.0) * 0.42

  ; ---- Bell ring extends well beyond the MIDI note-off ----
  ; xtratim covers: bell decay (iRing) + delay echo tail (~6 s max tap)
  ; + reverbsc tail (0.965 feedback, ~40 s to inaudible)
  iRing   = 8.0
  xtratim iRing + 50

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

  ; ---- Staggered per-voice envelopes (dynamic unison movement)
  ; Successively delayed attacks create a shimmering phasing effect
  aEnv1 expseg 0.001, 0.005, 1.00, 0.040, 0.55, iRing, 0.0001
  aEnv2 expseg 0.001, 0.009, 0.90, 0.050, 0.50, iRing, 0.0001
  aEnv3 expseg 0.001, 0.013, 0.80, 0.060, 0.45, iRing, 0.0001
  aEnv4 expseg 0.001, 0.017, 0.70, 0.070, 0.40, iRing, 0.0001

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
  ; SOURCE 1: 2-voice detuned sines — very narrow detune
  ; Calm, nearly pure tone with a faint beating shimmer
  ; ==============================================================
  iDtS1   random  0.001, 0.003
  aSin1a  oscili aEnv1, iFq1*(1+iDtS1)*kVib, giSine
  aSin1b  oscili aEnv2, iFq2*(1-iDtS1)*kVib, giSine
  aS1 = (aSin1a + aSin1b) * iamp * 0.36

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
  ; SOURCE 5: Narrow noiseband at fundamental
  ; Very tight BW (~3%) — sounds like a pure tone ±slight breath
  ; ==============================================================
  kNB5f   = ifreq * (1 + kFiltLFO * 0.005)
  kNB5bw  = ifreq * 0.030
  aNB5    noiseband kNB5f, kNB5bw
  aNB5env expseg 0.001, 0.010, 1.0, 0.08, 0.40, iRing*0.50, 0.0001
  aS5 = aNB5 * aNB5env * iamp * 0.55

  ; ==============================================================
  ; SOURCE 6: Narrow noiseband at 2.756x partial
  ; Classic Chowning bell overtone rendered as resonant noise
  ; Decays faster than the fundamental band
  ; ==============================================================
  kNB6f   = ifreq * 2.756 * (1 + kFiltLFO * 0.003)
  kNB6bw  = ifreq * 0.060
  aNB6    noiseband kNB6f, kNB6bw
  aNB6env expseg 0.001, 0.004, 1.0, 0.04, 0.30, iRing*0.28, 0.0001
  aS6 = aNB6 * aNB6env * iamp * 0.48

  ; ==============================================================
  ; SOURCE 7: Dual noiseband — fundamental + 5.404x partial
  ; Two resonant nodes that fade at different rates;
  ; the upper band is wider for an airy shimmer
  ; ==============================================================
  kNB7f1  = ifreq * (1 + kFiltLFO * 0.008)
  kNB7f2  = ifreq * 5.404
  kNB7bw  = ifreq * 0.040
  aNB7a   noiseband kNB7f1, kNB7bw
  aNB7b   noiseband kNB7f2, kNB7bw * 3.0
  aNB7env expseg 0.001, 0.006, 0.80, 0.05, 0.35, iRing*0.38, 0.0001
  aS7 = (aNB7a + aNB7b*0.50) * aNB7env * iamp * 0.44

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

  aMixL vec8 aS1, aS2, aS3, aS4, aS5, aS6, aS7, aS8, kLocalX,        kLocalY,        kLocalZ
  aMixR vec8 aS1, aS2, aS3, aS4, aS5, aS6, aS7, aS8, kLocalX+0.015,  kLocalY-0.010,  kLocalZ+0.012

  ; Apply tremolo and stereo pan
  aOutL  = aMixL * kTrem * kPL
  aOutR  = aMixR * kTrem * kPR

  ; Accumulate into global bus for MasterMix
  gaRevL = gaRevL + aOutL
  gaRevR = gaRevR + aOutR
endin

; =======================================================
; MasterMix
; Reads the global accumulation bus, applies a 5-tap
; dynamically modulated echo (elaborate shimmer), a deep
; reverbsc, master filtering, soft limiting, and outputs.
; Running continuously alongside all bell notes.
; =======================================================
instr MasterMix
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
  delayw gaRevL + aFbkL * 0.38

  ; ---- Multi-tap modulated delay — Right channel ----
  ; Offset tap times for natural stereo spread
  aBufR  delayr 6.5
  aTR1   deltap3 0.423 + kEL2 * 0.015
  aTR2   deltap3 0.891 + kEL3 * 0.020
  aTR3   deltap3 1.618 + kEL4 * 0.028
  aTR4   deltap3 3.141 + kEL5 * 0.035
  aTR5   deltap3 5.000 + kEL1 * 0.022
  aFbkR  butlp aTR1, 6000
  delayw gaRevR + aFbkR * 0.38

  ; Weighted tap sum (amplitude decreases with each tap)
  aEchoL = gaRevL + aTL1*0.38 + aTL2*0.24 + aTL3*0.15 + aTL4*0.09 + aTL5*0.05
  aEchoR = gaRevR + aTR1*0.38 + aTR2*0.24 + aTR3*0.15 + aTR4*0.09 + aTR5*0.05

  ; ---- Deep plate reverb (large room, very long tail) ----
  aRevL, aRevR reverbsc aEchoL, aEchoR, 0.965, 8000

  ; Wet/dry blend: 30% direct echo + 70% reverb
  aMixL = aEchoL * 0.30 + aRevL * 0.70
  aMixR = aEchoR * 0.30 + aRevR * 0.70

  ; ---- Master lowpass to tame high-frequency harshness ----
  aMixL butlp aMixL, 9000
  aMixR butlp aMixR, 9000

  ; ---- Soft limiter ----
  aOutL = tanh(aMixL * 1.5)
  aOutR = tanh(aMixR * 1.5)

  outs aOutL, aOutR

  ; Clear global bus each k-cycle
  gaRevL = 0
  gaRevR = 0
endin

</CsInstruments>

<CsScore>
; MorphController and MasterMix run for up to 2 hours.
; With -T flag the performance ends after the last MIDI note
; rings out (including xtratim extension).
i "MorphController" 0 7200
i "MasterMix"       0 7200

; Keep score alive; -T in the bat script governs actual end time
f 0 7200

e
</CsScore>

</CsoundSynthesizer>

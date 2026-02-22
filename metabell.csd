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
; filtered noise component.  The vec8 blend between all
; 8 sources is governed by gkMX/Y/Z which evolve randomly.
;
; Source timbres:
;   S1 - Additive sine bell  (Chowning inharmonic partials)
;   S2 - FM bell             (C:M = 1:1.4, medium index)
;   S3 - FM metallic/gong    (C:M = 1:2.8, high index)
;   S4 - Filtered sawtooth   (string/cello character)
;   S5 - Plucked string      (Karplus-Strong)
;   S6 - Bandpass noise bell (brushed gong / wind chime)
;   S7 - AM bell             (sideband shimmer)
;   S8 - Crystal bell        (4-voice detuned sine + chirp)
; =======================================================
instr MetaBell
  ; ---- MIDI input ----
  iVel   veloc
  ifreq  cpsmidi
  iamp   = (iVel / 127.0) * 0.42

  ; ---- Bell ring extends well beyond the MIDI note-off ----
  iRing   = 8.0
  xtratim iRing + 0.5

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
  iLR3 random 0.05, 1.50   ; filter-sweep rate
  iLR4 random 0.18, 4.50   ; FM-index modulation rate

  kVibLFO  oscili 1, iLR1, giSine
  kTremLFO oscili 1, iLR2, giSine
  kFiltLFO oscili 1, iLR3, giSine
  kFMiLFO  oscili 1, iLR4, giSine

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
  ; SOURCE 1: Additive Sine Bell — Chowning bell model
  ; Inharmonic partial ratios: 1.000, 2.756, 5.404, 8.933
  ; Higher partials decay faster (independent partial envelopes)
  ; Two detuned unison voices for warmth
  ; ==============================================================
  aP1e expseg 0.001, 0.004, 0.80, iRing*0.92, 0.0001
  aP2e expseg 0.001, 0.004, 0.60, iRing*0.52, 0.0001
  aP3e expseg 0.001, 0.004, 0.38, iRing*0.32, 0.0001
  aP4e expseg 0.001, 0.004, 0.22, iRing*0.20, 0.0001

  aB11 oscili aP1e, iFq1*1.000*kVib, giSine
  aB12 oscili aP2e, iFq1*2.756*kVib, giSine
  aB13 oscili aP3e, iFq1*5.404*kVib, giSine
  aB14 oscili aP4e, iFq1*8.933*kVib, giSine
  aB21 oscili aP1e, iFq2*1.000*kVib, giSine
  aB22 oscili aP2e, iFq2*2.756*kVib, giSine
  aB23 oscili aP3e, iFq2*5.404*kVib, giSine
  aB24 oscili aP4e, iFq2*8.933*kVib, giSine
  aS1 = (aB11+aB12+aB13+aB14+aB21+aB22+aB23+aB24) * iamp * 0.11

  ; ==============================================================
  ; SOURCE 2: FM Bell — classic bell FM synthesis
  ; Carrier:Modulator ratio 1:1.4 with slowly varying index
  ; Two detuned voices
  ; ==============================================================
  kFM2i   = 3.0 + kFMiLFO * 2.5
  aFM2m1  oscili kFM2i * iFq1 * 1.4, iFq1 * 1.4, giSine
  aFM2v1  oscili aEnv1, iFq1 + aFM2m1, giSine
  aFM2m2  oscili kFM2i * iFq2 * 1.4, iFq2 * 1.4, giSine
  aFM2v2  oscili aEnv2, iFq2 + aFM2m2, giSine
  aS2 = (aFM2v1 + aFM2v2) * iamp * 0.28

  ; ==============================================================
  ; SOURCE 3: FM Metallic/Gong — higher index, dissonant C:M ratio
  ; C:M = 1:2.8 produces rich gong/cymbal inharmonicity
  ; ==============================================================
  iFM3base random 5.0, 12.0
  kFM3i   = iFM3base + kFMiLFO * 3.5
  aFM3m1  oscili kFM3i * iFq1 * 2.8, iFq1 * 2.8, giSine
  aFM3v1  oscili aEnv1, iFq1 + aFM3m1, giSine
  aFM3m2  oscili kFM3i * iFq3 * 2.8, iFq3 * 2.8, giSine
  aFM3v2  oscili aEnv3, iFq3 + aFM3m2, giSine
  aS3 = (aFM3v1 + aFM3v2) * iamp * 0.24

  ; ==============================================================
  ; SOURCE 4: Filtered Sawtooth — bowed string / cello quality
  ; Moog ladder filter swept by LFO for evolving brightness
  ; ==============================================================
  aSw1   vco2 iamp * 0.5, iFq1 * kVib, 0
  aSw2   vco2 iamp * 0.5, iFq2 * kVib, 0
  kFcut  = limit(ifreq * (4 + kFiltLFO * 2), 200, 18000)
  kFres  = 0.30 + kTremLFO * 0.10
  aSw1f  moogladder aSw1 * aEnv1, kFcut,       kFres
  aSw2f  moogladder aSw2 * aEnv2, kFcut * 1.01, kFres
  aS4 = (aSw1f + aSw2f) * 0.30

  ; ==============================================================
  ; SOURCE 5: Plucked String — Karplus-Strong algorithm
  ; Harp / dulcimer / guitar character; natural exponential decay
  ; ==============================================================
  aPl1    pluck iamp * 0.35, iFq1 * kVib, iFq1, 0, 1
  aPl2    pluck iamp * 0.30, iFq2 * kVib, iFq2, 0, 1
  aPlEnv  expseg 0.001, 0.010, 1.0, iRing*0.55, 0.0001
  aS5 = (aPl1 + aPl2) * aPlEnv

  ; ==============================================================
  ; SOURCE 6: Bandpass Noise Bell — brushed gong / wind chime
  ; Uses the noiseband UDO from my_udos.inc for soft, airy texture
  ; Two bands: fundamental and 2nd inharmonic partial
  ; ==============================================================
  kBPf   = ifreq * (1 + kFiltLFO * 0.02)
  kBPbw  = ifreq * 0.06
  aNz1   noiseband kBPf,        kBPbw
  aNz2   noiseband kBPf * 2.756, kBPbw * 2
  aNzEnv expseg 0.001, 0.004, 1.0, 0.06, 0.25, iRing*0.35, 0.0001
  aS6 = (aNz1 + aNz2) * aNzEnv * iamp * 0.45

  ; ==============================================================
  ; SOURCE 7: AM Bell — amplitude modulation sideband shimmer
  ; Modulator at a musical sub-frequency creates a rich partial
  ; structure that breathes and shifts over the note duration
  ; ==============================================================
  iAMf   random 1.5, 8.0
  aAMc1  oscili aEnv1, iFq1, giSine
  aAMm1  oscili 0.50,  iAMf, giSine
  aAMv1  = aAMc1 * (0.50 + aAMm1)
  aAMc2  oscili aEnv2, iFq2, giSine
  aAMm2  oscili 0.50,  iAMf * 1.01, giSine
  aAMv2  = aAMc2 * (0.50 + aAMm2)
  aS7 = (aAMv1 + aAMv2) * iamp * 0.35

  ; ==============================================================
  ; SOURCE 8: Crystal Bell — 4-voice detuned sine with initial chirp
  ; Each voice has a staggered envelope for evolving shimmer.
  ; A brief upward chirp at attack then settles to target pitch.
  ; ==============================================================
  kChirp expseg ifreq * 1.012, 0.05, ifreq, iRing, ifreq
  aCr1   oscili aEnv1, iFq1 * (kChirp/ifreq) * kVib, giSine
  aCr2   oscili aEnv2, iFq2 * (kChirp/ifreq) * kVib, giSine
  aCr3   oscili aEnv3, iFq3 * (kChirp/ifreq) * kVib, giSine
  aCr4   oscili aEnv4, iFq4 * (kChirp/ifreq) * kVib, giSine
  aS8 = (aCr1 + aCr2 + aCr3 + aCr4) * iamp * 0.13

  ; ==============================================================
  ; VEC8 BLEND — trilinear interpolation between all 8 sources
  ; gkMX/Y/Z wander continuously; tiny offsets between L and R
  ; channels create a subtle stereo width without hard panning.
  ; ==============================================================
  aMixL vec8 aS1, aS2, aS3, aS4, aS5, aS6, aS7, aS8, gkMX,        gkMY,        gkMZ
  aMixR vec8 aS1, aS2, aS3, aS4, aS5, aS6, aS7, aS8, gkMX+0.015,  gkMY-0.010,  gkMZ+0.012

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

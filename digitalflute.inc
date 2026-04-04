; -------------------------------------------------------
; digitalflute.inc — DigitalFlute patch (importable)
;
; A velocity-sensitive digital flute voice with delayed
; vibrato, breath noise, and embouchure chiff transient.
; Subtle chorus and concert-hall reverb in the mix stage.
;
; Standalone (all MIDI channels routed to this patch):
;   #include "digitalflute.inc"
;
; Multi-patch (route a specific MIDI channel):
;   #define DIGITALFLUTE_CHANNEL #4#
;   #include "digitalflute.inc"
;
; Score lines required:
;   i "DigitalFluteModCtl"  0  <duration>
;   i "DigitalFluteMix"     0  <duration>
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
giDigitalFluteRenderTail = 8

gkDigitalFluteBreath  init 0
gkDigitalFluteWarmth  init 0

gaDigitalFluteAccL init 0
gaDigitalFluteAccR init 0

; =======================================================
; DigitalFluteModCtl — slow evolution for breath and warmth
; =======================================================
instr DigitalFluteModCtl
  seed 0
  kG1  jspline  0.50, 0.0010, 0.012
  kG2  jspline  0.40, 0.0015, 0.016
  gkDigitalFluteBreath  = 0.70 + tanh(kG1) * 0.30
  gkDigitalFluteWarmth  = 0.30 + tanh(kG2) * 0.65
endin

; =======================================================
; DigitalFlute
; A velocity-sensitive digital flute voice.
; - Sine-dominant tone with subtle harmonics
; - Delayed vibrato (ramps in ~300 ms after note onset)
; - Band-limited breath noise inversely scaled with velocity
; - Embouchure chiff noise burst on attack
; - Per-note slow modulation LFO for timbral life
; - Gentle saturation and stereo spread
; Writes into a global mix bus processed by DigitalFluteMix
; =======================================================
instr DigitalFlute
  seed 0

  ; MIDI input
  iVel   veloc
  iFreq  cpsmidi
  iAmp   = (iVel / 127.0) * 0.40

  ; Release and render tail
  iRel   = 0.200 + (1 - iVel/127.0) * 0.200
  xtratim  iRel + giDigitalFluteRenderTail

  ; Velocity-mapped attack (fast for loud, slower for soft)
  iAtt = 0.015 + (1 - iVel/127.0) * 0.085
  aEnvMain linsegr 0, iAtt, 1, iRel, 0

  ; ---- Delayed vibrato — ramps in after ~300 ms ----
  iVibRate  random 4.5, 6.0
  iVibDepth random 0.004, 0.008
  kVibOnset linseg 0, 0.30, 0, 0.20, 1
  kVibLFO   oscili 1, iVibRate, giSine
  kVib      = 1 + kVibLFO * iVibDepth * kVibOnset * (0.5 + iVel/254.0)

  ; Per-note slow modulation LFO (brightness / breath wobble)
  iModRate random 0.06, 0.25
  kModLFO  oscili 1, iModRate, giSine
  kMod     = kModLFO * 0.40

  ; ---- Flute body: fundamental + weak harmonics ----
  iDet1 random -0.0006, 0.0006
  iDet2 random -0.0010, 0.0010
  ; Fundamental (dominant) — gentle unison pair
  aF1a oscili aEnvMain * 0.70, iFreq * kVib * (1 + iDet1), giSine
  aF1b oscili aEnvMain * 0.20, iFreq * kVib * (1 - iDet1), giSine
  ; 2nd harmonic (soft)
  aF2  oscili aEnvMain * 0.10, iFreq * 2 * kVib * (1 + iDet2), giSine
  ; 3rd harmonic (very soft, velocity-dependent — louder playing
  ; excites more harmonics, softer playing stays pure)
  aF3  oscili aEnvMain * 0.04 * (iVel/127.0), iFreq * 3 * kVib, giSine

  aBody = (aF1a + aF1b + aF2 + aF3) * iAmp

  ; ---- Breath noise — band-limited around fundamental ----
  aNoise rand 1
  kBreathCF = iFreq * (1.5 + kMod * 0.3)
  aBreath1 reson aNoise, kBreathCF, iFreq * 0.6, 1
  aBreath2 reson aNoise, iFreq * 3, iFreq * 0.4, 1
  ; Softer notes have more breath (inverse velocity)
  kBreathLevel = gkDigitalFluteBreath * (0.05 + (1 - iVel/127.0) * 0.06)
  aBreathOut = (aBreath1 * 0.70 + aBreath2 * 0.30) * aEnvMain * iAmp * kBreathLevel

  ; ---- Chiff transient — short embouchure noise burst ----
  iChiffTime = 0.006 + (1 - iVel/127.0) * 0.018
  aChiffEnv linsegr 0, 0.001, 1, iChiffTime, 0
  aChiffNoise rand 1
  aChiff1 reson aChiffNoise, iFreq * 2.0, 150, 1
  aChiff2 reson aChiffNoise, iFreq * 3.5, 200, 1
  aChiff = (aChiff1 * 0.60 + aChiff2 * 0.40) * aChiffEnv * (iVel/127.0) * iAmp * 0.20

  ; ---- Mix voice components ----
  aFluteRaw = aBody * 0.88 + aBreathOut + aChiff

  ; Gentle warmth filter modulated by global warmth parameter
  kCutoff = 8000 + gkDigitalFluteWarmth * 2000 + kMod * 500
  aFlute butlp aFluteRaw, kCutoff

  ; Very gentle saturation for warmth
  aFlute = tanh(aFlute * 1.15) * 0.96

  ; ---- Stereo pan with slight LFO movement ----
  iPan random -0.40, 0.40
  kPanLFO oscili 1, 0.05, giSine
  kPanMod = kPanLFO * 0.04
  kPL = 0.5 - iPan * 0.5 + kPanMod
  kPR = 0.5 + iPan * 0.5 - kPanMod

  aOutL = aFlute * kPL
  aOutR = aFlute * kPR

  gaDigitalFluteAccL = gaDigitalFluteAccL + aOutL
  gaDigitalFluteAccR = gaDigitalFluteAccR + aOutR
endin

; =======================================================
; DigitalFluteMix — subtle chorus + concert-hall reverb
; =======================================================
instr DigitalFluteMix
  seed 0

  ; ---- Subtle stereo chorus: 3-tap modulated delay ----
  kCh1 oscili 1, 0.16, giSine
  kCh2 oscili 1, 0.22, giSine, 0.33
  kCh3 oscili 1, 0.28, giSine, 0.67

  aBufL delayr 0.050
  aTapL1 deltap3 0.010 + kCh1 * 0.002
  aTapL2 deltap3 0.018 + kCh2 * 0.003
  aTapL3 deltap3 0.026 + kCh3 * 0.002
  delayw gaDigitalFluteAccL

  aBufR delayr 0.050
  aTapR1 deltap3 0.012 + kCh2 * 0.002
  aTapR2 deltap3 0.020 + kCh3 * 0.003
  aTapR3 deltap3 0.028 + kCh1 * 0.002
  delayw gaDigitalFluteAccR

  aChrL = gaDigitalFluteAccL * 0.78 + (aTapL1 + aTapL2 + aTapL3) * 0.073
  aChrR = gaDigitalFluteAccR * 0.78 + (aTapR1 + aTapR2 + aTapR3) * 0.073

  ; ---- Concert-hall reverb ----
  aRevL, aRevR reverbsc aChrL, aChrR, 0.870, 9000

  ; 68% direct + 32% reverb for natural concert-hall depth
  aMixL = aChrL * 0.68 + aRevL * 0.32
  aMixR = aChrR * 0.68 + aRevR * 0.32

  ; ---- Warmth: gentle low-pass ----
  aMixL butlp aMixL, 10000
  aMixR butlp aMixR, 10000

  ; ---- Soft limiter ----
  aOutL = tanh(aMixL * 1.3)
  aOutR = tanh(aMixR * 1.3)

  outs aOutL, aOutR

  ; Clear global bus each k-cycle
  gaDigitalFluteAccL = 0
  gaDigitalFluteAccR = 0
endin

; -- MIDI channel routing --
#ifdef DIGITALFLUTE_CHANNEL
massign $DIGITALFLUTE_CHANNEL, "DigitalFlute"
#else
massign 0, "DigitalFlute"
pgmassign 0, "DigitalFlute"
#end

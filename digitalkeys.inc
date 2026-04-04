; -------------------------------------------------------
; digitalkeys.inc — DigitalKeys patch (importable)
;
; A velocity-sensitive electric-keys / Rhodes-like voice
; with chorus, reverb and vintage tape saturation.
;
; Standalone (all MIDI channels routed to this patch):
;   #include "digitalkeys.inc"
;
; Multi-patch (route a specific MIDI channel):
;   #define DIGITALKEYS_CHANNEL #1#
;   #include "digitalkeys.inc"
;
; Score lines required:
;   i "DigitalKeysModCtl"  0  <duration>
;   i "DigitalKeysMix"     0  <duration>
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
giDigitalKeysRenderTail = 8

gkDigitalKeysBright init 0
gkDigitalKeysChorus init 0

gaDigitalKeysAccL init 0
gaDigitalKeysAccR init 0

; =======================================================
; DigitalKeysModCtl — subtle, slow evolution for brightness
; =======================================================
instr DigitalKeysModCtl
  seed 0
  kG1  jspline  0.55, 0.0008, 0.010
  kG2  jspline  0.35, 0.0020, 0.014
  gkDigitalKeysBright = 0.25 + tanh(kG1) * 0.7
  gkDigitalKeysChorus = 0.12 + tanh(kG2) * 0.44
endin

; =======================================================
; DigitalKeys
; A velocity-sensitive electric-keys / Rhodes-like voice.
; - Short velocity-to-attack mapping for percussive feel
; - Noise-based hammer transient + tuned partials for body
; - Gentle saturation, stereo spread
; Writes into a global mix bus processed by DigitalKeysMix
; =======================================================
instr DigitalKeys
  seed 0

  ; MIDI input
  iVel   veloc
  iFreq  cpsmidi
  iAmp   = (iVel / 127.0) * 0.35

  ; Release and render tail
  iRel   = 1.20 + (1 - iVel/127.0) * 0.80
  xtratim  iRel + giDigitalKeysRenderTail

  ; Velocity-mapped attack (fast for loud, slower for soft)
  iAtt = 0.004 + (1 - iVel/127.0) * 0.046
  aEnvMain linsegr 0, iAtt, 1, iRel, 0
  aEnvBody linsegr 0, iAtt*1.4, 0.98, iRel*1.05, 0

  ; Small pitch vibrato for life (velocity-sensitive)
  iVibRate  random 5.0, 6.5
  iVibDepthBase random 0.0004, 0.0012
  kVibLFO  oscili 1, iVibRate, giSine
  kVib     = 1 + kVibLFO * iVibDepthBase * (0.5 + iVel/254.0)

  ; Per-note slow modulation LFO (filter/brightness/tremolo)
  iModRate random 0.08, 0.32
  kModLFO oscili 1, iModRate, giSine
  kMod = kModLFO * 0.55

  ; Hammer transient — short noise burst filtered
  iHamEnvTime = 0.010 + (1 - iVel/127.0) * 0.040
  aHamEnv linsegr 0, 0.001, 1, iHamEnvTime, 0
  aHamNoise rand 1
  aHamNoise = butlp(aHamNoise, 8000)
  aHam1 reson aHamNoise, iFreq*2.0, 80, 1
  aHam2 reson aHamNoise, iFreq*3.0, 120, 1
  aHammer = (aHam1*0.62 + aHam2*0.38) * aHamEnv * (iVel/127.0) * iAmp * 0.6
  ; Body: multiple sine partials with unison for vintage richness
  iDet1 random -0.0012, 0.0012
  iDet2 random -0.0025, 0.0025
  ; per-note small unison offsets (center + 2 detuned voices)
  iUnA  random 0.0010, 0.0019
  iUnB  random -0.0010, -0.0019

  ; Primary partials with 3-voice unison (center + two detuned)
  aP1c oscili aEnvBody*0.46, iFreq*kVib*(1+iDet1), giSine
  aP1u1 oscili aEnvBody*0.16, iFreq*kVib*(1+iDet1 + iUnA), giSine
  aP1u2 oscili aEnvBody*0.16, iFreq*kVib*(1+iDet1 + iUnB), giSine
  aP1 = aP1c + aP1u1 + aP1u2

  aP2c oscili aEnvBody*0.30, iFreq*2.0*kVib*(1+iDet2), giSine
  aP2u1 oscili aEnvBody*0.08, iFreq*2.0*kVib*(1+iDet2 + iUnA*1.1), giSine
  aP2u2 oscili aEnvBody*0.08, iFreq*2.0*kVib*(1+iDet2 + iUnB*1.1), giSine
  aP2 = aP2c + aP2u1 + aP2u2

  aP3c oscili aEnvBody*0.16, iFreq*3.0*kVib*(1+iDet2*0.6), giSine
  aP3u1 oscili aEnvBody*0.04, iFreq*3.0*kVib*(1+iDet2*0.6 + iUnA*1.2), giSine
  aP3u2 oscili aEnvBody*0.04, iFreq*3.0*kVib*(1+iDet2*0.6 + iUnB*1.2), giSine
  aP3 = aP3c + aP3u1 + aP3u2

  aBody = (aP1 + aP2*0.82 + aP3*0.56) * iAmp * 0.95

  ; Pickup / tine character via resonant bandpass stages (modulated by LFO)
  kBright = gkDigitalKeysBright
  aPickup1 reson aBody, iFreq * (1.0 + 0.12*kBright + kMod*0.08), iFreq*0.6, 1
  aPickup2 reson aBody, iFreq * (2.0 + 0.55*kBright + kMod*0.08), iFreq*1.0, 1

  ; Mix body + hammer transient — emphasize body, keep hammer subtle
  aKeysRaw = aBody*0.86 + aPickup1*0.28 + aPickup2*0.09 + aHammer*0.30

  ; Vintage tape-style pre-saturation: gentle pre-emphasis and soft clipping
  aPre = aKeysRaw * (1.0 + kBright*0.25)
  aPre = butlp(aPre, 12000)
  aSat = tanh(aPre * (1.0 + kMod*0.08)) * 0.98

  ; Stereo pan with slight LFO movement (adds width from unison)
  iPan random -0.35, 0.35
  kPanLFO oscili 1, 0.07, giSine
  kPanMod = kPanLFO * 0.06
  kPL = 0.5 - iPan * 0.5 + kPanMod
  kPR = 0.5 + iPan * 0.5 - kPanMod

  ; Slight tape-like saturation shaping per channel for warmth
  aOutL = tanh(aSat * kPL * (0.96 + kBright*0.08)) * 0.98
  aOutR = tanh(aSat * kPR * (0.96 + kBright*0.08)) * 0.98

  gaDigitalKeysAccL = gaDigitalKeysAccL + aOutL
  gaDigitalKeysAccR = gaDigitalKeysAccR + aOutR
endin

; =======================================================
; DigitalKeysMix — subtle chorus + short-medium reverb for keys
; =======================================================
instr DigitalKeysMix
  seed 0
  kCh1 oscili 1, 0.14, giSine
  kCh2 oscili 1, 0.20, giSine, 0.33
  kCh3 oscili 1, 0.26, giSine, 0.67

  ; Tape-style wow and flutter LFOs (slow wow + faster flutter)
  kTapeWowLFO oscili 1, 0.28, giSine
  kTapeFlutterLFO oscili 1, 7.3, giSine, 0.43
  kTapeMod = kTapeWowLFO*(0.004 + gkDigitalKeysChorus*0.002) + kTapeFlutterLFO*0.0009

  aBufL delayr 0.060
  aTapL1 deltap3 0.012 + kCh1*(0.003 + gkDigitalKeysChorus*0.008) + kTapeMod
  aTapL2 deltap3 0.020 + kCh2*(0.004 + gkDigitalKeysChorus*0.010) - kTapeMod*0.6
  aTapL3 deltap3 0.028 + kCh3*(0.003 + gkDigitalKeysChorus*0.008) + kTapeMod*0.4
  delayw gaDigitalKeysAccL

  aBufR delayr 0.060
  aTapR1 deltap3 0.014 + kCh2*(0.003 + gkDigitalKeysChorus*0.008) - kTapeMod*0.5
  aTapR2 deltap3 0.022 + kCh3*(0.004 + gkDigitalKeysChorus*0.010) + kTapeMod*0.7
  aTapR3 deltap3 0.030 + kCh1*(0.003 + gkDigitalKeysChorus*0.008) - kTapeMod*0.3
  delayw gaDigitalKeysAccR

  aChrL = gaDigitalKeysAccL*0.75 + (aTapL1 + aTapL2 + aTapL3) * 0.083
  aChrR = gaDigitalKeysAccR*0.75 + (aTapR1 + aTapR2 + aTapR3) * 0.083

  ; Short-large reverb tail tuned for keys
  aRevL, aRevR reverbsc aChrL, aChrR, 0.840, 8000

  aMixL = aChrL*0.78 + aRevL*0.22
  aMixR = aChrR*0.78 + aRevR*0.22

  aMixL butlp aMixL, 9000
  aMixR butlp aMixR, 9000

  ; Vintage tape saturation and warmth (gentle drive controlled by brightness)
  kDrive = 0.5 + gkDigitalKeysBright*0.9
  aTapeL = tanh(aMixL * (1.0 + kDrive*0.45)) * 0.98
  aTapeR = tanh(aMixR * (1.0 + kDrive*0.45)) * 0.98
  aTapeL butlp aTapeL, 9000
  aTapeR butlp aTapeR, 9000

  ; Subtle tape hiss / head noise
  aHissL rand 1
  aHissR rand 1
  aHissL = butlp(aHissL * 0.0025 * (0.8 + gkDigitalKeysChorus), 12000)
  aHissR = butlp(aHissR * 0.0025 * (0.8 + gkDigitalKeysChorus), 12000)

  ; small stereo crossfeed to emulate tape crosstalk and glue
  aOutL = aTapeL*0.985 + aTapeR*0.015 + aHissL
  aOutR = aTapeR*0.985 + aTapeL*0.015 + aHissR

  outs aOutL, aOutR

  ; Clear global bus each k-cycle
  gaDigitalKeysAccL = 0
  gaDigitalKeysAccR = 0
endin

; -- MIDI channel routing --
#ifdef DIGITALKEYS_CHANNEL
massign $DIGITALKEYS_CHANNEL, "DigitalKeys"
#else
massign 0, "DigitalKeys"
pgmassign 0, "DigitalKeys"
#end

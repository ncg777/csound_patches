<CsoundSynthesizer>
<CsOptions>
; Usage: csound -T -F input.mid -o output.wav digitalkeys.csd
; Companion script: digitalkeys.bat input.mid [output.wav]
--format=float
</CsOptions>

<CsInstruments>

sr     = 48000
ksmps  = 64
nchnls = 2
0dbfs  = 1

giRenderTail = 8

; Route all MIDI channels to DigitalKeys (instr 2)
massign 0, 2
; Lock program-change routing
pgmassign 0, 2

#include "my_udos.inc"

; Sine wave table
giSine  ftgen  0, 0, 65536, 10, 1

; Global mod targets
gkBright init 0
gkChorus init 0

; Global stereo accumulation bus
gaAccL  init  0
gaAccR  init  0

; =======================================================
; ModController — subtle, slow evolution for brightness
; =======================================================
instr ModController
  seed 0
  kG1  jspline  0.55, 0.0008, 0.010
  kG2  jspline  0.35, 0.0020, 0.014
  gkBright = 0.25 + tanh(kG1) * 0.7
  gkChorus = 0.12 + tanh(kG2) * 0.44
endin

; =======================================================
; DigitalKeys
; A velocity-sensitive electric-keys / Rhodes-like voice.
; - Short velocity-to-attack mapping for percussive feel
; - Noise-based hammer transient + tuned partials for body
; - Gentle saturation, stereo spread
; Writes into a global mix bus processed by KeysMix
; =======================================================
instr DigitalKeys
  seed 0

  ; MIDI input
  iVel   veloc
  iFreq  cpsmidi
  iAmp   = (iVel / 127.0) * 0.35

  ; Release and render tail
  iRel   = 1.20 + (1 - iVel/127.0) * 0.80
  xtratim  iRel + giRenderTail

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

  ; Body: multiple sine partials with slight detune
  iDet1 random -0.0012, 0.0012
  iDet2 random -0.0025, 0.0025
  aP1 oscili aEnvBody*0.78, iFreq*kVib*(1+iDet1), giSine
  aP2 oscili aEnvBody*0.46, iFreq*2.0*kVib*(1+iDet2), giSine
  aP3 oscili aEnvBody*0.24, iFreq*3.0*kVib*(1+iDet2*0.6), giSine
  aBody = (aP1 + aP2*0.82 + aP3*0.56) * iAmp

  ; Pickup / tine character via resonant bandpass stages (modulated by LFO)
  kBright = gkBright
  aPickup1 reson aBody, iFreq * (1.0 + 0.12*kBright + kMod*0.08), iFreq*0.6, 1
  aPickup2 reson aBody, iFreq * (2.0 + 0.55*kBright + kMod*0.08), iFreq*1.0, 1

  ; Mix body + hammer transient — emphasize body, keep hammer subtle
  aKeysRaw = aBody*0.86 + aPickup1*0.28 + aPickup2*0.09 + aHammer*0.30

  ; Gentle velocity/brightness-dependent saturation + small tremolo
  aSat = tanh(aKeysRaw * (1.0 + kBright*0.66 + kMod*0.08)) * 0.92
  aSat = aSat * (1 + kMod*0.04)

  ; Stereo pan with slight LFO movement
  iPan random -0.35, 0.35
  kPanLFO oscili 1, 0.07, giSine
  kPanMod = kPanLFO * 0.06
  kPL = 0.5 - iPan * 0.5 + kPanMod
  kPR = 0.5 + iPan * 0.5 - kPanMod

  aOutL = aSat * kPL
  aOutR = aSat * kPR

  gaAccL = gaAccL + aOutL
  gaAccR = gaAccR + aOutR
endin

; =======================================================
; KeysMix — subtle chorus + short-medium reverb for keys
; =======================================================
instr KeysMix
  seed 0

  kCh1 oscili 1, 0.14, giSine
  kCh2 oscili 1, 0.20, giSine, 0.33
  kCh3 oscili 1, 0.26, giSine, 0.67

  aBufL delayr 0.040
  aTapL1 deltap3 0.012 + kCh1*(0.003 + gkChorus*0.008)
  aTapL2 deltap3 0.020 + kCh2*(0.004 + gkChorus*0.010)
  aTapL3 deltap3 0.028 + kCh3*(0.003 + gkChorus*0.008)
  delayw gaAccL

  aBufR delayr 0.040
  aTapR1 deltap3 0.014 + kCh2*(0.003 + gkChorus*0.008)
  aTapR2 deltap3 0.022 + kCh3*(0.004 + gkChorus*0.010)
  aTapR3 deltap3 0.030 + kCh1*(0.003 + gkChorus*0.008)
  delayw gaAccR

  aChrL = gaAccL*0.75 + (aTapL1 + aTapL2 + aTapL3) * 0.083
  aChrR = gaAccR*0.75 + (aTapR1 + aTapR2 + aTapR3) * 0.083

  ; Short-large reverb tail tuned for keys
  aRevL, aRevR reverbsc aChrL, aChrR, 0.840, 8000

  aMixL = aChrL*0.80 + aRevL*0.20
  aMixR = aChrR*0.80 + aRevR*0.20

  aMixL butlp aMixL, 9500
  aMixR butlp aMixR, 9500

  aOutL = tanh(aMixL * 1.25)
  aOutR = tanh(aMixR * 1.25)

  outs aOutL, aOutR

  ; Clear global bus each k-cycle
  gaAccL = 0
  gaAccR = 0
endin

</CsInstruments>

<CsScore>
; ModController and KeysMix run as background processes
i "ModController"  0  7200
i "KeysMix"       0  7200

f 0 7200

e
</CsScore>

</CsoundSynthesizer>

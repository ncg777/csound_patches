<CsoundSynthesizer>
<CsOptions>
; Usage: csound -T -F input.mid -o output.wav metaorgan.csd
; Companion script: metaorgan.bat input.mid [output.wav]
; 32-bit float WAV avoids int16 scaling issues with 0dbfs=1
--format=float
</CsOptions>

<CsInstruments>

sr     = 48000
ksmps  = 64
nchnls = 2
0dbfs  = 1

giRenderTail = 10

; Route all MIDI channels to MetaOrgan (instr 2, after MorphController)
massign 0, 2
; Lock program-change routing so MIDI program-change events
; cannot silently redirect notes away from MetaOrgan.
pgmassign 0, 2

#include "my_udos.inc"

; Sine wave table
giSine  ftgen  0, 0, 65536, 10, 1

; -------------------------------------------------------
; Global morph coordinates for vec8
; Driven by MorphController, read by every MetaOrgan voice
; -------------------------------------------------------
gkMX  init  0
gkMY  init  0
gkMZ  init  0

; -------------------------------------------------------
; Global stereo accumulation bus
; MetaOrgan voices write here; OrganMix reads and clears
; -------------------------------------------------------
gaRevL  init  0
gaRevR  init  0

; =======================================================
; MorphController
; Same three-scale jspline orbit as MetaBell — drives the
; global morph coordinates with chaotic non-repeating motion.
; =======================================================
instr MorphController
  seed 0

  kG1  jspline  0.65, 0.0015, 0.010
  kG2  jspline  0.65, 0.0012, 0.009
  kG3  jspline  0.65, 0.0018, 0.011

  kS1  jspline  0.38, 0.012,  0.050
  kS2  jspline  0.38, 0.010,  0.045
  kS3  jspline  0.38, 0.014,  0.055

  kW1  jspline  0.18, 0.040,  0.200
  kW2  jspline  0.18, 0.035,  0.180
  kW3  jspline  0.18, 0.045,  0.220

  ; Moderate cross-coupling — enough chaos for audible drift
  kRX  =  kG1 + kS1 + kW1 + tanh(kG2*kS3)*0.20 + tanh(kG3*kW2)*0.10
  kRY  =  kG2 + kS2 + kW2 + tanh(kG3*kS1)*0.20 + tanh(kG1*kW3)*0.10
  kRZ  =  kG3 + kS3 + kW3 + tanh(kG1*kS2)*0.20 + tanh(kG2*kW1)*0.10

  gkMX  =  tanh(kRX)
  gkMY  =  tanh(kRY)
  gkMZ  =  tanh(kRZ)
endin

; =======================================================
; MetaOrgan
; MIDI-triggered sustained organ tone with 8 morphing
; timbres blended via vec8.  Design principles:
;
;   • Velocity → swell-box attack ramp (8 ms pp to 120 ms ff)
;   • Flat sustain held for as long as the key is depressed
;   • Clean 65 ms release on note-off (pipe closing speed)
;   • No post-release tone decay — the room carries the tail
;   • Per-note tremulant and vibrato for ensemble life
;
; Source timbres:
;   S1 - Flute 8': pure sine + whisper of 2nd harmonic
;   S2 - Principal 8'+4'+2': bright octave stack, gentle chorus
;   S3 - Full drawbar: 9-harmonic Hammond additive stack
;   S4 - Reed FM: oboe/clarinet coloring (C:M=1:1, index decays)
;   S5 - Celeste: two detuned ranks at 8'+4', slow beating
;   S6 - Mixture: upper partials 4x-8x with chorus shimmer
;   S7 - Open pipe: sine tone + chiff noise burst + steady breath
;   S8 - Vox Humana: multi-voice tremulant with sub-harmonic FM
;
; Blend: 50% per-note random cube corner + 50% MorphController
; =======================================================
instr MetaOrgan
  ; ---- MIDI input ----
  iVel   veloc
  ifreq  cpsmidi
  iamp   = (iVel / 127.0) * 0.32

  ; ---- Release time and xtratim ----
  ; 150 ms release plus reverb decay and an extra 10 s render buffer
  iRelTime  =  0.150
  xtratim  iRelTime + 8 + giRenderTail

  ; ---- Per-note random seed (time-seeded: unique for each MIDI event) ----
  seed 0

  ; ---- Swell: velocity maps to attack ramp time ----
  ; pp (vel=1)  → 120 ms slow swell   ff (vel=127) → 8 ms crisp attack
  iSwellAtt  =  0.008 + (1 - iVel/127.0) * 0.112

  ; ---- Per-note stereo pan ----
  iPan  random  -0.55, 0.55
  kPL   =  0.5 - iPan * 0.5
  kPR   =  0.5 + iPan * 0.5

  ; ---- Master sustain envelope ----
  ; linsegr: ramps to 1 over iSwellAtt, sustains at 1 until note-off,
  ; then falls to 0 over iRelTime (this is the correct organ amplitude shape)
  aEnvMain  linsegr  0, iSwellAtt, 1, iRelTime, 0
  ; Secondary: slightly slower attack for detuned-pair voices
  aEnvSub   linsegr  0, iSwellAtt*1.6, 0.94, iRelTime*1.2, 0

  ; ---- Organ tremulant (gentle — classical ensemble depth) ----
  iTremRate   random  5.0, 7.0
  iTremDepth  random  0.010, 0.025
  kTremLFO    oscili  1, iTremRate, giSine
  kTremAmp    =  1 + kTremLFO * iTremDepth

  ; Slow, subtle per-note vibrato — gentle ensemble breath, not noticeable wobble
  iVibRate   random  0.6, 1.8     ; 0.6–1.8 Hz: much slower than classic 5–7 Hz
  iVibDepth  random  0.0004, 0.0009  ; 0.04–0.09% pitch depth — subliminal
  kVibLFO    oscili  1, iVibRate, giSine
  kVib       =  1 + kVibLFO * iVibDepth

  ; ==============================================================
  ; SOURCE 1: Flute 8'
  ; Pure sine at fundamental with a barely audible 2nd harmonic
  ; (10% amplitude) that adds warmth without harmonic complexity.
  ; The most transparent, airy voice in the set.
  ; ==============================================================
  iDtF1   random   0.0003, 0.0012
  aSin1a  oscili   aEnvMain,        ifreq*(1+iDtF1)*kVib,  giSine
  aSin1b  oscili   aEnvMain*0.10,   ifreq*2*kVib,          giSine
  aS1 = (aSin1a + aSin1b) * iamp * 0.55

  ; ==============================================================
  ; SOURCE 2: Principal 8'+4'+2'
  ; Three octave-spaced harmonics (1x, 2x, 4x) with subtle
  ; per-note chorus detuning.  Bright, full, and clear —
  ; the foundational pipe organ principal chorus.
  ; ==============================================================
  iDtP2   random   0.0008, 0.0022
  aSin2a  oscili   aEnvMain,         ifreq*(1+iDtP2)*kVib,         giSine
  aSin2b  oscili   aEnvMain*0.65,    ifreq*2*(1-iDtP2*0.6)*kVib,   giSine
  aSin2c  oscili   aEnvMain*0.38,    ifreq*4*(1+iDtP2*0.4)*kVib,   giSine
  aS2 = (aSin2a + aSin2b + aSin2c) * iamp * 0.36

  ; ==============================================================
  ; SOURCE 3: Full Hammond drawbar stack
  ; 9 sinusoids at the classic Hammond drawbar positions:
  ;   16'(0.5x)  5-1/3'(0.75x)  8'(1x)    4'(2x)    2-2/3'(3x)
  ;   2'(4x)     1-3/5'(5x)     1-1/3'(6x)  1'(8x)
  ; Level weights approximate the "all 8s" full-organ setting.
  ; ==============================================================
  aSin3_1  oscili  aEnvMain*0.70,  ifreq*0.50,  giSine
  aSin3_2  oscili  aEnvMain*0.45,  ifreq*0.75,  giSine
  aSin3_3  oscili  aEnvMain*1.00,  ifreq*1.00,  giSine
  aSin3_4  oscili  aEnvMain*0.80,  ifreq*2.00,  giSine
  aSin3_5  oscili  aEnvMain*0.42,  ifreq*3.00,  giSine
  aSin3_6  oscili  aEnvMain*0.50,  ifreq*4.00,  giSine
  aSin3_7  oscili  aEnvMain*0.28,  ifreq*5.00,  giSine
  aSin3_8  oscili  aEnvMain*0.18,  ifreq*6.00,  giSine
  aSin3_9  oscili  aEnvMain*0.12,  ifreq*8.00,  giSine
  aS3 = (aSin3_1+aSin3_2+aSin3_3+aSin3_4+aSin3_5+aSin3_6+aSin3_7+aSin3_8+aSin3_9) * iamp * 0.38

  ; ==============================================================
  ; SOURCE 4: Reed FM stop — nasal oboe/clarinet
  ; C:M = 1:1 produces strong odd harmonics — the reed character.
  ; Index stays moderately high throughout sustain so the nasal
  ; quality persists, not just on the attack.  A second carrier an
  ; octave up adds the 'squeezed' clarino brightness.
  ; ==============================================================
  iMDet4   random   -0.0020, 0.0020
  kFMIdx4  linseg   2.20, iSwellAtt*2, 0.80, 12, 0.65
  aFMMod4a oscili   kFMIdx4 * ifreq,          ifreq*(1+iMDet4),       giSine
  aFMMod4b oscili   kFMIdx4 * ifreq * 0.60,   ifreq*(1-iMDet4*0.5),   giSine
  aS4env   linsegr  0, iSwellAtt, 1.0, iRelTime, 0
  aS4a     oscili   aS4env,        ifreq*kVib   + aFMMod4a,        giSine
  aS4b     oscili   aS4env*0.50,   ifreq*2*kVib + aFMMod4b,        giSine
  aS4c     oscili   aS4env*0.28,   ifreq*3*kVib + aFMMod4a*0.35,   giSine
  aS4 = (aS4a + aS4b + aS4c) * iamp * 0.42

  ; ==============================================================
  ; SOURCE 5: Celeste (two detuned ranks, 8'+4')
  ; A celeste coupler voices two slightly mistuned ranks — one
  ; sharp, one flat — producing slow, ethereal amplitude beating
  ; (~1-4 Hz depending on pitch).  The most melancholy register.
  ; ==============================================================
  iDtC5a  random   0.0030, 0.0070
  iDtC5b  random   0.0020, 0.0055
  aSin5a  oscili   aEnvMain,         ifreq*(1+iDtC5a)*kVib,    giSine
  aSin5b  oscili   aEnvMain*0.94,    ifreq*(1-iDtC5a)*kVib,    giSine
  aSin5c  oscili   aEnvSub*0.60,     ifreq*2*(1+iDtC5b)*kVib,  giSine
  aSin5d  oscili   aEnvSub*0.56,     ifreq*2*(1-iDtC5b)*kVib,  giSine
  aS5 = (aSin5a + aSin5b + aSin5c + aSin5d) * iamp * 0.26

  ; ==============================================================
  ; SOURCE 6: Mixture (upper partial cluster, 4x-8x)
  ; Pipe organ mixture stops voice only high partials, adding
  ; brightness and "sparkle" to the ensemble.  Slight chorus
  ; detuning makes the cluster shimmer rather than clang.
  ; ==============================================================
  ; Wide detuning on each partial gives the mixture a brilliant shimmer —
  ; tones near these inharmonic ratios phasebeat against each other,
  ; producing a glittering quality very unlike the lower octave sources.
  iDtM6    random   0.0035, 0.0075
  aSin6a   oscili   aEnvMain*1.00,  ifreq*4*(1+iDtM6)*kVib,         giSine
  aSin6a2  oscili   aEnvMain*0.70,  ifreq*4*(1-iDtM6*0.80)*kVib,    giSine
  aSin6b   oscili   aEnvMain*0.80,  ifreq*5*(1-iDtM6*0.70)*kVib,    giSine
  aSin6b2  oscili   aEnvMain*0.55,  ifreq*5*(1+iDtM6*0.55)*kVib,    giSine
  aSin6c   oscili   aEnvMain*0.55,  ifreq*6*(1+iDtM6*0.50)*kVib,    giSine
  aSin6d   oscili   aEnvMain*0.32,  ifreq*8*(1-iDtM6*0.30)*kVib,    giSine
  aS6 = (aSin6a+aSin6a2+aSin6b+aSin6b2+aSin6c+aSin6d) * iamp * 0.28

  ; ==============================================================
  ; SOURCE 7: Open flue pipe (tone + chiff + breath)
  ; A real open pipe has three acoustic layers:
  ;   a) Sine fundamental + soft 2nd harmonic (the standing wave)
  ;   b) Brief noise burst at the pipe mouth on each attack (chiff)
  ;      — band-passed near the 3/2 over-partial for realism
  ;   c) Quiet continuous breathiness from the windway
  ; Together these give the most phonorealistic pipe organ source.
  ; ==============================================================
  iDtPipe7   random   0.0010, 0.0035
  ; Pipe tone
  aSin7a     oscili   aEnvMain,         ifreq*(1+iDtPipe7)*kVib,   giSine
  aSin7b     oscili   aEnvMain*0.35,    ifreq*2*(1-iDtPipe7)*kVib, giSine
  ; Chiff: short noise burst, band-passed near the 3/2 harmonic
  aNoise7a   rand  1
  aChiff7    reson  aNoise7a, ifreq*1.50, ifreq*0.40, 1
  aChiffEnv  expseg  0.001, 0.002, 0.22, 0.060, 0.001
  ; Breath: very quiet steady bandpass noise — just enough windway texture
  aNoise7b   rand  1
  aBreath7   reson  aNoise7b, ifreq, ifreq*0.06, 1
  aS7 = (aSin7a + aSin7b + aChiff7*aChiffEnv*0.32 + aBreath7*aEnvMain*0.040) * iamp * 0.44

  ; ==============================================================
  ; SOURCE 8: Vox Humana / Choir
  ; Multiple detuned sine voices with a per-note tremulant
  ; oscillator and a sub-harmonic FM modulator (C:M = 1:0.5)
  ; that imparts a gentle vowel-like, "ah" formant coloration.
  ; Four voices at fundamental + octave + 12th add body depth.
  ; The most organic and human-sounding of the 8 sources.
  ; ==============================================================
  ; Wide detuning creates a choir of voices that beats slowly;
  ; sub-harmonic FM adds a throat-like formant warmth.
  ; Stronger per-source tremulant (applied only to S8) makes it
  ; stand out from the steady additive sources as clearly animate.
  iDtV8a   random   0.0090, 0.0180
  iDtV8b   random   0.0055, 0.0130
  iTremV8  random   4.5, 6.5
  kTremV8  oscili   1, iTremV8, giSine
  kFMIdx8  linseg   0.50, iSwellAtt*2, 0.16, 10, 0.10
  aFMMod8  oscili   kFMIdx8 * ifreq*0.5, ifreq*0.5, giSine
  aSin8a   oscili   aEnvMain,       ifreq*(1+iDtV8a)*kVib + aFMMod8*0.18, giSine
  aSin8b   oscili   aEnvMain*0.88,  ifreq*(1-iDtV8a)*kVib + aFMMod8*0.12, giSine
  aSin8c   oscili   aEnvSub*0.65,   ifreq*2*(1+iDtV8b)*kVib,               giSine
  aSin8d   oscili   aEnvSub*0.40,   ifreq*3*(1-iDtV8b*0.6)*kVib,           giSine
  aS8 = (aSin8a + aSin8b + aSin8c + aSin8d) * (1 + kTremV8*0.08) * iamp * 0.36

  ; ==============================================================
  ; VEC8 BLEND — continuous per-note timbral drift
  ; Three independent jspline LFOs walk the blend coordinates
  ; throughout the entire sustained note (14-40 s sweep period)
  ; so the timbre never stands still.  Tiny L/R offsets add width.
  ; 50% per-note drift + 50% global MorphController keeps
  ; individual character while the ensemble morphs together.
  ; ==============================================================

  ; Per-note jspline continuously drifts each blend axis
  ; Faster per-note drift: 8–25 s sweeps — audible even on short notes
  iMRa  random  0.040, 0.125
  iMRb  random  0.035, 0.110
  iMRc  random  0.042, 0.130
  kDriftX  jspline  0.9, iMRa*0.5, iMRa
  kDriftY  jspline  0.9, iMRb*0.5, iMRb
  kDriftZ  jspline  0.9, iMRc*0.5, iMRc
  kLocalX  =  tanh(kDriftX)
  kLocalY  =  tanh(kDriftY)
  kLocalZ  =  tanh(kDriftZ)

  ; Blend 50% local cube + 50% global MorphController
  kBlendX  =  kLocalX*0.5 + gkMX*0.5
  kBlendY  =  kLocalY*0.5 + gkMY*0.5
  kBlendZ  =  kLocalZ*0.5 + gkMZ*0.5

  aMixL  vec8  aS1,aS2,aS3,aS4,aS5,aS6,aS7,aS8,  kBlendX,        kBlendY,        kBlendZ
  aMixR  vec8  aS1,aS2,aS3,aS4,aS5,aS6,aS7,aS8,  kBlendX+0.015,  kBlendY-0.010,  kBlendZ+0.012

  ; Apply tremulant and stereo pan
  aOutL  =  aMixL * kTremAmp * kPL
  aOutR  =  aMixR * kTremAmp * kPR

  gaRevL  =  gaRevL + aOutL
  gaRevR  =  gaRevR + aOutR
endin

; =======================================================
; OrganMix
; Reads the global accumulation bus and applies:
;
;   1. Leslie rotating-speaker simulation
;      — Speed drifts between chorale (~0.8 Hz) and tremolo
;        (~6.4 Hz) via jspline (unique each run)
;      — Horn (high-freq, > 800 Hz): amplitude modulation +
;        Doppler effect via short modulated delay (8 ms ± 3 ms)
;      — Rotor (low-freq, < 800 Hz): amplitude modulation only
;      — L and R use 90°-offset oscillators for spatial sweep
;
;   2. Large hall reverbsc (0.900, 8500 Hz cutoff) — organ
;      benefits from a generous, bright acoustic space
;
;   3. Master low-pass (12 kHz) + soft tanh(1.5x) limiter
; =======================================================
instr OrganMix
  seed 0

  ; ---- Leslie speed: locked to chorale regime (0.6-1.2 Hz horn) ----
  ; Never reaches tremolo speed — stays calm and transparent
  kSpeedRaw  jspline  0.5, 0.004, 0.012
  kHornHz    =  0.70 + kSpeedRaw * 0.50   ; 0.45 ... 0.95 Hz — slow chorale
  kRotorHz   =  kHornHz * 0.83            ; woofer rotor slightly slower

  ; Horn AM oscillators — L and R are 90° out of phase so
  ; the sound sweeps convincingly across the stereo field
  kHornAmpL   oscili  1, kHornHz,   giSine, 0.00
  kHornAmpR   oscili  1, kHornHz,   giSine, 0.25
  ; Rotor AM oscillators (same phase offset trick)
  kRotorAmpL  oscili  1, kRotorHz,  giSine, 0.00
  kRotorAmpR  oscili  1, kRotorHz,  giSine, 0.25

  ; ---- Horn Doppler: gentle modulated short delay ----
  ; At chorale speed the Doppler shift is barely perceptible —
  ; adds subtle warmth rather than obvious pitch wobble.
  aBufHornL  delayr  0.025
  aHornTapL  deltap3  0.008 + kHornAmpL*0.0012
  delayw gaRevL

  aBufHornR  delayr  0.025
  aHornTapR  deltap3  0.008 + kHornAmpR*0.0012
  delayw gaRevR

  ; ---- HP/LP split: horn vs rotor bands ----
  aHiL  buthp  aHornTapL, 800     ; horn band: gets Doppler + AM
  aLoL  butlp  gaRevL,    800     ; rotor band: direct signal + AM only
  aHiR  buthp  aHornTapR, 800
  aLoR  butlp  gaRevR,    800

  ; ---- Apply Leslie amplitude modulation — gentle chorale depth ----
  aMixL  =  aHiL*(1 + kHornAmpL*0.09)   +  aLoL*(1 + kRotorAmpL*0.05)
  aMixR  =  aHiR*(1 + kHornAmpR*0.09)   +  aLoR*(1 + kRotorAmpR*0.05)

  ; ---- Large hall reverb (organ sounds best in a big room) ----
  aRevL, aRevR  reverbsc  aMixL, aMixR, 0.865, 8500

  ; Wet/dry: 60% Leslie direct + 40% reverb
  aMixL  =  aMixL*0.60 + aRevL*0.40
  aMixR  =  aMixR*0.60 + aRevR*0.40

  ; ---- Master low-pass (brighter cutoff than MetaBell) ----
  aMixL  butlp  aMixL, 12000
  aMixR  butlp  aMixR, 12000

  ; ---- Soft limiter ----
  aOutL  =  tanh(aMixL * 1.5)
  aOutR  =  tanh(aMixR * 1.5)

  outs  aOutL, aOutR

  ; Clear global bus each k-cycle
  gaRevL  =  0
  gaRevR  =  0
endin

</CsInstruments>

<CsScore>
; MorphController and OrganMix run for up to 2 hours.
; With -T the performance ends once the last MIDI note
; rings out, including the internal 10 s render buffer.
i "MorphController"  0  7200
i "OrganMix"         0  7200

; Keep score alive; -T governs actual end time
f 0 7200

e
</CsScore>

</CsoundSynthesizer>

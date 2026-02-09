<CsoundSynthesizer>
<CsOptions>
; Real-time playback
; csound -odac evolving_drone_template.csd
; File rendering: csound -o out.wav evolving_drone_template.csd
</CsOptions>

<CsInstruments>

sr = 44100
ksmps = 128
nchnls = 2
0dbfs = 1

; ---------------------------
; Global audio buses for 8 drone sources (stereo pairs)
; ---------------------------
gaSourceL1 init 0
gaSourceR1 init 0
gaSourceL2 init 0
gaSourceR2 init 0
gaSourceL3 init 0
gaSourceR3 init 0
gaSourceL4 init 0
gaSourceR4 init 0
gaSourceL5 init 0
gaSourceR5 init 0
gaSourceL6 init 0
gaSourceR6 init 0
gaSourceL7 init 0
gaSourceR7 init 0
gaSourceL8 init 0
gaSourceR8 init 0

; ---------------------------
; Helper functions (k-rate)
; ---------------------------
opcode mapLinear, k, kkkkk
    kIn, kInMin, kInMax, kOutMin, kOutMax xin
    kOut = (kIn - kInMin)*(kOutMax - kOutMin)/(kInMax - kInMin) + kOutMin
    xout kOut
endop

opcode mapExp, k, kkkkk
    kIn, kInMin, kInMax, kOutMin, kOutMax xin
    kNorm = (kIn - kInMin)/(kInMax - kInMin)
    kNorm = max(0, min(1, kNorm))  ; clamp between 0 and 1
    kOut = kOutMin*(kOutMax/kOutMin)^kNorm
    xout kOut
endop

; ---------------------------
; vec8 UDO from my_udos.inc
; Trilinear interpolation between 8 sources
; kx, ky, kz in range [-1, 1]
; ---------------------------
opcode vec8, a, aaaaaaaakkk
    a1, a2, a3, a4, a5, a6, a7, a8, kx, ky, kz xin
    kx1 = ((kx*0.5)+0.5)
    ky1 = ((ky*0.5)+0.5)
    kz1 = ((kz*0.5)+0.5)
    xout (1-kz1)*((1-ky1)*(((1-kx1)*a1)+(kx1*a2))+(ky1)*(((1-kx1)*a3)+(kx1*a4)))+(kz1)*((1-ky1)*(((1-kx1)*a5)+(kx1*a6))+(ky1)*(((1-kx1)*a7)+(kx1*a8)))
endop

; ---------------------------
; Chord interval pool & per-group root note storage
; ---------------------------
; Consonant intervals only: unison, P4, P5, octave
giIntervals ftgen 0, 0, -4, -2,  0, 5, 7, 12

; 5-35 pentatonic degrees in semitones (relative to tonic)
; Forte set class 5-35.05 [0,2,5,7,9]
giScaleDegrees ftgen 0, 0, -5, -2,  0, 2, 5, 7, 9

; Table to hold 8 random root MIDI notes (filled by instr 99)
giGroupRoots ftgen 0, 0, -8, -2,  0, 0, 0, 0, 0, 0, 0, 0

; ---------------------------
; Instrument 99: Initialization
; Picks one random tonic, applies random transposition (-6 to +6),
; then assigns group roots from 5-35 pentatonic built on that tonic.
; Groups are spread across 2 octaves for range.
; ---------------------------
instr 99
    seed p4
    ; Random tonic: MIDI 12 (C-1) to 23 (B-1)
    iTonic random 12, 24
    iTonic = int(iTonic)
    ; Random transposition: -6 to +6 semitones
    iTranspose random -6, 7
    iTranspose = int(iTranspose)
    iTonic = iTonic + iTranspose
    iScaleLen = ftlen(giScaleDegrees)
    iIdx = 0
    while (iIdx < 8) do
        ; Pick a 5-35 degree (cycle through with octave shifts)
        iDegIdx = iIdx % iScaleLen
        iOctShift = int(iIdx / iScaleLen) * 12  ; +12 for groups 6-8
        iDegree table iDegIdx, giScaleDegrees
        iRoot = iTonic + iDegree + iOctShift
        tableiw iRoot, iIdx, giGroupRoots
        iIdx += 1
    od
    turnoff
endin

; ---------------------------
; Instrument 1: Single drone voice
; p4 = morph (0-1)
; p5 = seed
; p6 = group number (1-8) for routing to global bus
; p7 = octave offset (0-3, spreads voices across registers)
; p8 = filter cutoff multiplier
; ---------------------------
instr 1
    iDur = p3
    iMorph = p4
    iSeed = p5
    iInstance = p6
    iOctaveOff = p7
    iCutoffMult = p8
    
    seed iSeed

    ; ---------- amplitude envelope ----------
    iAmp = 0.6
    iAttack = 1 + (iMorph*4)
    iRelease = 2
    kAmpEnv linen iAmp, iAttack, iDur, iRelease

    ; ---------- i-rate control parameters ----------
    ; Read this group's root note from the pre-computed table
    iGroupRoot table iInstance - 1, giGroupRoots
    ; Bass voices (octave 0) always play the root for harmonic anchoring
    ; Upper voices pick a consonant interval (P4, P5, or octave)
    if (iOctaveOff == 0) then
        iInterval = 0
    else
        iTableLen = ftlen(giIntervals)
        iIdx random 0, iTableLen - 0.001
        iIdx = int(iIdx)
        iInterval table iIdx, giIntervals
    endif
    ; Frequency = group root + interval + octave spread
    iBaseFreq = cpsmidinn(iGroupRoot + iInterval + iOctaveOff * 12)
    iOscMix   = 0.2 + iMorph*0.7
    iSpread   = 0.05 + iMorph*0.85

    ; ---------- k-rate control parameters for filter/reverb ----------
    kMorph = iMorph
    kCutoff   = mapExp(kMorph, 0, 1, 200, 5000) * iCutoffMult
    kResonance = mapLinear(kMorph, 0, 1, 0.1, 0.55)

    ; ---------- k-rate LFO for stochastic modulation ----------
    kLfoRate1 = mapExp(kMorph, 0, 1, 0.02, 0.6)
    kLfoRate2 = mapExp(kMorph, 0, 1, 0.005, 0.25)
    kRand1 randh 1.0, kLfoRate1
    kRand2 randh 1.0, kLfoRate2
    kDetuneCents = mapLinear(kRand1, -1, 1, -12*(1-iMorph), 12*iMorph)
    kFilterShift = mapLinear(kRand2, -1, 1, -0.5, 1.5)
    
    ; Frequency multiplier from detuning
    kDetuneMult = cent(kDetuneCents)

    ; ---------- oscillator bank (8 partials, unrolled) ----------
    ; Subtle detuning for warmth — tight enough to stay musical
    iRand0 random -0.006, 0.006
    iRand1 random -0.006, 0.006
    iRand2 random -0.006, 0.006
    iRand3 random -0.006, 0.006
    iRand4 random -0.006, 0.006
    iRand5 random -0.006, 0.006
    iRand6 random -0.006, 0.006
    iRand7 random -0.006, 0.006

    iFreq0 = iBaseFreq * (1.0 + iRand0)
    iFreq1 = iBaseFreq * (1.5 + iRand1)
    iFreq2 = iBaseFreq * (2.0 + iRand2)
    iFreq3 = iBaseFreq * (2.5 + iRand3)
    iFreq4 = iBaseFreq * (3.0 + iRand4)
    iFreq5 = iBaseFreq * (3.5 + iRand5)
    iFreq6 = iBaseFreq * (4.0 + iRand6)
    iFreq7 = iBaseFreq * (4.5 + iRand7)

    iPartAmp = 0.2

    ; Sine oscillators (lower partials)
    aOsc0 oscili iPartAmp * iOscMix, iFreq0 * kDetuneMult, 1
    aOsc1 oscili iPartAmp * iOscMix, iFreq1 * kDetuneMult, 1

    ; Sawtooth oscillators (higher partials)
    aOsc2 vco2 iPartAmp * (1-iOscMix), iFreq2 * kDetuneMult, 0
    aOsc3 vco2 iPartAmp * (1-iOscMix), iFreq3 * kDetuneMult, 0
    aOsc4 vco2 iPartAmp * (1-iOscMix), iFreq4 * kDetuneMult, 0
    aOsc5 vco2 iPartAmp * (1-iOscMix), iFreq5 * kDetuneMult, 0
    aOsc6 vco2 iPartAmp * (1-iOscMix), iFreq6 * kDetuneMult, 0
    aOsc7 vco2 iPartAmp * (1-iOscMix), iFreq7 * kDetuneMult, 0

    iPan0 = -1.0 * iSpread
    iPan1 = -0.714 * iSpread
    iPan2 = -0.429 * iSpread
    iPan3 = -0.143 * iSpread
    iPan4 = 0.143 * iSpread
    iPan5 = 0.429 * iSpread
    iPan6 = 0.714 * iSpread
    iPan7 = 1.0 * iSpread

    aSigL = aOsc0*(0.5 - iPan0*0.5) + aOsc1*(0.5 - iPan1*0.5) + aOsc2*(0.5 - iPan2*0.5) + aOsc3*(0.5 - iPan3*0.5)
    aSigL = aSigL + aOsc4*(0.5 - iPan4*0.5) + aOsc5*(0.5 - iPan5*0.5) + aOsc6*(0.5 - iPan6*0.5) + aOsc7*(0.5 - iPan7*0.5)
    
    aSigR = aOsc0*(0.5 + iPan0*0.5) + aOsc1*(0.5 + iPan1*0.5) + aOsc2*(0.5 + iPan2*0.5) + aOsc3*(0.5 + iPan3*0.5)
    aSigR = aSigR + aOsc4*(0.5 + iPan4*0.5) + aOsc5*(0.5 + iPan5*0.5) + aOsc6*(0.5 + iPan6*0.5) + aOsc7*(0.5 + iPan7*0.5)

    ; ---------- filtering ----------
    kDynCut = kCutoff * (1 + kFilterShift*0.15)
    aFiltL moogladder aSigL, kDynCut, kResonance
    aFiltR moogladder aSigR, kDynCut*1.01, kResonance

    ; ---------- subtle distortion ----------
    aSatL = tanh(aFiltL * (1 + kMorph*0.5))
    aSatR = tanh(aFiltR * (1 + kMorph*0.5))

    ; Apply envelope (spatial effects handled by master mixer)
    aOutL = aSatL * kAmpEnv
    aOutR = aSatR * kAmpEnv

    ; ---------- Route to global bus based on instance number ----------
    if (iInstance == 1) then
        gaSourceL1 = gaSourceL1 + aOutL
        gaSourceR1 = gaSourceR1 + aOutR
    elseif (iInstance == 2) then
        gaSourceL2 = gaSourceL2 + aOutL
        gaSourceR2 = gaSourceR2 + aOutR
    elseif (iInstance == 3) then
        gaSourceL3 = gaSourceL3 + aOutL
        gaSourceR3 = gaSourceR3 + aOutR
    elseif (iInstance == 4) then
        gaSourceL4 = gaSourceL4 + aOutL
        gaSourceR4 = gaSourceR4 + aOutR
    elseif (iInstance == 5) then
        gaSourceL5 = gaSourceL5 + aOutL
        gaSourceR5 = gaSourceR5 + aOutR
    elseif (iInstance == 6) then
        gaSourceL6 = gaSourceL6 + aOutL
        gaSourceR6 = gaSourceR6 + aOutR
    elseif (iInstance == 7) then
        gaSourceL7 = gaSourceL7 + aOutL
        gaSourceR7 = gaSourceR7 + aOutR
    elseif (iInstance == 8) then
        gaSourceL8 = gaSourceL8 + aOutL
        gaSourceR8 = gaSourceR8 + aOutR
    endif
endin

; ---------------------------
; Instrument 2: Main vectorial mixer
; Uses vec8 to crossfade between 8 drone sources
; with 3 LFOs controlling x, y, z coordinates
; ---------------------------
instr 2
    iDur = p3
    iSeed = p4
    seed iSeed

    ; ---------- Master amplitude envelope ----------
    iAmp = 1.0
    kMasterEnv linen iAmp, 5, iDur, 6

    ; ---------- Ultra-slow chaotic vectorial control ----------
    ; Each axis is a sum of 3 layers at very different time scales,
    ; cross-coupled for unpredictable orbital movement

    ; Layer 1: glacial drift (100-1000s cycles)
    kGlacial1 jspline 0.6, 0.001, 0.01
    kGlacial2 jspline 0.6, 0.0008, 0.009
    kGlacial3 jspline 0.6, 0.0012, 0.011

    ; Layer 2: slow evolution (30-100s cycles)
    kSlow1 jspline 0.4, 0.01, 0.035
    kSlow2 jspline 0.4, 0.008, 0.03
    kSlow3 jspline 0.4, 0.012, 0.04

    ; Layer 3: gentle wander (10-50s)
    kWander1 jspline 0.2, 0.02, 0.1
    kWander2 jspline 0.2, 0.018, 0.09
    kWander3 jspline 0.2, 0.025, 0.11

    ; Heavy cross-coupling for chaotic orbital paths
    kRawX = kGlacial1 + kSlow1 + kWander1 + tanh(kGlacial2 * kSlow3) * 0.3 + tanh(kGlacial3 * kWander2) * 0.15
    kRawY = kGlacial2 + kSlow2 + kWander2 + tanh(kGlacial3 * kSlow1) * 0.3 + tanh(kGlacial1 * kWander3) * 0.15
    kRawZ = kGlacial3 + kSlow3 + kWander3 + tanh(kGlacial1 * kSlow2) * 0.3 + tanh(kGlacial2 * kWander1) * 0.15

    ; Soft-clip to [-1, 1]
    kX = tanh(kRawX)
    kY = tanh(kRawY)
    kZ = tanh(kRawZ)

    ; ---------- Apply vec8 crossfade to left and right channels ----------
    aMixL vec8 gaSourceL1, gaSourceL2, gaSourceL3, gaSourceL4, gaSourceL5, gaSourceL6, gaSourceL7, gaSourceL8, kX, kY, kZ
    aMixR vec8 gaSourceR1, gaSourceR2, gaSourceR3, gaSourceR4, gaSourceR5, gaSourceR6, gaSourceR7, gaSourceR8, kX, kY, kZ

    ; ==========================================================
    ; FILTER VEC8: 8 antipodal filters with slow chaotic morphing
    ; Each corner has a fundamentally different filter character
    ; ==========================================================

    ; --- Chaotic LFOs for filter vec8 (independent from drone vec8) ---
    ; Glacial layer (200-800s)
    kFGlac1 jspline 0.65, 0.0012, 0.005
    kFGlac2 jspline 0.65, 0.001,  0.006
    kFGlac3 jspline 0.65, 0.0015, 0.0045

    ; Slow layer (40-120s)
    kFSlow1 jspline 0.35, 0.008, 0.025
    kFSlow2 jspline 0.35, 0.007, 0.022
    kFSlow3 jspline 0.35, 0.009, 0.028

    ; Drift layer (15-60s)
    kFDrift1 jspline 0.18, 0.017, 0.07
    kFDrift2 jspline 0.18, 0.015, 0.065
    kFDrift3 jspline 0.18, 0.02, 0.075

    ; Cross-couple filter axes
    kFRawX = kFGlac1 + kFSlow1 + kFDrift1 + tanh(kFGlac2 * kFSlow3) * 0.25
    kFRawY = kFGlac2 + kFSlow2 + kFDrift2 + tanh(kFGlac3 * kFSlow1) * 0.25
    kFRawZ = kFGlac3 + kFSlow3 + kFDrift3 + tanh(kFGlac1 * kFSlow2) * 0.25
    kFX = tanh(kFRawX)
    kFY = tanh(kFRawY)
    kFZ = tanh(kFRawZ)

    ; --- Slowly wandering filter parameters ---
    kFCrawl1 jspline 1, 0.003, 0.02
    kFCrawl2 jspline 1, 0.004, 0.025
    kFCrawl3 jspline 1, 0.002, 0.015

    ; 8 comb filters tuned to musical pitches from the pentatonic scale
    ; Each corner uses a different scale degree + octave for variety
    ; Delay times derived from MIDI notes for musical resonance
    ; Feedback (resonance) varies per filter for timbral contrast

    ; Read the root for comb tuning reference
    iCombRoot table 0, giGroupRoots

    ; --- Filter 1 (corner -1,-1,-1): root, low register ---
    iComb1midi = iCombRoot + 24  ; +2 octaves into audible range
    iComb1dly = 1 / cpsmidinn(iComb1midi)
    kComb1dly = iComb1dly * (1 + kFCrawl1 * 0.03)  ; subtle drift
    aF1L vcomb aMixL, 0.82, kComb1dly, 0.05
    aF1R vcomb aMixR, 0.82, kComb1dly * 1.005, 0.05
    aF1L = aF1L * 0.7 + aMixL * 0.3
    aF1R = aF1R * 0.7 + aMixR * 0.3

    ; --- Filter 2 (corner +1,-1,-1): +P5, low register ---
    iComb2midi = iCombRoot + 24 + 7
    iComb2dly = 1 / cpsmidinn(iComb2midi)
    kComb2dly = iComb2dly * (1 + kFCrawl2 * 0.03)
    aF2L vcomb aMixL, 0.85, kComb2dly, 0.05
    aF2R vcomb aMixR, 0.85, kComb2dly * 1.005, 0.05
    aF2L = aF2L * 0.7 + aMixL * 0.3
    aF2R = aF2R * 0.7 + aMixR * 0.3

    ; --- Filter 3 (corner -1,+1,-1): +2 semitones, mid register ---
    iComb3midi = iCombRoot + 36 + 2
    iComb3dly = 1 / cpsmidinn(iComb3midi)
    kComb3dly = iComb3dly * (1 + kFCrawl3 * 0.03)
    aF3L vcomb aMixL, 0.78, kComb3dly, 0.025
    aF3R vcomb aMixR, 0.78, kComb3dly * 1.005, 0.025
    aF3L = aF3L * 0.7 + aMixL * 0.3
    aF3R = aF3R * 0.7 + aMixR * 0.3

    ; --- Filter 4 (corner +1,+1,-1): +P4, mid register ---
    iComb4midi = iCombRoot + 36 + 5
    iComb4dly = 1 / cpsmidinn(iComb4midi)
    kComb4dly = iComb4dly * (1 + kFCrawl1 * 0.025)
    aF4L vcomb aMixL, 0.88, kComb4dly, 0.025
    aF4R vcomb aMixR, 0.88, kComb4dly * 1.005, 0.025
    aF4L = aF4L * 0.7 + aMixL * 0.3
    aF4R = aF4R * 0.7 + aMixR * 0.3

    ; --- Filter 5 (corner -1,-1,+1): +9 semitones (maj6), mid register ---
    iComb5midi = iCombRoot + 36 + 9
    iComb5dly = 1 / cpsmidinn(iComb5midi)
    kComb5dly = iComb5dly * (1 + kFCrawl2 * 0.025)
    aF5L vcomb aMixL, 0.75, kComb5dly, 0.02
    aF5R vcomb aMixR, 0.75, kComb5dly * 1.005, 0.02
    aF5L = aF5L * 0.7 + aMixL * 0.3
    aF5R = aF5R * 0.7 + aMixR * 0.3

    ; --- Filter 6 (corner +1,-1,+1): root, high register ---
    iComb6midi = iCombRoot + 48
    iComb6dly = 1 / cpsmidinn(iComb6midi)
    kComb6dly = iComb6dly * (1 + kFCrawl3 * 0.02)
    aF6L vcomb aMixL, 0.72, kComb6dly, 0.012
    aF6R vcomb aMixR, 0.72, kComb6dly * 1.005, 0.012
    aF6L = aF6L * 0.7 + aMixL * 0.3
    aF6R = aF6R * 0.7 + aMixR * 0.3

    ; --- Filter 7 (corner -1,+1,+1): +P5, high register ---
    iComb7midi = iCombRoot + 48 + 7
    iComb7dly = 1 / cpsmidinn(iComb7midi)
    kComb7dly = iComb7dly * (1 + kFCrawl1 * 0.02)
    aF7L vcomb aMixL, 0.80, kComb7dly, 0.012
    aF7R vcomb aMixR, 0.80, kComb7dly * 1.005, 0.012
    aF7L = aF7L * 0.7 + aMixL * 0.3
    aF7R = aF7R * 0.7 + aMixR * 0.3

    ; --- Filter 8 (corner +1,+1,+1): +octave+P4, highest ---
    iComb8midi = iCombRoot + 48 + 5
    iComb8dly = 1 / cpsmidinn(iComb8midi)
    kComb8dly = iComb8dly * (1 + kFCrawl2 * 0.02)
    aF8L vcomb aMixL, 0.70, kComb8dly, 0.01
    aF8R vcomb aMixR, 0.70, kComb8dly * 1.005, 0.01
    aF8L = aF8L * 0.7 + aMixL * 0.3
    aF8R = aF8R * 0.7 + aMixR * 0.3

    ; --- Apply filter vec8 crossfade ---
    aMixL vec8 aF1L, aF2L, aF3L, aF4L, aF5L, aF6L, aF7L, aF8L, kFX, kFY, kFZ
    aMixR vec8 aF1R, aF2R, aF3R, aF4R, aF5R, aF6R, aF7R, aF8R, kFX, kFY, kFZ

    ; ---------- Makeup gain after filter vec8 ----------
    aMixL = aMixL * 2.0
    aMixR = aMixR * 2.0

    ; ---------- Stereo multi-tap echo ----------
    aBufL delayr 4.0
    aTapL1 deltap3 0.375
    aTapL2 deltap3 1.125
    aTapL3 deltap3 2.25
    delayw aMixL + aTapL1 * 0.5

    aBufR delayr 4.0
    aTapR1 deltap3 0.5
    aTapR2 deltap3 1.333
    aTapR3 deltap3 2.667
    delayw aMixR + aTapR1 * 0.5

    aMixL = aMixL + aTapL1*0.35 + aTapL2*0.2 + aTapL3*0.1
    aMixR = aMixR + aTapR1*0.35 + aTapR2*0.2 + aTapR3*0.1

    ; ---------- Master reverb for spatial cohesion ----------
    aMstRevL, aMstRevR reverbsc aMixL, aMixR, 0.94, 10000
    aMixL = aMixL*0.35 + aMstRevL*0.65
    aMixR = aMixR*0.35 + aMstRevR*0.65

    ; ---------- Soft limiter ----------
    aMixL = aMixL * 2.0
    aMixR = aMixR * 2.0
    aOutL = tanh(aMixL)
    aOutR = tanh(aMixR)

    ; ---------- Master output ----------
    outs aOutL * kMasterEnv, aOutR * kMasterEnv

    ; ---------- Clear global buses ----------
    gaSourceL1 = 0
    gaSourceR1 = 0
    gaSourceL2 = 0
    gaSourceR2 = 0
    gaSourceL3 = 0
    gaSourceR3 = 0
    gaSourceL4 = 0
    gaSourceR4 = 0
    gaSourceL5 = 0
    gaSourceR5 = 0
    gaSourceL6 = 0
    gaSourceR6 = 0
    gaSourceL7 = 0
    gaSourceR7 = 0
    gaSourceL8 = 0
    gaSourceR8 = 0
endin

</CsInstruments>

<CsScore>
; f1 = sine wave table
f1 0 16384 10 1

; Initialize 8 random root notes (runs once, then turns off)
i99 0 0.01 __SEED__

; 8 drone groups × 4 voices = 32 voices → meta vec8
; p1=instr p2=start p3=dur p4=morph p5=seed p6=group(1-8) p7=octaveOff p8=cutoffMult
; Each group gets its own random root note; each voice picks a random chord interval

; Group 1 (vec8 corner -1,-1,-1)
i1 0.02 __DURATION__ 0.1  10001 1  0  0.5
i1 0.02 __DURATION__ 0.35 10002 1  1  0.8
i1 0.02 __DURATION__ 0.65 10003 1  2  1.3
i1 0.02 __DURATION__ 0.9  10004 1  3  1.8

; Group 2 (vec8 corner +1,-1,-1)
i1 0.02 __DURATION__ 0.1  20001 2  0  0.5
i1 0.02 __DURATION__ 0.35 20002 2  1  0.8
i1 0.02 __DURATION__ 0.65 20003 2  2  1.3
i1 0.02 __DURATION__ 0.9  20004 2  3  1.8

; Group 3 (vec8 corner -1,+1,-1)
i1 0.02 __DURATION__ 0.1  30001 3  0  0.5
i1 0.02 __DURATION__ 0.35 30002 3  1  0.8
i1 0.02 __DURATION__ 0.65 30003 3  2  1.3
i1 0.02 __DURATION__ 0.9  30004 3  3  1.8

; Group 4 (vec8 corner +1,+1,-1)
i1 0.02 __DURATION__ 0.1  40001 4  0  0.5
i1 0.02 __DURATION__ 0.35 40002 4  1  0.8
i1 0.02 __DURATION__ 0.65 40003 4  2  1.3
i1 0.02 __DURATION__ 0.9  40004 4  3  1.8

; Group 5 (vec8 corner -1,-1,+1)
i1 0.02 __DURATION__ 0.1  50001 5  0  0.5
i1 0.02 __DURATION__ 0.35 50002 5  1  0.8
i1 0.02 __DURATION__ 0.65 50003 5  2  1.3
i1 0.02 __DURATION__ 0.9  50004 5  3  1.8

; Group 6 (vec8 corner +1,-1,+1)
i1 0.02 __DURATION__ 0.1  60001 6  0  0.5
i1 0.02 __DURATION__ 0.35 60002 6  1  0.8
i1 0.02 __DURATION__ 0.65 60003 6  2  1.3
i1 0.02 __DURATION__ 0.9  60004 6  3  1.8

; Group 7 (vec8 corner -1,+1,+1)
i1 0.02 __DURATION__ 0.1  70001 7  0  0.5
i1 0.02 __DURATION__ 0.35 70002 7  1  0.8
i1 0.02 __DURATION__ 0.65 70003 7  2  1.3
i1 0.02 __DURATION__ 0.9  70004 7  3  1.8

; Group 8 (vec8 corner +1,+1,+1)
i1 0.02 __DURATION__ 0.1  80001 8  0  0.5
i1 0.02 __DURATION__ 0.35 80002 8  1  0.8
i1 0.02 __DURATION__ 0.65 80003 8  2  1.3
i1 0.02 __DURATION__ 0.9  80004 8  3  1.8

; Meta vec8 mixer — ultra-slow chaotic morphing between 8 drone groups
i2 0.02 __DURATION__ __SEED__

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
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>

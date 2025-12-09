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
; Instrument 1: Single drone voice
; p4 = morph (0-1)
; p5 = seed
; p6 = instance number (1-8) for routing to global bus
; p7 = base frequency multiplier
; p8 = filter cutoff multiplier
; ---------------------------
instr 1
    iDur = p3
    iMorph = p4
    iSeed = p5
    iInstance = p6
    iFreqMult = p7
    iCutoffMult = p8
    
    seed iSeed

    ; ---------- amplitude envelope ----------
    iAmp = 0.5
    iAttack = 1 + (iMorph*4)
    iRelease = 2
    kAmpEnv linen iAmp, iAttack, iDur, iRelease

    ; ---------- i-rate control parameters ----------
    iBaseFreq = 40 * pow(240/40, iMorph) * iFreqMult
    iOscMix   = 0.2 + iMorph*0.7
    iSpread   = 0.05 + iMorph*0.85

    ; ---------- k-rate control parameters for filter/reverb ----------
    kMorph = iMorph
    kCutoff   = mapExp(kMorph, 0, 1, 200, 8000) * iCutoffMult
    kResonance = mapLinear(kMorph, 0, 1, 0.1, 0.85)
    kReverbMix = mapLinear(kMorph, 0, 1, 0.1, 0.5)

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
    iRand0 random -0.1, 0.1
    iRand1 random -0.1, 0.1
    iRand2 random -0.1, 0.1
    iRand3 random -0.1, 0.1
    iRand4 random -0.1, 0.1
    iRand5 random -0.1, 0.1
    iRand6 random -0.1, 0.1
    iRand7 random -0.1, 0.1

    iFreq0 = iBaseFreq * (1.0 + iRand0)
    iFreq1 = iBaseFreq * (1.5 + iRand1)
    iFreq2 = iBaseFreq * (2.0 + iRand2)
    iFreq3 = iBaseFreq * (2.5 + iRand3)
    iFreq4 = iBaseFreq * (3.0 + iRand4)
    iFreq5 = iBaseFreq * (3.5 + iRand5)
    iFreq6 = iBaseFreq * (4.0 + iRand6)
    iFreq7 = iBaseFreq * (4.5 + iRand7)

    iPartAmp = 0.12

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

    ; ---------- reverb (individual per voice for variety) ----------
    aRevL, aRevR reverbsc aSatL, aSatR, 0.85, 8000
    aOutL = (1-kReverbMix)*aSatL + kReverbMix*aRevL
    aOutR = (1-kReverbMix)*aSatR + kReverbMix*aRevR

    ; Apply envelope
    aOutL = aOutL * kAmpEnv
    aOutR = aOutR * kAmpEnv

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
    iAmp = 0.8
    kMasterEnv linen iAmp, 3, iDur, 4

    ; ---------- LFOs for vectorial control (different rates for organic movement) ----------
    ; X-axis LFO: slowest, controls low/high frequency blend
    kLfoX lfo 1, 0.031, 0    ; ~32 second cycle, sine
    
    ; Y-axis LFO: medium speed, controls timbral darkness
    kLfoY lfo 1, 0.047, 0    ; ~21 second cycle, sine
    
    ; Z-axis LFO: fastest, controls density/complexity
    kLfoZ lfo 1, 0.071, 0    ; ~14 second cycle, sine

    ; Add some subtle randomness to the LFO movement
    kRandX randh 0.15, 0.1
    kRandY randh 0.15, 0.08
    kRandZ randh 0.15, 0.12
    
    kX = kLfoX + kRandX
    kY = kLfoY + kRandY
    kZ = kLfoZ + kRandZ
    
    ; Clamp to valid range
    kX = max(-1, min(1, kX))
    kY = max(-1, min(1, kY))
    kZ = max(-1, min(1, kZ))

    ; ---------- Apply vec8 crossfade to left and right channels ----------
    aMixL vec8 gaSourceL1, gaSourceL2, gaSourceL3, gaSourceL4, gaSourceL5, gaSourceL6, gaSourceL7, gaSourceL8, kX, kY, kZ
    aMixR vec8 gaSourceR1, gaSourceR2, gaSourceR3, gaSourceR4, gaSourceR5, gaSourceR6, gaSourceR7, gaSourceR8, kX, kY, kZ

    ; ---------- Master output ----------
    outs aMixL * kMasterEnv, aMixR * kMasterEnv

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

; 8 drone voices with drastically different settings
; p1=instr p2=start p3=dur p4=morph p5=seed p6=instance p7=freqMult p8=cutoffMult

; Voice 1: Deep sub-bass, dark (corner -1,-1,-1)
i1 0 __DURATION__ 0.05  11111 1  0.25   0.3
; Voice 2: Low bass, slightly brighter (corner +1,-1,-1)
i1 0 __DURATION__ 0.15  22222 2  0.5    0.5
; Voice 3: Low-mid, warm (corner -1,+1,-1)
i1 0 __DURATION__ 0.3   33333 3  0.75   0.7
; Voice 4: Mid-range, neutral (corner +1,+1,-1)
i1 0 __DURATION__ 0.45  44444 4  1.0    1.0
; Voice 5: Mid-high, airy (corner -1,-1,+1)
i1 0 __DURATION__ 0.6   55555 5  1.5    1.3
; Voice 6: High, shimmering (corner +1,-1,+1)
i1 0 __DURATION__ 0.75  66666 6  2.0    1.6
; Voice 7: Very high, ethereal (corner -1,+1,+1)
i1 0 __DURATION__ 0.9   77777 7  3.0    2.0
; Voice 8: Highest, crystalline (corner +1,+1,+1)
i1 0 __DURATION__ 1.0   88888 8  4.0    2.5

; Main vectorial mixer (must run after drone voices, hence higher instr number)
i2 0 __DURATION__ __SEED__

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

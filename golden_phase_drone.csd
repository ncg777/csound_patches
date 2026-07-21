<CsoundSynthesizer>
<CsOptions>
; Real-time playback: csound -odac golden_phase_drone.csd
; File rendering: csound -o out.wav golden_phase_drone.csd
</CsOptions>

<CsInstruments>

sr = 48000
ksmps = 64
nchnls = 2
0dbfs = 1

giPhi = 1.61803398875

gaWashL init 0
gaWashR init 0
gaRootL init 0
gaRootR init 0

opcode mapExp, k, kkkkk
    kIn, kInMin, kInMax, kOutMin, kOutMax xin
    kNorm = (kIn - kInMin)/(kInMax - kInMin)
    kNorm = max(0, min(1, kNorm))
    kOut = kOutMin*(kOutMax/kOutMin)^kNorm
    xout kOut
endop

opcode softclip, a, ak
    aIn, kDrive xin
    xout tanh(aIn * kDrive) / tanh(kDrive)
endop

; ------------------------------------------------------------
; Golden-ratio drone voice
; p4 = base frequency
; p5 = layer index
; p6 = seed
; p7 = amplitude scale
; p8 = stereo phase depth
; ------------------------------------------------------------
instr 1
    iDur = p3
    iBase = p4
    iLayer = p5
    iSeed = p6
    iAmp = p7
    iPhaseDepth = p8

    seed iSeed

    iOctave = int((iLayer - 1) / 3)
    iFold = iLayer - (iOctave * 3)
    iLayerBase = iBase * (2 ^ iOctave)

    ; Golden ratios folded into a compact harmonic band.
    iRatio1 = 1
    iRatio2 = giPhi
    iRatio3 = (giPhi ^ 2) / 2
    iRatio4 = (giPhi ^ 3) / 4
    iRatio5 = (giPhi ^ 4) / 4
    iRatio6 = (giPhi ^ 5) / 8
    iRatio7 = (giPhi ^ 6) / 16
    iRatio8 = (giPhi ^ 7) / 16

    iDetune random -0.35, 0.35
    iSlowRate random 0.003, 0.018
    iBreathRate random 0.011, 0.055
    iCombDrift random 0.002, 0.012
    iPhaseBias random 0.12, 0.38

    iHold = max(0.1, iDur - 18)
    kEntry linseg 0, 8 + iLayer * 1.7, 1, iHold, 1, 10, 0
    kBreath oscili 0.16, iBreathRate, 1, iPhaseBias
    kBreath = 0.84 + kBreath
    kWander jspline 1, iSlowRate, iSlowRate * 4
    kDetune = cent((kWander * 4) + iDetune)

    kLayerTilt oscili 1, 0.002 + (iLayer * 0.0007), 1, iLayer * 0.071
    kBright = mapExp(kLayerTilt, -1, 1, 0.65, 1.45)

    a1 oscili 0.28, iLayerBase * iRatio1 * kDetune, 1, 0.00
    a2 oscili 0.21, iLayerBase * iRatio2 * kDetune, 1, 0.13
    a3 oscili 0.17, iLayerBase * iRatio3 * kDetune, 1, 0.21
    a4 oscili 0.13, iLayerBase * iRatio4 * kDetune, 1, 0.34
    a5 oscili 0.10, iLayerBase * iRatio5 * kDetune, 1, 0.55
    a6 oscili 0.075, iLayerBase * iRatio6 * kDetune, 1, 0.89
    a7 oscili 0.055, iLayerBase * iRatio7 * kDetune, 1, 0.08
    a8 oscili 0.040, iLayerBase * iRatio8 * kDetune, 1, 0.44

    aCore = a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8

    ; The side layer is intentionally polarity-opposed between ears.
    aInv1 oscili 0.22, iLayerBase * iRatio1 * kDetune, 1, 0.50
    aInv2 oscili 0.18, iLayerBase * iRatio2 * kDetune, 1, 0.63
    aInv3 oscili 0.14, iLayerBase * iRatio3 * kDetune, 1, 0.71
    aInv4 oscili 0.11, iLayerBase * iRatio4 * kDetune, 1, 0.84
    aInv5 oscili 0.085, iLayerBase * iRatio5 * kDetune, 1, 0.05
    aInv6 oscili 0.060, iLayerBase * iRatio6 * kDetune, 1, 0.39
    aInv7 oscili 0.045, iLayerBase * iRatio7 * kDetune, 1, 0.58
    aInv8 oscili 0.032, iLayerBase * iRatio8 * kDetune, 1, 0.94
    aSide = aInv1 + aInv2 + aInv3 + aInv4 + aInv5 + aInv6 + aInv7 + aInv8

    kSidePulse oscili 0.23, 0.006 + (iLayer * 0.0009), 1, iLayer * 0.113
    kSideDepth = iPhaseDepth * (0.72 + kSidePulse)

    kCut = mapExp(kBright, 0.65, 1.45, 520, 4200)
    aCore butlp aCore, kCut
    aSide butlp aSide, kCut * 1.12
    aCore butterhp aCore, 24
    aSide butterhp aSide, 24

    aCombSend = (aCore * 0.55) + (aSide * 0.45)
    kComb = (1 / (iLayerBase * giPhi)) * (1 + (kWander * iCombDrift))
    aComb vcomb aCombSend, 0.42, kComb, 0.08

    aCenter = (aCore * 0.45) + (aComb * 0.18)
    aSide = (aSide * 0.36) + (aComb * 0.20)

    aOutL = (aCenter + aSide * kSideDepth) * kEntry * kBreath * iAmp
    aOutR = (aCenter - aSide * kSideDepth) * kEntry * kBreath * iAmp

    if (iFold == 1) then
        gaRootL = gaRootL + aOutL
        gaRootR = gaRootR + aOutR
    else
        gaWashL = gaWashL + aOutL
        gaWashR = gaWashR + aOutR
    endif
endin

; ------------------------------------------------------------
; Master mixer
; p4 = seed
; ------------------------------------------------------------
instr 2
    iDur = p3
    iSeed = p4
    seed iSeed

    iHold = max(0.1, iDur - 24)
    kEnv linseg 0, 12, 1, iHold, 1, 12, 0
    kLowPulse oscili 0.08, 0.004, 1, 0.27
    kWidePulse oscili 0.18, 0.0031, 1, 0.61

    aRootL moogladder gaRootL, 900 + (kLowPulse * 320), 0.22
    aRootR moogladder gaRootR, 930 + (kLowPulse * 330), 0.22
    aWashL moogladder gaWashL, 2100 + (kWidePulse * 900), 0.18
    aWashR moogladder gaWashR, 2180 + (kWidePulse * 940), 0.18

    aMixL = (aRootL * 0.85) + (aWashL * 0.72)
    aMixR = (aRootR * 0.85) + (aWashR * 0.72)

    aDelL delayr 6.0
    aTapL1 deltap3 0.809
    aTapL2 deltap3 2.118
    aTapL3 deltap3 4.236
    delayw aMixL + aTapL2 * 0.22

    aDelR delayr 6.0
    aTapR1 deltap3 1.000
    aTapR2 deltap3 2.618
    aTapR3 deltap3 4.854
    delayw aMixR + aTapR2 * 0.22

    aMixL = aMixL + aTapL1 * 0.22 + aTapL2 * 0.15 + aTapL3 * 0.09
    aMixR = aMixR + aTapR1 * 0.22 + aTapR2 * 0.15 + aTapR3 * 0.09

    aRevL, aRevR reverbsc aMixL, aMixR, 0.93, 5400
    aMixL = aMixL * 0.42 + aRevL * 0.58
    aMixR = aMixR * 0.42 + aRevR * 0.58

    aMixL butlp aMixL, 6200
    aMixR butlp aMixR, 6200
    aMixL butterhp aMixL, 22
    aMixR butterhp aMixR, 22

    aOutL softclip aMixL, 1.8
    aOutR softclip aMixR, 1.8

    outs aOutL * kEnv * 0.78, aOutR * kEnv * 0.78

    gaWashL = 0
    gaWashR = 0
    gaRootL = 0
    gaRootR = 0
endin

</CsInstruments>

<CsScore>
f1 0 16384 10 1

; Golden-ratio harmonics layered with bilateral phase-inversion.
; p1=instr p2=start p3=dur p4=baseHz p5=layer p6=seed p7=amp p8=phaseDepth

i1 0.02 __DURATION__ 54.000 1 11001 0.135 0.56
i1 0.02 __DURATION__ 54.000 2 11002 0.118 0.62
i1 0.02 __DURATION__ 54.000 3 11003 0.102 0.68

i1 0.02 __DURATION__ 66.742 4 12001 0.104 0.72
i1 0.02 __DURATION__ 66.742 5 12002 0.091 0.78
i1 0.02 __DURATION__ 66.742 6 12003 0.078 0.82

i1 0.02 __DURATION__ 87.333 7 13001 0.073 0.86
i1 0.02 __DURATION__ 87.333 8 13002 0.064 0.90
i1 0.02 __DURATION__ 87.333 9 13003 0.055 0.94

i1 0.02 __DURATION__ 43.248 2 14001 0.085 0.70
i1 0.02 __DURATION__ 104.665 5 14002 0.060 0.88
i1 0.02 __DURATION__ 33.371 8 14003 0.070 0.76

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
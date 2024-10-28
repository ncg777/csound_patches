<CsoundSynthesizer>


<CsOptions>
-o kick.wav
</CsOptions>


<CsInstruments>

	sr     = 44100
	kr     = 4410
	ksmps  = 10
	nchnls = 2

	instr 1
		kf line 0, p3, 1
		kf pow kf, 0.05
		kf=(kf+p4) + kf*(p5-p4)
		aenv adsr 0.01, 0, 1, 0.005
		ak oscil 0dbfs, kf, 1
		outs ak*aenv, ak*aenv
	endin
</CsInstruments>


<CsScore>
f 1 0 16384 10 1
i 1 0 0.05 4000 20

</CsScore>


</CsoundSynthesizer>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 72 179 400 200
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>

<MacGUI>
ioView nobackground {61680, 61680, 61680}
ioSlider {5, 5} {20, 100} 0.000000 1.000000 0.000000 slider1
ioSlider {45, 5} {20, 100} 0.000000 1.000000 0.000000 slider2
ioSlider {85, 5} {20, 100} 0.000000 1.000000 0.000000 slider3
ioSlider {125, 5} {20, 100} 0.000000 1.000000 0.000000 slider4
ioSlider {165, 5} {20, 100} 0.000000 1.000000 0.000000 slider5
</MacGUI>


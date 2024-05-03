 device zxspectrum128

	org $6500-13				; Origin
tap_b:	db $22,"NONAME",$22			;name		  	HEADER
	db "M"					;type		  	HEADER
	dw end-begin				;program length	  	HEADER
	dw begin				;load point		HEADER
	org $6500







;
;  tbeepr ver.1.1	copyright (c) 1995, 2013 introspec
;
;  beeper engine custom-made for the old game 'tank battle'. it was written under heavy
;  influence of the Wham! by Mark Alexander and the beeper engine by David Whittaker (as used
;  in Dizzy 1), so i am not fully sure how original some of these codes are. a lot of it
;  reads as completely new now. i decided to fix some obvious inefficiencies (because i can).
;


begin
	ld hl,musicData
	call play
	ret



	;engine code

play
	di
	exx
	push	hl
	exx
	push	iy

	ld	a, (hl)
	ld	(CurrentTempo+2), a
	inc	hl

	ld	(SaveSP+1), sp
	ld	sp, hl
	pop	hl
	ld	(PatternChannel1+1), hl
	pop	hl
	ld	(PatternChannel2+1), hl
	pop	hl
	ld	(PatternChannel3+1), hl
SaveSP:
	ld	sp, 0		; pattern pointers have now been initialised

	call	PatternChannel1
	ld	(CurrentPosChannel1+1), hl
	call	PatternChannel2
	ld	(CurrentPosChannel2+1), hl
	call	PatternChannel3
	ld	(CurrentPosChannel3+1), hl

	ld	a, 7		; border colour
	ld	(BorderColour1+1), a
	ld	(BorderColour2+1), a
	ld	(BorderColour3+1), a

	ld	a, 1		; ensure that all channels are reloaded at the start
	ld	b, a
	exx
	ld	b, a
	ld	iyl, a
	jr	UpdateChannel1

;
;  this is the main ('fast') loop where the sound is generated. there are two channels, and every loop iteration updates one of the channels.
;  the switching between channels is achieved by swapping the register set (note the unbalanced exa : exx at the end of the loop).
;
;  the registers for each channel are as follows:
;  A - current port state
;  B - counter of 'slow' loop iterations before changing the current note
;  D - counter of 'fast' loop iterations before alternating the current output state
;  E - number of 'fast' loop iterations during ON
;  H - 24 (when the sound is produced) or 0 (when the channel is silent)
;  L - number of 'fast' loop iterations during OFF
;
;  IYL - counter of 'slow' loop iterations before playing the next drum
;
;  IXH - 'fast' loop iterations counter
;  IXL - 'medium' loop iterations counter
;
;  'fast' loop repeats every 90 t-states. with two equivalent sound channels this corresponds to the discretization frequency
;  of 3500000/90/2 = 19444.4 hz. the 'fast' loop always repeats 256 times, hence it lasts for 90*256 = 23040 t-states. 'medium' loop
;  is used to define the tempo of the tune; the tempo is defined as the number of repetitions of the 'fast' loop within the 'medium'
;  loop. the tempo of 6 corresponds to the shortest note possible lasting 6*23040 = 138240t (~1/25th of a second).
;
;  i can see now that it is possible to speed up the main loop and squeeze more performance out of it. however, i decided to
;  leave the engine sound generator mostly intact and to only do small optimizations outside of the main sound loop, so that
;  the original track from the 'tank battle' sounds without any changes.
;
;  channel one is also modified in a PWM-type fashion (with monotonously decreasing duty cycle). unfortunately, the speed
;  of this variation is independent of the frequency and/or tempo.
;
;  ok, i could not resist and modified the fast sound loop. it now runs at 3500000/88/2 = 19886.4 hz. the fact that the 'fast' loop
;  has the number of tacts which is divisible by 8 is highly important on contended spectrums, where this improves the quality of
;  sound by quite a significant margin. 256 repetitions of the 'fast' loop last for 88*256 = 22528 t-states.
;

PreCoreSoundLoop:	; the asymmetry of the 'fast' loop reduces the impact of the 'medium' loop (=better sound)
	nop
	nop				; 8t	(padding the 'fast' loop duration)
CoreSoundLoopExx:
	exx				; 4t

CoreSoundLoop:
	out	($84), a	; 11t
	dec	d			; 4t
	jr	z, AlternateOutput	; 12t/7t

CheckKeyboard:
	ld	c, a		; 4t
	xor	a			; 4t
	in	a, (254)	; 11t
	cpl				; 4t
	and	31			; 7t
	ld	a, c		; 4t
	jr	z, CoreLoopPart2	; 10t => 11+4+7 + 4+4+11+4+7+4+12 = 68t

StopPlayback:
	pop	iy
	pop	hl
	exx
	ei
	ret

AlternateOutput:
	ret	nz			; 5t (waste tacts to align the duration of this branch)
	xor	h			; 4t
	bit	4, a		; 8t
	jp	nz, ItWasLow1		; 10t

ItWasHigh1:
	ld	d, l		; 4t
	jp	CoreLoopPart2		; 10t

ItWasLow1:
	ld	d, e		; 4t
	jp	CoreLoopPart2		; 10t -> 11+4+12 + 5+4+8+10+4+10 = 68t

CoreLoopPart2:
	dec	ixh				; 8t
	dec	ixh				; 8t
	exa					; 4t -> 68t+8+8+4 = 88t

	out	($84), a		; 11t
	exx					; 4t
	dec	d				; 4t
	jr	nz, WasteTime	; 12t/7t

	xor	h				; 4t
	bit	4, a			; 8t
	jp	nz, ItWasLow2	; 10t

ItWasHigh2:
	ld	d, l			; 4t
	jp	NextIteration	; 10t

ItWasLow2:
	ld	d, e			; 4t
	jp	NextIteration	; 10t -> 11+4+4+7 +4+8+10+4+10 = 62t

WasteTime:
	jr	z, $+2			; 11+4+4+12 + X = 62t => X=31t
	db	24, 0, 24, 0

NextIteration:
	exa					; 4t
	jp	nz, PreCoreSoundLoop	; 10t -> 62t + 4+10 + 12t = 88t

	; this is the 'medium' loop, which is responsible for tempo and envelope variations for channel 1
EnvelopeChannel2:
	dec	e
FXType2:
	jr	z, StepBackOverflow2
	inc	l
	db	#0E
StepBackOverflow2:
	inc	e
	exx

	dec	e
FXType1:
	jr	z, StepBackOverflow1	; could be JR Z, nn (duty cycle decay) or JR nn (constant duty cycle)
	inc	l			; adjust L so that the note period stays constant
	db	#0E			; LD C, n (a cheap way to skip the increment)
StepBackOverflow1:
	inc	e


MediumLoopNext:
	dec	ixl
	jp	nz, CoreSoundLoop


;
;  'slow' loop updates the current notes, plays drums and also executes 'special' commands when necessary.
;  channels 1 and 2 can also have a choice of few crude duty cycle variations.
;

UpdateChannel1:
	djnz	UpdateChannel2		; do we need to read the next note for channel 1?

ReadNoteChannel1:
CurrentPosChannel1:
	ld	hl, 0			; current address within the current pattern
NextNoteChannel1:
	ld	a, (hl)
	inc	hl
	ld	(CurrentPosChannel1+1), hl
	or	a
	jp	m, ProcessCommand1	; this is not a note, but a command that must be processed separately

	add	a,FreqTable&255
	ld	l, a
	adc	a,FreqTable/256
	sub	l
	ld	h, a
	ld	a, (hl)
	dec	a
DutyCycleChannel1:
	jr	$+2

Ch1DutyCycle:
Ch1DutyCycle99:
	ld	e, a			; 99% duty cycle for channel 1
	ld	l, 1
	jr	InitCounters1

Ch1DutyCycle01:
	ld	l, a			; 1% duty cycle for channel 1
	ld	e, 1
	jr	InitCounters1

Ch1DutyCycle25:
	srl	a			; 25% duty cycle for channel 1
Ch1DutyCycle50:
	srl	a			; 50% duty cycle for channel 1
	jr	Ch1DutyCycle75_000

Ch1DutyCycle75:
	srl	a			; 75% duty cycle for channel 1
	ld	e, a
	srl	a
	add	a,e

Ch1DutyCycle75_000:
	ld	e, a
	ld	a, (hl)
	sub	e
	ld	l, a

InitCounters1:
	ld	h, 24			; H=24 for sound, H=0 for mute
PauseChannel1:
	ld	d, 1			; D=1 will be updated during the first cycle iteration
BorderColour1:
	ld	a, 0			; current output state is 0
DurationChannel1:
	ld	b, 0

;
;  pretty much identical manipulations are done for channel 2. the old engine was a bit more limited in terms
;  of what it could do with the second channel, however, this update makes both channels fully equal.
;

UpdateChannel2:
	exa
	exx
	djnz	UpdateChannel3

CurrentPosChannel2:
	ld	hl, 0
NextNoteChannel2:
	ld	a, (hl)
	inc	hl
	ld	(CurrentPosChannel2+1), hl
	or	a
	jp	m, ProcessCommand2

	add	a,FreqTable&255
	ld	l, a
	adc	a,FreqTable/256
	sub	l
	ld	h, a
	ld	a, (hl)
	dec	a
DutyCycleChannel2:
	jr	$+2		 ; 49384 24     6

Ch2DutyCycle:
Ch2DutyCycle99:
	ld	e, a			; 99% duty cycle for channel 2
	ld	l, 1
	jr	InitCounters2

Ch2DutyCycle01:
	ld	l, a			; 1% duty cycle for channel 2
	ld	e, 1
	jr	InitCounters2

Ch2DutyCycle25:
	srl	a			; 25% duty cycle for channel 2
Ch2DutyCycle50:
	srl	a			; 50% duty cycle for channel 2
	jr	Ch2DutyCycle75_000

Ch2DutyCycle75:
	srl	a			; 75% duty cycle for channel 2
	ld	e, a
	srl	a
	add	a,e

Ch2DutyCycle75_000:
	ld	e, a
	ld	a, (hl)
	sub	e
	ld	l, a

InitCounters2:
	ld	h, 24
PauseChannel2:
	ld	d, 1
BorderColour2:
	ld	a, 0
DurationChannel2:
	ld	b, 0

;
;  third channel plays interrupting drums
;

UpdateChannel3:
	exa
CurrentTempo:
	ld	ix, 6

	dec	iyl
	jp	nz, CoreSoundLoopExx

	push	af
	push	de
	push	hl
CurrentPosChannel3:
	ld	hl, 0

NextDrumChannel3:
	ld	a, (hl)
	inc	hl
	ld	(CurrentPosChannel3+1), hl
	or	a
	jp	m, ProcessCommand3

	ld	l, a
	add	a,a
	add	a,l
	add	a,DrumsTable&255
	ld	l, a
	adc	a,DrumsTable/256
	sub	l
	ld	h, a

	ld	a, ixl			; adjustement for the drum duration
	sub	(hl)
	ld	ixl, a

	push	bc
	inc	hl
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	call	DrumSynth
	pop	bc

SkipDrumming:
	pop	hl
	pop	de
	pop	af
DurationChannel3:
	ld	iyl, 0

	jp	CoreSoundLoopExx

;
;  the following section of the program is responsible for processing special codes occuring in channel 1 stream.
;  0-127 - offsets in the table of note periods (there are only 50 entries there, actually).
;  128 - mute channel
;  129 - stop playback and return from the player
;  130 - 1% duty cycle
;  131 - 25% duty cycle
;  132 - 50% duty cycle
;  133 - 75% duty cycle
;  134 - 99% duty cycle
;  135 - PWM envelope on (duty cycle decrease)
;  136 - PWM envelope off
;  137 - end of the pattern
;  223..255 - set new notes duration (in periods of the slow cycle)
;

ProcessCommand1:
	sub	223
	jr	c, NotALength1
	ld	(DurationChannel1+1), a
	jp	NextNoteChannel1

NotALength1:
	add	a,223-128
	add	a,a
	add	a,a
	ld	(CommandChannel1+1), a
CommandChannel1:
	jr	$+2

Ch1_128:
	ld	h, a
	jp	PauseChannel1

Ch1_129:
	jp	StopPlayback
	nop

Ch1_130:
	ld	a, Ch1DutyCycle01-Ch1DutyCycle
	jr	UpdateDutyCycle1
Ch1_131:
	ld	a, Ch1DutyCycle25-Ch1DutyCycle
	jr	UpdateDutyCycle1
Ch1_132:
	ld	a, Ch1DutyCycle50-Ch1DutyCycle
	jr	UpdateDutyCycle1
Ch1_133:
	ld	a, Ch1DutyCycle75-Ch1DutyCycle
	jr	UpdateDutyCycle1
Ch1_134:
	ld	a, Ch1DutyCycle99-Ch1DutyCycle
	jr	UpdateDutyCycle1

Ch1_135:
	ld	a, 40			; JR Z, nn (switch on PWM envelope)
	jr	UpdateFXType1
Ch1_136:
	ld	a, 24			; JR nn (switch off PWM envelope)
	jr	UpdateFXType1

Ch1_137:
	ld	hl, NextNoteChannel1
	push	hl

PatternChannel1:
	ld	hl, 0
ReadNextPattern1:
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	ld	(PatternChannel1+1), hl
	ex	de, hl
	ld	a, h
	or	l
	ret	nz
	ex	de, hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ex	de, hl
	jr	ReadNextPattern1

UpdateDutyCycle1:
	ld	(DutyCycleChannel1+1), a
	jp	NextNoteChannel1

UpdateFXType1:
	ld	(FXType1), a
	jp	NextNoteChannel1

;
;  the following section of the program is responsible for processing special codes occuring in channel 2 stream.
;  0-127 - offsets in the table of note periods (there are 50 entries there, actually).
;  128 - mute channel
;  129 - stop playback and return from the player
;  130 - 1% duty cycle
;  131 - 25% duty cycle
;  132 - 50% duty cycle
;  133 - 75% duty cycle
;  134 - 99% duty cycle
;  135 - PWM envelope on (duty cycle decrease)
;  136 - PWM envelope off
;  137 - end of the pattern
;  223..255 - set new notes duration (in periods of the slow cycle)
;

ProcessCommand2:
	sub	223
	jr	c, NotALength2
	ld	(DurationChannel2+1), a
	jp	NextNoteChannel2

NotALength2:
	add	a,223-128
	add	a,a
	add	a,a
	ld	(CommandChannel2+1), a
CommandChannel2:
	jr	$+2

Ch2_128:
	ld	h, a
	jp	PauseChannel2

Ch2_129:
	jp	StopPlayback
	nop

Ch2_130:
	ld	a, Ch2DutyCycle01-Ch2DutyCycle
	jr	UpdateDutyCycle2
Ch2_131:
	ld	a, Ch2DutyCycle25-Ch2DutyCycle
	jr	UpdateDutyCycle2
Ch2_132:
	ld	a, Ch2DutyCycle50-Ch2DutyCycle
	jr	UpdateDutyCycle2
Ch2_133:
	ld	a, Ch2DutyCycle75-Ch2DutyCycle
	jr	UpdateDutyCycle2
Ch2_134:
	ld	a, Ch2DutyCycle99-Ch2DutyCycle
	jr	UpdateDutyCycle2

Ch2_135:
	ld	a, 40			; JR Z, nn (switch on PWM envelope)
	jr	UpdateFXType2
Ch2_136:
	ld	a, 24			; JR nn (switch off PWM envelope)
	jr	UpdateFXType2

Ch2_137:
	ld	hl, NextNoteChannel2
	push	hl

PatternChannel2:
	ld	hl, 0
ReadNextPattern2:
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	ld	(PatternChannel2+1), hl
	ex	de, hl
	ld	a, h
	or	l
	ret	nz
	ex	de, hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ex	de, hl
	jr	ReadNextPattern2

UpdateDutyCycle2:
	ld	(DutyCycleChannel2+1), a
	jp	NextNoteChannel2

UpdateFXType2:
	ld	(FXType2), a
	jp	NextNoteChannel2

;
;  the following section of the program is responsible for processing special codes occuring in channel 3 stream.
;  0-127 - offsets in the table of drums (there are 20 entries there, actually).
;  128 - mute channel
;  129 - end of the pattern
;  223..255 - set new notes duration (in periods of the slow cycle)
;

ProcessCommand3:
	sub	223
	jr	c, NotALength3
	ld	(DurationChannel3+2), a
	jp	NextDrumChannel3

NotALength3:
	add	a,223-128
	add	a,a
	add	a,a
	ld	(CommandChannel3+1), a
CommandChannel3:
	jr	$+2

Ch3_128:
	jp	SkipDrumming
	nop

Ch3_129:
	ld	hl, NextDrumChannel3
	push	hl

PatternChannel3:
	ld	hl, 0
ReadNextPattern3:
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	inc	hl
	ld	(PatternChannel3+1), hl
	ex	de, hl
	ld	a, h
	or	l
	ret	nz
	ex	de, hl
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ex	de, hl
	jr	ReadNextPattern3

;
;  a universal routine to produce drum-like sounds (it is likely that i borrowed it from D.Whittaker's engine)
;
;  in order to stabilise the tempo properly, the parameters of the drum synth have been selected to closely
;  match the integer number of iterations of the 'medium' loop. the drum noise lasts for 69*B-5+16*C*B+8*B^2 t-states.
;  the drums whose description starts with 1 are tuned to last for ~22528 t-states
;  the drums whose description starts with 2 are tuned to last for ~45056 t-states
;

DrumSynth:
	ld	hl, play+40
BorderColour3:
	ld	d, 0

DrumSynthLoop:
	ld	a, (hl)			; 7t
	inc	hl				; 6t
	and	24				; 7t
	or	d				; 4t
	out	($84), a		; 11t
	ld	a, c			; 4t
DrumSynthLoop_001:
	dec	a				; 16t*C0-5
	jr	nz, DrumSynthLoop_001
	or	d				; 4t
	out	($84), a		; 11t
	ld	a, b			; 4t
DrumSynthLoop_002:
	dec	a				; 16t*B-5
	jr	nz, DrumSynthLoop_002
	djnz	DrumSynthLoop		; 13t
	ret

DrumsTable:		; drums to replace 1 iteration of the medium loop
	db	1, 227, 6
	db	1, 193, 7
	db	1, 148, 9
	db	1, 107, 12
	db	1, 65, 18
	db	1, 37, 26
	db	1, 20, 34
	db	1, 17, 36
	db	1, 11, 40
	db	1, 7, 43
	; drums to replace 2 iterations of the medium loop
	db	2, 246, 11
	db	2, 206, 13
	db	2, 153, 17
	db	2, 101, 24
	db	2, 71, 31
	db	2, 44, 41
	db	2, 27, 50
	db	2, 18, 56
	db	2, 14, 59
	db	2, 9, 63

;
;  the new frequency table is properly recomputed from the standard note frequencies.
;  this is a table of relative errors achieved when using this table:
;  octave	c	c#	d	d#	e	f	f#	g	g#	a	a#	b
;  2					0.1	-0.11	0.086	0.004	0.037	0.25	0.13	0.25	-0.047
;  3		-0.018	-0.47	-0.47	0.2	0.46	0.17	-0.86	-0.9	0.5	-0.96	-0.88	1.4
;  4		-0.037	0.98	1.2	0.4	-1.8	0.34	1.7	2.1	1	-1.9	3.7	-3.3
;  5		-0.073	2	2.4	0.8	-3.6	-11.8	3.5	-11.5	2	15.4	-14.6	-6.6
;  6		-0.15	3.9	4.9	1.6	-7.3
;

FreqTable:
	db	0, 241, 228, 215, 203, 192, 181, 171, 161		; great octave, starts at D#2 (biggest error 0.25%)
	db	152, 143, 135, 128, 121, 114, 107, 101, 96, 90, 85, 81	; small octave (biggest errors G3 -0.9%, A3 -1%, B3 1.4%)
	db	76, 72, 68, 64, 60, 57, 54, 51, 48, 45, 43, 40	; one-line octave (biggest errors G4 2.1%, A#4 3.7%, B4 -3.3%)
	db	38, 36, 34, 32, 30, 28, 27, 25, 24, 23, 21, 20	; two-line octave (biggest errors F5 -11.8%, A5 15.4%, A#5 -14.6%)
	db	19, 18, 17, 16, 15			; three-line octave, ends at E6 (biggest errors C#6 3.9%, D6 4.9%, E6 -7.3%)

;compiled music data

musicData
 db 9
 dw .order1
 dw .order2
 dw .order3
.order1
 dw .chn11
.loop1
 dw .chn12
 dw 0,.loop1
.order2
 dw .chn21
.loop2
 dw .chn22
 dw 0,.loop2
.order3
 dw .chn31
.loop3
 dw .chn32
 dw 0,.loop3
.chn11
 db 134
 db 136
 db 225
 db 33
 db 32
 db 28
 db 23
 db 130
 db 135
 db 21
 db 20
 db 16
 db 11
 db 131
 db 33
 db 32
 db 28
 db 23
 db 132
 db 21
 db 20
 db 16
 db 11
 db 133
 db 33
 db 32
 db 28
 db 23
 db 132
 db 21
 db 20
 db 16
 db 11
 db 131
 db 33
 db 32
 db 28
 db 23
 db 130
 db 21
 db 20
 db 16
 db 11
 db 134
 db 136
 db 33
 db 32
 db 28
 db 23
 db 130
 db 135
 db 21
 db 20
 db 16
 db 11
 db 131
 db 33
 db 32
 db 28
 db 23
 db 132
 db 21
 db 20
 db 16
 db 11
 db 133
 db 33
 db 32
 db 28
 db 23
 db 132
 db 21
 db 20
 db 16
 db 11
 db 131
 db 33
 db 32
 db 28
 db 23
 db 130
 db 21
 db 20
 db 16
 db 11
 db 134
 db 136
 db 33
 db 32
 db 28
 db 23
 db 130
 db 135
 db 21
 db 20
 db 16
 db 11
 db 131
 db 33
 db 32
 db 28
 db 23
 db 132
 db 21
 db 20
 db 16
 db 11
 db 133
 db 33
 db 32
 db 28
 db 23
 db 132
 db 21
 db 20
 db 16
 db 11
 db 131
 db 33
 db 32
 db 28
 db 23
 db 130
 db 21
 db 20
 db 16
 db 11
 db 134
 db 136
 db 33
 db 32
 db 28
 db 23
 db 130
 db 135
 db 21
 db 20
 db 16
 db 11
 db 131
 db 33
 db 32
 db 28
 db 23
 db 132
 db 21
 db 20
 db 16
 db 11
 db 133
 db 33
 db 32
 db 28
 db 23
 db 132
 db 21
 db 20
 db 16
 db 11
 db 131
 db 11
 db 16
 db 20
 db 21
 db 23
 db 28
 db 32
 db 33
 db 227
 db 128
 db 132
 db 136
 db 225
 db 25
 db 136
 db 25
 db 135
 db 23
 db 136
 db 25
 db 227
 db 128
 db 133
 db 136
 db 225
 db 25
 db 136
 db 25
 db 135
 db 23
 db 136
 db 227
 db 25
 db 225
 db 128
 db 131
 db 135
 db 23
 db 25
 db 26
 db 26
 db 25
 db 23
 db 227
 db 128
 db 133
 db 136
 db 224
 db 26
 db 128
 db 26
 db 128
 db 25
 db 128
 db 20
 db 228
 db 128
 db 132
 db 135
 db 225
 db 4
 db 4
 db 4
 db 4
 db 227
 db 128
 db 132
 db 136
 db 225
 db 23
 db 136
 db 25
 db 135
 db 26
 db 136
 db 26
 db 25
 db 23
 db 227
 db 128
 db 133
 db 224
 db 24
 db 228
 db 25
 db 229
 db 23
 db 133
 db 224
 db 24
 db 226
 db 25
 db 132
 db 227
 db 25
 db 131
 db 25
 db 132
 db 25
 db 133
 db 231
 db 28
 db 131
 db 135
 db 224
 db 1
 db 128
 db 1
 db 128
 db 1
 db 128
 db 1
 db 128
 db 227
 db 128
 db 132
 db 136
 db 225
 db 25
 db 136
 db 25
 db 135
 db 23
 db 136
 db 25
 db 227
 db 128
 db 133
 db 136
 db 225
 db 25
 db 136
 db 25
 db 135
 db 23
 db 136
 db 227
 db 25
 db 225
 db 128
 db 131
 db 135
 db 23
 db 25
 db 26
 db 26
 db 25
 db 23
 db 227
 db 128
 db 133
 db 224
 db 26
 db 128
 db 26
 db 128
 db 25
 db 128
 db 20
 db 228
 db 128
 db 132
 db 135
 db 225
 db 4
 db 4
 db 4
 db 4
 db 227
 db 128
 db 132
 db 136
 db 225
 db 23
 db 25
 db 26
 db 26
 db 25
 db 23
 db 227
 db 128
 db 133
 db 224
 db 24
 db 228
 db 25
 db 229
 db 23
 db 133
 db 224
 db 24
 db 226
 db 25
 db 132
 db 227
 db 25
 db 131
 db 25
 db 132
 db 25
 db 133
 db 231
 db 28
 db 131
 db 135
 db 224
 db 1
 db 128
 db 1
 db 128
 db 1
 db 128
 db 1
 db 128
 db 134
 db 136
 db 225
 db 33
 db 32
 db 28
 db 23
 db 130
 db 135
 db 21
 db 20
 db 16
 db 11
 db 131
 db 33
 db 32
 db 28
 db 23
 db 132
 db 21
 db 20
 db 16
 db 11
 db 133
 db 33
 db 32
 db 28
 db 23
 db 132
 db 21
 db 20
 db 16
 db 11
 db 131
 db 33
 db 32
 db 28
 db 23
 db 130
 db 21
 db 20
 db 16
 db 11
 db 134
 db 136
 db 33
 db 32
 db 28
 db 23
 db 130
 db 135
 db 21
 db 20
 db 16
 db 11
 db 131
 db 33
 db 32
 db 28
 db 23
 db 132
 db 21
 db 20
 db 16
 db 11
 db 133
 db 33
 db 32
 db 28
 db 23
 db 132
 db 21
 db 20
 db 16
 db 11
 db 131
 db 33
 db 32
 db 28
 db 23
 db 130
 db 21
 db 20
 db 16
 db 11
 db 134
 db 136
 db 33
 db 32
 db 28
 db 23
 db 130
 db 135
 db 21
 db 20
 db 16
 db 11
 db 131
 db 33
 db 32
 db 28
 db 23
 db 132
 db 21
 db 20
 db 16
 db 11
 db 133
 db 33
 db 32
 db 28
 db 23
 db 132
 db 21
 db 20
 db 16
 db 11
 db 131
 db 33
 db 32
 db 28
 db 23
 db 130
 db 21
 db 20
 db 16
 db 11
 db 134
 db 136
 db 33
 db 32
 db 28
 db 23
 db 130
 db 135
 db 21
 db 20
 db 16
 db 11
 db 131
 db 33
 db 32
 db 28
 db 23
 db 132
 db 21
 db 20
 db 16
 db 11
 db 133
 db 33
 db 32
 db 28
 db 23
 db 132
 db 21
 db 20
 db 16
 db 11
 db 131
 db 11
 db 16
 db 20
 db 21
 db 23
 db 28
 db 32
 db 33
 db 227
 db 128
 db 132
 db 136
 db 225
 db 25
 db 136
 db 25
 db 135
 db 23
 db 136
 db 25
 db 227
 db 128
 db 133
 db 136
 db 225
 db 25
 db 136
 db 25
 db 135
 db 23
 db 136
 db 227
 db 25
 db 225
 db 128
 db 131
 db 135
 db 23
 db 25
 db 26
 db 26
 db 25
 db 23
 db 227
 db 128
 db 133
 db 136
 db 224
 db 26
 db 128
 db 26
 db 128
 db 25
 db 128
 db 20
 db 228
 db 128
 db 132
 db 135
 db 225
 db 4
 db 4
 db 4
 db 4
 db 227
 db 128
 db 132
 db 136
 db 225
 db 23
 db 136
 db 25
 db 135
 db 26
 db 136
 db 26
 db 25
 db 23
 db 227
 db 128
 db 133
 db 224
 db 24
 db 228
 db 25
 db 229
 db 23
 db 133
 db 224
 db 24
 db 226
 db 25
 db 132
 db 227
 db 25
 db 131
 db 25
 db 132
 db 25
 db 133
 db 231
 db 28
 db 131
 db 135
 db 224
 db 1
 db 128
 db 1
 db 128
 db 1
 db 128
 db 1
 db 128
 db 227
 db 128
 db 132
 db 136
 db 225
 db 25
 db 136
 db 25
 db 135
 db 23
 db 136
 db 25
 db 227
 db 128
 db 133
 db 136
 db 225
 db 25
 db 136
 db 25
 db 135
 db 23
 db 136
 db 227
 db 25
 db 225
 db 128
 db 131
 db 135
 db 23
 db 25
 db 26
 db 26
 db 25
 db 23
 db 227
 db 128
 db 133
 db 224
 db 26
 db 128
 db 26
 db 128
 db 25
 db 128
 db 20
 db 228
 db 128
 db 132
 db 135
 db 225
 db 4
 db 4
 db 4
 db 4
 db 227
 db 128
 db 132
 db 136
 db 225
 db 23
 db 25
 db 26
 db 26
 db 25
 db 23
 db 227
 db 128
 db 133
 db 224
 db 24
 db 228
 db 25
 db 229
 db 23
 db 133
 db 224
 db 24
 db 226
 db 25
 db 132
 db 227
 db 25
 db 131
 db 25
 db 132
 db 25
 db 133
 db 231
 db 28
 db 131
 db 135
 db 224
 db 1
 db 128
 db 1
 db 128
 db 1
 db 128
 db 1
 db 128
 db 134
 db 135
 db 31
 db 32
 db 239
 db 33
 db 133
 db 136
 db 224
 db 25
 db 128
 db 32
 db 128
 db 25
 db 128
 db 30
 db 128
 db 25
 db 128
 db 28
 db 128
 db 25
 db 128
 db 134
 db 135
 db 239
 db 33
 db 224
 db 34
 db 35
 db 36
 db 236
 db 37
 db 241
 db 32
 db 133
 db 136
 db 224
 db 23
 db 128
 db 30
 db 128
 db 23
 db 128
 db 28
 db 128
 db 23
 db 128
 db 26
 db 128
 db 23
 db 128
 db 134
 db 135
 db 239
 db 32
 db 35
 db 255
 db 33
 db 239
 db 32
 db 28
 db 255
 db 32
 db 239
 db 33
 db 35
 db 134
 db 135
 db 224
 db 31
 db 32
 db 225
 db 33
 db 224
 db 33
 db 128
 db 33
 db 128
 db 33
 db 128
 db 33
 db 128
 db 33
 db 128
 db 33
 db 128
 db 33
 db 128
 db 133
 db 136
 db 25
 db 128
 db 32
 db 128
 db 25
 db 128
 db 30
 db 128
 db 25
 db 128
 db 28
 db 128
 db 25
 db 128
 db 134
 db 135
 db 239
 db 33
 db 224
 db 34
 db 35
 db 36
 db 236
 db 37
 db 224
 db 32
 db 128
 db 32
 db 128
 db 32
 db 128
 db 32
 db 128
 db 32
 db 128
 db 32
 db 128
 db 32
 db 128
 db 32
 db 128
 db 32
 db 128
 db 133
 db 136
 db 23
 db 128
 db 30
 db 128
 db 23
 db 128
 db 28
 db 128
 db 23
 db 128
 db 26
 db 128
 db 23
 db 128
 db 134
 db 135
 db 239
 db 32
 db 35
 db 224
 db 33
 db 128
 db 227
 db 33
 db 224
 db 33
 db 128
 db 227
 db 33
 db 224
 db 33
 db 128
 db 227
 db 33
 db 224
 db 33
 db 128
 db 227
 db 33
 db 224
 db 33
 db 128
 db 227
 db 33
 db 224
 db 33
 db 128
 db 239
 db 32
 db 28
 db 224
 db 32
 db 128
 db 227
 db 32
 db 224
 db 32
 db 128
 db 227
 db 32
 db 224
 db 32
 db 128
 db 227
 db 32
 db 224
 db 32
 db 128
 db 227
 db 32
 db 224
 db 32
 db 128
 db 227
 db 32
 db 224
 db 32
 db 128
 db 134
 db 135
 db 33
 db 128
 db 33
 db 128
 db 33
 db 128
 db 33
 db 128
 db 131
 db 45
 db 128
 db 45
 db 128
 db 45
 db 128
 db 45
 db 128
 db 132
 db 136
 db 35
 db 128
 db 35
 db 128
 db 35
 db 128
 db 35
 db 128
 db 47
 db 128
 db 47
 db 128
 db 47
 db 128
 db 47
 db 128
 db 134
 db 135
 db 225
 db 30
 db 224
 db 30
 db 128
 db 30
 db 128
 db 30
 db 128
 db 130
 db 136
 db 30
 db 128
 db 30
 db 128
 db 30
 db 128
 db 30
 db 128
 db 137
.chn12
 db 227
 db 128
 db 137
.chn21
 db 132
 db 135
 db 224
 db 6
 db 128
 db 6
 db 128
 db 18
 db 128
 db 6
 db 128
 db 6
 db 128
 db 6
 db 128
 db 18
 db 128
 db 6
 db 128
 db 6
 db 128
 db 6
 db 128
 db 18
 db 128
 db 6
 db 128
 db 6
 db 128
 db 6
 db 128
 db 18
 db 128
 db 6
 db 128
 db 6
 db 128
 db 6
 db 128
 db 18
 db 128
 db 6
 db 128
 db 6
 db 128
 db 6
 db 128
 db 18
 db 128
 db 6
 db 128
 db 6
 db 128
 db 6
 db 128
 db 18
 db 128
 db 6
 db 128
 db 6
 db 128
 db 6
 db 128
 db 18
 db 128
 db 6
 db 128
 db 2
 db 128
 db 2
 db 128
 db 14
 db 128
 db 2
 db 128
 db 2
 db 128
 db 2
 db 128
 db 14
 db 128
 db 2
 db 128
 db 2
 db 128
 db 2
 db 128
 db 14
 db 128
 db 2
 db 128
 db 2
 db 128
 db 2
 db 128
 db 14
 db 128
 db 2
 db 128
 db 1
 db 128
 db 1
 db 128
 db 13
 db 128
 db 1
 db 128
 db 1
 db 128
 db 1
 db 128
 db 13
 db 128
 db 1
 db 128
 db 1
 db 128
 db 1
 db 128
 db 13
 db 128
 db 1
 db 128
 db 1
 db 128
 db 1
 db 128
 db 13
 db 128
 db 1
 db 128
 db 135
 db 6
 db 128
 db 6
 db 128
 db 131
 db 18
 db 128
 db 132
 db 6
 db 128
 db 6
 db 128
 db 6
 db 128
 db 131
 db 18
 db 128
 db 132
 db 6
 db 128
 db 6
 db 128
 db 6
 db 128
 db 131
 db 18
 db 128
 db 132
 db 6
 db 128
 db 6
 db 128
 db 6
 db 128
 db 131
 db 18
 db 128
 db 132
 db 6
 db 128
 db 132
 db 135
 db 6
 db 128
 db 6
 db 128
 db 131
 db 18
 db 128
 db 132
 db 6
 db 128
 db 6
 db 128
 db 6
 db 128
 db 131
 db 18
 db 128
 db 132
 db 6
 db 128
 db 6
 db 128
 db 6
 db 128
 db 131
 db 18
 db 128
 db 132
 db 6
 db 128
 db 6
 db 128
 db 6
 db 128
 db 131
 db 18
 db 128
 db 132
 db 6
 db 128
 db 132
 db 135
 db 2
 db 128
 db 2
 db 128
 db 131
 db 14
 db 128
 db 132
 db 2
 db 128
 db 2
 db 128
 db 2
 db 128
 db 131
 db 14
 db 128
 db 132
 db 2
 db 128
 db 2
 db 128
 db 2
 db 128
 db 131
 db 14
 db 128
 db 132
 db 2
 db 128
 db 2
 db 128
 db 2
 db 128
 db 131
 db 14
 db 128
 db 132
 db 2
 db 128
 db 132
 db 135
 db 1
 db 128
 db 1
 db 128
 db 131
 db 13
 db 128
 db 132
 db 1
 db 128
 db 1
 db 128
 db 1
 db 128
 db 131
 db 13
 db 128
 db 132
 db 1
 db 128
 db 1
 db 128
 db 1
 db 128
 db 131
 db 13
 db 128
 db 132
 db 1
 db 128
 db 1
 db 128
 db 1
 db 128
 db 131
 db 13
 db 128
 db 132
 db 1
 db 128
 db 131
 db 135
 db 6
 db 128
 db 132
 db 6
 db 128
 db 134
 db 18
 db 128
 db 130
 db 136
 db 18
 db 128
 db 131
 db 135
 db 6
 db 128
 db 132
 db 6
 db 128
 db 134
 db 18
 db 128
 db 130
 db 136
 db 18
 db 128
 db 131
 db 135
 db 6
 db 128
 db 132
 db 6
 db 128
 db 134
 db 18
 db 128
 db 130
 db 136
 db 18
 db 128
 db 131
 db 135
 db 6
 db 128
 db 132
 db 6
 db 128
 db 134
 db 18
 db 128
 db 130
 db 136
 db 18
 db 128
 db 131
 db 135
 db 4
 db 128
 db 132
 db 4
 db 128
 db 134
 db 16
 db 128
 db 130
 db 136
 db 16
 db 128
 db 131
 db 135
 db 4
 db 128
 db 132
 db 4
 db 128
 db 134
 db 16
 db 128
 db 130
 db 136
 db 16
 db 128
 db 131
 db 135
 db 4
 db 128
 db 132
 db 4
 db 128
 db 134
 db 16
 db 128
 db 130
 db 136
 db 16
 db 128
 db 131
 db 135
 db 4
 db 128
 db 132
 db 4
 db 128
 db 134
 db 16
 db 128
 db 130
 db 136
 db 16
 db 128
 db 131
 db 135
 db 11
 db 128
 db 132
 db 11
 db 128
 db 134
 db 23
 db 128
 db 130
 db 136
 db 23
 db 128
 db 131
 db 135
 db 11
 db 128
 db 132
 db 11
 db 128
 db 134
 db 23
 db 128
 db 130
 db 136
 db 23
 db 128
 db 131
 db 135
 db 11
 db 128
 db 132
 db 11
 db 128
 db 134
 db 23
 db 128
 db 130
 db 136
 db 23
 db 128
 db 131
 db 135
 db 11
 db 128
 db 132
 db 11
 db 128
 db 134
 db 23
 db 128
 db 130
 db 136
 db 23
 db 128
 db 131
 db 135
 db 1
 db 128
 db 132
 db 1
 db 128
 db 134
 db 13
 db 128
 db 130
 db 136
 db 13
 db 128
 db 131
 db 135
 db 1
 db 128
 db 132
 db 1
 db 128
 db 134
 db 13
 db 128
 db 130
 db 136
 db 13
 db 128
 db 131
 db 135
 db 1
 db 128
 db 132
 db 1
 db 128
 db 134
 db 13
 db 128
 db 130
 db 136
 db 13
 db 128
 db 131
 db 135
 db 1
 db 128
 db 132
 db 1
 db 128
 db 134
 db 13
 db 128
 db 130
 db 136
 db 13
 db 128
 db 131
 db 135
 db 6
 db 128
 db 132
 db 6
 db 128
 db 133
 db 18
 db 128
 db 132
 db 18
 db 128
 db 131
 db 6
 db 128
 db 132
 db 6
 db 128
 db 133
 db 18
 db 128
 db 132
 db 18
 db 128
 db 131
 db 6
 db 128
 db 132
 db 6
 db 128
 db 133
 db 18
 db 128
 db 132
 db 18
 db 128
 db 131
 db 6
 db 128
 db 132
 db 6
 db 128
 db 133
 db 18
 db 128
 db 132
 db 18
 db 128
 db 131
 db 4
 db 128
 db 132
 db 4
 db 128
 db 133
 db 16
 db 128
 db 132
 db 16
 db 128
 db 131
 db 4
 db 128
 db 132
 db 4
 db 128
 db 133
 db 16
 db 128
 db 132
 db 16
 db 128
 db 131
 db 4
 db 128
 db 132
 db 4
 db 128
 db 133
 db 16
 db 128
 db 132
 db 16
 db 128
 db 131
 db 4
 db 128
 db 132
 db 4
 db 128
 db 133
 db 16
 db 128
 db 132
 db 16
 db 128
 db 131
 db 11
 db 128
 db 132
 db 11
 db 128
 db 133
 db 23
 db 128
 db 132
 db 23
 db 128
 db 131
 db 11
 db 128
 db 132
 db 11
 db 128
 db 133
 db 23
 db 128
 db 132
 db 23
 db 128
 db 131
 db 11
 db 128
 db 132
 db 11
 db 128
 db 133
 db 23
 db 128
 db 132
 db 23
 db 128
 db 131
 db 11
 db 128
 db 132
 db 11
 db 128
 db 133
 db 23
 db 128
 db 132
 db 23
 db 128
 db 131
 db 1
 db 128
 db 132
 db 1
 db 128
 db 133
 db 13
 db 128
 db 132
 db 13
 db 128
 db 131
 db 1
 db 128
 db 132
 db 1
 db 128
 db 133
 db 13
 db 128
 db 132
 db 13
 db 128
 db 131
 db 4
 db 128
 db 132
 db 4
 db 130
 db 136
 db 28
 db 133
 db 135
 db 16
 db 130
 db 136
 db 28
 db 132
 db 135
 db 16
 db 130
 db 136
 db 28
 db 131
 db 136
 db 13
 db 128
 db 132
 db 13
 db 128
 db 133
 db 13
 db 128
 db 132
 db 13
 db 128
 db 132
 db 136
 db 6
 db 128
 db 133
 db 135
 db 6
 db 128
 db 133
 db 136
 db 18
 db 128
 db 133
 db 136
 db 6
 db 128
 db 132
 db 136
 db 6
 db 128
 db 133
 db 135
 db 6
 db 128
 db 133
 db 136
 db 18
 db 128
 db 133
 db 136
 db 6
 db 128
 db 132
 db 136
 db 6
 db 128
 db 133
 db 135
 db 6
 db 128
 db 133
 db 136
 db 18
 db 128
 db 133
 db 136
 db 6
 db 128
 db 132
 db 136
 db 6
 db 128
 db 133
 db 135
 db 6
 db 128
 db 133
 db 136
 db 18
 db 128
 db 133
 db 136
 db 6
 db 128
 db 132
 db 136
 db 6
 db 128
 db 133
 db 135
 db 6
 db 130
 db 33
 db 133
 db 136
 db 18
 db 130
 db 32
 db 133
 db 136
 db 6
 db 130
 db 28
 db 132
 db 136
 db 6
 db 130
 db 23
 db 133
 db 135
 db 6
 db 130
 db 21
 db 133
 db 136
 db 18
 db 130
 db 20
 db 133
 db 136
 db 6
 db 130
 db 16
 db 132
 db 136
 db 6
 db 130
 db 11
 db 133
 db 135
 db 6
 db 130
 db 33
 db 133
 db 136
 db 18
 db 130
 db 32
 db 133
 db 136
 db 6
 db 130
 db 28
 db 132
 db 136
 db 6
 db 130
 db 23
 db 133
 db 135
 db 6
 db 130
 db 21
 db 133
 db 136
 db 18
 db 130
 db 20
 db 133
 db 136
 db 6
 db 130
 db 16
 db 132
 db 136
 db 2
 db 128
 db 133
 db 135
 db 2
 db 128
 db 133
 db 136
 db 14
 db 128
 db 133
 db 136
 db 2
 db 128
 db 132
 db 136
 db 2
 db 128
 db 133
 db 135
 db 2
 db 128
 db 133
 db 136
 db 14
 db 128
 db 133
 db 136
 db 2
 db 128
 db 132
 db 136
 db 2
 db 128
 db 133
 db 135
 db 2
 db 128
 db 133
 db 136
 db 14
 db 128
 db 133
 db 136
 db 2
 db 128
 db 132
 db 136
 db 2
 db 128
 db 133
 db 135
 db 2
 db 128
 db 133
 db 136
 db 14
 db 128
 db 133
 db 136
 db 2
 db 128
 db 132
 db 136
 db 1
 db 128
 db 133
 db 135
 db 1
 db 130
 db 33
 db 133
 db 136
 db 13
 db 130
 db 32
 db 133
 db 136
 db 1
 db 130
 db 28
 db 132
 db 136
 db 1
 db 130
 db 23
 db 133
 db 135
 db 1
 db 130
 db 21
 db 133
 db 136
 db 13
 db 130
 db 20
 db 133
 db 136
 db 1
 db 130
 db 16
 db 132
 db 136
 db 1
 db 130
 db 11
 db 133
 db 135
 db 1
 db 130
 db 33
 db 133
 db 136
 db 13
 db 130
 db 32
 db 133
 db 136
 db 1
 db 130
 db 28
 db 132
 db 136
 db 1
 db 130
 db 23
 db 133
 db 135
 db 1
 db 128
 db 133
 db 136
 db 13
 db 128
 db 133
 db 136
 db 1
 db 128
 db 132
 db 136
 db 6
 db 128
 db 133
 db 135
 db 6
 db 128
 db 133
 db 136
 db 18
 db 128
 db 133
 db 136
 db 6
 db 128
 db 132
 db 136
 db 6
 db 128
 db 133
 db 135
 db 6
 db 128
 db 133
 db 136
 db 18
 db 128
 db 133
 db 136
 db 6
 db 128
 db 132
 db 136
 db 6
 db 128
 db 133
 db 135
 db 6
 db 128
 db 133
 db 136
 db 18
 db 128
 db 133
 db 136
 db 6
 db 128
 db 132
 db 136
 db 6
 db 128
 db 133
 db 135
 db 6
 db 128
 db 133
 db 136
 db 18
 db 128
 db 133
 db 136
 db 6
 db 128
 db 132
 db 136
 db 6
 db 128
 db 133
 db 135
 db 6
 db 130
 db 33
 db 133
 db 136
 db 18
 db 130
 db 32
 db 133
 db 136
 db 6
 db 130
 db 28
 db 132
 db 136
 db 6
 db 130
 db 23
 db 133
 db 135
 db 6
 db 130
 db 21
 db 133
 db 136
 db 18
 db 130
 db 20
 db 133
 db 136
 db 6
 db 130
 db 16
 db 132
 db 136
 db 6
 db 130
 db 11
 db 133
 db 135
 db 6
 db 130
 db 33
 db 133
 db 136
 db 18
 db 130
 db 32
 db 133
 db 136
 db 6
 db 130
 db 28
 db 132
 db 136
 db 6
 db 130
 db 23
 db 133
 db 135
 db 6
 db 130
 db 21
 db 133
 db 136
 db 18
 db 130
 db 20
 db 133
 db 136
 db 6
 db 130
 db 16
 db 132
 db 136
 db 2
 db 128
 db 133
 db 135
 db 2
 db 128
 db 133
 db 136
 db 14
 db 128
 db 133
 db 136
 db 2
 db 128
 db 132
 db 136
 db 2
 db 128
 db 133
 db 135
 db 2
 db 128
 db 133
 db 136
 db 14
 db 128
 db 133
 db 136
 db 2
 db 128
 db 132
 db 136
 db 2
 db 128
 db 133
 db 135
 db 2
 db 128
 db 133
 db 136
 db 14
 db 128
 db 133
 db 136
 db 2
 db 128
 db 132
 db 136
 db 2
 db 128
 db 133
 db 135
 db 2
 db 128
 db 133
 db 136
 db 14
 db 128
 db 133
 db 136
 db 2
 db 128
 db 132
 db 136
 db 1
 db 128
 db 133
 db 135
 db 1
 db 130
 db 33
 db 133
 db 136
 db 13
 db 130
 db 32
 db 133
 db 136
 db 1
 db 130
 db 28
 db 132
 db 136
 db 1
 db 130
 db 23
 db 133
 db 135
 db 1
 db 130
 db 21
 db 133
 db 136
 db 13
 db 130
 db 21
 db 133
 db 136
 db 1
 db 130
 db 18
 db 132
 db 136
 db 1
 db 130
 db 11
 db 133
 db 135
 db 1
 db 134
 db 135
 db 11
 db 133
 db 136
 db 13
 db 134
 db 135
 db 16
 db 133
 db 136
 db 1
 db 134
 db 135
 db 20
 db 132
 db 136
 db 1
 db 134
 db 135
 db 21
 db 133
 db 135
 db 1
 db 134
 db 135
 db 23
 db 133
 db 136
 db 13
 db 134
 db 135
 db 28
 db 133
 db 136
 db 1
 db 134
 db 135
 db 32
 db 131
 db 135
 db 6
 db 128
 db 132
 db 6
 db 128
 db 133
 db 18
 db 128
 db 132
 db 18
 db 128
 db 131
 db 6
 db 130
 db 25
 db 132
 db 6
 db 130
 db 25
 db 133
 db 18
 db 130
 db 23
 db 132
 db 18
 db 130
 db 25
 db 131
 db 6
 db 128
 db 132
 db 6
 db 128
 db 133
 db 18
 db 130
 db 25
 db 132
 db 18
 db 130
 db 25
 db 131
 db 6
 db 130
 db 23
 db 132
 db 6
 db 130
 db 25
 db 133
 db 18
 db 128
 db 132
 db 18
 db 128
 db 131
 db 4
 db 130
 db 23
 db 132
 db 4
 db 130
 db 25
 db 133
 db 16
 db 130
 db 26
 db 132
 db 16
 db 130
 db 26
 db 131
 db 4
 db 130
 db 25
 db 132
 db 4
 db 130
 db 23
 db 133
 db 16
 db 128
 db 132
 db 16
 db 128
 db 131
 db 4
 db 130
 db 26
 db 132
 db 4
 db 130
 db 26
 db 133
 db 16
 db 130
 db 25
 db 132
 db 16
 db 130
 db 20
 db 131
 db 4
 db 128
 db 132
 db 4
 db 128
 db 133
 db 16
 db 128
 db 132
 db 16
 db 128
 db 131
 db 11
 db 128
 db 132
 db 11
 db 128
 db 133
 db 23
 db 128
 db 132
 db 23
 db 128
 db 131
 db 11
 db 130
 db 23
 db 132
 db 11
 db 130
 db 25
 db 133
 db 23
 db 130
 db 26
 db 132
 db 23
 db 130
 db 26
 db 131
 db 11
 db 130
 db 25
 db 132
 db 11
 db 130
 db 23
 db 133
 db 23
 db 128
 db 132
 db 23
 db 128
 db 131
 db 11
 db 130
 db 25
 db 132
 db 11
 db 130
 db 25
 db 133
 db 23
 db 128
 db 132
 db 23
 db 128
 db 131
 db 1
 db 128
 db 132
 db 1
 db 128
 db 133
 db 13
 db 130
 db 25
 db 132
 db 13
 db 130
 db 25
 db 131
 db 1
 db 130
 db 25
 db 132
 db 1
 db 130
 db 25
 db 133
 db 13
 db 130
 db 25
 db 132
 db 13
 db 130
 db 25
 db 131
 db 1
 db 130
 db 25
 db 132
 db 1
 db 130
 db 25
 db 133
 db 13
 db 130
 db 28
 db 132
 db 13
 db 130
 db 28
 db 131
 db 1
 db 128
 db 132
 db 1
 db 128
 db 133
 db 13
 db 128
 db 132
 db 13
 db 128
 db 131
 db 135
 db 6
 db 128
 db 132
 db 6
 db 128
 db 133
 db 18
 db 128
 db 132
 db 18
 db 128
 db 131
 db 6
 db 130
 db 25
 db 132
 db 6
 db 130
 db 25
 db 133
 db 18
 db 130
 db 23
 db 132
 db 18
 db 130
 db 25
 db 131
 db 6
 db 128
 db 132
 db 6
 db 128
 db 133
 db 18
 db 130
 db 25
 db 132
 db 18
 db 130
 db 25
 db 131
 db 6
 db 130
 db 23
 db 132
 db 6
 db 130
 db 25
 db 133
 db 18
 db 128
 db 132
 db 18
 db 128
 db 131
 db 4
 db 130
 db 23
 db 132
 db 4
 db 130
 db 25
 db 133
 db 16
 db 130
 db 26
 db 132
 db 16
 db 130
 db 26
 db 131
 db 4
 db 130
 db 25
 db 132
 db 4
 db 130
 db 23
 db 133
 db 16
 db 128
 db 132
 db 16
 db 128
 db 131
 db 4
 db 130
 db 26
 db 132
 db 4
 db 130
 db 26
 db 133
 db 16
 db 130
 db 25
 db 132
 db 16
 db 130
 db 20
 db 131
 db 4
 db 128
 db 132
 db 4
 db 128
 db 133
 db 16
 db 128
 db 132
 db 16
 db 128
 db 131
 db 11
 db 128
 db 132
 db 11
 db 128
 db 133
 db 23
 db 128
 db 132
 db 23
 db 128
 db 131
 db 11
 db 130
 db 23
 db 132
 db 11
 db 130
 db 25
 db 133
 db 23
 db 130
 db 26
 db 132
 db 23
 db 130
 db 26
 db 131
 db 11
 db 130
 db 25
 db 132
 db 11
 db 130
 db 23
 db 133
 db 23
 db 128
 db 132
 db 23
 db 128
 db 131
 db 11
 db 130
 db 25
 db 132
 db 11
 db 130
 db 25
 db 133
 db 23
 db 128
 db 132
 db 23
 db 128
 db 131
 db 1
 db 128
 db 132
 db 1
 db 128
 db 133
 db 13
 db 25
 db 132
 db 13
 db 25
 db 131
 db 1
 db 25
 db 132
 db 1
 db 25
 db 133
 db 13
 db 25
 db 132
 db 13
 db 25
 db 131
 db 4
 db 28
 db 132
 db 4
 db 130
 db 136
 db 28
 db 133
 db 135
 db 16
 db 130
 db 136
 db 28
 db 132
 db 135
 db 16
 db 130
 db 136
 db 28
 db 131
 db 136
 db 13
 db 128
 db 132
 db 13
 db 128
 db 133
 db 13
 db 128
 db 132
 db 13
 db 128
 db 131
 db 135
 db 6
 db 128
 db 132
 db 225
 db 6
 db 130
 db 224
 db 6
 db 130
 db 33
 db 134
 db 225
 db 6
 db 131
 db 224
 db 6
 db 130
 db 33
 db 132
 db 225
 db 6
 db 130
 db 224
 db 6
 db 130
 db 33
 db 134
 db 225
 db 6
 db 131
 db 224
 db 6
 db 128
 db 132
 db 6
 db 128
 db 130
 db 6
 db 130
 db 25
 db 134
 db 6
 db 130
 db 32
 db 131
 db 6
 db 130
 db 25
 db 132
 db 6
 db 130
 db 30
 db 130
 db 6
 db 130
 db 25
 db 134
 db 6
 db 130
 db 28
 db 131
 db 135
 db 6
 db 128
 db 132
 db 225
 db 6
 db 130
 db 224
 db 6
 db 130
 db 33
 db 134
 db 225
 db 6
 db 131
 db 224
 db 6
 db 130
 db 33
 db 132
 db 225
 db 6
 db 130
 db 224
 db 6
 db 130
 db 33
 db 134
 db 225
 db 6
 db 131
 db 224
 db 6
 db 128
 db 132
 db 225
 db 6
 db 130
 db 224
 db 6
 db 128
 db 134
 db 225
 db 6
 db 131
 db 224
 db 6
 db 128
 db 132
 db 225
 db 6
 db 130
 db 224
 db 6
 db 128
 db 134
 db 225
 db 6
 db 131
 db 135
 db 224
 db 4
 db 128
 db 132
 db 225
 db 4
 db 130
 db 224
 db 4
 db 128
 db 134
 db 225
 db 4
 db 131
 db 224
 db 4
 db 128
 db 132
 db 225
 db 4
 db 130
 db 224
 db 4
 db 128
 db 134
 db 225
 db 4
 db 131
 db 224
 db 4
 db 128
 db 132
 db 225
 db 4
 db 130
 db 224
 db 4
 db 128
 db 134
 db 225
 db 4
 db 131
 db 224
 db 4
 db 128
 db 132
 db 225
 db 4
 db 130
 db 224
 db 4
 db 128
 db 134
 db 225
 db 4
 db 131
 db 135
 db 224
 db 4
 db 128
 db 132
 db 225
 db 4
 db 130
 db 224
 db 4
 db 128
 db 134
 db 225
 db 4
 db 131
 db 224
 db 4
 db 128
 db 132
 db 225
 db 4
 db 130
 db 224
 db 4
 db 128
 db 134
 db 225
 db 4
 db 131
 db 224
 db 4
 db 128
 db 132
 db 225
 db 4
 db 130
 db 224
 db 4
 db 128
 db 134
 db 225
 db 4
 db 131
 db 224
 db 4
 db 128
 db 132
 db 225
 db 4
 db 130
 db 224
 db 4
 db 128
 db 134
 db 225
 db 4
 db 131
 db 135
 db 224
 db 11
 db 128
 db 132
 db 225
 db 11
 db 130
 db 224
 db 11
 db 128
 db 134
 db 225
 db 11
 db 131
 db 224
 db 11
 db 128
 db 132
 db 225
 db 11
 db 130
 db 224
 db 11
 db 128
 db 134
 db 225
 db 11
 db 131
 db 224
 db 11
 db 128
 db 132
 db 225
 db 11
 db 130
 db 224
 db 11
 db 128
 db 134
 db 225
 db 11
 db 131
 db 224
 db 11
 db 128
 db 132
 db 225
 db 11
 db 130
 db 224
 db 11
 db 128
 db 134
 db 225
 db 11
 db 131
 db 135
 db 224
 db 11
 db 128
 db 132
 db 225
 db 11
 db 130
 db 224
 db 11
 db 128
 db 134
 db 225
 db 11
 db 131
 db 224
 db 11
 db 128
 db 132
 db 225
 db 11
 db 130
 db 224
 db 11
 db 128
 db 134
 db 225
 db 11
 db 131
 db 224
 db 11
 db 128
 db 132
 db 225
 db 11
 db 130
 db 224
 db 11
 db 128
 db 134
 db 225
 db 11
 db 131
 db 224
 db 11
 db 128
 db 132
 db 225
 db 11
 db 130
 db 224
 db 11
 db 128
 db 134
 db 225
 db 11
 db 131
 db 135
 db 224
 db 1
 db 128
 db 132
 db 225
 db 1
 db 130
 db 224
 db 1
 db 128
 db 134
 db 225
 db 1
 db 131
 db 224
 db 1
 db 128
 db 132
 db 225
 db 1
 db 130
 db 224
 db 1
 db 128
 db 134
 db 225
 db 1
 db 131
 db 224
 db 1
 db 128
 db 132
 db 225
 db 1
 db 130
 db 224
 db 1
 db 128
 db 134
 db 225
 db 1
 db 131
 db 224
 db 1
 db 128
 db 132
 db 225
 db 1
 db 130
 db 224
 db 1
 db 128
 db 134
 db 225
 db 1
 db 131
 db 135
 db 224
 db 1
 db 128
 db 132
 db 225
 db 1
 db 130
 db 224
 db 1
 db 128
 db 134
 db 225
 db 1
 db 131
 db 224
 db 1
 db 128
 db 132
 db 225
 db 1
 db 130
 db 224
 db 1
 db 128
 db 134
 db 225
 db 1
 db 131
 db 224
 db 1
 db 128
 db 132
 db 225
 db 1
 db 130
 db 224
 db 1
 db 128
 db 134
 db 225
 db 1
 db 131
 db 224
 db 1
 db 128
 db 132
 db 225
 db 1
 db 130
 db 224
 db 1
 db 128
 db 134
 db 225
 db 1
 db 131
 db 135
 db 224
 db 6
 db 128
 db 132
 db 225
 db 6
 db 130
 db 224
 db 6
 db 33
 db 134
 db 225
 db 6
 db 131
 db 224
 db 6
 db 130
 db 33
 db 132
 db 225
 db 6
 db 130
 db 224
 db 6
 db 130
 db 33
 db 134
 db 225
 db 6
 db 131
 db 224
 db 6
 db 128
 db 132
 db 6
 db 130
 db 33
 db 130
 db 6
 db 130
 db 25
 db 134
 db 6
 db 130
 db 32
 db 131
 db 6
 db 130
 db 25
 db 132
 db 6
 db 130
 db 30
 db 130
 db 6
 db 130
 db 25
 db 134
 db 6
 db 130
 db 28
 db 131
 db 135
 db 6
 db 128
 db 132
 db 225
 db 6
 db 130
 db 224
 db 6
 db 130
 db 33
 db 134
 db 225
 db 6
 db 131
 db 224
 db 6
 db 130
 db 33
 db 132
 db 225
 db 6
 db 130
 db 224
 db 6
 db 130
 db 33
 db 134
 db 225
 db 6
 db 131
 db 224
 db 6
 db 128
 db 132
 db 225
 db 6
 db 130
 db 224
 db 6
 db 128
 db 134
 db 225
 db 6
 db 131
 db 224
 db 6
 db 128
 db 132
 db 225
 db 6
 db 130
 db 224
 db 6
 db 128
 db 134
 db 225
 db 6
 db 131
 db 135
 db 224
 db 4
 db 128
 db 132
 db 225
 db 4
 db 130
 db 224
 db 4
 db 130
 db 32
 db 134
 db 225
 db 4
 db 131
 db 224
 db 4
 db 130
 db 32
 db 132
 db 225
 db 4
 db 130
 db 224
 db 4
 db 130
 db 32
 db 134
 db 225
 db 4
 db 131
 db 224
 db 4
 db 130
 db 32
 db 132
 db 225
 db 4
 db 130
 db 224
 db 4
 db 130
 db 32
 db 134
 db 225
 db 4
 db 131
 db 224
 db 4
 db 130
 db 23
 db 132
 db 225
 db 4
 db 130
 db 224
 db 4
 db 130
 db 28
 db 134
 db 225
 db 4
 db 131
 db 135
 db 224
 db 4
 db 128
 db 132
 db 225
 db 4
 db 130
 db 224
 db 4
 db 128
 db 134
 db 225
 db 4
 db 131
 db 224
 db 4
 db 128
 db 132
 db 225
 db 4
 db 130
 db 224
 db 4
 db 128
 db 134
 db 225
 db 4
 db 131
 db 224
 db 4
 db 128
 db 132
 db 225
 db 4
 db 130
 db 224
 db 4
 db 128
 db 134
 db 225
 db 4
 db 131
 db 224
 db 4
 db 128
 db 132
 db 225
 db 4
 db 130
 db 224
 db 4
 db 128
 db 134
 db 225
 db 4
 db 131
 db 135
 db 224
 db 11
 db 128
 db 132
 db 225
 db 11
 db 130
 db 224
 db 11
 db 130
 db 33
 db 134
 db 225
 db 11
 db 131
 db 224
 db 11
 db 130
 db 33
 db 132
 db 225
 db 11
 db 130
 db 224
 db 11
 db 130
 db 33
 db 134
 db 225
 db 11
 db 131
 db 224
 db 11
 db 130
 db 33
 db 132
 db 225
 db 11
 db 130
 db 224
 db 11
 db 130
 db 33
 db 134
 db 225
 db 11
 db 131
 db 224
 db 11
 db 130
 db 33
 db 132
 db 225
 db 11
 db 130
 db 224
 db 11
 db 130
 db 33
 db 134
 db 225
 db 11
 db 131
 db 135
 db 224
 db 11
 db 128
 db 132
 db 225
 db 11
 db 130
 db 224
 db 11
 db 128
 db 134
 db 225
 db 11
 db 131
 db 224
 db 11
 db 128
 db 132
 db 225
 db 11
 db 130
 db 224
 db 11
 db 128
 db 134
 db 225
 db 11
 db 131
 db 224
 db 11
 db 128
 db 132
 db 225
 db 11
 db 130
 db 224
 db 11
 db 128
 db 134
 db 225
 db 11
 db 131
 db 224
 db 11
 db 128
 db 132
 db 225
 db 11
 db 130
 db 224
 db 11
 db 128
 db 134
 db 225
 db 11
 db 131
 db 135
 db 224
 db 1
 db 128
 db 132
 db 225
 db 1
 db 130
 db 224
 db 1
 db 130
 db 32
 db 134
 db 225
 db 1
 db 131
 db 224
 db 1
 db 130
 db 32
 db 132
 db 225
 db 1
 db 130
 db 224
 db 1
 db 130
 db 32
 db 134
 db 225
 db 1
 db 131
 db 224
 db 1
 db 130
 db 32
 db 132
 db 225
 db 1
 db 130
 db 224
 db 1
 db 130
 db 32
 db 134
 db 225
 db 1
 db 131
 db 224
 db 1
 db 130
 db 32
 db 132
 db 225
 db 1
 db 130
 db 224
 db 1
 db 130
 db 32
 db 134
 db 225
 db 1
 db 134
 db 135
 db 224
 db 1
 db 2
 db 3
 db 4
 db 5
 db 6
 db 7
 db 8
 db 9
 db 10
 db 11
 db 12
 db 13
 db 14
 db 15
 db 16
 db 17
 db 18
 db 19
 db 20
 db 21
 db 22
 db 23
 db 24
 db 231
 db 25
 db 131
 db 135
 db 224
 db 6
 db 128
 db 6
 db 128
 db 6
 db 128
 db 6
 db 128
 db 130
 db 6
 db 128
 db 6
 db 128
 db 6
 db 128
 db 6
 db 128
 db 137
.chn22
 db 227
 db 128
 db 137
.chn31
 db 227
 db 10
 db 7
 db 19
 db 7
 db 10
 db 7
 db 19
 db 7
 db 10
 db 7
 db 19
 db 7
 db 10
 db 7
 db 19
 db 7
 db 10
 db 7
 db 19
 db 7
 db 10
 db 7
 db 19
 db 7
 db 10
 db 7
 db 19
 db 7
 db 10
 db 7
 db 19
 db 7
 db 10
 db 7
 db 19
 db 7
 db 10
 db 7
 db 19
 db 7
 db 10
 db 7
 db 19
 db 7
 db 10
 db 7
 db 19
 db 7
 db 10
 db 7
 db 19
 db 7
 db 10
 db 7
 db 19
 db 7
 db 10
 db 7
 db 19
 db 7
 db 10
 db 224
 db 19
 db 18
 db 17
 db 16
 db 15
 db 14
 db 13
 db 12
 db 11
 db 10
 db 9
 db 8
 db 227
 db 10
 db 9
 db 12
 db 225
 db 8
 db 229
 db 8
 db 227
 db 10
 db 12
 db 225
 db 7
 db 7
 db 227
 db 10
 db 6
 db 12
 db 225
 db 5
 db 229
 db 5
 db 227
 db 10
 db 12
 db 225
 db 6
 db 6
 db 227
 db 10
 db 9
 db 12
 db 225
 db 9
 db 229
 db 9
 db 227
 db 10
 db 12
 db 9
 db 10
 db 9
 db 12
 db 225
 db 9
 db 229
 db 9
 db 227
 db 10
 db 225
 db 16
 db 16
 db 16
 db 16
 db 227
 db 10
 db 12
 db 225
 db 16
 db 10
 db 227
 db 12
 db 10
 db 12
 db 225
 db 16
 db 10
 db 227
 db 12
 db 10
 db 12
 db 225
 db 16
 db 10
 db 227
 db 12
 db 10
 db 12
 db 225
 db 16
 db 10
 db 227
 db 12
 db 10
 db 12
 db 225
 db 16
 db 10
 db 227
 db 12
 db 10
 db 12
 db 225
 db 16
 db 10
 db 227
 db 12
 db 10
 db 12
 db 225
 db 16
 db 10
 db 227
 db 12
 db 10
 db 12
 db 225
 db 16
 db 16
 db 16
 db 16
 db 10
 db 6
 db 19
 db 227
 db 5
 db 225
 db 10
 db 19
 db 6
 db 10
 db 10
 db 19
 db 227
 db 6
 db 225
 db 10
 db 19
 db 5
 db 10
 db 6
 db 19
 db 227
 db 5
 db 225
 db 10
 db 19
 db 6
 db 10
 db 10
 db 19
 db 227
 db 6
 db 225
 db 10
 db 19
 db 5
 db 10
 db 6
 db 19
 db 227
 db 5
 db 225
 db 10
 db 19
 db 6
 db 10
 db 10
 db 19
 db 227
 db 6
 db 225
 db 10
 db 19
 db 5
 db 10
 db 6
 db 19
 db 227
 db 5
 db 225
 db 10
 db 19
 db 6
 db 10
 db 10
 db 19
 db 227
 db 6
 db 225
 db 10
 db 19
 db 5
 db 10
 db 6
 db 19
 db 227
 db 5
 db 225
 db 10
 db 19
 db 6
 db 10
 db 10
 db 19
 db 227
 db 6
 db 225
 db 10
 db 19
 db 5
 db 10
 db 6
 db 19
 db 227
 db 5
 db 225
 db 10
 db 19
 db 6
 db 10
 db 10
 db 19
 db 227
 db 6
 db 225
 db 10
 db 19
 db 5
 db 10
 db 6
 db 19
 db 227
 db 5
 db 225
 db 10
 db 19
 db 6
 db 10
 db 10
 db 19
 db 227
 db 6
 db 225
 db 10
 db 19
 db 5
 db 10
 db 6
 db 19
 db 227
 db 5
 db 225
 db 10
 db 19
 db 6
 db 10
 db 10
 db 224
 db 19
 db 18
 db 17
 db 16
 db 15
 db 14
 db 13
 db 12
 db 11
 db 10
 db 9
 db 8
 db 227
 db 10
 db 9
 db 12
 db 225
 db 8
 db 229
 db 8
 db 227
 db 10
 db 12
 db 225
 db 7
 db 7
 db 227
 db 10
 db 6
 db 12
 db 225
 db 5
 db 229
 db 5
 db 227
 db 10
 db 12
 db 225
 db 6
 db 6
 db 227
 db 10
 db 9
 db 12
 db 225
 db 9
 db 229
 db 9
 db 227
 db 10
 db 12
 db 9
 db 10
 db 9
 db 12
 db 225
 db 9
 db 229
 db 9
 db 227
 db 10
 db 225
 db 16
 db 16
 db 16
 db 16
 db 227
 db 10
 db 12
 db 225
 db 16
 db 10
 db 227
 db 12
 db 10
 db 12
 db 225
 db 16
 db 10
 db 227
 db 12
 db 10
 db 12
 db 225
 db 16
 db 10
 db 227
 db 12
 db 10
 db 12
 db 225
 db 16
 db 10
 db 227
 db 12
 db 10
 db 12
 db 225
 db 16
 db 10
 db 227
 db 12
 db 10
 db 12
 db 225
 db 16
 db 10
 db 227
 db 12
 db 10
 db 12
 db 225
 db 16
 db 10
 db 227
 db 12
 db 10
 db 12
 db 225
 db 16
 db 16
 db 16
 db 16
 db 10
 db 6
 db 19
 db 5
 db 3
 db 10
 db 19
 db 6
 db 10
 db 10
 db 19
 db 6
 db 3
 db 10
 db 19
 db 5
 db 10
 db 6
 db 19
 db 5
 db 3
 db 10
 db 19
 db 6
 db 10
 db 10
 db 19
 db 6
 db 3
 db 10
 db 19
 db 5
 db 10
 db 6
 db 19
 db 5
 db 3
 db 10
 db 19
 db 6
 db 10
 db 10
 db 3
 db 6
 db 3
 db 10
 db 19
 db 5
 db 10
 db 6
 db 19
 db 5
 db 3
 db 10
 db 19
 db 6
 db 10
 db 10
 db 19
 db 6
 db 3
 db 10
 db 19
 db 5
 db 10
 db 6
 db 19
 db 5
 db 3
 db 10
 db 19
 db 6
 db 10
 db 10
 db 19
 db 6
 db 3
 db 10
 db 19
 db 5
 db 10
 db 6
 db 19
 db 5
 db 3
 db 10
 db 19
 db 6
 db 10
 db 10
 db 19
 db 6
 db 3
 db 10
 db 19
 db 5
 db 10
 db 6
 db 19
 db 5
 db 3
 db 10
 db 19
 db 6
 db 10
 db 10
 db 19
 db 6
 db 3
 db 10
 db 19
 db 5
 db 10
 db 6
 db 19
 db 5
 db 3
 db 10
 db 19
 db 6
 db 10
 db 10
 db 19
 db 6
 db 3
 db 10
 db 19
 db 5
 db 3
 db 6
 db 19
 db 5
 db 3
 db 10
 db 19
 db 6
 db 3
 db 10
 db 19
 db 6
 db 3
 db 10
 db 19
 db 5
 db 3
 db 6
 db 19
 db 5
 db 3
 db 10
 db 19
 db 6
 db 3
 db 10
 db 19
 db 6
 db 3
 db 10
 db 19
 db 5
 db 3
 db 6
 db 19
 db 5
 db 3
 db 10
 db 19
 db 6
 db 3
 db 10
 db 19
 db 6
 db 3
 db 10
 db 19
 db 5
 db 3
 db 6
 db 19
 db 5
 db 3
 db 10
 db 19
 db 6
 db 3
 db 10
 db 19
 db 6
 db 3
 db 10
 db 19
 db 5
 db 3
 db 6
 db 19
 db 5
 db 3
 db 10
 db 19
 db 6
 db 3
 db 10
 db 19
 db 6
 db 3
 db 10
 db 19
 db 5
 db 3
 db 6
 db 19
 db 5
 db 3
 db 10
 db 19
 db 6
 db 3
 db 10
 db 19
 db 6
 db 3
 db 10
 db 19
 db 5
 db 3
 db 4
 db 5
 db 6
 db 7
 db 8
 db 9
 db 10
 db 11
 db 12
 db 13
 db 14
 db 15
 db 16
 db 17
 db 18
 db 3
 db 4
 db 5
 db 6
 db 7
 db 8
 db 9
 db 10
 db 11
 db 12
 db 13
 db 14
 db 15
 db 16
 db 17
 db 18
 db 239
 db 7
 db 129
.chn32
 db 227
 db 128
 db 129






end

;calc checksum
    LUA
    local checksum
    checksum=0

    for i=sj.get_label("begin"),sj.get_label("end") do
    checksum=checksum+sj.get_byte( i )
    end
--	print("cs:",string.format("%08X",checksum))
	sj.insert_label("CSU", checksum%256)
    ENDLUA

;rest tail
checkd: db CSU,CSU ;checksum LSB two times
;execute point
	dw begin
;high byte of execute point
	db begin/256
tap_e:
;	display /d,end-begin

	savebin "tbeepr_lightbeam.tap",tap_b,tap_e-tap_b




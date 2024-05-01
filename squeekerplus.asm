 device zxspectrum128

	org $6500-13				; Origin
tap_b:	db $22,"NONAME",$22			;name		  	
	db "M"					;type		  	
	dw end-begin				;program length	  	
	dw begin				;load point		
	org $6500
begin:



;Squeeker Plus
;ZX Spectrum beeper engine by utz
;based on Squeeker by zilogat0r



	

;HL = add counter ch1
;DE = add counter ch2
;IX = add counter ch3
;IY = add counter ch4
;BC = basefreq ch1-4
;SP = buffer pointer

	
init
;	ei			;detect kempston
;	halt
;	in a,($1f)
;	inc a
;	jr nz,_skip
;	ld (maskKempston),a
;_skip	
	di
	exx
	push hl			;preserve HL' for return to BASIC
	ld (oldSP),sp
	ld hl,musicData
	ld (seqpntr),hl

;******************************************************************
rdseq
seqpntr equ $+1
	ld sp,0
	xor a
	pop de			;pattern pointer to DE
	or d
	ld (seqpntr),sp
	jr nz,rdptn0
	
	;jp exit		;uncomment to disable looping
	
	ld sp,loop		;get loop point
	jr rdseq+3

;******************************************************************
rdptn0
	;ld (ptnpntr),de
	ex de,hl
	ld sp,hl
	ld iy,0
rdptn
;	in a,($1f)		;read joystick
;maskKempston equ $+1
;	and $1f
;	ld c,a
;	in a,($fe)		;read kbd
;	cpl
;	or c
;	and $1f
;	jp nz,exit


;ptnpntr equ $+1
;	ld sp,0	
	
	pop af
	jr z,rdseq
	
	ld i,a
	
	exx
	
	pop hl
	ld a,h
	ld (noise1),a
	ld a,l
	ld (noise2),a
	
	jr c,ld2
	pop hl
	ld (fch1),hl
	pop hl
	ld (envset1),hl
	ld a,(hl)
	ld (duty1),a
	exx
	ld hl,0
	exx
ld2	
	jp pe,ld3
	pop hl
	ld (fch2),hl
	pop hl
	ld (envset2),hl
	ld a,(hl)
	ld (duty2),a
	exx
	ld de,0
	exx
ld3
	jp m,ld4	
	pop hl
	ld (fch3),hl
	pop hl
	ld (envset3),hl
	ld a,(hl)
	ld (duty3),a
	ld ix,0
ld4	
	pop af
	jr z,ldx
	pop hl
	ld (fch4),hl		;freq 4
	ld iy,0
	ld de,0
	ld a,slideskip-jrcalc-1
	jr nc,nokick
	ld a,d			;A=0
	ex de,hl
nokick
	ld (jrcalc),a
	pop hl
	ld (envset4),hl
	ld a,(hl)
	ld (duty4),a

ldx	
	jp pe,drum1
	jp m,drum2
	xor a
	ld c,a
drumret
	ex af,af'	
	

		
	;ld (ptnpntr),sp
	ld b,$80
	
	exx
	
;******************************************************************
playNote

fch1 equ $+1
	ld bc,0			;10
	add hl,bc		;11
noise1
	db  $00,$04		;8	;replaced with cb 04 (rlc h) for noise
					; - 04 is inc b, which has no effect
duty1 equ $+1
	ld a,0			;7
	add a,h			;4
	exx			;4
	rl c			;8
	exx			;4
	
	ex de,hl		;4
fch2 equ $+1
	ld bc,0			;10
	add hl,bc		;11
noise2
	db  $00,$04		;8
duty2 equ $+1
	ld a,0			;7
	add a,h			;4
	ex de,hl		;4
	exx			;4
	rl c			;8
	exx			;4

fch3 equ $+1
	ld bc,0			;10
	add ix,bc		;15
	
duty3 equ $+1
	ld a,0			;7
	add a,ixh		;8
	exx			;4
	rl c			;8
	exx			;4
				;176

fch4 equ $+1
	ld bc,0			;10
	add iy,bc		;15
duty4 equ $+1
	ld a,0			;7
	add a,iyh		;8
	
	exx			;4
	ld a,$f			;7
	adc a,c			;4
	ld c,0			;7
	exx			;4
	
	and 16		;7

	out ($84),a		;11
	
	
	ex af,af'		;4
	dec a			;4
	jp z,updateTimer	;10
	ex af,af'		;4
	
	ex (sp),hl		;19
	ex (sp),hl		;19
	ex (sp),hl		;19
	ex (sp),hl		;19
	
	jp playNote		;10
				;368

;******************************************************************
updateTimer
	ex af,af'
	
	exx
	
envset1 equ $+1			;update duty envelope pointers
	ld hl,0
	inc hl
	ld a,(hl)
	cp b			;check for envelope end (b = $80)
	jr z,e2
	ld (duty1),a
	ld (envset1),hl
e2	
envset2 equ $+1
	ld hl,0
	inc hl
	ld a,(hl)
	cp b
	jr z,e3
	ld (duty2),a
	ld (envset2),hl
e3
envset3 equ $+1
	ld hl,0
	inc hl
	ld a,(hl)
	cp b
	jr z,e4
	ld (duty3),a
	ld (envset3),hl
e4	
envset4 equ $+1
	ld hl,0
	inc hl
	ld a,(hl)
	cp b
	jr z,eex
	ld (duty4),a
	ld (envset4),hl

eex
jrcalc equ $+1
	jr slideskip		;

	ld hl,(fch4)		;update ch4 pitch
	srl d			;if pitch slide is enabled, de = freq.ch4
	rr e			;else, de = 0
	
	sbc hl,de		;thus, freq.ch4 = freq.ch4 - int(freq.ch4/2)
	ld (fch4),hl		;if pitch slide is enabled, else no change
 	
	ld iy,0			;reset add counter ch4 so it isn't accidentally
slideskip			;left in a "high" state
	
	exx
	
	ld a,i
	dec a
	jp z,rdptn
	ld i,a
	jp playNote

;******************************************************************
exit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret
;******************************************************************
drum2
	ld hl,hat1
	ld b,hat1end-hat1
	jr drentry
drum1
	ld hl,kick1		;10
	ld b,kick1end-kick1	;7
drentry
	xor a			;4
_s2	
	xor 16		;7
	ld c,(hl)		;7
	inc hl			;6
_s1	
	out ($84),a		;11

	dec c			;4
	jr nz,_s1		;12/7    
	
	djnz _s2		;13/8
	ld a,$6d		;7	;correct tempo
	jp drumret		;10
	
kick1					;27*16*4 + 27*32*4 + 27*64*4 + 27*128*4 + 27*256*4 = 53568, + 20*33 = 53568 -> -147,4 loops -> AF' = $6D
	ds 4,$10
	ds 4,$20
	ds 4,$40
	ds 4,$80
	ds 4,0
kick1end

hat1
	db  16,3,12,6,9,20,4,8,2,14,9,17,5,8,12,4,7,16,13,22,5,3,16,3,12,6,9,20,4,8,2,14,9,17,5,8,12,4,7,16,13,22,5,3
	db  12,8,1,24,6,7,4,9,18,12,8,3,11,7,5,8,3,17,9,15,22,6,5,8,11,13,4,8,12,9,2,4,7,8,12,6,7,4,19,22,1,9,6,27,4,3,11
	db  5,8,14,2,11,13,5,9,2,17,10,3,7,19,4,3,8,2,9,11,4,17,6,4,9,14,2,22,8,4,19,2,3,5,11,1,16,20,4,7
	db  8,9,4,12,2,8,14,3,7,7,13,9,15,1,8,4,17,3,22,4,8,11,4,21,9,6,12,4,3,8,7,17,5,9,2,11,17,4,9,3,2
	db  22,4,7,3,8,9,4,11,8,5,9,2,6,2,8,8,3,11,5,3,9,6,7,4,8
hat1end

env0
	db  0,$80
	
musicData


			;sequence
loop
	dw ptn0
	dw ptn1
	dw ptn2
	dw ptn3
	dw ptn4
	dw ptn4
	dw ptn5
	dw ptn5
	dw ptn6
	dw ptn6
	dw ptn7
	dw ptn7
	dw ptn8
	dw ptn8
	dw ptn9
	dw 0

			;patterns
ptn0
	dw #400,#0000,#0,env0,#800,envS_20,#0,env0,#0,#0,env0
	dw #485,#0000,#40
	dw #485,#0000,#40
	dw #481,#0000,#400,env7,#40
	dw #481,#0000,#400,env7,#40
	dw #481,#0000,#400,env7,#40
	dw #481,#0000,#984,envS_20,#40
	dw #485,#0000,#40
	dw #485,#0000,#40
	dw #481,#0000,#400,env7,#40
	dw #481,#0000,#400,env7,#40
	dw #481,#0000,#400,env7,#40
	dw #481,#0000,#8fb,envS_20,#40
	dw #485,#0000,#40
	dw #485,#0000,#40
	dw #481,#0000,#400,env7,#40
	dw #481,#0000,#400,env7,#40
	dw #481,#0000,#400,env7,#40
	dw #481,#0000,#721,envS_20,#40
	dw #485,#0000,#40
	dw #481,#0000,#800,envS_20,#40
	dw #485,#0000,#40
	dw #481,#0000,#721,envS_20,#40
	dw #485,#0000,#40
	dw #481,#0000,#800,envS_20,#40
	dw #485,#0000,#40
	dw #485,#0000,#40
	dw #481,#0000,#400,env7,#40
	dw #481,#0000,#400,env7,#40
	dw #481,#0000,#400,env7,#40
	dw #481,#0000,#984,envS_20,#40
	dw #485,#0000,#40
	dw #485,#0000,#40
	dw #481,#0000,#400,env7,#40
	dw #481,#0000,#400,env7,#40
	dw #481,#0000,#400,env7,#40
	dw #481,#0000,#8fb,envS_20,#40
	dw #485,#0000,#40
	dw #485,#0000,#40
	dw #481,#0000,#400,env7,#40
	dw #481,#0000,#400,env7,#40
	dw #481,#0000,#400,env7,#40
	dw #481,#0000,#721,envS_20,#40
	dw #485,#0000,#40
	dw #481,#0000,#800,envS_20,#40
	dw #485,#0000,#40
	dw #481,#0000,#721,envS_20,#40
	dw #485,#0000,#40
	db #40

ptn1
	dw #400,#0000,#0,env0,#800,envS_20,#0,env0,#0,#0,env0
	dw #485,#0000,#40
	dw #485,#0000,#40
	dw #481,#0000,#32d,env7,#40
	dw #481,#0000,#32d,env7,#40
	dw #481,#0000,#32d,env7,#40
	dw #481,#0000,#984,envS_20,#40
	dw #485,#0000,#40
	dw #485,#0000,#40
	dw #481,#0000,#32d,env7,#40
	dw #481,#0000,#32d,env7,#40
	dw #481,#0000,#32d,env7,#40
	dw #481,#0000,#8fb,envS_20,#40
	dw #485,#0000,#40
	dw #485,#0000,#40
	dw #481,#0000,#32d,env7,#40
	dw #481,#0000,#32d,env7,#40
	dw #481,#0000,#32d,env7,#40
	dw #481,#0000,#721,envS_20,#40
	dw #485,#0000,#40
	dw #481,#0000,#800,envS_20,#40
	dw #485,#0000,#40
	dw #481,#0000,#721,envS_20,#40
	dw #485,#0000,#40
	dw #481,#0000,#800,envS_20,#40
	dw #485,#0000,#40
	dw #485,#0000,#40
	dw #481,#0000,#2ff,env7,#40
	dw #481,#0000,#2ff,env7,#40
	dw #481,#0000,#2ff,env7,#40
	dw #481,#0000,#984,envS_20,#40
	dw #485,#0000,#40
	dw #485,#0000,#40
	dw #481,#0000,#2ff,env7,#40
	dw #481,#0000,#2ff,env7,#40
	dw #481,#0000,#2ff,env7,#40
	dw #481,#0000,#8fb,envS_20,#40
	dw #485,#0000,#40
	dw #485,#0000,#40
	dw #481,#0000,#2ff,env7,#40
	dw #481,#0000,#2ff,env7,#40
	dw #481,#0000,#2ff,env7,#40
	dw #481,#0000,#721,envS_20,#40
	dw #485,#0000,#40
	dw #481,#0000,#800,envS_20,#40
	dw #485,#0000,#40
	dw #481,#0000,#721,envS_20,#40
	dw #485,#0000,#40
	db #40

ptn2
	dw #400,#cb00,#2175,env6,#800,envS_40,#400,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #485,#cb00,#41
	dw #401,#cb00,#400,env7,#100,env7,#1,#400,envS_40
	dw #401,#cb00,#400,env7,#100,env7,#1,#400,envS_40
	dw #401,#cb00,#400,env7,#100,env7,#1,#400,envS_40
	dw #400,#cb00,#2175,env6,#984,envS_40,#4c2,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #485,#cb00,#41
	dw #401,#cb00,#400,env7,#100,env7,#1,#400,envS_40
	dw #401,#cb00,#400,env7,#100,env7,#1,#400,envS_40
	dw #401,#cb00,#400,env7,#100,env7,#1,#400,envS_40
	dw #400,#cb00,#2175,env6,#8fb,envS_40,#47d,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #485,#cb00,#41
	dw #401,#cb00,#400,env7,#100,env7,#1,#400,envS_40
	dw #401,#cb00,#400,env7,#100,env7,#1,#400,envS_40
	dw #401,#cb00,#400,env7,#100,env7,#1,#400,envS_40
	dw #400,#cb00,#2175,env6,#721,envS_40,#390,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #400,#cb00,#2175,env6,#800,envS_40,#400,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #400,#cb00,#2175,env6,#721,envS_40,#390,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #400,#cb00,#2175,env6,#800,envS_40,#400,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #485,#cb00,#41
	dw #401,#cb00,#400,env7,#100,env7,#1,#400,envS_40
	dw #401,#cb00,#400,env7,#100,env7,#1,#400,envS_40
	dw #401,#cb00,#400,env7,#100,env7,#1,#400,envS_40
	dw #400,#cb00,#2175,env6,#984,envS_40,#4c2,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #485,#cb00,#41
	dw #401,#cb00,#400,env7,#100,env7,#1,#400,envS_40
	dw #401,#cb00,#400,env7,#100,env7,#1,#400,envS_40
	dw #401,#cb00,#400,env7,#100,env7,#1,#400,envS_40
	dw #400,#cb00,#2175,env6,#8fb,envS_40,#47d,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #485,#cb00,#41
	dw #401,#cb00,#400,env7,#100,env7,#1,#400,envS_40
	dw #401,#cb00,#400,env7,#100,env7,#1,#400,envS_40
	dw #401,#cb00,#400,env7,#100,env7,#1,#400,envS_40
	dw #400,#cb00,#2175,env6,#721,envS_40,#390,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #400,#cb00,#2175,env6,#800,envS_40,#400,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #400,#cb00,#2175,env6,#721,envS_40,#390,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	db #40

ptn3
	dw #400,#cb00,#2175,env6,#800,envS_40,#400,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #485,#cb00,#41
	dw #401,#cb00,#32d,env7,#196,env7,#1,#400,envS_40
	dw #401,#cb00,#32d,env7,#196,env7,#1,#400,envS_40
	dw #401,#cb00,#32d,env7,#196,env7,#1,#400,envS_40
	dw #400,#cb00,#2175,env6,#984,envS_40,#4c2,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #485,#cb00,#41
	dw #401,#cb00,#32d,env7,#196,env7,#1,#400,envS_40
	dw #401,#cb00,#32d,env7,#196,env7,#1,#400,envS_40
	dw #401,#cb00,#32d,env7,#196,env7,#1,#400,envS_40
	dw #400,#cb00,#2175,env6,#8fb,envS_40,#47d,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #485,#cb00,#41
	dw #401,#cb00,#32d,env7,#196,env7,#1,#400,envS_40
	dw #401,#cb00,#32d,env7,#196,env7,#1,#400,envS_40
	dw #401,#cb00,#32d,env7,#196,env7,#1,#400,envS_40
	dw #400,#cb00,#2175,env6,#721,envS_40,#390,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #400,#cb00,#2175,env6,#800,envS_40,#400,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #400,#cb00,#2175,env6,#721,envS_40,#390,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #400,#cb00,#2175,env6,#800,envS_40,#400,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #485,#cb00,#41
	dw #401,#cb00,#2ff,env7,#17f,env7,#1,#400,envS_40
	dw #401,#cb00,#2ff,env7,#17f,env7,#1,#400,envS_40
	dw #401,#cb00,#2ff,env7,#17f,env7,#1,#400,envS_40
	dw #400,#cb00,#2175,env6,#984,envS_40,#4c2,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #485,#cb00,#41
	dw #401,#cb00,#2ff,env7,#17f,env7,#1,#400,envS_40
	dw #401,#cb00,#2ff,env7,#17f,env7,#1,#400,envS_40
	dw #401,#cb00,#2ff,env7,#17f,env7,#1,#400,envS_40
	dw #400,#cb00,#2175,env6,#8fb,envS_40,#47d,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #485,#cb00,#41
	dw #401,#cb00,#2ff,env7,#17f,env7,#1,#400,envS_40
	dw #401,#cb00,#2ff,env7,#17f,env7,#1,#400,envS_40
	dw #401,#cb00,#2ff,env7,#17f,env7,#1,#400,envS_40
	dw #400,#cb00,#2175,env6,#721,envS_40,#390,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #400,#cb00,#2175,env6,#800,envS_40,#400,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	dw #400,#cb00,#2175,env6,#721,envS_40,#390,envS_40,#5,#400,envS_40
	dw #485,#cb00,#41
	db #40

ptn4
	dw #400,#0000,#4c2,env8,#200,envS_40,#800,enva,#0,#0,env0
	dw #485,#0000,#40
	dw #485,#0000,#40
	dw #481,#0000,#100,env7,#40
	dw #481,#0000,#100,env7,#40
	dw #481,#0000,#100,env7,#40
	dw #480,#0000,#5fe,env8,#200,envS_40,#40
	dw #485,#0000,#40
	dw #485,#0000,#40
	dw #481,#0000,#100,env7,#40
	dw #481,#0000,#100,env7,#40
	dw #481,#0000,#100,env7,#40
	dw #480,#0000,#557,env8,#200,envS_40,#40
	dw #485,#0000,#40
	dw #485,#0000,#40
	dw #481,#0000,#100,env7,#40
	dw #481,#0000,#100,env7,#40
	dw #481,#0000,#100,env7,#40
	dw #480,#0000,#47d,env8,#200,envS_40,#40
	dw #485,#0000,#40
	dw #485,#0000,#40
	dw #481,#0000,#100,env7,#40
	dw #481,#0000,#100,env7,#40
	dw #481,#0000,#100,env7,#40
	dw #480,#0000,#4c2,env8,#200,envS_40,#40
	dw #485,#0000,#40
	dw #485,#0000,#40
	dw #481,#0000,#100,env7,#40
	dw #481,#0000,#100,env7,#40
	dw #481,#0000,#100,env7,#40
	dw #480,#0000,#5fe,env8,#200,envS_40,#40
	dw #485,#0000,#40
	dw #485,#0000,#40
	dw #481,#0000,#100,env7,#40
	dw #481,#0000,#100,env7,#40
	dw #481,#0000,#100,env7,#40
	dw #480,#0000,#557,env8,#200,envS_40,#40
	dw #485,#0000,#40
	dw #485,#0000,#40
	dw #481,#0000,#100,env7,#40
	dw #481,#0000,#100,env7,#40
	dw #481,#0000,#100,env7,#40
	dw #480,#0000,#47d,env8,#200,envS_40,#40
	dw #485,#0000,#40
	dw #485,#0000,#40
	dw #481,#0000,#100,env7,#40
	dw #481,#0000,#100,env7,#40
	dw #481,#0000,#100,env7,#40
	db #40

ptn5
	dw #400,#0000,#4c2,env8,#200,envS_40,#1307,env9,#1,#800,envS_40
	dw #405,#0000,#11f6,env9,#1,#800,envS_40
	dw #405,#0000,#1307,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#155c,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#1307,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#11f6,env9,#1,#800,envS_40
	dw #400,#0000,#5fe,env8,#200,envS_40,#1307,env9,#1,#800,envS_40
	dw #405,#0000,#11f6,env9,#1,#800,envS_40
	dw #405,#0000,#1307,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#155c,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#1307,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#11f6,env9,#1,#800,envS_40
	dw #400,#0000,#557,env8,#200,envS_40,#1307,env9,#1,#800,envS_40
	dw #405,#0000,#11f6,env9,#1,#800,envS_40
	dw #405,#0000,#1307,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#155c,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#1307,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#11f6,env9,#1,#800,envS_40
	dw #400,#0000,#47d,env8,#200,envS_40,#1307,env9,#1,#800,envS_40
	dw #405,#0000,#11f6,env9,#1,#800,envS_40
	dw #405,#0000,#1307,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#155c,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#1307,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#11f6,env9,#1,#800,envS_40
	dw #400,#0000,#4c2,env8,#200,envS_40,#1307,env9,#1,#800,envS_40
	dw #405,#0000,#11f6,env9,#1,#800,envS_40
	dw #405,#0000,#1307,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#155c,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#1307,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#11f6,env9,#1,#800,envS_40
	dw #400,#0000,#5fe,env8,#200,envS_40,#1307,env9,#1,#800,envS_40
	dw #405,#0000,#11f6,env9,#1,#800,envS_40
	dw #405,#0000,#1307,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#155c,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#1307,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#11f6,env9,#1,#800,envS_40
	dw #400,#0000,#557,env8,#200,envS_40,#1307,env9,#1,#800,envS_40
	dw #405,#0000,#11f6,env9,#1,#800,envS_40
	dw #405,#0000,#1307,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#155c,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#1307,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#11f6,env9,#1,#800,envS_40
	dw #400,#0000,#47d,env8,#200,envS_40,#1307,env9,#1,#800,envS_40
	dw #405,#0000,#11f6,env9,#1,#800,envS_40
	dw #405,#0000,#1307,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#155c,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#1307,env9,#1,#800,envS_40
	dw #401,#0000,#100,env7,#11f6,env9,#1,#800,envS_40
	db #40

ptn6
	dw #400,#0000,#65a,env8,#2ab,envS_40,#1966,env9,#1,#557,envS_40
	dw #405,#0000,#17f9,env9,#1,#557,envS_40
	dw #405,#0000,#1966,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#1c82,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#1966,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#17f9,env9,#1,#557,envS_40
	dw #400,#0000,#800,env8,#2ab,envS_40,#1966,env9,#1,#557,envS_40
	dw #405,#0000,#17f9,env9,#1,#557,envS_40
	dw #405,#0000,#1966,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#1c82,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#1966,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#17f9,env9,#1,#557,envS_40
	dw #400,#0000,#721,env8,#2ab,envS_40,#1966,env9,#1,#557,envS_40
	dw #405,#0000,#17f9,env9,#1,#557,envS_40
	dw #405,#0000,#1966,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#1c82,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#1966,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#17f9,env9,#1,#557,envS_40
	dw #400,#0000,#5fe,env8,#2ab,envS_40,#1966,env9,#1,#557,envS_40
	dw #405,#0000,#17f9,env9,#1,#557,envS_40
	dw #405,#0000,#1966,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#1c82,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#1966,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#17f9,env9,#1,#557,envS_40
	dw #400,#0000,#65a,env8,#2ab,envS_40,#1966,env9,#1,#557,envS_40
	dw #405,#0000,#17f9,env9,#1,#557,envS_40
	dw #405,#0000,#1966,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#1c82,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#1966,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#17f9,env9,#1,#557,envS_40
	dw #400,#0000,#800,env8,#2ab,envS_40,#1966,env9,#1,#557,envS_40
	dw #405,#0000,#17f9,env9,#1,#557,envS_40
	dw #405,#0000,#1966,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#1c82,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#1966,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#17f9,env9,#1,#557,envS_40
	dw #400,#0000,#721,env8,#2ab,envS_40,#1966,env9,#1,#557,envS_40
	dw #405,#0000,#17f9,env9,#1,#557,envS_40
	dw #405,#0000,#1966,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#1c82,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#1966,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#17f9,env9,#1,#557,envS_40
	dw #400,#0000,#5fe,env8,#2ab,envS_40,#1966,env9,#1,#557,envS_40
	dw #405,#0000,#17f9,env9,#1,#557,envS_40
	dw #405,#0000,#1966,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#1c82,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#1966,env9,#1,#557,envS_40
	dw #401,#0000,#155,env7,#17f9,env9,#1,#557,envS_40
	db #40

ptn7
	dw #400,#0000,#4c2,env8,#200,envS_40,#1307,env9,#5,#400,envS_40
	dw #405,#0000,#11f6,env9,#5,#400,envS_40
	dw #405,#0000,#1307,env9,#5,#400,envS_40
	dw #401,#0000,#100,env7,#155c,env9,#81,#400,envS_40
	dw #401,#0000,#100,env7,#1307,env9,#5,#400,envS_40
	dw #401,#0000,#100,env7,#11f6,env9,#5,#400,envS_40
	dw #400,#0000,#5fe,env8,#200,envS_40,#1307,env9,#5,#400,envS_40
	dw #405,#0000,#11f6,env9,#5,#400,envS_40
	dw #405,#0000,#1307,env9,#5,#400,envS_40
	dw #401,#0000,#100,env7,#155c,env9,#81,#400,envS_40
	dw #401,#0000,#100,env7,#1307,env9,#5,#400,envS_40
	dw #401,#0000,#100,env7,#11f6,env9,#5,#400,envS_40
	dw #400,#0000,#557,env8,#200,envS_40,#1307,env9,#5,#400,envS_40
	dw #405,#0000,#11f6,env9,#5,#400,envS_40
	dw #405,#0000,#1307,env9,#5,#400,envS_40
	dw #401,#0000,#100,env7,#155c,env9,#81,#400,envS_40
	dw #401,#0000,#100,env7,#1307,env9,#5,#400,envS_40
	dw #401,#0000,#100,env7,#11f6,env9,#5,#400,envS_40
	dw #400,#0000,#47d,env8,#200,envS_40,#1307,env9,#5,#400,envS_40
	dw #405,#0000,#11f6,env9,#5,#400,envS_40
	dw #405,#0000,#1307,env9,#5,#400,envS_40
	dw #401,#0000,#100,env7,#155c,env9,#81,#400,envS_40
	dw #401,#0000,#100,env7,#1307,env9,#5,#400,envS_40
	dw #401,#0000,#100,env7,#11f6,env9,#5,#400,envS_40
	dw #400,#0000,#4c2,env8,#200,envS_40,#1307,env9,#5,#400,envS_40
	dw #405,#0000,#11f6,env9,#5,#400,envS_40
	dw #405,#0000,#1307,env9,#5,#400,envS_40
	dw #401,#0000,#100,env7,#155c,env9,#81,#400,envS_40
	dw #401,#0000,#100,env7,#1307,env9,#5,#400,envS_40
	dw #401,#0000,#100,env7,#11f6,env9,#5,#400,envS_40
	dw #400,#0000,#5fe,env8,#200,envS_40,#1307,env9,#5,#400,envS_40
	dw #405,#0000,#11f6,env9,#5,#400,envS_40
	dw #405,#0000,#1307,env9,#5,#400,envS_40
	dw #401,#0000,#100,env7,#155c,env9,#81,#400,envS_40
	dw #401,#0000,#100,env7,#1307,env9,#5,#400,envS_40
	dw #401,#0000,#100,env7,#11f6,env9,#5,#400,envS_40
	dw #400,#0000,#557,env8,#200,envS_40,#1307,env9,#5,#400,envS_40
	dw #405,#0000,#11f6,env9,#5,#400,envS_40
	dw #405,#0000,#1307,env9,#5,#400,envS_40
	dw #401,#0000,#100,env7,#155c,env9,#81,#400,envS_40
	dw #401,#0000,#100,env7,#1307,env9,#5,#400,envS_40
	dw #401,#0000,#100,env7,#11f6,env9,#5,#400,envS_40
	dw #400,#0000,#47d,env8,#200,envS_40,#1307,env9,#5,#400,envS_40
	dw #405,#0000,#11f6,env9,#5,#400,envS_40
	dw #405,#0000,#1307,env9,#5,#400,envS_40
	dw #401,#0000,#100,env7,#155c,env9,#81,#400,envS_40
	dw #401,#0000,#100,env7,#1307,env9,#81,#400,envS_40
	dw #401,#0000,#100,env7,#11f6,env9,#81,#400,envS_40
	db #40

ptn8
	dw #400,#0000,#65a,env8,#2ab,envS_40,#1966,env9,#5,#400,envS_40
	dw #405,#0000,#17f9,env9,#5,#400,envS_40
	dw #405,#0000,#1966,env9,#5,#400,envS_40
	dw #401,#0000,#155,env7,#1c82,env9,#81,#400,envS_40
	dw #401,#0000,#155,env7,#1966,env9,#5,#400,envS_40
	dw #401,#0000,#155,env7,#17f9,env9,#5,#400,envS_40
	dw #400,#0000,#800,env8,#2ab,envS_40,#1966,env9,#5,#400,envS_40
	dw #405,#0000,#17f9,env9,#5,#400,envS_40
	dw #405,#0000,#1966,env9,#5,#400,envS_40
	dw #401,#0000,#155,env7,#1c82,env9,#81,#400,envS_40
	dw #401,#0000,#155,env7,#1966,env9,#5,#400,envS_40
	dw #401,#0000,#155,env7,#17f9,env9,#5,#400,envS_40
	dw #400,#0000,#721,env8,#2ab,envS_40,#1966,env9,#5,#400,envS_40
	dw #405,#0000,#17f9,env9,#5,#400,envS_40
	dw #405,#0000,#1966,env9,#5,#400,envS_40
	dw #401,#0000,#155,env7,#1c82,env9,#81,#400,envS_40
	dw #401,#0000,#155,env7,#1966,env9,#5,#400,envS_40
	dw #401,#0000,#155,env7,#17f9,env9,#5,#400,envS_40
	dw #400,#0000,#5fe,env8,#2ab,envS_40,#1966,env9,#5,#400,envS_40
	dw #405,#0000,#17f9,env9,#5,#400,envS_40
	dw #405,#0000,#1966,env9,#5,#400,envS_40
	dw #401,#0000,#155,env7,#1c82,env9,#81,#400,envS_40
	dw #401,#0000,#155,env7,#1966,env9,#5,#400,envS_40
	dw #401,#0000,#155,env7,#17f9,env9,#5,#400,envS_40
	dw #400,#0000,#65a,env8,#2ab,envS_40,#1966,env9,#5,#400,envS_40
	dw #405,#0000,#17f9,env9,#5,#400,envS_40
	dw #405,#0000,#1966,env9,#5,#400,envS_40
	dw #401,#0000,#155,env7,#1c82,env9,#81,#400,envS_40
	dw #401,#0000,#155,env7,#1966,env9,#5,#400,envS_40
	dw #401,#0000,#155,env7,#17f9,env9,#5,#400,envS_40
	dw #400,#0000,#800,env8,#2ab,envS_40,#1966,env9,#5,#400,envS_40
	dw #405,#0000,#17f9,env9,#5,#400,envS_40
	dw #405,#0000,#1966,env9,#5,#400,envS_40
	dw #401,#0000,#155,env7,#1c82,env9,#81,#400,envS_40
	dw #401,#0000,#155,env7,#1966,env9,#5,#400,envS_40
	dw #401,#0000,#155,env7,#17f9,env9,#5,#400,envS_40
	dw #400,#0000,#721,env8,#2ab,envS_40,#1966,env9,#5,#400,envS_40
	dw #405,#0000,#17f9,env9,#5,#400,envS_40
	dw #405,#0000,#1966,env9,#5,#400,envS_40
	dw #401,#0000,#155,env7,#1c82,env9,#81,#400,envS_40
	dw #401,#0000,#155,env7,#1966,env9,#5,#400,envS_40
	dw #401,#0000,#155,env7,#17f9,env9,#5,#400,envS_40
	dw #400,#0000,#5fe,env8,#2ab,envS_40,#1966,env9,#5,#400,envS_40
	dw #405,#0000,#17f9,env9,#5,#400,envS_40
	dw #405,#0000,#1966,env9,#5,#400,envS_40
	dw #401,#0000,#155,env7,#1c82,env9,#81,#400,envS_40
	dw #401,#0000,#155,env7,#1966,env9,#5,#400,envS_40
	dw #401,#0000,#155,env7,#17f9,env9,#5,#400,envS_40
	db #40

ptn9
	dw #400,#0000,#0,env0,#1307,env9,#0,env0,#0,#0,env0
	dw #481,#0000,#11f6,env9,#40
	dw #481,#0000,#1307,env9,#40
	dw #481,#0000,#155c,env9,#40
	dw #481,#0000,#1307,env9,#40
	dw #481,#0000,#11f6,env9,#40
	dw #481,#0000,#1307,env9,#40
	dw #481,#0000,#11f6,env9,#40
	dw #481,#0000,#1307,env9,#40
	dw #481,#0000,#155c,env9,#40
	dw #481,#0000,#1307,env9,#40
	dw #481,#0000,#11f6,env9,#40
	dw #481,#0000,#1307,env9,#40
	dw #481,#0000,#11f6,env9,#40
	dw #481,#0000,#1307,env9,#40
	dw #481,#0000,#155c,env9,#40
	dw #481,#0000,#1307,env9,#40
	dw #481,#0000,#11f6,env9,#40
	dw #481,#0000,#1307,env9,#40
	dw #481,#0000,#11f6,env9,#40
	dw #481,#0000,#1307,env9,#40
	dw #481,#0000,#155c,env9,#40
	dw #481,#0000,#1307,env9,#40
	dw #481,#0000,#11f6,env9,#40
	dw #400,#cb00,#2175,env6,#800,envS_20,#200,envS_40,#5,#400,envS_40
	dw #401,#cb00,#5fe,envS_20,#17f,envS_40,#0,#0,env0
	dw #401,#cb00,#4c2,envS_20,#130,envS_40,#40
	dw #401,#cb00,#400,envS_20,#100,envS_40,#40
	dw #485,#cb00,#40
	dw #485,#cb00,#40
	dw #401,#cb00,#0,env0,#0,env0,#40
	dw #485,#cb00,#40
	dw #485,#cb00,#40
	dw #485,#cb00,#40
	dw #485,#cb00,#40
	dw #485,#cb00,#40
	dw #485,#cb00,#40
	dw #485,#cb00,#40
	dw #485,#cb00,#40
	dw #485,#cb00,#40
	dw #485,#cb00,#40
	dw #485,#cb00,#40
	dw #485,#cb00,#40
	dw #485,#cb00,#40
	dw #485,#cb00,#40
	dw #485,#cb00,#40
	dw #485,#cb00,#40
	dw #485,#cb00,#40
	db #40

envelopes
envS_8	db #8,#80
envS_20	db #20,#80
envS_40	db #40,#80

env6
	db #30,#2e,#2c,#2a,#28,#27,#25,#23,#21,#1f,#1e,#1c,#1a,#18,#17,#15,#13,#11,#f,#e,#c,#a,#8,#7,#5,#3,#1,#0,#80

env7
	db #40,#30,#20,#10,#0,#80

env8
	db #30,#2e,#2c,#2b,#29,#27,#26,#24,#22,#21,#1f,#1d,#1c,#1a,#18,#17,#15,#13,#12,#10,#e,#d,#b,#9,#8,#6,#4,#3,#1,#0,#80

env9
	db #21,#1a,#13,#c,#80

enva
	db #38,#37,#37,#37,#36,#36,#36,#35,#35,#35,#34,#34,#34,#34,#33,#33,#33,#32,#32,#32,#31,#31,#31,#31,#30,#30,#30,#2f,#2f,#2f,#2e,#2e
	db #2e,#2d,#2d,#2d,#2d,#2c,#2c,#2c,#2b,#2b,#2b,#2a,#2a,#2a,#2a,#29,#29,#29,#28,#28,#28,#27,#27,#27,#26,#26,#26,#26,#25,#25,#25,#24
	db #24,#24,#23,#23,#23,#23,#22,#22,#22,#21,#21,#21,#20,#20,#20,#1f,#1f,#1f,#1f,#1e,#1e,#1e,#1d,#1d,#1d,#1c,#1c,#1c,#1c,#1b,#1b,#1b
	db #1a,#1a,#1a,#19,#19,#19,#19,#18,#18,#18,#17,#17,#17,#16,#16,#16,#15,#15,#15,#15,#14,#14,#14,#13,#13,#13,#12,#12,#12,#12,#11,#11
	db #11,#10,#10,#10,#f,#f,#f,#e,#e,#e,#e,#d,#d,#d,#c,#c,#c,#b,#b,#b,#b,#a,#a,#a,#9,#9,#9,#8,#8,#8,#7,#7
	db #7,#7,#6,#6,#6,#5,#5,#5,#4,#4,#4,#4,#3,#3,#3,#2,#2,#2,#1,#1,#1,#1,#80







end
    LUA					;calc checksum
    local checksum
    checksum=0
    for i=sj.get_label("begin"),sj.get_label("end") do
    checksum=checksum+sj.get_byte( i )
    end
	sj.insert_label("CSU", checksum%256)
    ENDLUA

checkd: db CSU,CSU ;checksum LSB two times
	dw begin
	db begin/256
tap_e:	savebin "squeekerplus.tap",tap_b,tap_e-tap_b



 device zxspectrum128

	org $6500-13				; Origin
tap_b:	db $22,"NONAME",$22			;name		  	
	db "M"					;type		  	
	dw end-begin				;program length	  	
	dw begin				;load point		
	org $6500
begin:




;******************************************************************
;Octode 2k15 - 8ch beeper engine
;
;original code: Shiru 02'11
;"XL" version: introspec 10'14-04'15
;"2k15" version: utz 09'15
;******************************************************************


	di
init
;	ei			;detect kempston
;	halt
;	in a,(#1f)
;	inc a
;	jr nz,_skip
;	ld (maskKempston),a
;_skip	
	di
	exx
	push hl			;preserve HL' for return to BASIC
	ld iyl,0
	ld (oldSP),sp
	ld hl,musicdata
	ld (seqpntr),hl

;******************************************************************
rdseq
seqpntr equ $+1
	ld sp,0
	xor a
	pop hl			;pattern pointer to HL
	or h
	ld (seqpntr),sp
	jr nz,rdptn0	
	;jp exit		;uncomment to disable looping
	
	ld sp,loop		;get loop point
	jr rdseq+3

;******************************************************************
rdptn0	
	ld sp,hl		;fetch pattern pointer
rdptn
	xor a
	out (#84),a

;	in a,(#1f)		;read joystick
;maskKempston equ $+1
;	and #1f
;	ld c,a
;	in a,(#fe)		;read kbd
;	cpl
;	or c
;	and #1f
;	jp nz,exit

	pop af
	jr z,rdseq
	
	jp c,drums
drumret	
	ld b,a			;B,B' = timer
	
	pop de			;freq8
	ld (fstack),sp
	
fstack equ $+1
	ld hl,0
	exx
	
	ld bc,#84
	xor a

;***************************************************frame1
play

cnt1 equ $+1
	ld hl,0		;10
	pop de		;10
	add hl,de	;11
	ld (cnt1),hl	;16
			;-47
	
	rra		;4
	out (c),a	;12
	nop		;4	
	rrca		;4
	out (c),a	;12
			;4
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (#84),a	;11
	rrca		;4
	out (#84),a	;11
	rrca		;4
	out (#84),a	;11
	rrca		;4
	nop
			;184
	
;***************************************************frame2

cnt2 equ $+1
	ld hl,0		;10
	pop de		;10
	add hl,de	;11
	ld (cnt2),hl	;16
			;-47
	
	rra		;4
	out (c),a	;12
	nop	
	rrca		;4
	out (c),a	;12
	
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (#84),a	;11
	rrca		;4
	out (#84),a	;11
	rrca		;4
	out (#84),a	;11
	rrca		;4
	nop
			;184

;***************************************************frame3

cnt3 equ $+1
	ld hl,0		;10
	pop de		;10
	add hl,de	;11
	ld (cnt3),hl	;16
			;-47
	
	rra		;4
	out (c),a	;12
	nop	
	rrca		;4
	out (c),a	;12
	
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (#84),a	;11
	rrca		;4
	out (#84),a	;11
	rrca		;4
	out (#84),a	;11
	rrca		;4
	nop
			;184

;***************************************************frame4

cnt4 equ $+1
	ld hl,0		;10
	pop de		;10
	add hl,de	;11
	ld (cnt4),hl	;16
			;-47
	
	rra		;4
	out (c),a	;12
	nop	
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (#84),a	;11
	rrca		;4
	out (#84),a	;11
	rrca		;4
	out (#84),a	;11
	rrca		;4
	nop
			;184
	
;***************************************************frame5

cnt5 equ $+1
	ld hl,0		;10
	pop de		;10
	add hl,de	;11
	ld (cnt5),hl	;16
			;-47
	
	rra		;4
	out (c),a	;12
	nop	
	rrca		;4
	out (c),a	;12
	
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (#84),a	;11
	rrca		;4
	out (#84),a	;11
	rrca		;4
	out (#84),a	;11
	rrca		;4
	dec b
			;184
	
;***************************************************frame6

cnt6 equ $+1
	ld hl,0		;10
	pop de		;10
	add hl,de	;11
	ld (cnt6),hl	;16
			;-47
	
	rra		;4
	out (c),a	;12
	nop	
	rrca		;4
	out (c),a	;12
	
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (#84),a	;11
	rrca		;4
	out (#84),a	;11
	rrca		;4
	out (#84),a	;11
	rrca		;4
	dec b
			;184
	
;***************************************************frame7

cnt7 equ $+1
	ld hl,0		;10
	pop de		;10
	add hl,de	;11
	ld (cnt7),hl	;16
			;-47
	
	rra		;4
	out (c),a	;12
	nop	
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (#84),a	;11
	rrca		;4
	out (#84),a	;11
	rrca		;4
	out (#84),a	;11
	rrca		;4
	dec b
			;184
	
;***************************************************frame8
	exx		;4
	ld sp,hl	;6
	add ix,de	;15
	nop		;4
	exx		;4
			;33

	rra		;4
	out (c),a	;12
	nop		;4
	rrca		;4
	out (c),a	;12
	nop		;4
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (c),a	;12
	rrca		;4
	out (#84),a	;11
	rrca		;4
	out (#84),a	;11
	rrca		;4
	out (#84),a	;11
	rrca		;4
			;129
			;170
	dec b		;4	
	jp nz,play	;10
			;184
	exx
	dec b
	exx
	jp nz,play

	ld hl,14
	add hl,sp
	ld sp,hl
	jp rdptn
;******************************************************************
exit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret
;******************************************************************

drums
	jp pe,drum2
	jp m,drum3

drum1					;k(l)ick
	ex af,af'
	xor a		;1
	ld b,a		;1
	ld c,a		;1
	
drum1a
	out (#84),a	;2	
	djnz drum1a	;2
	ld b,#60	;2		;b = length, ~ #2-#20 but if bit 4 not set then must use
	xor #10		;1		;xor #10/#18		;2
_xx			
	inc c		;1		;dec c is also possible for different sound
	jr z,dx		;1
	djnz _xx	;2					
	ld b,c		;1
	jr drum1a	;2	
	
	
	
drum2					;noise, self-contained, customizable ***
	ld de,#3310	;3		;d = frequency
	ex af,af'
	xor a		;1
	ld bc,#b0	;3		;bc = length
	
drum2a
	out (#84),a	;2	;11
	add hl,de	;1	;11
	jr nc,_yy	;2	;12/7
	xor e		;1	;4
_yy
	rlc h		;2	;8
	cpi		;2	;16
	jp pe,drum2a


dx
	ex af,af'
	jp drumret

drum3
	ld de,#5510
	jr drum2+3


musicdata
;	include "music.asm"

;sequence
loop
	dw ptn0
	dw ptn0
	dw ptn1
	dw ptn1
	dw ptn2
	dw ptn2
	dw ptn3
	dw ptn3
	dw ptn4
	dw ptn4
	dw ptn3
	dw ptn3
	dw 0

;pattern data
ptn0
	dw #401,#0,#1429,#1429,#0,#0,#0,#0,#0
	dw #400,#0,#1429,#17f9,#0,#0,#0,#0,#0
	dw #400,#0,#1e34,#1e34,#0,#0,#0,#0,#0
	dw #400,#0,#1e34,#1429,#0,#0,#0,#0,#0
	dw #481,#0,#16a1,#16a1,#0,#0,#0,#0,#0
	dw #400,#0,#16a1,#1e34,#0,#0,#0,#0,#0
	dw #400,#0,#17f9,#17f9,#0,#0,#0,#0,#0
	dw #400,#0,#17f9,#16a1,#0,#0,#0,#0,#0
	dw #405,#0,#1429,#1429,#0,#0,#0,#0,#0
	dw #400,#0,#1429,#17f9,#0,#0,#0,#0,#0
	dw #400,#0,#1e34,#1e34,#0,#0,#0,#0,#0
	dw #400,#0,#1e34,#1429,#0,#0,#0,#0,#0
	dw #481,#0,#16a1,#16a1,#0,#0,#0,#0,#0
	dw #400,#0,#16a1,#1e34,#0,#0,#0,#0,#0
	dw #400,#0,#17f9,#17f9,#0,#0,#0,#0,#0
	dw #400,#0,#17f9,#16a1,#0,#0,#0,#0,#0
	dw #401,#0,#1429,#1429,#0,#0,#0,#0,#0
	dw #400,#0,#1429,#17f9,#0,#0,#0,#0,#0
	dw #400,#0,#1e34,#1e34,#0,#0,#0,#0,#0
	dw #400,#0,#1e34,#1429,#0,#0,#0,#0,#0
	dw #481,#0,#16a1,#16a1,#0,#0,#0,#0,#0
	dw #400,#0,#16a1,#1e34,#0,#0,#0,#0,#0
	dw #400,#0,#17f9,#17f9,#0,#0,#0,#0,#0
	dw #400,#0,#17f9,#16a1,#0,#0,#0,#0,#0
	dw #405,#0,#1429,#1429,#0,#0,#0,#0,#0
	dw #400,#0,#1429,#17f9,#0,#0,#0,#0,#0
	dw #400,#0,#1e34,#1e34,#0,#0,#0,#0,#0
	dw #400,#0,#1e34,#1429,#0,#0,#0,#0,#0
	dw #481,#0,#16a1,#16a1,#0,#0,#0,#0,#0
	dw #400,#0,#16a1,#1e34,#0,#0,#0,#0,#0
	dw #481,#0,#17f9,#17f9,#0,#0,#0,#0,#0
	dw #400,#0,#17f9,#16a1,#0,#0,#0,#0,#0
	db #40

ptn1
	dw #401,#0,#1429,#1429,#a14,#50a,#0,#0,#0
	dw #400,#0,#1429,#17f9,#a14,#50a,#0,#0,#0
	dw #400,#0,#1e34,#1e34,#a14,#50a,#0,#0,#0
	dw #400,#0,#1e34,#1429,#a14,#50a,#0,#0,#0
	dw #481,#0,#16a1,#16a1,#a14,#50a,#0,#0,#0
	dw #400,#0,#16a1,#1e34,#a14,#50a,#0,#0,#0
	dw #400,#0,#17f9,#17f9,#a14,#50a,#0,#0,#0
	dw #400,#0,#17f9,#16a1,#a14,#50a,#0,#0,#0
	dw #405,#0,#1429,#1429,#a14,#50a,#0,#0,#0
	dw #400,#0,#1429,#17f9,#a14,#50a,#0,#0,#0
	dw #400,#0,#1e34,#1e34,#a14,#50a,#0,#0,#0
	dw #400,#0,#1e34,#1429,#a14,#50a,#0,#0,#0
	dw #481,#0,#16a1,#16a1,#a14,#50a,#0,#0,#0
	dw #400,#0,#16a1,#1e34,#a14,#50a,#0,#0,#0
	dw #400,#0,#17f9,#17f9,#a14,#50a,#0,#0,#0
	dw #400,#0,#17f9,#16a1,#a14,#50a,#0,#0,#0
	dw #401,#0,#1429,#1429,#a14,#50a,#0,#0,#0
	dw #400,#0,#1429,#17f9,#a14,#50a,#0,#0,#0
	dw #400,#0,#1e34,#1e34,#a14,#50a,#0,#0,#0
	dw #400,#0,#1e34,#1429,#a14,#50a,#0,#0,#0
	dw #481,#0,#16a1,#16a1,#a14,#50a,#0,#0,#0
	dw #400,#0,#16a1,#1e34,#a14,#50a,#0,#0,#0
	dw #400,#0,#17f9,#17f9,#a14,#50a,#0,#0,#0
	dw #400,#0,#17f9,#16a1,#a14,#50a,#0,#0,#0
	dw #405,#0,#1429,#1429,#a14,#50a,#0,#0,#0
	dw #400,#0,#1429,#17f9,#a14,#50a,#0,#0,#0
	dw #400,#0,#1e34,#1e34,#a14,#50a,#0,#0,#0
	dw #400,#0,#1e34,#1429,#a14,#50a,#0,#0,#0
	dw #481,#0,#16a1,#16a1,#a14,#50a,#0,#0,#0
	dw #400,#0,#16a1,#1e34,#a14,#50a,#0,#0,#0
	dw #481,#0,#17f9,#17f9,#a14,#50a,#0,#0,#0
	dw #400,#0,#17f9,#16a1,#a14,#50a,#0,#0,#0
	db #40

ptn2
	dw #201,#47d6,#1429,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#1429,#a14,#50a,#0,#0,#0
	dw #200,#47d6,#1429,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#17f9,#a14,#50a,#0,#0,#0
	dw #200,#47d6,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#47d6,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#47d6,#1e34,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1e34,#1429,#a14,#50a,#0,#0,#0
	dw #281,#47d6,#16a1,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#16a1,#a14,#50a,#0,#0,#0
	dw #200,#47d6,#16a1,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#1e34,#a14,#50a,#0,#0,#0
	dw #200,#47d6,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#47d6,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#47d6,#17f9,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#17f9,#16a1,#a14,#50a,#0,#0,#0
	dw #205,#47d6,#1429,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#1429,#a14,#50a,#0,#0,#0
	dw #200,#47d6,#1429,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#17f9,#a14,#50a,#0,#0,#0
	dw #200,#47d6,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#47d6,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#47d6,#1e34,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1e34,#1429,#a14,#50a,#0,#0,#0
	dw #281,#47d6,#16a1,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#16a1,#a14,#50a,#0,#0,#0
	dw #200,#47d6,#16a1,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#1e34,#a14,#50a,#0,#0,#0
	dw #200,#47d6,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#47d6,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#47d6,#17f9,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#17f9,#16a1,#a14,#50a,#0,#0,#0
	dw #201,#47d6,#1429,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#1429,#a14,#50a,#0,#0,#0
	dw #200,#47d6,#1429,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#17f9,#a14,#50a,#0,#0,#0
	dw #200,#47d6,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#47d6,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#47d6,#1e34,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1e34,#1429,#a14,#50a,#0,#0,#0
	dw #281,#47d6,#16a1,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#16a1,#a14,#50a,#0,#0,#0
	dw #200,#47d6,#16a1,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#1e34,#a14,#50a,#0,#0,#0
	dw #200,#47d6,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#47d6,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#47d6,#17f9,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#17f9,#16a1,#a14,#50a,#0,#0,#0
	dw #205,#47d6,#1429,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#1429,#a14,#50a,#0,#0,#0
	dw #200,#47d6,#1429,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#17f9,#a14,#50a,#0,#0,#0
	dw #200,#47d6,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#47d6,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#47d6,#1e34,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1e34,#1429,#a14,#50a,#0,#0,#0
	dw #281,#47d6,#16a1,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#16a1,#a14,#50a,#0,#0,#0
	dw #200,#47d6,#16a1,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#1e34,#a14,#50a,#0,#0,#0
	dw #281,#47d6,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#47d6,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#47d6,#17f9,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#17f9,#16a1,#a14,#50a,#0,#0,#0
	db #40

ptn3
	dw #201,#43ce,#1429,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#1429,#a14,#50a,#0,#0,#0
	dw #200,#43ce,#1429,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#17f9,#a14,#50a,#0,#0,#0
	dw #200,#43ce,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#43ce,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#43ce,#1e34,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1e34,#1429,#a14,#50a,#0,#0,#0
	dw #281,#43ce,#16a1,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#16a1,#a14,#50a,#0,#0,#0
	dw #200,#43ce,#16a1,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#1e34,#a14,#50a,#0,#0,#0
	dw #200,#43ce,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#43ce,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#43ce,#17f9,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#17f9,#16a1,#a14,#50a,#0,#0,#0
	dw #205,#43ce,#1429,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#1429,#a14,#50a,#0,#0,#0
	dw #200,#43ce,#1429,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#17f9,#a14,#50a,#0,#0,#0
	dw #200,#43ce,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#43ce,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#43ce,#1e34,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1e34,#1429,#a14,#50a,#0,#0,#0
	dw #281,#43ce,#16a1,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#16a1,#a14,#50a,#0,#0,#0
	dw #200,#43ce,#16a1,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#1e34,#a14,#50a,#0,#0,#0
	dw #200,#43ce,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#43ce,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#43ce,#17f9,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#17f9,#16a1,#a14,#50a,#0,#0,#0
	dw #201,#43ce,#1429,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#1429,#a14,#50a,#0,#0,#0
	dw #200,#43ce,#1429,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#17f9,#a14,#50a,#0,#0,#0
	dw #200,#43ce,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#43ce,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#43ce,#1e34,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1e34,#1429,#a14,#50a,#0,#0,#0
	dw #281,#43ce,#16a1,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#16a1,#a14,#50a,#0,#0,#0
	dw #200,#43ce,#16a1,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#1e34,#a14,#50a,#0,#0,#0
	dw #200,#43ce,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#43ce,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#43ce,#17f9,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#17f9,#16a1,#a14,#50a,#0,#0,#0
	dw #205,#43ce,#1429,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#1429,#a14,#50a,#0,#0,#0
	dw #200,#43ce,#1429,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#17f9,#a14,#50a,#0,#0,#0
	dw #200,#43ce,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#43ce,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#43ce,#1e34,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1e34,#1429,#a14,#50a,#0,#0,#0
	dw #281,#43ce,#16a1,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#16a1,#a14,#50a,#0,#0,#0
	dw #200,#43ce,#16a1,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#1e34,#a14,#50a,#0,#0,#0
	dw #281,#43ce,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#43ce,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#43ce,#17f9,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#17f9,#16a1,#a14,#50a,#0,#0,#0
	db #40

ptn4
	dw #201,#1e34,#1429,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#1429,#a14,#50a,#0,#0,#0
	dw #200,#1e34,#1429,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#17f9,#a14,#50a,#0,#0,#0
	dw #200,#1e34,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#1e34,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#1e34,#1e34,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1e34,#1429,#a14,#50a,#0,#0,#0
	dw #281,#1e34,#16a1,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#16a1,#a14,#50a,#0,#0,#0
	dw #200,#1e34,#16a1,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#1e34,#a14,#50a,#0,#0,#0
	dw #200,#1e34,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#1e34,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#1e34,#17f9,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#17f9,#16a1,#a14,#50a,#0,#0,#0
	dw #205,#1e34,#1429,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#1429,#a14,#50a,#0,#0,#0
	dw #200,#1e34,#1429,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#17f9,#a14,#50a,#0,#0,#0
	dw #200,#1e34,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#1e34,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#1e34,#1e34,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1e34,#1429,#a14,#50a,#0,#0,#0
	dw #281,#1e34,#16a1,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#16a1,#a14,#50a,#0,#0,#0
	dw #200,#1e34,#16a1,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#1e34,#a14,#50a,#0,#0,#0
	dw #200,#1e34,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#1e34,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#1e34,#17f9,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#17f9,#16a1,#a14,#50a,#0,#0,#0
	dw #201,#1e34,#1429,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#1429,#a14,#50a,#0,#0,#0
	dw #200,#1e34,#1429,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#17f9,#a14,#50a,#0,#0,#0
	dw #200,#1e34,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#1e34,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#1e34,#1e34,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1e34,#1429,#a14,#50a,#0,#0,#0
	dw #281,#1e34,#16a1,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#16a1,#a14,#50a,#0,#0,#0
	dw #200,#1e34,#16a1,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#1e34,#a14,#50a,#0,#0,#0
	dw #200,#1e34,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#1e34,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#1e34,#17f9,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#17f9,#16a1,#a14,#50a,#0,#0,#0
	dw #205,#1e34,#1429,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#1429,#a14,#50a,#0,#0,#0
	dw #200,#1e34,#1429,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1429,#17f9,#a14,#50a,#0,#0,#0
	dw #200,#1e34,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#1e34,#1e34,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#1e34,#1e34,#1429,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#1e34,#1429,#a14,#50a,#0,#0,#0
	dw #281,#1e34,#16a1,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#16a1,#a14,#50a,#0,#0,#0
	dw #200,#1e34,#16a1,#1e34,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#16a1,#1e34,#a14,#50a,#0,#0,#0
	dw #281,#1e34,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#1e34,#17f9,#17f9,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#1e34,#17f9,#16a1,#a14,#50a,#0,#2ff2,#3c68
	dw #200,#0,#17f9,#16a1,#a14,#50a,#0,#0,#0
	db #40





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
	savebin "octode2k15.tap",tap_b,tap_e-tap_b




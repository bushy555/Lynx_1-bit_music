 device zxspectrum128

	org $6500-13				; Origin
tap_b:	db $22,"NONAME",$22			;name		  	
	db "M"					;type		  	
	dw end-begin				;program length	  	
	dw begin				;load point		
	org $6500
begin:


;******************************************************************
;* octode 2k16                                                    *
;* 8ch beeper engine by utz 05'2016                               *
;* www.irrlichtproject.de                                         *
;******************************************************************

;SP set to start of current buffer/ptn row
;(addBuffer) - add cntr 1-3
;DE  - add cntr 4
;HL  - accu 1-3, jump val
;HL' - add cntr 5
;DE' - add cntr 6
;BC/BC' - base counters
;IX - add cntr 7
;IY - add cntr 8
;A  - vol.add
;A',I - timer

NMOS EQU 1
CMOS EQU 2

OUTHI equ #41ed
OUTLO equ #71ed

PCTRL equ #1084			;values for NMOS Z80
PCTRL_B equ #84

;IF Z80=CMOS			;values for CMOS Z80
;PCTRL equ #0084
;PCTRL_B equ #00
;ENDIF






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
	exx
	ld (oldSP),sp
	ld hl,musicData
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
updateTimer0
	nop
	dw OUTLO
updateTimer
	ld a,i			;9
	dec a			;4
	jp z,readNextRow	;10
	ld i,a			;9
	xor a			;4
	ex af,af'		;4
	jp (hl)			;4
				;44 TODO: adjust timings!
				
updateTimerX
	ld a,i			;9
	dec a			;4
	jp z,readNextRow	;10
	ld i,a			;9
	xor a			;4
	ex af,af'		;4
	ld a,(hl)		;7	;timing
	dw OUTLO		;12
	xor a			;4
	nop			;4
	jp (hl)			;4
				
addBuffer
	ds 6

;******************************************************************
exit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret
;******************************************************************

rdptn0
	ld (patpntr),hl
readNextRow
;	in a,(#1f)		;read joystick
;maskKempston equ $+1
;	and #1f
;	ld c,a
;	in a,(#fe)		;read kbd
;	cpl
;	or c
;	and #1f
;	jp nz,exit

	ld de,0			;clear add counters 1-4
	ld sp,addBuffer+6
	push de
	push de
	push de

patpntr equ $+1			;fetch pointer to pattern data
	ld sp,0

	pop af
	jr z,rdseq
	
	ld i,a			;timer
	
	jr c,drumNoise
	jp pe,drumKick
	jp m,drumSnare
drumRet
		
	pop hl			;fetch row buffer addr
	
	ld (patpntr),sp
	
	ld sp,hl		;row buffer addr -> SP
	
	xor a			;timer lo
	exx
	ld h,a			;clear add counters 5-8
	ld l,a
	ld d,a
	ld e,a
	ld ix,0
	ld iy,0
	exx
	
	ex af,af'
	xor a
	ld bc,PCTRL
	jp core0


drumNoise	
	ld hl,#35d1	;10
drumX
	ex de,hl	;4		;DE = 0, so now HL = 0
	pop bc		;10		;duty in C, B = 0
	
_dlp	
	add hl,de	;11
	ld a,h		;4
	cp c		;4
	sbc a,a		;4
	and #10		;7
	out (#84),a	;11
	rlc h		;8
	djnz _dlp	;13/8 - 62*256 = 15872
	
	ld d,b		;4	;reset DE
	ld e,b		;4
	ld a,#d6	;7	;adjust row length
	ex af,af'	;4
	jp drumRet	;10
			;15933/15943 ~ 41,5 sound loop iterations

drumKick
	ld hl,1
	jr drumX

drumSnare
	ld hl,5
	jr drumX

;*********************************************************************************************
	align 256

core0						;volume 0, 0t
basec equ HIGH($)

	dw OUTLO		;12__		;switch sound on

	ld hl,(addBuffer)	;16		;get ch1 accu
	pop bc			;10		;get ch1 base freq
	add hl,bc		;11		;add them up
	ld (addBuffer),hl	;16		;store ch1 accu
	rl h			;8		;rotate bit 7 into volume accu
	rla			;4
	
	ld hl,(addBuffer+2)	;16		;as above, for ch2
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+2),hl	;16
	rl h			;8
	adc a,0			;7
	
	ld hl,(addBuffer+4)	;16		;as above for ch3
	
	ld c,#84		;7
	ds 3			;12
	
	ret c			;5		;timing, branch never taken
	ld b,PCTRL_B		;7		;B = #10
	;------------------	;--192
	
	dw OUTLO		;12__		;sound on
	
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+4),hl	;16
	rl h			;8
	adc a,0			;7

	ex de,hl		;4		;DE is ch4 accu
	pop bc			;10		;add base freq as usual
	add hl,bc		;11
	ex de,hl		;4
	ld b,d			;4		;get bit 7 of ch4 accu without modifying the accu itself
	rl b			;8
	adc a,0			;7
	
	exx			;4

	pop bc			;10		;get base freq ch5
	add hl,bc		;11		;HL' is ch5 accu
	ld b,h			;4
	rl b			;8
		
	ld r,a			;9		;timing
	ld bc,PCTRL		;10
	dw OUTLO		;12__168

	adc a,0			;7
	ret c			;5		;timing
	;-----------------	;--192
	
	dw OUTLO		;12__
	
	ex de,hl		;4		;DE' is accu ch6
	pop bc			;10
	add hl,bc		;11
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	ex de,hl		;4
	
	pop bc			;10
	add ix,bc		;15		;IX is accu ch7
	ld b,ixh		;8
	rl b			;8
	adc a,0			;7
	ret c			;5		;timing
	
	pop bc			;10	
	add iy,bc		;15		;IY is accu ch8	
	ld b,iyh		;8
	rl b			;8
	
	exx			;4
	ld bc,PCTRL		;10
	dw OUTLO		;12__168
	
	ex af,af'		;4
	dec a			;4
	ex af,af'		;4
	;-----------------	;--192
	
	dw OUTLO		;12__
	
	adc a,0			;7

	ld hl,-16		;10		;point SP to beginning of pattern row again
	add hl,sp		;11
	ld sp,hl		;6
	add a,basec		;7		;calculate which core to use for next frame
	ld h,a			;4		;and put the value in HL
	xor a			;4		;also reset volume accu
	ld l,a			;4
	
	ex (sp),hl		;19		;timing
	ex (sp),hl		;19		;timing
	
	ex af,af'		;4		;check if timer has expired
	dec a			;4
	jp z,updateTimer	;10		;and update if necessary
	ret z			;5		;timing
	ex af,af'		;4
	
	ex (sp),hl		;19		;timing
	ex (sp),hl		;19		;timing

	dw OUTLO		;12__168
		
	ds 2			;8		;timing
	jp (hl)			;4		;jump to next frame
	;-----------------	;--192


;*********************************************************************************************
	org 256*(1+(HIGH($)))
core1						;vol 1 - 24t

	dw OUTHI		;12__		;switch sound on
	ex af,af'		;4		;update timer
	dec a			;4
	ex af,af'		;4
	dw OUTLO		;12__24		;switch sound off

	ld hl,(addBuffer)	;16		;get ch1 accu
	pop bc			;10		;get ch1 base freq
	add hl,bc		;11		;add them up
	ld (addBuffer),hl	;16		;store ch1 accu
	rl h			;8		;rotate bit 7 into volume accu
	rla			;4
	
	ld hl,(addBuffer+2)	;16		;as above, for ch2
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+2),hl	;16
	rl h			;8
	adc a,0			;7
	
	ret c			;5		;timing, branch never taken
	ds 2			;8
	
	ld bc,PCTRL		;10		;BC = #10fe
	;------------------	;--192
	
	dw OUTHI		;12__		;sound on
	ex af,af'		;4		;update timer again (for better speed control)
	dec a			;4
	ex af,af'		;4
	dw OUTLO		;12__24
	
	ld hl,(addBuffer+4)	;16		;as above for ch3
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+4),hl	;16
	rl h			;8
	adc a,0			;7

	ex de,hl		;4		;DE is ch4 accu
	pop bc			;10		;add base freq as usual
	add hl,bc		;11
	ex de,hl		;4
	ld b,d			;4		;get bit 7 of ch4 accu without modifying the accu itself
	rl b			;8
	adc a,0			;7
	
	ret c			;5		;timing, branch never taken
	
	exx			;4
	pop bc			;10		;get base freq ch5
	add hl,bc		;11		;HL' is ch5 accu
	
	ld bc,PCTRL		;10
	;-----------------	;--192
	
	dw OUTHI		;12__
	ld b,h			;4
	rl b			;8
	dw OUTLO		;12__24
	
	adc a,0			;7
	
	ex de,hl		;4		;DE' is accu ch6
	pop bc			;10
	add hl,bc		;11
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	
	ex de,hl		;4
	pop bc			;10
	add ix,bc		;15		;IX is accu ch7
	ld b,ixh		;8
	rl b			;8
	adc a,0			;7
	
	pop bc			;10
	add iy,bc		;15		;IY is accu ch8
	
	exx			;4
	ld bc,PCTRL		;10
	ld bc,PCTRL		;10		;timing
	nop			;4
	;-----------------	;--192
	
	dw OUTHI		;12__
	ds 3			;12
	dw OUTLO		;12__24
	
	exx			;4
	ld b,iyh		;8
	rl b			;8
	adc a,0			;7
	
	exx			;4
	ld hl,-16		;10		;point SP to beginning of pattern row again
	add hl,sp		;11
	ld sp,hl		;6
	
	add a,basec		;7		;calculate which core to use for next frame
	ld h,a			;4		;and put the value in HL
	
	ld a,(hl)		;7		;timing
	ld a,(hl)		;7		;timing
	ld a,(hl)		;7		;timing
	nop			;4		;timing
	
	xor a			;4		;also reset volume accu
	ld l,a			;4
	
	ex af,af'		;4		;check if timer has expired
	jp z,updateTimer	;10		;and update if necessary
	ex af,af'		;4
	
	ds 8			;32		;timing (to match updateTimer length)
	
	jp (hl)			;4		;jump to next frame
	;-----------------	;--192
	
	
;*********************************************************************************************
	org 256*(1+(HIGH($)))
core2						;vol 2 - 48t

	dw OUTHI		;12__		;switch sound on
	ex af,af'		;4		;update timer
	dec a			;4
	ex af,af'		;4
	ld hl,(addBuffer)	;16		;get ch1 accu
	ds 2			;8		;timing
	dw OUTLO		;12__48		;switch sound off

	pop bc			;10		;get ch1 base freq
	add hl,bc		;11		;add them up
	ld (addBuffer),hl	;16		;store ch1 accu
	rl h			;8		;rotate bit 7 into volume accu
	rla			;4
	
	ld hl,(addBuffer+2)	;16		;as above, for ch2
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+2),hl	;16
	rl h			;8
	adc a,0			;7
	
	ret c			;5		;timing, branch never taken
	
	ld bc,PCTRL		;10		;BC = #10fe
	;------------------	;--192
	
	dw OUTHI		;12__		;sound on
	ex af,af'		;4		;update timer again (for better speed control)
	dec a			;4
	ex af,af'		;4
	ld hl,(addBuffer+4)	;16		;as above for ch3
	ds 2			;8
	dw OUTLO		;12__48
	
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+4),hl	;16
	rl h			;8
	adc a,0			;7

	ex de,hl		;4		;DE is ch4 accu
	pop bc			;10		;add base freq as usual
	add hl,bc		;11
	ex de,hl		;4
	ld b,d			;4		;get bit 7 of ch4 accu without modifying the accu itself
	rl b			;8
	adc a,0			;7
	
	nop			;4		;timing	
	exx			;4
	pop bc			;10		;get base freq ch5
	exx			;4
	
	ld bc,PCTRL		;10
	;-----------------	;--192
	
	dw OUTHI		;12__
	exx			;4
	add hl,bc		;11		;HL' is ch5 accu
	ld b,h			;4
	ld r,a			;9		;timing
	nop			;4
	exx			;4
	dw OUTLO		;12__48
	
	exx			;4
	rl b			;8
	adc a,0			;7
	
	ex de,hl		;4		;DE' is accu ch6
	pop bc			;10
	add hl,bc		;11
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	
	ex de,hl		;4
	pop bc			;10
	add ix,bc		;15		;IX is accu ch7
	ld b,ixh		;8
	rl b			;8
	
	exx			;4
	ld bc,PCTRL		;10
	ld bc,PCTRL		;10		;timing
	;-----------------	;--192
	
	dw OUTHI		;12__
	exx			;4
	
	adc a,0			;7
	ld b,(hl)		;7		;timing
	nop			;4
	pop bc			;10
	
	exx			;4
	dw OUTLO		;12__48
	exx			;4
		
	add iy,bc		;15		;IY is accu ch8
	ld b,iyh		;8
	rl b			;8
	adc a,0			;7
	
	exx			;4
	ld hl,-16		;10		;point SP to beginning of pattern row again
	add hl,sp		;11
	ld sp,hl		;6
	
	add a,basec		;7		;calculate which core to use for next frame
	ld h,a			;4		;and put the value in HL
	
	xor a			;4		;also reset volume accu
	ld l,a			;4
	
	ex af,af'		;4		;check if timer has expired
	jp z,updateTimer	;10		;and update if necessary
	ex af,af'		;4
	
	ld a,(hl)		;7		;timing
	ld a,(hl)		;7		;timing
	xor a			;4
	
	jp (hl)			;4		;jump to next frame
	;-----------------	;--192
	
	
;*********************************************************************************************
	org 256*(1+(HIGH($)))
core3						;vol 3 - 72t

	dw OUTHI		;12__		;switch sound on

	ld hl,(addBuffer)	;16		;get ch1 accu
	pop bc			;10		;get ch1 base freq
	add hl,bc		;11		;add them up
	ld (addBuffer),hl	;16		;store ch1 accu
	ld c,#84		;7

	dw OUTLO		;12__72		;switch sound off

	rl h			;8		;rotate bit 7 into volume accu
	rla			;4
	
	ld hl,(addBuffer+2)	;16		;as above, for ch2
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+2),hl	;16
	rl h			;8
	adc a,0			;7
	
	ex af,af'		;4		;update timer
	dec a			;4
	ex af,af'		;4
	inc bc			;6		;timing 
	
	ld bc,PCTRL		;10		;BC = #10fe
	;------------------	;--192
	
	dw OUTHI		;12__		;sound on

	ld hl,(addBuffer+4)	;16		;as above for ch3
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+4),hl	;16
	
	ld c,#84		;7
	dw OUTLO		;12__72
	
	rl h			;8
	adc a,0			;7

	ex de,hl		;4		;DE is ch4 accu
	pop bc			;10		;add base freq as usual
	add hl,bc		;11
	ex de,hl		;4
	ld b,d			;4		;get bit 7 of ch4 accu without modifying the accu itself
	rl b			;8
	adc a,0			;7
	
	exx			;4
	pop bc			;10		;get base freq ch5
	add hl,bc		;11		;HL' is ch5 accu
	exx			;4
	
	inc bc			;6		;timing
	ld bc,PCTRL		;10
	;-----------------	;--192
	
	dw OUTHI		;12__
	exx			;4
	
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	ex de,hl		;4		;DE' is accu ch6
	pop bc			;10
	add hl,bc		;11
	ld b,h			;4
	nop			;4
	
	exx			;4
	dw OUTLO		;12__72
	exx			;4
	
	rl b			;8
	adc a,0			;7
	
	ex de,hl		;4
	pop bc			;10
	add ix,bc		;15		;IX is accu ch7
	ld b,ixh		;8
	rl b			;8
	adc a,0			;7
	
	pop bc			;10
	
	exx			;4
	ld b,(hl)		;7		;timing
	inc bc			;6		;timing
	ld bc,PCTRL		;10
	;-----------------	;--192
	
	dw OUTHI		;12__
	exx			;4
	
	add iy,bc		;15		;IY is accu ch8
	ld b,iyh		;8
	rl b			;8
	adc a,0			;7
	
	nop			;4
	
	exx			;4
	ld hl,-16		;10		;point SP to beginning of pattern row again
	dw OUTLO		;12__72

	add hl,sp		;11
	ld sp,hl		;6
	
	add a,basec		;7		;calculate which core to use for next frame
	ld h,a			;4		;and put the value in HL
	
	ld a,(hl)		;7		;timing
	ld a,(hl)		;7		;timing
	
	xor a			;4		;also reset volume accu
	ld l,a			;4
	
	ex af,af'		;4		;check if timer has expired
	dec a			;4
	jp z,updateTimer	;10		;and update if necessary
	ex af,af'		;4
	
	ds 8			;32		;timing (to match updateTimer length)
	
	jp (hl)			;4		;jump to next frame
	;-----------------	;--192
	
	
;*********************************************************************************************
	org 256*(1+(HIGH($)))
core4						;vol 4 - 96t

	dw OUTHI		;12__		;switch sound on

	ld hl,(addBuffer)	;16		;get ch1 accu
	pop bc			;10		;get ch1 base freq
	add hl,bc		;11		;add them up
	ld (addBuffer),hl	;16		;store ch1 accu

	rl h			;8		;rotate bit 7 into volume accu
	ld hl,(addBuffer+2)	;16		;as above, for ch2

	ld c,#84		;7
	dw OUTLO		;12__96		;switch sound off

	rla			;4
		
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+2),hl	;16
	rl h			;8
	adc a,0			;7
	
	ex af,af'		;4		;update timer
	dec a			;4
	ex af,af'		;4
	inc bc			;6		;timing 
	
	ld bc,PCTRL		;10		;BC = #10fe
	;------------------	;--192
	
	dw OUTHI		;12__		;sound on

	ld hl,(addBuffer+4)	;16		;as above for ch3
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+4),hl	;16
	rl h			;8
	adc a,0			;7
	ret c			;5		;timing

	ex de,hl		;4		;DE is ch4 accu
	
	ld c,#84		;7
	dw OUTLO		;12__96
		
	pop bc			;10		;add base freq as usual
	add hl,bc		;11
	ex de,hl		;4
	ld b,d			;4		;get bit 7 of ch4 accu without modifying the accu itself
	rl b			;8
	adc a,0			;7
	
	exx			;4
	pop bc			;10		;get base freq ch5
	
	exx			;4	
	inc bc			;6		;timing
	inc bc			;6		;timing
	ld bc,PCTRL		;10
	;-----------------	;--192
	
	dw OUTHI		;12__
	exx			;4
	
	add hl,bc		;11		;HL' is ch5 accu
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	ex de,hl		;4		;DE' is accu ch6
	pop bc			;10
	add hl,bc		;11
	ld b,h			;4
	rl b			;8
	ld r,a			;9
	
	exx			;4
	dw OUTLO		;12__96
	exx			;4
	
	adc a,0			;7
	
	ex de,hl		;4
	pop bc			;10
	add ix,bc		;15		;IX is accu ch7
	ld b,ixh		;8
	rl b			;8
	nop			;4
	
	pop bc			;10
	
	exx			;4
	ld bc,PCTRL		;10
	;-----------------	;--192
	
	dw OUTHI		;12__
	exx			;4
	
	adc a,0			;7
	
	add iy,bc		;15		;IY is accu ch8
	ld b,iyh		;8
	rl b			;8
	adc a,0			;7

	exx			;4
	ld hl,-16		;10		;point SP to beginning of pattern row again
	add hl,sp		;11
	ld sp,hl		;6
	nop			;4
	
	dw OUTLO		;12__96

	add a,basec		;7		;calculate which core to use for next frame
	ld h,a			;4		;and put the value in HL
	
	ld a,(hl)		;7		;timing
	
	xor a			;4		;also reset volume accu
	ld l,a			;4
	
	ex af,af'		;4		;check if timer has expired
	dec a			;4
	jp z,updateTimer	;10		;and update if necessary
	ex af,af'		;4
	
	ds 8			;32		;timing (to match updateTimer length)
	
	jp (hl)			;4		;jump to next frame
	;-----------------	;--192
	
;*********************************************************************************************
	org 256*(1+(HIGH($)))
core5						;vol 5 - 120t

	dw OUTHI		;12__		;switch sound on

	ld hl,(addBuffer)	;16		;get ch1 accu
	pop bc			;10		;get ch1 base freq
	add hl,bc		;11		;add them up
	ld (addBuffer),hl	;16		;store ch1 accu
	rl h			;8		;rotate bit 7 into volume accu
	rla			;4
	
	ld hl,(addBuffer+2)	;16		;as above, for ch2

	ds 5			;20

	ld c,#84		;7
	dw OUTLO		;12__120	;switch sound off

	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+2),hl	;16
	
	ld r,a			;9		;timing
	nop			;4
	
	ld bc,PCTRL		;10		;BC = #10fe
	;------------------	;--192
	
	dw OUTHI		;12__		;sound on

	rl h			;8
	adc a,0			;7
	
	ld hl,(addBuffer+4)	;16		;as above for ch3
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+4),hl	;16
	rl h			;8
	adc a,0			;7

	ex de,hl		;4		;DE is ch4 accu
	
	ld b,(hl)		;7		;timing
	ld b,(hl)		;7		;timing
	ld c,#84		;7
	dw OUTLO		;12__120
		
	pop bc			;10		;add base freq as usual
	add hl,bc		;11
	ex de,hl		;4
	ld b,d			;4		;get bit 7 of ch4 accu without modifying the accu itself
	rl b			;8
	adc a,0			;7
	
	inc bc			;6		;timing
	ld bc,PCTRL		;10
	;-----------------	;--192
	
	dw OUTHI		;12__
	exx			;4
		
	pop bc			;10		;get base freq ch5
	add hl,bc		;11		;HL' is ch5 accu
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	ex de,hl		;4		;DE' is accu ch6
	pop bc			;10
	add hl,bc		;11
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	
	inc bc			;6		;timing
	pop bc			;10
	exx			;4
	dw OUTLO		;12__120
	exx			;4
	
	ex de,hl		;4
	
	add ix,bc		;15		;IX is accu ch7
	ld b,ixh		;8
	rl b			;8
	adc a,0			;7
	
	pop bc			;10
	
	exx			;4
	;-----------------	;--192
	
	dw OUTHI		;12__
	exx			;4
		
	add iy,bc		;15		;IY is accu ch8
	ld b,iyh		;8
	rl b			;8
	adc a,0			;7
	
	exx			;4

	ld hl,-16		;10		;point SP to beginning of pattern row again
	add hl,sp		;11
	ld sp,hl		;6
	add a,basec		;7		;calculate which core to use for next frame
	ld h,a			;4		;and put the value in HL
	xor a			;4		;also reset volume accu
	ld l,a			;4
	
	ex af,af'		;4		;check if timer has expired
	dec a			;4
	dec a			;4
	nop			;4
	
	
	dw OUTLO		;12__120
	
	ld bc,PCTRL		;10		;not necessary, just for timing
		
	jp z,updateTimer	;10		;and update if necessary
	ex af,af'		;4
	
	ds 8			;32		;timing (to match updateTimer length)
	
	jp (hl)			;4		;jump to next frame
	;-----------------	;--192
		

;*********************************************************************************************
	org 256*(1+(HIGH($)))
core6						;vol 6 - 144t

	dw OUTHI		;12__		;switch sound on

	ld hl,(addBuffer)	;16		;get ch1 accu
	pop bc			;10		;get ch1 base freq
	add hl,bc		;11		;add them up
	ld (addBuffer),hl	;16		;store ch1 accu
	rl h			;8		;rotate bit 7 into volume accu
	rla			;4
	
	ld hl,(addBuffer+2)	;16		;as above, for ch2
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+2),hl	;16
	
	ld c,(hl)		;7		;timing
	ld c,#84		;7
	dw OUTLO		;12__144	;switch sound off
	
	rl h			;8
	adc a,0			;7
	
	ld b,(hl)		;7		;timing
	nop			;4		
	ld bc,PCTRL		;10		;BC = #10fe
	;------------------	;--192
	
	dw OUTHI		;12__		;sound on
	
	ld hl,(addBuffer+4)	;16		;as above for ch3
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+4),hl	;16
	rl h			;8
	adc a,0			;7

	ex de,hl		;4		;DE is ch4 accu
	pop bc			;10		;add base freq as usual
	add hl,bc		;11
	ex de,hl		;4
	ld b,d			;4		;get bit 7 of ch4 accu without modifying the accu itself
	rl b			;8
	adc a,0			;7
	
	ld r,a			;9		;timing
	ld c,#84		;7
	dw OUTLO		;12__144
		
	
	ld b,(hl)		;7		;timing	
	ld b,(hl)		;7		;timing
	ds 3			;12

	ld bc,PCTRL		;10
	;-----------------	;--192
	
	dw OUTHI		;12__
	exx			;4
		
	pop bc			;10		;get base freq ch5
	add hl,bc		;11		;HL' is ch5 accu
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	ex de,hl		;4		;DE' is accu ch6
	pop bc			;10
	add hl,bc		;11
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	ex de,hl		;4
	
	pop bc			;10
	add ix,bc		;15		;IX is accu ch7
	
	ld b,(hl)		;7		;timing
	nop			;4
	
	exx			;4
	dw OUTLO		;12__144
	exx			;4
	
	ld b,ixh		;8
	rl b			;8
	adc a,0			;7
	
	ret c			;5		;timing
	
	exx			;4
	;-----------------	;--192
	
	dw OUTHI		;12__
	exx			;4
	
	pop bc			;10	
	add iy,bc		;15		;IY is accu ch8
	ld b,iyh		;8
	rl b			;8
	adc a,0			;7

	exx			;4
	
	ld hl,-16		;10		;point SP to beginning of pattern row again
	add hl,sp		;11
	ld sp,hl		;6
	add a,basec		;7		;calculate which core to use for next frame
	ld h,a			;4		;and put the value in HL
	xor a			;4		;also reset volume accu
	ld l,a			;4
	
	ex af,af'		;4		;check if timer has expired
	dec a			;4
	dec a			;4
	nop			;4
	jp z,updateTimer0	;10		;and update if necessary
	ex af,af'		;4
	
	dw OUTLO		;12__144
		
	ds 8			;32		;timing (to match updateTimer length)
	
	jp (hl)			;4		;jump to next frame
	;-----------------	;--192


;*********************************************************************************************
	org 256*(1+(HIGH($)))
core7						;vol 7 - 168t

	dw OUTHI		;12__		;switch sound on

	ld hl,(addBuffer)	;16		;get ch1 accu
	pop bc			;10		;get ch1 base freq
	add hl,bc		;11		;add them up
	ld (addBuffer),hl	;16		;store ch1 accu
	rl h			;8		;rotate bit 7 into volume accu
	rla			;4
	
	ld hl,(addBuffer+2)	;16		;as above, for ch2
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+2),hl	;16
	rl h			;8
	adc a,0			;7
	
	ld hl,(addBuffer+4)	;16		;as above for ch3
	
	ld c,#84		;7
	dw OUTLO		;12__168	;switch sound off
	
	ret c			;5		;timing, branch never taken
	ld b,PCTRL_B		;7		;B = #10
	;------------------	;--192
	
	dw OUTHI		;12__		;sound on
	
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+4),hl	;16
	rl h			;8
	adc a,0			;7

	ex de,hl		;4		;DE is ch4 accu
	pop bc			;10		;add base freq as usual
	add hl,bc		;11
	ex de,hl		;4
	ld b,d			;4		;get bit 7 of ch4 accu without modifying the accu itself
	rl b			;8
	adc a,0			;7
	
	exx			;4

	pop bc			;10		;get base freq ch5
	add hl,bc		;11		;HL' is ch5 accu
	ld b,h			;4
	rl b			;8
		
	ld r,a			;9		;timing
	ld bc,PCTRL		;10
	dw OUTLO		;12__168

	adc a,0			;7
	ret c			;5		;timing
	;-----------------	;--192
	
	dw OUTHI		;12__
	
	ex de,hl		;4		;DE' is accu ch6
	pop bc			;10
	add hl,bc		;11
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	ex de,hl		;4
	
	pop bc			;10
	add ix,bc		;15		;IX is accu ch7
	ld b,ixh		;8
	rl b			;8
	adc a,0			;7
	ret c			;5		;timing
	
	pop bc			;10	
	add iy,bc		;15		;IY is accu ch8	
	ld b,iyh		;8
	rl b			;8
	
	exx			;4
	ld bc,PCTRL		;10
	dw OUTLO		;12__168
	
	ex af,af'		;4
	dec a			;4
	ex af,af'		;4
	;-----------------	;--192
	
	dw OUTHI		;12__
	
	adc a,0			;7

	ld hl,-16		;10		;point SP to beginning of pattern row again
	add hl,sp		;11
	ld sp,hl		;6
	add a,basec		;7		;calculate which core to use for next frame
	ld h,a			;4		;and put the value in HL
	xor a			;4		;also reset volume accu
	ld l,a			;4
	
	ex (sp),hl		;19		;timing
	ex (sp),hl		;19		;timing
	
	ex af,af'		;4		;check if timer has expired
	dec a			;4
	jp z,updateTimerX	;10		;and update if necessary
	ret z			;5		;timing
	ex af,af'		;4
	
	ex (sp),hl		;19		;timing
	ex (sp),hl		;19		;timing
				;    (47)
	dw OUTLO		;12__168
		
	ds 2			;8		;timing
	jp (hl)			;4		;jump to next frame
	;-----------------	;--192

		
;*********************************************************************************************
	org 256*(1+(HIGH($)))
core8						;vol 8 - 192t

	dw OUTHI		;12__		;switch sound on

	ld hl,(addBuffer)	;16		;get ch1 accu
	pop bc			;10		;get ch1 base freq
	add hl,bc		;11		;add them up
	ld (addBuffer),hl	;16		;store ch1 accu
	rl h			;8		;rotate bit 7 into volume accu
	rla			;4
	
	ld hl,(addBuffer+2)	;16		;as above, for ch2
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+2),hl	;16
	rl h			;8
	adc a,0			;7
	
	ld hl,(addBuffer+4)	;16		;as above for ch3
	
	ld c,#84		;7
	ds 3			;12
	
	ret c			;5		;timing, branch never taken
	ld b,PCTRL_B		;7		;B = #10
	;------------------	;--192
	
	dw OUTHI		;12__		;sound on
	
	pop bc			;10
	add hl,bc		;11
	ld (addBuffer+4),hl	;16
	rl h			;8
	adc a,0			;7

	ex de,hl		;4		;DE is ch4 accu
	pop bc			;10		;add base freq as usual
	add hl,bc		;11
	ex de,hl		;4
	ld b,d			;4		;get bit 7 of ch4 accu without modifying the accu itself
	rl b			;8
	adc a,0			;7
	
	exx			;4

	pop bc			;10		;get base freq ch5
	add hl,bc		;11		;HL' is ch5 accu
	ld b,h			;4
	rl b			;8
		
	ld r,a			;9		;timing
	ld bc,PCTRL		;10
	dw OUTHI		;12__168

	adc a,0			;7
	ret c			;5		;timing
	;-----------------	;--192
	
	dw OUTHI		;12__
	
	ex de,hl		;4		;DE' is accu ch6
	pop bc			;10
	add hl,bc		;11
	ld b,h			;4
	rl b			;8
	adc a,0			;7
	ex de,hl		;4
	
	pop bc			;10
	add ix,bc		;15		;IX is accu ch7
	ld b,ixh		;8
	rl b			;8
	adc a,0			;7
	ret c			;5		;timing
	
	pop bc			;10	
	add iy,bc		;15		;IY is accu ch8	
	ld b,iyh		;8
	rl b			;8
	
	exx			;4
	ld bc,PCTRL		;10
	dw OUTHI		;12__168
	
	ex af,af'		;4
	dec a			;4
	ex af,af'		;4
	;-----------------	;--192
	
	dw OUTHI		;12__
	
	adc a,0			;7

	ld hl,-16		;10		;point SP to beginning of pattern row again
	add hl,sp		;11
	ld sp,hl		;6
	add a,basec		;7		;calculate which core to use for next frame
	ld h,a			;4		;and put the value in HL
	xor a			;4		;also reset volume accu
	ld l,a			;4
	
	ex (sp),hl		;19		;timing
	ex (sp),hl		;19		;timing
	
	ex af,af'		;4		;check if timer has expired
	dec a			;4
	jp z,updateTimer	;10		;and update if necessary
	ret z			;5		;timing
	ex af,af'		;4
	
	ex (sp),hl		;19		;timing
	ex (sp),hl		;19		;timing

	dw OUTHI		;12__168
		
	ds 2			;8		;timing
	jp (hl)			;4		;jump to next frame
	;-----------------	;--192

		
	
;*********************************************************************************************	
musicData
;	include "music.asm"
	

;sequence
	dw ptn8
	dw ptn8
	dw ptn9
	dw ptna
loop
	dw ptn1
	dw ptn1
	dw ptn2
	dw ptn2
	dw ptn1
	dw ptn3
	dw ptn4
	dw ptn4
	dw ptn5
	dw ptn5
	dw ptn6
	dw ptn6
	dw ptnd
	dw ptnd
	dw ptnb
	dw ptne
	dw 0

ptn1
	dw $300,row0
	dw $300,row1
	dw $300,row2
	dw $300,row3
	dw $300,row4
	dw $300,row5
	dw $300,row6
	dw $300,row7
	dw $300,row8
	dw $300,row9
	dw $300,rowa
	dw $300,rowb
	dw $300,rowc
	dw $300,rowd
	dw $300,rowe
	dw $300,rowf
	dw $300,row10
	dw $300,row1
	dw $300,row2
	dw $300,row3
	dw $300,row11
	dw $300,row12
	dw $300,row6
	dw $300,row13
	dw $300,row8
	dw $300,row9
	dw $300,row14
	dw $300,rowb
	dw $300,rowc
	dw $300,rowd
	dw $300,rowe
	dw $300,rowf
	dw $300,row10
	dw $300,row1
	dw $300,row2
	dw $300,row3
	dw $300,row4
	dw $300,row5
	dw $300,row6
	dw $300,row7
	dw $300,row8
	dw $300,row9
	dw $300,rowa
	dw $300,rowb
	dw $300,rowc
	dw $300,rowd
	dw $300,rowe
	dw $300,rowf
	dw $300,row10
	dw $300,row1
	dw $300,row2
	dw $300,row3
	dw $300,row11
	dw $300,row12
	dw $300,row6
	dw $300,row13
	dw $300,row8
	dw $300,row9
	dw $300,row14
	dw $300,rowb
	dw $300,rowc
	dw $300,rowd
	dw $300,rowe
	dw $300,rowf
	db $40

ptn2
	dw $300,row15
	dw $300,row16
	dw $300,row17
	dw $300,row18
	dw $300,row19
	dw $300,row1a
	dw $300,row1b
	dw $300,row1c
	dw $300,row1d
	dw $300,row1e
	dw $300,row1f
	dw $300,row20
	dw $300,row21
	dw $300,row22
	dw $300,row23
	dw $300,row24
	dw $300,row15
	dw $300,row16
	dw $300,row17
	dw $300,row18
	dw $300,row25
	dw $300,row26
	dw $300,row1b
	dw $300,row27
	dw $300,row1d
	dw $300,row1e
	dw $300,row28
	dw $300,row20
	dw $300,row21
	dw $300,row22
	dw $300,row23
	dw $300,row24
	dw $300,row15
	dw $300,row16
	dw $300,row17
	dw $300,row18
	dw $300,row19
	dw $300,row1a
	dw $300,row1b
	dw $300,row1c
	dw $300,row1d
	dw $300,row1e
	dw $300,row1f
	dw $300,row20
	dw $300,row21
	dw $300,row22
	dw $300,row23
	dw $300,row24
	dw $300,row15
	dw $300,row16
	dw $300,row17
	dw $300,row18
	dw $300,row25
	dw $300,row26
	dw $300,row1b
	dw $300,row27
	dw $300,row1d
	dw $300,row1e
	dw $300,row28
	dw $300,row20
	dw $300,row21
	dw $300,row22
	dw $300,row23
	dw $300,row24
	db $40

ptn3
	dw $300,row10
	dw $300,row1
	dw $300,row2
	dw $300,row3
	dw $300,row4
	dw $300,row5
	dw $300,row6
	dw $300,row7
	dw $300,row8
	dw $300,row9
	dw $300,rowa
	dw $300,rowb
	dw $300,rowc
	dw $300,rowd
	dw $300,rowe
	dw $300,rowf
	dw $300,row10
	dw $300,row1
	dw $300,row2
	dw $300,row3
	dw $300,row11
	dw $300,row12
	dw $300,row6
	dw $300,row13
	dw $300,row8
	dw $300,row9
	dw $300,row14
	dw $300,rowb
	dw $300,rowc
	dw $300,rowd
	dw $300,rowe
	dw $300,rowf
	dw $300,row10
	dw $300,row1
	dw $300,row2
	dw $300,row3
	dw $300,row4
	dw $300,row5
	dw $300,row29
	dw $300,row2a
	dw $300,row2b
	dw $300,row2c
	dw $300,row2d
	dw $300,row2e
	dw $300,row2f
	dw $300,row30
	dw $300,row31
	dw $300,row32
	dw $300,row33
	dw $300,row34
	dw $300,row35
	dw $300,row36
	dw $300,row37
	dw $300,row38
	dw $300,row39
	dw $300,row3a
	dw $300,row3b
	dw $300,row3c
	dw $300,row3d
	dw $300,row3e
	dw $300,row3f
	dw $300,row40
	dw $300,row41
	dw $300,row42
	db $40

ptn4
	dw $300,row43
	dw $300,row44
	dw $300,row45
	dw $300,row46
	dw $300,row47
	dw $300,row48
	dw $300,row49
	dw $300,row4a
	dw $300,row4b
	dw $300,row4c
	dw $300,row4d
	dw $300,row4e
	dw $300,row4f
	dw $300,row50
	dw $300,row51
	dw $300,row52
	dw $300,row43
	dw $300,row44
	dw $300,row45
	dw $300,row46
	dw $300,row53
	dw $300,row54
	dw $300,row49
	dw $300,row55
	dw $300,row4b
	dw $300,row4c
	dw $300,row56
	dw $300,row4e
	dw $300,row4f
	dw $300,row50
	dw $300,row51
	dw $300,row52
	dw $300,row43
	dw $300,row44
	dw $300,row45
	dw $300,row46
	dw $300,row47
	dw $300,row48
	dw $300,row49
	dw $300,row4a
	dw $300,row4b
	dw $300,row4c
	dw $300,row4d
	dw $300,row4e
	dw $300,row4f
	dw $300,row50
	dw $300,row51
	dw $300,row52
	dw $300,row43
	dw $300,row44
	dw $300,row45
	dw $300,row46
	dw $300,row53
	dw $300,row54
	dw $300,row49
	dw $300,row55
	dw $300,row4b
	dw $300,row4c
	dw $300,row56
	dw $300,row4e
	dw $300,row4f
	dw $300,row50
	dw $300,row51
	dw $300,row52
	db $40

ptn5
	dw $301,$0080,row57
	dw $300,row58
	dw $301,$0040,row2
	dw $300,row59
	dw $301,$0020,row5a
	dw $300,row5b
	dw $301,$0010,row6
	dw $300,row5c
	dw $301,$008,row5d
	dw $300,row5e
	dw $301,$004,rowa
	dw $300,row5f
	dw $301,$004,row60
	dw $300,row61
	dw $301,$004,rowe
	dw $300,row62
	dw $301,$004,row57
	dw $300,row58
	dw $301,$004,row2
	dw $300,row59
	dw $301,$004,row63
	dw $300,row64
	dw $301,$004,row6
	dw $300,row65
	dw $301,$004,row5d
	dw $300,row5e
	dw $301,$004,row14
	dw $300,row5f
	dw $301,$004,row60
	dw $300,row61
	dw $301,$004,rowe
	dw $300,row62
	dw $301,$004,row57
	dw $300,row58
	dw $301,$004,row2
	dw $300,row59
	dw $301,$004,row5a
	dw $300,row5b
	dw $301,$004,row6
	dw $300,row5c
	dw $301,$004,row5d
	dw $300,row5e
	dw $301,$004,rowa
	dw $300,row5f
	dw $301,$004,row60
	dw $300,row61
	dw $301,$004,rowe
	dw $300,row62
	dw $301,$004,row57
	dw $300,row58
	dw $301,$004,row2
	dw $300,row59
	dw $301,$004,row63
	dw $300,row64
	dw $301,$004,row6
	dw $300,row65
	dw $301,$008,row5d
	dw $300,row5e
	dw $301,$0010,row14
	dw $300,row5f
	dw $301,$0020,row60
	dw $300,row61
	dw $301,$0040,rowe
	dw $300,row62
	db $40

ptn6
	dw $301,$0080,row66
	dw $300,row67
	dw $301,$0040,row45
	dw $300,row68
	dw $301,$0020,row69
	dw $300,row6a
	dw $301,$0010,row49
	dw $300,row6b
	dw $301,$008,row6c
	dw $300,row6d
	dw $301,$004,row4d
	dw $300,row6e
	dw $301,$004,row6f
	dw $300,row70
	dw $301,$004,row51
	dw $300,row71
	dw $301,$004,row66
	dw $300,row67
	dw $301,$004,row45
	dw $300,row68
	dw $301,$004,row72
	dw $300,row73
	dw $301,$004,row49
	dw $300,row74
	dw $301,$004,row6c
	dw $300,row6d
	dw $301,$004,row56
	dw $300,row6e
	dw $301,$004,row6f
	dw $300,row70
	dw $301,$004,row51
	dw $300,row71
	dw $301,$004,row66
	dw $300,row67
	dw $301,$004,row45
	dw $300,row68
	dw $301,$004,row69
	dw $300,row6a
	dw $301,$004,row49
	dw $300,row6b
	dw $301,$004,row6c
	dw $300,row6d
	dw $301,$004,row4d
	dw $300,row6e
	dw $301,$004,row6f
	dw $300,row70
	dw $301,$004,row51
	dw $300,row71
	dw $301,$004,row66
	dw $300,row67
	dw $301,$004,row45
	dw $300,row68
	dw $301,$004,row72
	dw $300,row73
	dw $301,$004,row49
	dw $300,row74
	dw $301,$008,row6c
	dw $300,row6d
	dw $301,$0010,row56
	dw $300,row6e
	dw $301,$0020,row6f
	dw $300,row70
	dw $301,$0040,row51
	dw $300,row71
	db $40

ptn8
	dw $300,row75
	dw $300,row76
	dw $300,row77
	dw $300,row78
	dw $300,row79
	dw $300,row7a
	dw $300,row78
	dw $300,row7b
	dw $300,row7c
	dw $300,row7d
	dw $300,row7b
	dw $300,row7e
	dw $300,row7f
	dw $300,row80
	dw $300,row7e
	dw $300,row77
	dw $300,row75
	dw $300,row76
	dw $300,row77
	dw $300,row78
	dw $300,row81
	dw $300,row82
	dw $300,row78
	dw $300,row83
	dw $300,row7c
	dw $300,row7d
	dw $300,row83
	dw $300,row7e
	dw $300,row7f
	dw $300,row80
	dw $300,row7e
	dw $300,row77
	dw $300,row75
	dw $300,row76
	dw $300,row77
	dw $300,row78
	dw $300,row79
	dw $300,row7a
	dw $300,row78
	dw $300,row7b
	dw $300,row7c
	dw $300,row7d
	dw $300,row7b
	dw $300,row7e
	dw $300,row7f
	dw $300,row80
	dw $300,row7e
	dw $300,row77
	dw $300,row75
	dw $300,row76
	dw $300,row77
	dw $300,row78
	dw $300,row81
	dw $300,row82
	dw $300,row78
	dw $300,row83
	dw $300,row7c
	dw $300,row7d
	dw $300,row83
	dw $300,row7e
	dw $300,row7f
	dw $300,row80
	dw $300,row7e
	dw $300,row77
	db $40

ptn9
	dw $300,row84
	dw $300,row85
	dw $300,row77
	dw $300,row78
	dw $300,row86
	dw $300,row87
	dw $300,row78
	dw $300,row7b
	dw $300,row88
	dw $300,row89
	dw $300,row7b
	dw $300,row7e
	dw $300,row8a
	dw $300,row8b
	dw $300,row7e
	dw $300,row77
	dw $300,row84
	dw $300,row85
	dw $300,row77
	dw $300,row78
	dw $300,row8c
	dw $300,row8d
	dw $300,row78
	dw $300,row83
	dw $300,row88
	dw $300,row89
	dw $300,row83
	dw $300,row7e
	dw $300,row8a
	dw $300,row8b
	dw $300,row7e
	dw $300,row77
	dw $300,row84
	dw $300,row85
	dw $300,row77
	dw $300,row78
	dw $300,row86
	dw $300,row87
	dw $300,row78
	dw $300,row7b
	dw $300,row88
	dw $300,row89
	dw $300,row7b
	dw $300,row7e
	dw $300,row8a
	dw $300,row8b
	dw $300,row7e
	dw $300,row77
	dw $300,row84
	dw $300,row85
	dw $300,row77
	dw $300,row78
	dw $300,row8c
	dw $300,row8d
	dw $300,row78
	dw $300,row83
	dw $300,row88
	dw $300,row89
	dw $300,row83
	dw $300,row7e
	dw $300,row8a
	dw $300,row8b
	dw $300,row7e
	dw $300,row77
	db $40

ptna
	dw $300,row84
	dw $300,row85
	dw $300,row77
	dw $300,row78
	dw $300,row86
	dw $300,row87
	dw $300,row78
	dw $300,row7b
	dw $300,row88
	dw $300,row89
	dw $300,row7b
	dw $300,row7e
	dw $300,row8a
	dw $300,row8b
	dw $300,row7e
	dw $300,row77
	dw $300,row84
	dw $300,row85
	dw $300,row77
	dw $300,row78
	dw $300,row8c
	dw $300,row8d
	dw $300,row78
	dw $300,row83
	dw $300,row88
	dw $300,row89
	dw $300,row83
	dw $300,row7e
	dw $300,row8a
	dw $300,row8b
	dw $300,row7e
	dw $300,row77
	dw $300,row84
	dw $300,row85
	dw $300,row77
	dw $300,row78
	dw $300,row86
	dw $300,row87
	dw $300,row78
	dw $300,row7b
	dw $300,row88
	dw $300,row89
	dw $300,row7b
	dw $300,row7e
	dw $300,row8a
	dw $300,row8b
	dw $300,row7e
	dw $300,row77
	dw $300,row84
	dw $300,row85
	dw $300,row77
	dw $300,row78
	dw $300,row8c
	dw $300,row8d
	dw $300,row78
	dw $300,row83
	dw $301,$002,row88
	dw $301,$004,row89
	dw $301,$008,row83
	dw $301,$0010,row7e
	dw $301,$0020,row8a
	dw $301,$0030,row8b
	dw $301,$0040,row7e
	dw $301,$0050,row77
	db $40

ptnb
	dw $301,$0080,row8e
	dw $300,row8f
	dw $301,$0040,row17
	dw $300,row1b
	dw $301,$0020,row90
	dw $300,row91
	dw $301,$0010,row1b
	dw $300,row1f
	dw $301,$008,row92
	dw $300,row93
	dw $301,$004,row1f
	dw $300,row23
	dw $301,$004,row94
	dw $300,row95
	dw $301,$004,row23
	dw $300,row17
	dw $301,$004,row8e
	dw $300,row8f
	dw $301,$004,row17
	dw $300,row1b
	dw $301,$004,row96
	dw $300,row97
	dw $301,$004,row1b
	dw $300,row28
	dw $301,$004,row92
	dw $300,row93
	dw $301,$004,row28
	dw $300,row23
	dw $301,$004,row94
	dw $300,row95
	dw $301,$004,row23
	dw $300,row17
	dw $301,$004,row8e
	dw $300,row8f
	dw $301,$004,row17
	dw $300,row1b
	dw $301,$004,row90
	dw $300,row91
	dw $301,$004,row1b
	dw $300,row1f
	dw $301,$004,row92
	dw $300,row93
	dw $301,$004,row1f
	dw $300,row23
	dw $301,$004,row94
	dw $300,row95
	dw $301,$004,row23
	dw $300,row17
	dw $301,$004,row8e
	dw $300,row8f
	dw $301,$004,row17
	dw $300,row1b
	dw $301,$004,row96
	dw $300,row97
	dw $301,$004,row1b
	dw $300,row28
	dw $301,$008,row92
	dw $300,row93
	dw $301,$0010,row28
	dw $300,row23
	dw $301,$0020,row94
	dw $300,row95
	dw $301,$0040,row23
	dw $300,row17
	db $40

ptnd
	dw $301,$0080,row98
	dw $300,row99
	dw $301,$0040,row2
	dw $300,row6
	dw $301,$0020,row9a
	dw $300,row9b
	dw $301,$0010,row6
	dw $300,rowa
	dw $301,$008,row9c
	dw $300,row9d
	dw $301,$004,rowa
	dw $300,rowe
	dw $301,$004,row9e
	dw $300,row9f
	dw $301,$004,rowe
	dw $300,row2
	dw $301,$004,row98
	dw $300,row99
	dw $301,$004,row2
	dw $300,row6
	dw $301,$004,rowa0
	dw $300,rowa1
	dw $301,$004,row6
	dw $300,row14
	dw $301,$004,row9c
	dw $300,row9d
	dw $301,$004,row14
	dw $300,rowe
	dw $301,$004,row9e
	dw $300,row9f
	dw $301,$004,rowe
	dw $300,row2
	dw $301,$004,row98
	dw $300,row99
	dw $301,$004,row2
	dw $300,row6
	dw $301,$004,row9a
	dw $300,row9b
	dw $301,$004,row6
	dw $300,rowa
	dw $301,$004,row9c
	dw $300,row9d
	dw $301,$004,rowa
	dw $300,rowe
	dw $301,$004,row9e
	dw $300,row9f
	dw $301,$004,rowe
	dw $300,row2
	dw $301,$004,row98
	dw $300,row99
	dw $301,$004,row2
	dw $300,row6
	dw $301,$004,rowa0
	dw $300,rowa1
	dw $301,$004,row6
	dw $300,row14
	dw $301,$008,row9c
	dw $300,row9d
	dw $301,$0010,row14
	dw $300,rowe
	dw $301,$0020,row9e
	dw $300,row9f
	dw $301,$0040,rowe
	dw $300,row2
	db $40

ptne
	dw $301,$0080,row8e
	dw $300,row8f
	dw $301,$0040,row17
	dw $300,row1b
	dw $301,$0020,row90
	dw $300,row91
	dw $301,$0010,row1b
	dw $300,row1f
	dw $301,$008,row92
	dw $300,row93
	dw $301,$004,row1f
	dw $300,row23
	dw $301,$004,row94
	dw $300,row95
	dw $301,$004,row23
	dw $300,row17
	dw $301,$004,row8e
	dw $300,row8f
	dw $301,$004,row17
	dw $300,row1b
	dw $301,$004,row96
	dw $300,row97
	dw $301,$004,row1b
	dw $300,row28
	dw $301,$004,row92
	dw $300,row93
	dw $301,$004,row28
	dw $300,row23
	dw $301,$004,row94
	dw $300,row95
	dw $301,$004,row23
	dw $300,row17
	dw $301,$004,row8e
	dw $300,row8f
	dw $301,$004,row17
	dw $300,row1b
	dw $301,$004,row90
	dw $300,row91
	dw $301,$004,row1b
	dw $300,row1f
	dw $301,$004,row92
	dw $300,row93
	dw $301,$004,row1f
	dw $300,row23
	dw $301,$004,row94
	dw $300,row95
	dw $301,$004,row23
	dw $300,row17
	dw $301,$004,row8e
	dw $300,row8f
	dw $301,$004,row17
	dw $300,row1b
	dw $301,$004,row96
	dw $300,row97
	dw $301,$004,row1b
	dw $300,row28
	dw $301,$008,row92
	dw $300,row93
	dw $301,$0010,row28
	dw $300,row23
	dw $301,$0020,row94
	dw $300,row95
	dw $301,$0040,row23
	dw $300,row17
	db $40



;row buffers
row0	dw $400,$400,$800,$1000,$1000,$984,$bfd,$1000
row1	dw $400,$0,$800,$0,$1000,$984,$bfd,$1000
row2	dw $0,$0,$0,$17f9,$0,$984,$bfd,$1000
row3	dw $400,$0,$0,$1000,$0,$984,$bfd,$1000
row4	dw $800,$800,$1000,$2000,$2000,$984,$bfd,$1000
row5	dw $800,$0,$1000,$0,$2000,$984,$bfd,$1000
row6	dw $0,$0,$0,$1000,$0,$984,$bfd,$1000
row7	dw $800,$0,$0,$2000,$0,$984,$bfd,$1000
row8	dw $557,$557,$aae,$155c,$155c,$984,$bfd,$1000
row9	dw $557,$0,$aae,$0,$155c,$984,$bfd,$1000
rowa	dw $0,$0,$0,$2000,$0,$984,$bfd,$1000
rowb	dw $557,$0,$0,$155c,$0,$984,$bfd,$1000
rowc	dw $5fe,$5fe,$bfd,$17f9,$17f9,$984,$bfd,$1000
rowd	dw $5fe,$0,$bfd,$0,$17f9,$984,$bfd,$1000
rowe	dw $0,$0,$0,$155c,$0,$984,$bfd,$1000
rowf	dw $5fe,$0,$0,$17f9,$0,$984,$bfd,$1000
row10	dw $400,$400,$800,$1000,$1000,$984,$bfd,$1000
row11	dw $4c2,$4c2,$984,$1307,$1307,$984,$bfd,$1000
row12	dw $4c2,$0,$984,$0,$1307,$984,$bfd,$1000
row13	dw $4c2,$0,$0,$1307,$0,$984,$bfd,$1000
row14	dw $0,$0,$0,$1307,$0,$984,$bfd,$1000
row15	dw $400,$400,$800,$1000,$1000,$984,$bfd,$e41
row16	dw $400,$0,$800,$0,$1000,$984,$bfd,$e41
row17	dw $0,$0,$0,$17f9,$0,$984,$bfd,$e41
row18	dw $400,$0,$0,$1000,$0,$984,$bfd,$e41
row19	dw $800,$800,$1000,$2000,$2000,$984,$bfd,$e41
row1a	dw $800,$0,$1000,$0,$2000,$984,$bfd,$e41
row1b	dw $0,$0,$0,$1000,$0,$984,$bfd,$e41
row1c	dw $800,$0,$0,$2000,$0,$984,$bfd,$e41
row1d	dw $557,$557,$aae,$155c,$155c,$984,$bfd,$e41
row1e	dw $557,$0,$aae,$0,$155c,$984,$bfd,$e41
row1f	dw $0,$0,$0,$2000,$0,$984,$bfd,$e41
row20	dw $557,$0,$0,$155c,$0,$984,$bfd,$e41
row21	dw $5fe,$5fe,$bfd,$17f9,$17f9,$984,$bfd,$e41
row22	dw $5fe,$0,$bfd,$0,$17f9,$984,$bfd,$e41
row23	dw $0,$0,$0,$155c,$0,$984,$bfd,$e41
row24	dw $5fe,$0,$0,$17f9,$0,$984,$bfd,$e41
row25	dw $4c2,$4c2,$984,$1307,$1307,$984,$bfd,$e41
row26	dw $4c2,$0,$984,$0,$1307,$984,$bfd,$e41
row27	dw $4c2,$0,$0,$1307,$0,$984,$bfd,$e41
row28	dw $0,$0,$0,$1307,$0,$984,$bfd,$e41
row29	dw $0,$0,$0,$1000,$0,$984,$bfd,$17f9
row2a	dw $800,$0,$0,$2000,$0,$984,$bfd,$155c
row2b	dw $557,$557,$aae,$155c,$155c,$984,$bfd,$17f9
row2c	dw $557,$0,$aae,$0,$155c,$984,$bfd,$17f9
row2d	dw $0,$0,$0,$2000,$0,$984,$bfd,$17f9
row2e	dw $557,$0,$0,$155c,$0,$984,$bfd,$17f9
row2f	dw $5fe,$5fe,$bfd,$17f9,$17f9,$984,$bfd,$17f9
row30	dw $5fe,$0,$bfd,$0,$17f9,$984,$bfd,$17f9
row31	dw $0,$0,$0,$155c,$0,$984,$bfd,$17f9
row32	dw $5fe,$0,$0,$17f9,$0,$984,$bfd,$17f9
row33	dw $400,$400,$800,$1000,$1000,$984,$bfd,$17f9
row34	dw $400,$0,$800,$0,$1000,$984,$bfd,$17f9
row35	dw $0,$0,$0,$17f9,$0,$984,$bfd,$17f9
row36	dw $400,$0,$0,$1000,$0,$984,$bfd,$17f9
row37	dw $4c2,$4c2,$984,$1307,$1307,$984,$bfd,$17f9
row38	dw $4c2,$0,$984,$0,$1307,$984,$bfd,$17f9
row39	dw $0,$0,$0,$1000,$0,$984,$bfd,$155c
row3a	dw $4c2,$0,$0,$1307,$0,$984,$bfd,$1307
row3b	dw $557,$557,$aae,$155c,$155c,$984,$bfd,$155c
row3c	dw $557,$0,$aae,$0,$155c,$984,$bfd,$155c
row3d	dw $0,$0,$0,$1307,$0,$984,$bfd,$155c
row3e	dw $557,$0,$0,$155c,$0,$984,$bfd,$155c
row3f	dw $5fe,$5fe,$bfd,$17f9,$17f9,$984,$bfd,$155c
row40	dw $5fe,$0,$bfd,$0,$17f9,$984,$bfd,$155c
row41	dw $0,$0,$0,$155c,$0,$984,$bfd,$155c
row42	dw $5fe,$0,$0,$17f9,$0,$984,$bfd,$155c
row43	dw $390,$390,$721,$e41,$e41,$87a,$aae,$e41
row44	dw $390,$0,$721,$0,$e41,$87a,$aae,$e41
row45	dw $0,$0,$0,$155c,$0,$87a,$aae,$e41
row46	dw $390,$0,$0,$e41,$0,$87a,$aae,$e41
row47	dw $721,$721,$e41,$1c82,$1c82,$87a,$aae,$e41
row48	dw $721,$0,$e41,$0,$1c82,$87a,$aae,$e41
row49	dw $0,$0,$0,$e41,$0,$87a,$aae,$e41
row4a	dw $721,$0,$0,$1c82,$0,$87a,$aae,$e41
row4b	dw $4c2,$4c2,$984,$1307,$1307,$87a,$aae,$e41
row4c	dw $4c2,$0,$984,$0,$1307,$87a,$aae,$e41
row4d	dw $0,$0,$0,$1c82,$0,$87a,$aae,$e41
row4e	dw $4c2,$0,$0,$1307,$0,$87a,$aae,$e41
row4f	dw $557,$557,$aae,$155c,$155c,$87a,$aae,$e41
row50	dw $557,$0,$aae,$0,$155c,$87a,$aae,$e41
row51	dw $0,$0,$0,$1307,$0,$87a,$aae,$e41
row52	dw $557,$0,$0,$155c,$0,$87a,$aae,$e41
row53	dw $43d,$43d,$87a,$10f4,$10f4,$87a,$aae,$e41
row54	dw $43d,$0,$87a,$0,$10f4,$87a,$aae,$e41
row55	dw $43d,$0,$0,$10f4,$0,$87a,$aae,$e41
row56	dw $0,$0,$0,$10f4,$0,$87a,$aae,$e41
row57	dw $200,$200,$800,$1000,$1000,$984,$bfd,$1000
row58	dw $200,$0,$800,$0,$1000,$984,$bfd,$1000
row59	dw $200,$0,$0,$1000,$0,$984,$bfd,$1000
row5a	dw $400,$400,$1000,$2000,$2000,$984,$bfd,$1000
row5b	dw $400,$0,$1000,$0,$2000,$984,$bfd,$1000
row5c	dw $400,$0,$0,$2000,$0,$984,$bfd,$1000
row5d	dw $2ab,$2ab,$aae,$155c,$155c,$984,$bfd,$1000
row5e	dw $2ab,$0,$aae,$0,$155c,$984,$bfd,$1000
row5f	dw $2ab,$0,$0,$155c,$0,$984,$bfd,$1000
row60	dw $2ff,$2ff,$bfd,$17f9,$17f9,$984,$bfd,$1000
row61	dw $2ff,$0,$bfd,$0,$17f9,$984,$bfd,$1000
row62	dw $2ff,$0,$0,$17f9,$0,$984,$bfd,$1000
row63	dw $261,$261,$984,$1307,$1307,$984,$bfd,$1000
row64	dw $261,$0,$984,$0,$1307,$984,$bfd,$1000
row65	dw $261,$0,$0,$1307,$0,$984,$bfd,$1000
row66	dw $1c8,$390,$721,$e41,$e41,$87a,$aae,$e41
row67	dw $1c8,$0,$721,$0,$e41,$87a,$aae,$e41
row68	dw $1c8,$0,$0,$e41,$0,$87a,$aae,$e41
row69	dw $390,$721,$e41,$1c82,$1c82,$87a,$aae,$e41
row6a	dw $390,$0,$e41,$0,$1c82,$87a,$aae,$e41
row6b	dw $390,$0,$0,$1c82,$0,$87a,$aae,$e41
row6c	dw $261,$4c2,$984,$1307,$1307,$87a,$aae,$e41
row6d	dw $261,$0,$984,$0,$1307,$87a,$aae,$e41
row6e	dw $261,$0,$0,$1307,$0,$87a,$aae,$e41
row6f	dw $2ab,$557,$aae,$155c,$155c,$87a,$aae,$e41
row70	dw $2ab,$0,$aae,$0,$155c,$87a,$aae,$e41
row71	dw $2ab,$0,$0,$155c,$0,$87a,$aae,$e41
row72	dw $21e,$43d,$87a,$10f4,$10f4,$87a,$aae,$e41
row73	dw $21e,$0,$87a,$0,$10f4,$87a,$aae,$e41
row74	dw $21e,$0,$0,$10f4,$0,$87a,$aae,$e41
row75	dw $0,$0,$0,$1000,$1000,$0,$0,$0
row76	dw $0,$0,$0,$0,$1000,$0,$0,$0
row77	dw $0,$0,$0,$17f9,$0,$0,$0,$0
row78	dw $0,$0,$0,$1000,$0,$0,$0,$0
row79	dw $0,$0,$0,$2000,$2000,$0,$0,$0
row7a	dw $0,$0,$0,$0,$2000,$0,$0,$0
row7b	dw $0,$0,$0,$2000,$0,$0,$0,$0
row7c	dw $0,$0,$0,$155c,$155c,$0,$0,$0
row7d	dw $0,$0,$0,$0,$155c,$0,$0,$0
row7e	dw $0,$0,$0,$155c,$0,$0,$0,$0
row7f	dw $0,$0,$0,$17f9,$17f9,$0,$0,$0
row80	dw $0,$0,$0,$0,$17f9,$0,$0,$0
row81	dw $0,$0,$0,$1307,$1307,$0,$0,$0
row82	dw $0,$0,$0,$0,$1307,$0,$0,$0
row83	dw $0,$0,$0,$1307,$0,$0,$0,$0
row84	dw $0,$0,$800,$1000,$1000,$0,$0,$0
row85	dw $0,$0,$800,$0,$1000,$0,$0,$0
row86	dw $0,$0,$1000,$2000,$2000,$0,$0,$0
row87	dw $0,$0,$1000,$0,$2000,$0,$0,$0
row88	dw $0,$0,$aae,$155c,$155c,$0,$0,$0
row89	dw $0,$0,$aae,$0,$155c,$0,$0,$0
row8a	dw $0,$0,$bfd,$17f9,$17f9,$0,$0,$0
row8b	dw $0,$0,$bfd,$0,$17f9,$0,$0,$0
row8c	dw $0,$0,$984,$1307,$1307,$0,$0,$0
row8d	dw $0,$0,$984,$0,$1307,$0,$0,$0
row8e	dw $0,$0,$800,$1000,$1000,$984,$bfd,$e41
row8f	dw $0,$0,$800,$0,$1000,$984,$bfd,$e41
row90	dw $0,$0,$1000,$2000,$2000,$984,$bfd,$e41
row91	dw $0,$0,$1000,$0,$2000,$984,$bfd,$e41
row92	dw $0,$0,$aae,$155c,$155c,$984,$bfd,$e41
row93	dw $0,$0,$aae,$0,$155c,$984,$bfd,$e41
row94	dw $0,$0,$bfd,$17f9,$17f9,$984,$bfd,$e41
row95	dw $0,$0,$bfd,$0,$17f9,$984,$bfd,$e41
row96	dw $0,$0,$984,$1307,$1307,$984,$bfd,$e41
row97	dw $0,$0,$984,$0,$1307,$984,$bfd,$e41
row98	dw $0,$0,$800,$1000,$1000,$984,$bfd,$1000
row99	dw $0,$0,$800,$0,$1000,$984,$bfd,$1000
row9a	dw $0,$0,$1000,$2000,$2000,$984,$bfd,$1000
row9b	dw $0,$0,$1000,$0,$2000,$984,$bfd,$1000
row9c	dw $0,$0,$aae,$155c,$155c,$984,$bfd,$1000
row9d	dw $0,$0,$aae,$0,$155c,$984,$bfd,$1000
row9e	dw $0,$0,$bfd,$17f9,$17f9,$984,$bfd,$1000
row9f	dw $0,$0,$bfd,$0,$17f9,$984,$bfd,$1000
rowa0	dw $0,$0,$984,$1307,$1307,$984,$bfd,$1000
rowa1	dw $0,$0,$984,$0,$1307,$984,$bfd,$1000





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
	savebin "octode2k16.tap",tap_b,tap_e-tap_b




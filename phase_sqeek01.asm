;Phase Squeek aka TOUPEE (Totally Overpowered, Utterly Pointless Extreme Engine)
;version 0.1
;ZX Spectrum beeper engine
;by utz 08'2016 * www.irrlichtproject.de




 device zxspectrum128

	org $6500-13				; Origin
tap_b:	db $22,"NONAME",$22			;name		  	
	db "M"					;type		  	
	dw end-begin				;program length	  	
	dw begin				;load point		
	org $6500
begin:




BORDER equ #ff
noise equ #2175
;	include "freqtab.asm"	;note name equates, can be omitted

a0	 equ #ec
ais0	 equ #fa
h0	 equ #109
c1	 equ #118
cis1	 equ #129
d1	 equ #13b
dis1	 equ #14d
e1	 equ #161
f1	 equ #176
fis1	 equ #18d
g1	 equ #1a4
gis1	 equ #1bd
a1	 equ #1d8
ais1	 equ #1f4
h1	 equ #211
c2	 equ #231
cis2	 equ #252
d2	 equ #275
dis2	 equ #29b
e2	 equ #2c2
f2	 equ #2ed
fis2	 equ #319
g2	 equ #348
gis2	 equ #37a
a2	 equ #3af
ais2	 equ #3e7
h2	 equ #423
c3	 equ #461
cis3	 equ #4a4
d3	 equ #4eb
dis3	 equ #536
e3	 equ #585
f3	 equ #5d9
fis3	 equ #632
g3	 equ #690
gis3	 equ #6f4
a3	 equ #75e
ais3	 equ #7ce
h3	 equ #845
c4	 equ #8c3
cis4	 equ #948
d4	 equ #9d6
dis4	 equ #a6b
e4	 equ #b0a
f4	 equ #bb2
fis4	 equ #c64
g4	 equ #d21
gis4	 equ #de9
a4	 equ #ebc
ais4	 equ #f9d
h4	 equ #108a
c5	 equ #1186
cis5	 equ #1291
d5	 equ #13ab
dis5	 equ #14d7
e5	 equ #1614
f5	 equ #1764
fis5	 equ #18c8
g5	 equ #1a41
gis5	 equ #1bd1
a5	 equ #1d79
ais5	 equ #1f39
h5	 equ #2114
c6	 equ #230c
cis6	 equ #2521
d6	 equ #2757
dis6	 equ #29ae
e6	 equ #2c28
f6	 equ #2ec8
fis6	 equ #3190
g6	 equ #3483
gis6	 equ #37a2
a6	 equ #3af1
ais6	 equ #3e72
h6	 equ #4229
c7	 equ #4618
cis7	 equ #4a43
d7	 equ #4ead
dis7	 equ #535b
e7	 equ #5850
f7	 equ #5d90
fis7	 equ #6321
g7	 equ #6906
gis7	 equ #6f44
a7	 equ #75e2



init
	ei			;detect kempston
;	halt
;	in a,(#1f)
;	inc a
;	jr nz,skip
;	ld (maskKempston),a
;skip	
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
	pop bc			;pattern pointer to DE
	or b
	ld (seqpntr),sp
	jr nz,rdptn0
	
	;jp exit		;uncomment to disable looping
	
	ld sp,loop		;get loop point
	jr rdseq+3

;******************************************************************
rdptn0
	ld (ptnpntr),bc
rdptn
;	in a,(#1f)		;read joystick
;maskKempston equ $+1
;	and #1f
;	ld c,a
;	in a,(#fe)		;read kbd
;	cpl
;	or c
;	and #1f
;	jp nz,exit


ptnpntr equ $+1
	ld sp,0
	
	pop af			;global ctrl (F) and method (A)
	jr z,rdseq
	jr c,noFxUpdate2
	
	pop bc			;fx table pointer
	ld (fxPointer),bc

noFxUpdate2
	jp pe,ctrl32		;no updates for this row
	
	ld (globalMethod),a
	
	jp m,ctrl22		;no updates for ch1
	
	
	pop af			;ch1 ctrl (F) and method (A)
	ld (method1),a
	
	jr c,noF1Update2
	
	pop hl			;frequency ch1 op1
	ld (freq1A),hl
	pop hl			;frequency ch1 op2
	ld (freq1B),hl

noF1Update2
	jr z,noDuty1Update2
	
	pop de			;duties ch1 op1/2
	
noDuty1Update2
	jp pe,noSID1Update2
	
	pop bc			;SID/ES ch1 op1
	ld (sid1A),bc
	pop bc			;SID/ES ch1 op2
	ld (sid1B),bc
		
noSID1Update2
	jp m,noPhase1Update2

	pop hl			;phase ch1
	ld ix,0
	
noPhase1Update2
ctrl22
	pop af			;ch2 ctrl (F) and method (A)
	
	ld (method2),a
	exx
	jr c,noF2Update2
	
	pop hl			;freq ch2 op1
	ld (freq2A),hl
	pop hl			;freq ch2 op2
	ld (freq2B),hl

noF2Update2
	jr z,noDuty2Update2
	
	pop de			;duties ch2 op1/2
	
noDuty2Update2
	ld a,0
	jp po,setNoise22
	
	ld a,#cb
	
setNoise22
	ld (noise2),a		;a=0 - noise disabled, a=#cb - noise enabled
	jp m,noPhase2Update2
	
	pop hl			;phase ch2
	ld iy,0
	
noPhase2Update2
	exx
ctrl32
	pop af			;drum ctrl (F) and speed
	
	jp z,drum1
	jp m,drum2
	
	ld c,0			;set speed (length counter) lo-byte
	ex af,af'
	
drumret
	ld (ptnpntr),sp

;*******************************************************************************
playNote
freq1A equ $+1
	ld sp,0			;10
	add hl,sp		;11
	ld a,d			;4
sid1A
shaker1A equ $+1				;add a,n = c6, adc a,n = c6
 	adc a,0			;7
 	ld d,a			;4
	add a,h			;4
	sbc a,a			;4
	ld b,a			;4
	
freq1B equ $+1
	ld sp,0			;10
	add ix,sp		;15
	ld a,e			;4
sid1B
shaker1B equ $+1
 	adc a,0			;7
 	ld e,a			;4
	add a,ixh		;4
	sbc a,a			;4
method1
	xor b			;4		;xor = a8, or = b0, and = a0
	ld b,a			;4		;preserve output state ch1
	
	exx			;4	
	
freq2A equ $+1
	ld sp,0			;10
	add hl,sp		;11
noise2
	rlc h			;8		;rlc h = cb 04 - noise enable
						;nop,inc b = 00 04 - noise disable 
	ld a,d			;4
	add a,h			;4
	sbc a,a			;4
	ld b,a			;4
	
freq2B equ $+1
	ld sp,0			;10
	add iy,sp		;15
	ld a,e			;4
	add a,iyh		;8
	sbc a,a			;4
method2
	xor b			;4
	
	exx			;4

globalMethod
	xor b			;4		;combine with state ch1
	ret c			;5		;timing
	
	out (#84),a		;11
	
	dec c			;4		;timer
	
	jp nz,playNote		;10
				;232
	
;*******************************************************************************
updateTimer
		
fxPointer equ $+1
	ld sp,0
	
	pop af			;global ctrl (F) and method (A)
	jr z,stopFx
	jp pe,noUpdate		;no updates for this row
	jr nc,noFxPntrReset
	
	exx
	pop bc			;fx table pointer reset
	ld (fxPointer),bc
	exx
	jp updateTimer
	
noFxPntrReset
	ld (globalMethod),a
	
	jp m,ctrl2		;no updates for ch1
	
	
	pop af			;ch1 ctrl (F) and method (A)
	ld (method1),a
	
	jr c,noF1Update
	
	pop hl			;frequency ch1 op1
	ld (freq1A),hl
	pop hl			;frequency ch1 op2
	ld (freq1B),hl

noF1Update
	jr z,noDuty1Update
	
	pop de			;duties ch1 op1/2
	
noDuty1Update
	jp pe,noSID1Update
	
	exx
	pop bc			;SID/ES ch1 op1
	ld (sid1A),bc
	pop bc			;SID/ES ch1 op2
	ld (sid1B),bc
	exx
		
noSID1Update
	jp m,noPhase1Update	

	pop hl			;phase ch1
	ld ix,0
	
noPhase1Update
ctrl2
	pop af			;ch2 ctrl (F) and method (A)
	
	ld (method2),a
	exx
	jr c,noF2Update
	
	pop hl			;freq ch2 op1
	ld (freq2A),hl
	pop hl			;freq ch2 op2
	ld (freq2B),hl

noF2Update
	jr z,noDuty2Update
	
	pop de			;duties ch2 op1/2
	
noDuty2Update
	ld a,0
	jp po,setNoise2
	
	ld a,#cb
	
setNoise2
	ld (noise2),a		;a=0 - noise disabled, a=#cb - noise enabled
	jp m,noPhase2Update
	
	pop hl			;phase ch2
	ld iy,0
	
noPhase2Update
	exx	

noUpdate
	ld (fxPointer),sp

stopFx
	ex af,af'
	dec a
	jp z,rdptn
	ex af,af'
	jp playNote

;*******************************************************************************
drum2
	ld (HLrestore),hl
	ex af,af'

	ld hl,hat1
	ld b,hat1end-hat1
	jr drentry
drum1

	ld (HLrestore),hl
	ex af,af'
	
	ld hl,kick1		;10
	ld b,kick1end-kick1	;7
drentry
	xor a			;4
s2	
	xor BORDER		;7
	ld c,(hl)		;7
	inc hl			;6
s1	
	out (#84),a		;11
	dec c			;4
	jr nz,s1		;12/7    
	
	djnz s2		;13/8
	ld c,#10; 19		;7	;correct frame length

HLrestore equ $+1
	ld hl,0
	jp drumret		;10
	
kick1					;27*16*4 + 27*32*4 + 27*64*4 + 27*128*4 + 27*256*4 = 53568, + 20*33 = 53568 -> -231 loops -> C = #19
	ds 4,#10
	ds 4,#20
	ds 4,#40
	ds 4,#80
	ds 4,0
kick1end

hat1
	db 16,3,12,6,9,20,4,8,2,14,9,17,5,8,12,4,7,16,13,22,5,3,16,3,12,6,9,20,4,8,2,14,9,17,5,8,12,4,7,16,13,22,5,3
	db 12,8,1,24,6,7,4,9,18,12,8,3,11,7,5,8,3,17,9,15,22,6,5,8,11,13,4,8,12,9,2,4,7,8,12,6,7,4,19,22,1,9,6,27,4,3,11
	db 5,8,14,2,11,13,5,9,2,17,10,3,7,19,4,3,8,2,9,11,4,17,6,4,9,14,2,22,8,4,19,2,3,5,11,1,16,20,4,7
	db 8,9,4,12,2,8,14,3,7,7,13,9,15,1,8,4,17,3,22,4,8,11,4,21,9,6,12,4,3,8,7,17,5,9,2,11,17,4,9,3,2
	db 22,4,7,3,8,9,4,11,8,5,9,2,6,2,8,8,3,11,5,3,9,6,7,4,8
hat1end
;*******************************************************************************
exit
oldSP equ $+1
	ld sp,0
	pop hl
	exx
	ei
	ret

;*******************************************************************************
musicData
;	include "music.asm"

;example music data for Phase Squeek

 	dw ptn0
	dw ptn0
loop
	dw ptn1
	dw ptn1
	dw ptn2
	dw ptn3

	dw ptn4
	dw ptn5
	dw ptn6
	dw 0

	;ctrl_0+globalMethod,fxPointer,ctrl_1+method1,freq1a,freq1b,duty1,sid_es1a,sid_es1b,phase1,ctrl_2+method2,freq2a,freq2b,duty2,phase2,drums+speed

ptn6
		
	dw #a800,fxtab1,#a800,c1,c1,#4040,#00ce,#00ce,#0800,#b000,c1,#0000,#4000,#1800,#1040
	dw #a800,fxtab1,#a800,c2,c2,#4040,#00ce,#00ce,#0800,#b000,c1,#0000,#4000,#1800,#1000
	dw #a800,fxtab1,#a800,c1,c1,#3030,#00ce,#00ce,#0800,#b000,c1,#0000,#3000,#1800,#1080
	dw #a800,fxtab1,#a800,c2,c2,#3030,#00ce,#00ce,#0800,#b000,c1,#0000,#3000,#1800,#1000
	
	dw #a800,fxtab1,#a800,c1,c1,#2020,#00ce,#00ce,#0800,#b000,c1,#0000,#2000,#1800,#1040
	dw #a800,fxtab1,#a800,c2,c2,#2020,#00ce,#00ce,#0800,#b000,c1,#0000,#2000,#1800,#1000
	dw #a800,fxtab1,#a800,c1,c1,#1010,#00ce,#00ce,#0800,#b000,c1,#0000,#1000,#1800,#1080
	dw #a800,fxtab1,#a800,c2,c2,#1010,#00ce,#00ce,#0800,#b000,c1,#0000,#1000,#1800,#1000
	
	dw #a800,fxtab1,#a800,c1,c1,#4040,#01ce,#00ce,#0800,#a800,c1,c2,#4040,#1800,#1040
	dw #a800,fxtab1,#a800,c2,c2,#4040,#01ce,#00ce,#0800,#a800,c1,c2,#4040,#1800,#1000
	dw #a800,fxtab1,#a800,c1,c1,#4040,#01ce,#00ce,#0800,#a800,c1,c2,#4040,#1800,#1080
	dw #a800,fxtab1,#a800,c2,c2,#4040,#01ce,#00ce,#0800,#a800,c1,c2,#4040,#1800,#1000
	
	dw #a800,fxtab1,#a800,c1,c1+1,#4040,#01ce,#01ce,#0800,#a800,c1,c2,#4040,#1800,#1040
	dw #a800,fxtab1,#a800,c2,c2+2,#4040,#01ce,#01ce,#0800,#a800,c1,c2,#4040,#1800,#1000
	dw #a800,fxtab1,#a800,c1,c1+1,#4040,#01ce,#01ce,#0800,#a800,c1,c2,#4040,#1800,#1080
	dw #a800,fxtab1,#a800,c2,c2+2,#4040,#01ce,#01ce,#0800,#a800,c1,c2,#4040,#1800,#1000

; 	dw #a800,fxtab1,#a800,c1,c1,#4040,#00ce,#00ce,#0800,#b000,c1,#0000,#4000,#1800,#1040
; 	dw #a800,fxtab1,#a800,c2,c2,#4040,#00ce,#00ce,#0800,#b000,c1,#0000,#4000,#1800,#1000
; 	dw #a800,fxtab1,#a800,c1,c1,#3030,#00ce,#00ce,#0800,#b000,c1,#0000,#3000,#1800,#1080
; 	dw #a800,fxtab1,#a800,c2,c2,#3030,#00ce,#00ce,#0800,#b000,c1,#0000,#3000,#1800,#1000
; 	
; 	dw #a800,fxtab1,#a800,c1,c1,#2020,#00ce,#00ce,#0800,#b000,c1,#0000,#2000,#1800,#1040
; 	dw #a800,fxtab1,#a800,c2,c2,#2020,#00ce,#00ce,#0800,#b000,c1,#0000,#2000,#1800,#1000
; 	dw #a800,fxtab1,#a800,c1,c1,#1010,#00ce,#00ce,#0800,#b000,c1,#0000,#1000,#1800,#1080
; 	dw #a800,fxtab1,#a800,c2,c2,#1010,#00ce,#00ce,#0800,#b000,c1,#0000,#1000,#1800,#1000
	
	dw #a800,fxtab1,#a800,c1,c1,#4040,#00ce,#00ce,#0800,#a800,c1,g1,#4040,#1800,#1040
	dw #a800,fxtab1,#a800,c2,c2,#4040,#00ce,#00ce,#0800,#a800,c1,g1,#4040,#1800,#1000
	dw #a800,fxtab1,#a800,c1,c1,#4040,#00ce,#00ce,#0800,#a800,c1,g1,#4040,#1800,#1080
	dw #a800,fxtab1,#a800,c2,c2,#4040,#00ce,#00ce,#0800,#a800,c1,g1,#4040,#1800,#1000
	
	dw #a800,fxtab1,#a800,c1,c1,#4040,#00ce,#00ce,#0800,#a800,c1,g1,#4040,#1800,#1040
	dw #a800,fxtab1,#a800,c2,c2,#4040,#00ce,#00ce,#0800,#a800,c1,g1,#4040,#1800,#1000
	dw #a800,fxtab1,#a800,c1,c1,#4040,#00ce,#00ce,#0800,#a800,c1,g1,#4040,#1800,#1080
	dw #a800,fxtab1,#a800,c2,c2,#4040,#00ce,#00ce,#0800,#a800,c1,g1,#4040,#1800,#1000
	
	dw #a000,fxtab1,#a800,c1,c1+1,#4040,#02ce,#02ce,#4800,#a800,c1,c2,#4040,#1800,#1040
	dw #a000,fxtab1,#a800,c2,c2+2,#4040,#02ce,#02ce,#4800,#a800,c1,c2,#4040,#1800,#1000
	dw #a000,fxtab1,#a800,c1,c1+1,#4040,#02ce,#02ce,#2800,#a800,c1,c2,#4040,#1800,#1080
	dw #a000,fxtab1,#a800,c2,c2+2,#4040,#02ce,#02ce,#2800,#a800,c1,c2,#4040,#1800,#1000
	
	dw #a000,fxtab1,#a800,c1,c1+1,#4040,#01ce,#01ce,#1800,#a800,c1,c2,#4040,#1800,#1040
	dw #a000,fxtab1,#a800,c2,c2+2,#4040,#01ce,#01ce,#1800,#a800,c1,c2,#4040,#1800,#1000
	dw #a000,fxtab1,#a800,c1,c1+1,#4040,#01ce,#01ce,#0800,#a800,c1,c2,#4040,#1800,#1080
	dw #a000,fxtab1,#a800,c2,c2+2,#4040,#01ce,#01ce,#0800,#a800,c1,c2,#4040,#1800,#1040
	
	
	db #40
	
; ptn7
; 	dw #a800,fxtab1,#a800,c1,c1+1,#4040,#00ce,#00ce,#0800,#b000,c1,#0000,#4000,#1800,#1040
; 	dw #a800,fxtab1,#a800,c2,c2+2,#4040,#00ce,#00ce,#0800,#b000,c1,#0000,#4000,#1800,#1000
; 	dw #a800,fxtab1,#a800,c1,c1+1,#3030,#00ce,#00ce,#0800,#b000,c1,#0000,#3000,#1800,#1080
; 	dw #a800,fxtab1,#a800,c2,c2+2,#3030,#00ce,#00ce,#0800,#b000,c1,#0000,#3000,#1800,#1000
; 	
; 	dw #a800,fxtab1,#a800,c1,c1+1,#2020,#00ce,#00ce,#0800,#b000,c1-1,#0000,#2000,#1800,#1040
; 	dw #a800,fxtab1,#a800,c2,c2+2,#2020,#00ce,#00ce,#0800,#b000,c1-2,#0000,#2000,#1800,#1000
; 	dw #a800,fxtab1,#a800,c1,c1+1,#1010,#00ce,#00ce,#0800,#b000,c1-3,#0000,#1000,#1800,#1080
; 	dw #a800,fxtab1,#a800,c2,c2+2,#1010,#00ce,#00ce,#0800,#b000,c1-4,#0000,#1000,#1800,#1000
; 	
; 	dw #a800,fxtab1,#a800,c1,c1,#4040,#00ce,#00ce,#0800,#a800,c1-1,c1,#4040,#1800,#1040
; 	dw #a800,fxtab1,#a800,c2,c2,#4040,#00ce,#00ce,#0800,#a800,c1-2,c2,#4040,#1800,#1000
; 	dw #a800,fxtab1,#a800,c1,c1,#4040,#00ce,#00ce,#0800,#a800,c1-3,c1,#4040,#1800,#1080
; 	dw #a800,fxtab1,#a800,c2,c2,#4040,#00ce,#00ce,#0800,#a800,c1-4,c2,#4040,#1800,#1000
; 	
; 	dw #a800,fxtab1,#a800,c1,c1+1,#4040,#00c6,#00ce,#0800,#a800,c1-1,c1,#4040,#1800,#1040
; 	dw #a800,fxtab1,#a800,c2,c2+2,#4040,#00c6,#00ce,#0800,#a800,c1-2,c2,#4040,#1800,#1000
; 	dw #a800,fxtab1,#a800,c1,c1+3,#4040,#00c6,#00ce,#0800,#a800,c1-3,c1,#4040,#1800,#1080
; 	dw #a800,fxtab1,#a800,c2,c2+4,#4040,#00c6,#00ce,#0800,#a800,c1-4,c2,#4040,#1800,#1000
; 	
; 	dw #a000,fxtab1,#a800,c1,c1+1,#4040,#01ce,#01ce,#0800,#a800,c1,c2,#4040,#1800,#1040
; 	dw #a000,fxtab1,#a800,c2,c2+2,#4040,#01ce,#01ce,#0800,#a800,c1,c2,#4040,#1800,#1000
; 	dw #a000,fxtab1,#a800,c1,c1+1,#4040,#01ce,#01ce,#1800,#a800,c1,c2,#4040,#1800,#1080
; 	dw #a000,fxtab1,#a800,c2,c2+2,#4040,#01ce,#01ce,#1800,#a800,c1,c2,#4040,#1800,#1000
; 	
; 	dw #a000,fxtab1,#a800,c1,c1+1,#4040,#02ce,#02ce,#2800,#a800,c1,c2,#4040,#1800,#1040
; 	dw #a000,fxtab1,#a800,c2,c2+2,#4040,#02ce,#02ce,#2800,#a800,c1,c2,#4040,#1800,#1000
; 	dw #a000,fxtab1,#a800,c1,c1+1,#4040,#02ce,#02ce,#4800,#a800,c1,c2,#4040,#1800,#1080
; 	dw #a000,fxtab1,#a800,c2,c2+2,#4040,#02ce,#02ce,#4800,#a800,c1,c2,#4040,#1800,#1000
; 	
; 	dw #a800,fxtab1,#a800,c1,c1+1,#4040,#03ce,#03ce,#0800,#a800,c1,c2,#4040,#1800,#1040
; 	dw #a800,fxtab1,#a800,c2,c2+2,#4040,#03ce,#03ce,#0800,#a800,c1,c2,#4040,#1800,#1000
; 	dw #a800,fxtab1,#a800,c1,c1+1,#4040,#03ce,#03ce,#0800,#a800,c1,c2,#4040,#1800,#1080
; 	dw #a800,fxtab1,#a800,c2,c2+2,#4040,#03ce,#03ce,#0800,#a800,c1,c2,#4040,#1800,#1000
; 	
; 	dw #a800,fxtab1,#a800,c1,c1+1,#4040,#04ce,#04ce,#0800,#a800,c1,c1/2,#4040,#1800,#1040
; 	dw #a800,fxtab1,#a800,c2,c2+2,#4040,#04ce,#04ce,#0800,#a800,c1,c1/2,#4040,#1800,#1000
; 	dw #a800,fxtab1,#a800,c1,c1+1,#4040,#04ce,#04ce,#0800,#a800,c1,c1/2,#4040,#1800,#1080
; 	dw #a800,fxtab1,#a800,c2,c2+2,#4040,#04ce,#04ce,#0800,#a800,c1,c1/2,#4040,#1800,#1000
; 	
; 	db #40

ptn5
	dw #b000,fxtab1,#a800,c1,c1,#4040,#00ce,#00c6,#0800,#b004,noise,#0000,#3800,#0000,#1040
	dw #b000,fxtab1,#a800,c2,c2,#4040,#00ce,#00c6,#0800,#b004,noise,#0000,#2000,#0000,#1000
	dw #b000,fxtab1,#a800,c1,c1,#4040,#00ce,#00c6,#0800,#b004,noise,#0000,#0800,#0000,#1080
	dw #b000,fxtab1,#a800,c2,c2,#4040,#00ce,#00c6,#0800,#b000,#0000,#0000,#0000,#0000,#1000
	
	dw #a800,fxtab1,#a800,c1,c1,#4040,#00ce,#00ce,#0800,#b000,#0000,#0000,#0000,#0000,#1040
	dw #a800,fxtab1,#a800,c2,c2,#4040,#00ce,#00ce,#0800,#b000,#0000,#0000,#0000,#0000,#1000
	dw #a800,fxtab1,#a800,c1,c1,#4040,#00ce,#00ce,#0800,#b000,#0000,#0000,#0000,#0000,#1080
	dw #a800,fxtab1,#a800,c2,c2,#4040,#00ce,#00ce,#0800,#b000,#0000,#0000,#0000,#0000,#1000
	
	dw #a800,fxtab1,#a800,c1,c1+1,#4040,#00ce,#00ce,#0800,#b000,#0000,#0000,#0000,#0000,#1040
	dw #a800,fxtab1,#a800,c2,c2+2,#4040,#00ce,#00ce,#0800,#b000,#0000,#0000,#0000,#0000,#1000
	dw #a800,fxtab1,#a800,c1,c1+1,#4040,#00ce,#00ce,#0800,#b000,#0000,#0000,#0000,#0000,#1080
	dw #a800,fxtab1,#a800,c2,c2+2,#4040,#00ce,#00ce,#0800,#b000,#0000,#0000,#0000,#0000,#1000
	
	dw #a800,fxtab1,#a000,c1,c1+1,#4040,#04ce,#00ce,#0800,#b000,#0000,#0000,#0000,#0000,#1040
	dw #a800,fxtab1,#a000,c2,c2+2,#4040,#04ce,#00ce,#0800,#b000,#0000,#0000,#0000,#0000,#1000
	dw #a800,fxtab1,#a000,c1,c1+1,#4040,#04ce,#01ce,#0800,#b000,#0000,#0000,#0000,#0000,#1080
	dw #a800,fxtab1,#a000,c2,c2+2,#4040,#04ce,#01ce,#0800,#b000,#0000,#0000,#0000,#0000,#1000
	
	dw #a800,fxtab1,#a800,c1,c1+1,#4040,#00ce,#00ce,#4800,#b004,noise,#0000,#3800,#0000,#1040
	dw #a800,fxtab1,#a800,c2,c2+2,#4040,#00ce,#00ce,#4800,#b004,noise,#0000,#2000,#0000,#1000
	dw #a800,fxtab1,#a800,c1,c1+1,#4040,#00ce,#00ce,#4800,#b004,noise,#0000,#0800,#0000,#1080
	dw #a800,fxtab1,#a800,c2,c2+2,#4040,#00ce,#00ce,#4800,#b000,00000,#0000,#0000,#0000,#1000
	
	dw #a800,fxtab1,#a800,c1,c1,#4040,#00ce,#00ce,#2800,#b000,#0000,#0000,#0000,#0000,#1040
	dw #a800,fxtab1,#a800,c2,c2,#4040,#00ce,#00ce,#2800,#b000,#0000,#0000,#0000,#0000,#1000
	dw #a800,fxtab1,#a800,c1,c1,#4040,#00ce,#00ce,#2800,#b000,#0000,#0000,#0000,#0000,#1080
	dw #a800,fxtab1,#a800,c2,c2,#4040,#00ce,#00ce,#2800,#b000,#0000,#0000,#0000,#0000,#1000
	
	dw #b000,fxtab1,#a800,c1,c1,#4040,#00ce,#00c6,#1800,#b000,#0000,#0000,#0000,#0000,#1040
	dw #b000,fxtab1,#a800,c2,c2,#4040,#00ce,#00c6,#1800,#b000,#0000,#0000,#0000,#0000,#1000
	dw #b000,fxtab1,#a800,c1,c1,#4040,#00ce,#00c6,#1800,#b000,#0000,#0000,#0000,#0000,#1080
	dw #b000,fxtab1,#a800,c2,c2,#4040,#00ce,#00c6,#1800,#b000,#0000,#0000,#0000,#0000,#1000
	
	dw #a800,fxtab1,#a000,c1,c1+1,#4040,#01ce,#00ce,#0800,#b000,#0000,#0000,#0000,#0000,#1040
	dw #a800,fxtab1,#a000,c2,c2+2,#4040,#01ce,#00ce,#0800,#b000,#0000,#0000,#0000,#0000,#1000
	dw #a800,fxtab1,#a000,c1,c1+1,#4040,#01ce,#01ce,#0800,#b000,#0000,#0000,#0000,#0000,#1080
	dw #a800,fxtab1,#a000,c2,c2+2,#4040,#01ce,#01ce,#0800,#b000,#0000,#0000,#0000,#0000,#1000
	
	db #40

ptn0
	dw #b000,fxtab1,#b000,c1,0,#4040,#00c6,#00c6,#0800,#b000,#0000,#0000,#0000,#0000,#1040
	dw #b000,fxtab1,#b000,c2,0,#4040,#00c6,#00c6,#0800,#b000,#0000,#0000,#0000,#0000,#1000
	dw #b000,fxtab1,#b000,c3,0,#4040,#00c6,#00c6,#0800,#b000,#0000,#0000,#0000,#0000,#1080
	dw #b000,fxtab1,#b000,dis3,0,#4040,#00c6,#00c6,#0800,#b000,#0000,#0000,#0000,#0000,#1000
	
	dw #b000,fxtab1,#b000,c1,0,#4040,#00c6,#00c6,#0800,#b000,#0000,#0000,#0000,#0000,#1040
	dw #b000,fxtab1,#b000,c2,0,#4040,#00c6,#00c6,#0800,#b000,#0000,#0000,#0000,#0000,#1000
	dw #b000,fxtab1,#b000,c3,0,#4040,#00c6,#00c6,#0800,#b000,#0000,#0000,#0000,#0000,#1080
	dw #b000,fxtab1,#b000,ais2,0,#4040,#00c6,#00c6,#0800,#b000,#0000,#0000,#0000,#0000,#1000
	
	dw #b000,fxtab1,#b000,c1,0,#4040,#00c6,#00c6,#0800,#b000,#0000,#0000,#0000,#0000,#1040
	dw #b000,fxtab1,#b000,c2,0,#4040,#00c6,#00c6,#0800,#b000,#0000,#0000,#0000,#0000,#1000
	dw #b000,fxtab1,#b000,c3,0,#4040,#00c6,#00c6,#0800,#b000,#0000,#0000,#0000,#0000,#1080
	dw #b000,fxtab1,#b000,dis3,0,#4040,#00c6,#00c6,#0800,#b000,#0000,#0000,#0000,#0000,#1000
	
	dw #b000,fxtab1,#b000,c1,0,#4040,#00c6,#00c6,#0800,#b000,#0000,#0000,#0000,#0000,#1040
	dw #b000,fxtab1,#b000,c2,0,#4040,#00c6,#00c6,#0800,#b000,#0000,#0000,#0000,#0000,#1000
	dw #b000,fxtab1,#b000,c3,0,#4040,#00c6,#00c6,#0800,#b000,#0000,#0000,#0000,#0000,#1080
	dw #b000,fxtab1,#b000,g3,0,#4040,#00c6,#00c6,#0800,#b000,#0000,#0000,#0000,#0000,#1000
	
	db #40
	
ptn1
	dw #b000,fxtab1,#b000,c1,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1040
	dw #b000,fxtab1,#b000,c2,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	dw #b000,fxtab1,#b000,c3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1080
	dw #b000,fxtab1,#b000,dis3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	
	dw #b000,fxtab1,#b000,c1,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1040
	dw #b000,fxtab1,#b000,c2,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	dw #b000,fxtab1,#b000,c3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1080
	dw #b000,fxtab1,#b000,ais2,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	
	dw #b000,fxtab1,#b000,c1,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1040
	dw #b000,fxtab1,#b000,c2,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	dw #b000,fxtab1,#b000,c3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1080
	dw #b000,fxtab1,#b000,dis3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	
	dw #b000,fxtab1,#b000,c1,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1040
	dw #b000,fxtab1,#b000,c2,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	dw #b000,fxtab1,#b000,c3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1080
	dw #b000,fxtab1,#b000,g3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	
	db #40
	
ptn2
	dw #b000,fxtab1,#b000,f1,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1040
	dw #b000,fxtab1,#b000,f2,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	dw #b000,fxtab1,#b000,f3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1080
	dw #b000,fxtab1,#b000,ais3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	
	dw #b000,fxtab1,#b000,f1,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1040
	dw #b000,fxtab1,#b000,f2,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	dw #b000,fxtab1,#b000,f3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1080
	dw #b000,fxtab1,#b000,dis3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	
	dw #b000,fxtab1,#b000,f1,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1040
	dw #b000,fxtab1,#b000,f2,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	dw #b000,fxtab1,#b000,f3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1080
	dw #b000,fxtab1,#b000,ais3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	
	dw #b000,fxtab1,#b000,f1,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1040
	dw #b000,fxtab1,#b000,f2,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	dw #b000,fxtab1,#b000,f3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1080
	dw #b000,fxtab1,#b000,dis3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	
	db #40
	
ptn3
	dw #b000,fxtab1,#b000,f1,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1040
	dw #b000,fxtab1,#b000,f2,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	dw #b000,fxtab1,#b000,f3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1080
	dw #b000,fxtab1,#b000,ais3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	
	dw #b000,fxtab1,#b000,f1,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1040
	dw #b000,fxtab1,#b000,f2,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	dw #b000,fxtab1,#b000,f3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1080
	dw #b000,fxtab1,#b000,dis3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	
	dw #b000,fxtab1,#b000,f1,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1040
	dw #b000,fxtab1,#b000,f2,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	dw #b000,fxtab1,#b000,f3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1080
	dw #b000,fxtab1,#b000,dis3,c4,#4020,#00c6,#00c6,#0800,#b000,dis4,g3,#2020,#0000,#1000
	
	dw #b000,fxtab1,#b000,f1,dis4,#4020,#00c6,#00c6,#0800,#b004,noise,g3,#0820,#0000,#1040
	dw #b000,fxtab1,#b000,f2,dis4,#4020,#00c6,#00c6,#0800,#b004,noise,g3,#1020,#0000,#1000
	dw #b000,fxtab1,#b000,f3,dis4,#4020,#00c6,#00c6,#0800,#b004,noise,g3,#2020,#0000,#1080
	dw #b000,fxtab1,#b000,dis3,dis4,#4020,#00c6,#00c6,#0800,#b004,noise,g3,#3020,#0000,#1000
	
	db #40
	
ptn4
	dw #b000,fxtab4,#a800,c1,c1+1,#4040,#00c6,#00c6,#0800,#b004,noise,g3,#4020,#0000,#1040
	dw #b081,#b001,#2020,#0000,#1000
	dw #b081,#b001,#2020,#0000,#1080
	dw #b081,#b001,#2020,#0000,#1000
	
	dw #b081,#b001,#2020,#0000,#1040
	dw #b081,#b001,#2020,#0000,#1000
	dw #b081,#b001,#2020,#0000,#1080
	dw #b081,#b001,#2020,#0000,#1040
	
	dw #b081,#b001,#2020,#0000,#1040
	dw #b081,#b001,#2020,#0000,#1000
	dw #b081,#b001,#2020,#0000,#1080
	dw #b081,#b001,#2020,#0000,#1040
	
	dw #b081,#b001,#2020,#0000,#1040
	dw #b081,#b001,#2020,#0000,#1000
	dw #b081,#b001,#2020,#0000,#1080
	dw #b081,#b001,#2020,#0000,#0800
	dw #b081,#b001,#2020,#0000,#0880
	
	dw #b000,fxtab4,#a800,c1,c1+1,#4040,#00c6,#00c6,#0800,#b004,noise,g3,#4020,#0000,#1040
	dw #b081,#b001,#2020,#0000,#1000
	dw #b081,#b001,#2020,#0000,#1080
	dw #b081,#b001,#2020,#0000,#1000
	
	dw #b081,#b001,#2020,#0000,#1040
	dw #b081,#b001,#2020,#0000,#1000
	dw #b081,#b001,#2020,#0000,#1080
	dw #b081,#b001,#2020,#0000,#1040
	
	dw #b081,#b001,#2020,#0000,#1040
	dw #b081,#b001,#2020,#0000,#1000
	dw #b081,#b001,#2020,#0000,#1080
	dw #b081,#b001,#2020,#0000,#1040
	
	dw #b081,#b001,#2020,#0000,#1040
	dw #b081,#b001,#2020,#0000,#1000
	dw #b081,#b001,#2020,#0000,#1080
	dw #b081,#b001,#2020,#0000,#0840
	dw #b081,#b001,#2020,#0000,#0840
	
	dw #b000,fxtab4,#a800,c1,c1+1,#4040,#00ce,#00ce,#0800,#b004,noise,g3,#4020,#0000,#1040
	dw #b081,#b001,#2020,#0000,#1000
	dw #b081,#b001,#2020,#0000,#1080
	dw #b081,#b001,#2020,#0000,#1000
	
	dw #b081,#b001,#2020,#0000,#1040
	dw #b081,#b001,#2020,#0000,#1000
	dw #b081,#b001,#2020,#0000,#1080
	dw #b081,#b001,#2020,#0000,#1040
	
	dw #b081,#b001,#2020,#0000,#1040
	dw #b081,#b001,#2020,#0000,#1000
	dw #b081,#b001,#2020,#0000,#1080
	dw #b081,#b001,#2020,#0000,#1040
	
	dw #b081,#b001,#2020,#0000,#1040
	dw #b081,#b001,#2020,#0000,#1000
	dw #b081,#b001,#2020,#0000,#1080
	dw #b081,#b001,#2020,#0000,#1080
	
	dw #b000,fxtab4,#a800,c1,c1+15,#4020,#00c6,#00c6,#4800,#b004,noise,g3,#4020,#0000,#1040
	dw #b081,#b001,#2020,#0000,#1000
	dw #b081,#b001,#2020,#0000,#1080
	dw #b081,#b001,#2020,#0000,#1000
	
	dw #b081,#b001,#2020,#0000,#1040
	dw #b081,#b001,#2020,#0000,#1000
	dw #b081,#b001,#2020,#0000,#1080
	dw #b081,#b001,#2020,#0000,#1040
	
	dw #b081,#b001,#2020,#0000,#1040
	dw #b081,#b001,#2020,#0000,#1000
	dw #b081,#b001,#2020,#0000,#1080
	dw #b081,#b001,#2020,#0000,#1040
	
	dw #b081,#b001,#2020,#0000,#1040
	dw #b081,#b001,#2020,#0000,#1000
	dw #b081,#b001,#2020,#0000,#1080
	dw #b081,#b001,#2020,#0000,#0440
	dw #b081,#b001,#2020,#0000,#0440
	dw #b081,#b001,#2020,#0000,#0440
	dw #b081,#b001,#2020,#0000,#0440
	
	db #40


fxtab1
	db #40
	
; fxtab2
; 	dw #0004,#0004,#0004,#0040
; 	
; fxtab3
; 	dw #0004,#0004,#0004,#0001,fxtab3
	
fxtab4
	dw #0004
	dw #b080,#b084,noise,c4,#3d20
	dw #0004
	dw #b080,#b084,noise,dis4,#3a20
	dw #0004
	dw #b080,#b084,noise,g3,#3720
	
	dw #0004
	dw #b080,#b084,noise,c4,#3420
	dw #0004
	dw #b080,#b084,noise,dis4,#3120
	dw #0004
	dw #b080,#b084,noise,g3,#2e20
	
	dw #0004
	dw #b080,#b084,noise,c4,#2b20
	dw #0004
	dw #b080,#b084,noise,dis4,#2820
	dw #0004
	dw #b080,#b084,noise,g3,#2520
	
	dw #0004
	dw #b080,#b084,noise,c4,#2220
	dw #0004
	dw #b080,#b084,noise,dis4,#1f20
	dw #0004
	dw #b080,#b084,noise,g3,#1c20
	
	dw #0004
	dw #b080,#b084,noise,c4,#1920
	dw #0004
	dw #b080,#b084,noise,dis4,#1620
	dw #0004
	dw #b080,#b084,noise,g3,#1320
	
	dw #0004
	dw #b080,#b084,noise,c4,#1020
	dw #0004
	dw #b080,#b084,noise,dis4,#0d20
	dw #0004
	dw #b080,#b084,noise,g3,#0a20
	
	dw #0004
	dw #b080,#b084,noise,c4,#0720
	dw #0004
	dw #b080,#b084,noise,dis4,#0420
	dw #0004
	dw #b080,#b084,noise,g3,#0120
	
fxtab4a	
	dw #0004
	dw #b080,#b0c0,0,c4
	dw #0004
	dw #b080,#b0c0,0,dis4
	dw #0004
	dw #b080,#b0c0,0,g3
	dw #0001,fxtab4a
	

		

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

	savebin "phase_sqeek01.tap",tap_b,tap_e-tap_b


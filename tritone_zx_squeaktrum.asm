 device zxspectrum128

	org $6500-13				; Origin
tap_b:	db $22,"NONAME",$22			;name		  	HEADER
	db "M"					;type		  	HEADER
	dw end-begin				;program length	  	HEADER
	dw begin				;load point		HEADER
	org $6500
begin:; ZX squeaktrumasm
;
;Tritone v2 beeper music engine by Shiru (shiru@mailru) 03'11
;Three channels of tone, per-pattern tempo
;One channel of interrupting drums
;Feel free to do whatever you want with the code, it is PD
;
;
; TRITONE Engine
; Song :JOURNEY (found within Z88DK Tritone examples)
; VZ conversion: Sep 19
;
; Assemble with PASMO
;
; 	pasmo --alocal %1asm
; 	rbinary %1obj %1vz


OP_NOP	equ $00
OP_SCF	equ $37
OP_ORC	equ $b1



	ld hl,MUSICDATA
	call play
	jp begin


NO_VOLUME equ 0			;define this if you want to have the same volume for all the channels

play
	di
	ld (nppos),hl
	ld c,33
	push iy
	exx
	push hl
	ld (prevSP),sp
	xor a
	ld h,a
	ld l,h
	ld (cnt0),hl
	ld (cnt1),hl
	ld (cnt2),hl
	ld (duty0),a
	ld (duty1),a
	ld (duty2),a
	ld (skipDrum),a
;	in a,($1f)
;;	and $1f
;	ld a,OP_NOP
;	jr nz,$+4
;	ld a,OP_ORC
;	ld (checkKempston),a
	jp nextPos

nextRow
nrpos equ $+1
	ld hl,0
	ld a,(hl)
	inc hl
	cp 2
	jr c,ch0
	cp 128
	jr c,drumSound
	cp 255
	jp z,nextPos

ch0
	ld d,1
	cp d
	jr z,ch1
	or a
	jr nz,ch0note
	ld b,a
	ld c,a
	jr ch0set
ch0note
	ld e,a
	and $0f
	ld b,a
	ld c,(hl)
	inc hl
	ld a,e
	and $f0
ch0set
	ld (duty0),a
	ld (cnt0),bc
ch1
	ld a,(hl)
	inc hl
	cp d
	jr z,ch2
	or a
	jr nz,ch1note
	ld b,a
	ld c,a
	jr ch1set
ch1note
	ld e,a
	and $0f
	ld b,a
	ld c,(hl)
	inc hl
	ld a,e
	and $f0
ch1set
	ld (duty1),a
	ld (cnt1),bc
ch2
	ld a,(hl)
	inc hl
	cp d
	jr z,skip
	or a
	jr nz,ch2note
	ld b,a
	ld c,a
	jr ch2set
ch2note
	ld e,a
	and $0f
	ld b,a
	ld c,(hl)
	inc hl
	ld a,e
	and $f0
ch2set
	ld (duty2),a
	ld (cnt2),bc

skip
	ld (nrpos),hl
skipDrum equ $
	scf
	jp nc,playRow
	ld a,OP_NOP
	ld (skipDrum),a

	ld hl,(speed)
	ld de,-150
	add hl,de
	ex de,hl
	jr c,$+5
	ld de,257
	ld a,d
	or a
	jr nz,$+3
	inc d
	ld a,e
	or a
	jr nz,$+3
	inc e
	jp drum

drumSound
	ld (nrpos),hl

	add a,a
	ld ixl,a
	ld ixh,0
	ld bc,drumSettings-4
	add ix,bc
	cp 14*2
	ld a,OP_SCF
	ld (skipDrum),a
	jr nc,drumNoise

drumTone
	ld bc,2
	ld a,b
	ld de,$1001	; DJM
	ld l,(ix)
l01
	bit 0,b
	jr z,l11
	dec e
	jr nz,l11
	ld e,l
	exa
	ld a,l
	add a,(ix+1)
	ld l,a
;	exa
	ex af,af'
	xor d
l11
	out ($84), a
	djnz l01
	dec c
	jr nz,l01

	jp nextRow

drumNoise
	ld b,0
	ld h,b
	ld l,h
	ld de,$1001	; DJM
l02
	ld a,(hl)
	and d
	out ($84), a
	and (ix)
	dec e
	out ($84), a
	jr nz,l12
	ld e,(ix+1)
	inc hl
l12
	djnz l02

	jp nextRow

nextPos
nppos equ $+1
	ld hl,0
read
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld a,d
	or e
	jr z,orderLoop
	ld (nppos),hl
	ex de,hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	ld (nrpos),hl
	ld (speed),bc
	jp nextRow

orderLoop
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	jr read

playRow
speed equ $+1
	ld de,0
drum
cnt0 equ $+1
	ld bc,0
prevHL equ $+1
	ld hl,0
	exx
cnt1 equ $+1
	ld de,0
cnt2 equ $+1
	ld sp,0
	exx


soundLoop
	if NO_VOLUME = 1		;all the channels has the same volume
	
	add hl,bc	;11
	ld a,h		;4
duty0 equ $+1
	cp 128		;7
	sbc a,a		;4
	exx			;4
	and c		;4
	out ($84), a	;11
	add ix,de	;15
	ld a,ixh	;8
duty1 equ $+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	out ($84), a	;11
	add hl,sp	;11
	ld a,h		;4
duty2 equ $+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	exx			;4
	dec e		;4
	out ($84), a	;11
	jr nz,soundLoop	;10=153t
	dec d		;4
	jr nz,soundLoop	;10
	
	else				; all the channels has different volume

	add hl,bc	;11
	ld a,h		;4
	exx			;4
duty0 equ $+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	add ix,de	;15
	out ($84), a	;11
	ld a,ixh	;8
duty1 equ $+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	out ($84), a	;11
	add hl,sp	;11
	ld a,h		;4
duty2 equ $+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	exx			;4
	dec e		;4
	out ($84), a	;11
	jr nz,soundLoop	;10=153t
	dec d		;4
	jr nz,soundLoop	;10
	
	endif
	

;	xor a
;	out ($84), a

	ld (prevHL),hl

;	in a,($1f)
;	and $1f
;	ld c,a
;	in a,($fe)
;	cpl
;checkKempston equ $
;	or c
;	and $1f
;	jp z,nextRow
	jp nextRow

stopPlayer
prevSP equ $+1
	ld sp,0
	pop hl
	exx
	pop iy
	ei
	ret

drumSettings
	db $01,$01	;tone,highest
	db $01,$02
	db $01,$04
	db $01,$08
	db $01,$20
	db $20,$04
	db $40,$04
	db $40,$08	;lowest
	db $04,$80	;special
	db $08,$80
	db $10,$80
	db $10,$02
	db $20,$02
	db $40,$02
	db $16,$01	;noise,highest
	db $16,$02
	db $16,$04
	db $16,$08
	db $16,$10
	db $00,$01
	db $00,$02
	db $00,$04
	db $00,$08
	db $00,$10


; ************************************************************************
; * Song data...
; ************************************************************************
BORDER_CLR:          EQU $0


MUSICDATA:

; *** Song layout ***
LOOPSTART:            DEFW      PAT0
                      DEFW      PAT1
                      DEFW      PAT2
                      DEFW      PAT3
                      DEFW      PAT8
                      DEFW      PAT5
                      DEFW      PAT6
                      DEFW      PAT7
                      DEFW      PAT4
                      DEFW      PAT9
                      DEFW      PAT10
                      DEFW      PAT11
                      DEFW      PAT12
                      DEFW      PAT13
                      DEFW      PAT14
                      DEFW      PAT15
                      DEFW      PAT16
                      DEFW      PAT17
                      DEFW      PAT18
                      DEFW      PAT19
                      DEFW      PAT20
                      DEFW      PAT21
                      DEFW      PAT22
                      DEFW      PAT23
                      DEFW      $0000
                      DEFW      LOOPSTART

; *** Patterns ***
PAT0:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $FB,$B6,$C0,$9D,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $FB,$0D,$C0,$9D,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $F7,$60,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$00
                DEFB      $F9,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$60,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$B6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$60,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F9,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$60,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$B6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F9,$D9,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $F8,$C6,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT1:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $FB,$B6,$C0,$9D,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $FB,$0D,$C0,$9D,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $F7,$60,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F9,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$60,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$B6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$60,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F9,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$60,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$B6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FD,$25,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$B6,$C0,$B0,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $FB,$0D,$C0,$B0,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT2:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $FB,$B6,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $FB,$0D,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $F7,$D0,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F9,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$D0,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$B6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$D0,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F9,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$D0,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$B6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F9,$D9,$C0,$B0,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT3:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $FB,$B6,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $FB,$0D,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $F7,$D0,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F9,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$D0,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FD,$25,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$B6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$D0,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F9,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$D0,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FE,$C1,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FD,$25,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$B6,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT4:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $8B,$B6,$C0,$9D,$84,$E7
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$9D,$94,$E7
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$87,$60,$00    ,$A4,$E7
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$9D,$B4,$E7
                DEFB      $00    ,$00    ,$01
                DEFB      $89,$D9,$C0,$9D,$C4,$E7
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$B4,$E7
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$C0,$9D,$A4,$E7
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$9D,$94,$E7
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$9D,$84,$E7
                DEFB      $00    ,$00    ,$01
                DEFB  $06,$89,$D9,$C0,$9D,$85,$86
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$85,$DB
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$B6,$C0,$9D,$86,$92
                DEFB      $00    ,$00    ,$01
                DEFB      $8D,$25,$C0,$9D,$85,$DB
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$00    ,$85,$86
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$8C,$84,$63
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT5:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $FB,$B6,$C0,$9D,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $FB,$0D,$C0,$9D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$60,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F9,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$60,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$B6,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FD,$25,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$60,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$C0,$9D,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $F9,$D9,$C0,$B0,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $F7,$60,$C0,$BB,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $FB,$B6,$C0,$D2,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FD,$25,$C0,$BB,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$B6,$C0,$B0,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT6:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $FB,$B6,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $FB,$0D,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F8,$C6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F9,$D9,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F8,$C6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$B6,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $FB,$0D,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$60,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F9,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$60,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F9,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$B6,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT7:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $FB,$B6,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $FB,$0D,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F8,$C6,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $F9,$D9,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$D0,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$B6,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F8,$C6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F9,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$60,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F9,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$FB,$B6,$C0,$B0,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT8:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $FB,$B6,$80,$9D,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $FB,$0D,$80,$9D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$60,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F9,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$60,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$B6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$60,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F9,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F7,$60,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$B6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $FB,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $F9,$D9,$80,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $F8,$C6,$80,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT9:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $8B,$B6,$C0,$9D,$84,$E7
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$9D,$94,$E7
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$87,$60,$00    ,$A4,$E7
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$9D,$B4,$E7
                DEFB      $00    ,$00    ,$01
                DEFB      $89,$D9,$C0,$9D,$C4,$E7
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$B4,$E7
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$C0,$9D,$00
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$9D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$85,$DB
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$9D,$01
                DEFB      $00    ,$00    ,$01
                DEFB  $06,$89,$D9,$C0,$9D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$85,$86
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$B6,$C0,$9D,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $87,$60,$C0,$9D,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$0D,$00    ,$83,$B0
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$87,$60,$C0,$B0,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT10:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $8B,$B6,$C0,$8C,$84,$63
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$8C,$94,$63
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$88,$C6,$00    ,$A4,$63
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$8C,$B4,$63
                DEFB      $00    ,$00    ,$01
                DEFB      $89,$D9,$C0,$8C,$C4,$63
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$C0,$8C,$D4,$63
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$C0,$8C,$E4,$63
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$8C,$F4,$63
                DEFB      $00    ,$01    ,$01
                DEFB      $88,$C6,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB  $06,$89,$D9,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$D0,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$B6,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$89,$D9,$00    ,$00
                DEFB      $00    ,$01    ,$01
                DEFB      $88,$C6,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT11:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $8B,$B6,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$88,$C6,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $89,$D9,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $88,$C6,$00    ,$85,$DB
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB  $06,$89,$D9,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$D0,$00    ,$86,$92
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB  $06,$8D,$25,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$00    ,$85,$86
                DEFB  $06,$00    ,$01    ,$01
                DEFB  $06,$8B,$0D,$C0,$B0,$01
                DEFB  $06,$00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT12:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $8B,$B6,$C0,$9D,$85,$DB
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$9D,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$87,$60,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$9D,$84,$E7
                DEFB      $00    ,$00    ,$01
                DEFB      $89,$D9,$C0,$9D,$94,$E7
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$A4,$E7
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$C0,$9D,$B4,$E7
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$9D,$C4,$E7
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$00
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$9D,$84,$E7
                DEFB      $00    ,$00    ,$01
                DEFB  $06,$89,$D9,$C0,$9D,$85,$86
                DEFB      $00    ,$01    ,$01
                DEFB      $88,$C6,$00    ,$85,$DB
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$B6,$C0,$9D,$87,$60
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$9D,$86,$92
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$89,$D9,$00    ,$85,$DB
                DEFB      $00    ,$01    ,$01
                DEFB      $88,$C6,$C0,$8C,$85,$86
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT13:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $8B,$B6,$C0,$9D,$84,$E7
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$9D,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$87,$60,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$9D,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $89,$D9,$C0,$9D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$C0,$9D,$00
                DEFB      $00    ,$00    ,$01
                DEFB      $8D,$25,$C0,$9D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$85,$DB
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$9D,$01
                DEFB      $00    ,$00    ,$01
                DEFB  $06,$89,$D9,$C0,$9D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$86,$92
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$B6,$C0,$9D,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$9D,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$87,$60,$00    ,$87,$60
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$0D,$C0,$B0,$01
                DEFB  $06,$00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT14:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $8B,$B6,$C0,$8C,$88,$C6
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$88,$C6,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$B6,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$8C,$98,$C6
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$A8,$C6
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$C0,$8C,$B8,$C6
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$8C,$C8,$C6
                DEFB      $00    ,$01    ,$01
                DEFB      $88,$C6,$00    ,$D8,$C6
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$B6,$C0,$8C,$E8,$C6
                DEFB      $00    ,$00    ,$01
                DEFB  $06,$8B,$0D,$C0,$8C,$F8,$C6
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$B6,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$88,$C6,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$0D,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT15:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $8B,$B6,$C0,$8C,$00
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$88,$C6,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$B6,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $88,$C6,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$B6,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB  $06,$8B,$0D,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$89,$D9,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $88,$C6,$C0,$76,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT16:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $8B,$B6,$C0,$7D,$85,$DB
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$87,$D0,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$7D,$83,$E8
                DEFB      $00    ,$00    ,$01
                DEFB      $89,$D9,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$D0,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$C0,$7D,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$D0,$00    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$7D,$01
                DEFB      $00    ,$00    ,$01
                DEFB  $06,$89,$D9,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$D0,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$B6,$C0,$7D,$86,$92
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$89,$D9,$00    ,$85,$86
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$76,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT17:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $8B,$B6,$C0,$7D,$85,$DB
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$87,$D0,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$7D,$83,$E8
                DEFB      $00    ,$00    ,$01
                DEFB      $89,$D9,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$01
                DEFB      $00    ,$01    ,$00
                DEFB  $06,$8B,$B6,$C0,$7D,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$D0,$00    ,$85,$DB
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$7D,$01
                DEFB      $00    ,$00    ,$01
                DEFB  $06,$89,$D9,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$86,$92
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$B6,$C0,$7D,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $87,$D0,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$0D,$00    ,$87,$60
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT18:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $8B,$B6,$C0,$9D,$89,$D9
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$9D,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$87,$60,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$9D,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $89,$D9,$C0,$9D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$C0,$9D,$01
                DEFB      $00    ,$00    ,$89,$C5
                DEFB      $8B,$0D,$C0,$9D,$89,$ED
                DEFB      $00    ,$01    ,$89,$C5
                DEFB      $87,$60,$00    ,$89,$ED
                DEFB      $00    ,$01    ,$89,$BB
                DEFB      $8B,$0D,$C0,$9D,$89,$F7
                DEFB      $00    ,$00    ,$89,$BB
                DEFB  $06,$89,$D9,$C0,$9D,$89,$F7
                DEFB      $00    ,$01    ,$89,$BB
                DEFB      $87,$60,$00    ,$89,$F7
                DEFB      $00    ,$01    ,$89,$BB
                DEFB      $8B,$B6,$C0,$9D,$89,$F7
                DEFB      $00    ,$00    ,$89,$BB
                DEFB      $87,$60,$C0,$9D,$00
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$88,$C6,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT19:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $8B,$B6,$C0,$9D,$00
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$9D,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$87,$60,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$9D,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $89,$D9,$C0,$9D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$C0,$9D,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$9D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $88,$C6,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$9D,$01
                DEFB      $00    ,$00    ,$01
                DEFB  $06,$89,$D9,$C0,$8C,$85,$DB
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$B6,$C0,$8C,$86,$92
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$88,$C6,$00    ,$87,$60
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$87,$60,$C0,$8C,$01
                DEFB  $06,$00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT20:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $8B,$B6,$C0,$7D,$85,$DB
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$87,$D0,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$7D,$83,$E8
                DEFB      $00    ,$00    ,$01
                DEFB      $89,$D9,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$D0,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$C0,$7D,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$D0,$00    ,$00
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$7D,$01
                DEFB      $00    ,$00    ,$01
                DEFB  $06,$89,$D9,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$D0,$C0,$7D,$87,$60
                DEFB      $00    ,$00    ,$01
                DEFB      $88,$C6,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$89,$D9,$00    ,$86,$92
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$0D,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT21:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $8B,$B6,$C0,$7D,$85,$DB
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$87,$D0,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$7D,$83,$E8
                DEFB      $00    ,$00    ,$01
                DEFB      $89,$D9,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$C0,$7D,$00
                DEFB      $01    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$D0,$00    ,$85,$DB
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$7D,$01
                DEFB      $00    ,$00    ,$01
                DEFB  $06,$89,$D9,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$85,$86
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$B6,$C0,$7D,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $8D,$25,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$00    ,$83,$B0
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$76,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT22:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB      $8B,$B6,$C0,$8C,$84,$63
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$88,$C6,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$8C,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $89,$D9,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$D0,$00    ,$94,$63
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$C0,$8C,$A4,$63
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$8C,$B4,$63
                DEFB      $00    ,$01    ,$01
                DEFB      $88,$C6,$00    ,$C4,$63
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$0D,$C0,$8C,$D4,$63
                DEFB      $00    ,$00    ,$01
                DEFB  $06,$89,$D9,$C0,$8C,$E4,$63
                DEFB      $00    ,$01    ,$01
                DEFB      $87,$60,$00    ,$F4,$63
                DEFB      $00    ,$01    ,$01
                DEFB      $8B,$B6,$C0,$8C,$00
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$8C,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$00    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $8D,$25,$C0,$7D,$01
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT23:
                DEFW  2464     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $06,$8B,$B6,$C0,$8C,$85,$DB
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$8C,$85,$86
                DEFB      $00    ,$01    ,$00
                DEFB  $06,$88,$C6,$00    ,$84,$63
                DEFB      $00    ,$01    ,$00
                DEFB      $8D,$25,$C0,$8C,$86,$92
                DEFB      $00    ,$00    ,$00
                DEFB  $06,$8B,$B6,$C0,$8C,$85,$DB
                DEFB      $00    ,$01    ,$00
                DEFB      $87,$60,$00    ,$84,$63
                DEFB      $00    ,$01    ,$00
                DEFB  $06,$8B,$B6,$C0,$8C,$85,$DB
                DEFB      $00    ,$00    ,$01
                DEFB      $8B,$0D,$C0,$8C,$85,$86
                DEFB      $00    ,$01    ,$00
                DEFB  $06,$87,$60,$00    ,$88,$C6
                DEFB      $00    ,$01    ,$00
                DEFB  $06,$8D,$25,$C0,$8C,$86,$92
                DEFB      $00    ,$00    ,$00
                DEFB  $06,$8B,$B6,$C0,$8C,$85,$DB
                DEFB      $00    ,$01    ,$00
                DEFB  $06,$87,$60,$00    ,$83,$B0
                DEFB      $00    ,$01    ,$00
                DEFB  $06,$8E,$C1,$C0,$76,$87,$60
                DEFB      $00    ,$00    ,$01
                DEFB  $06,$8D,$25,$C0,$76,$86,$92
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$B6,$00    ,$85,$DB
                DEFB      $00    ,$01    ,$01
                DEFB  $06,$8B,$0D,$C0,$76,$85,$86
                DEFB      $00    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

end
    LUA
    local checksum
    checksum=0
    for i=sj.get_label("begin"),sj.get_label("end") do
    checksum=checksum+sj.get_byte( i )
    end
--	print("cs:",string.format("%08X",checksum))
	sj.insert_label("CSU", checksum%256)
    ENDLUA

checkd: db CSU,CSU ;checksum LSB two times
	dw begin
	db begin/256
tap_e:	savebin "tritone_zx_squeaktrum.tap",tap_b,tap_e-tap_b


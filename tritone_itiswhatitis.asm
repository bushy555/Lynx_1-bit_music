 device zxspectrum128

	org $6500-13				; Origin
tap_b:	db $22,"NONAME",$22			;name		  	HEADER
	db "M"					;type		  	HEADER
	dw end-begin				;program length	  	HEADER
	dw begin				;load point		HEADER
	org $6500




	;Tritone v2 beeper music engine by Shiru (shiru@mail.ru) 03'11
;Three channels of tone, per-pattern tempo
;One channel of interrupting drums
;Feel free to do whatever you want with the code, it is PD


OP_NOP	equ $00
OP_SCF	equ $37
OP_ORC	equ $b1



begin
	ld hl,musicData
	call play
	jp begin


NO_VOLUME equ 0			;define this if you want to have the same volume for all the channels

play
	di
	ld (nextPos.pos),hl
	ld c,16
	push iy
	exx
	push hl
	ld (stopPlayer.prevSP),sp
	xor a
	ld h,a
	ld l,h
	ld (playRow.cnt0),hl
	ld (playRow.cnt1),hl
	ld (playRow.cnt2),hl
	ld (soundLoop.duty0),a
	ld (soundLoop.duty1),a
	ld (soundLoop.duty2),a
	ld (nextRow.skipDrum),a
;	in a,(#1f)
;	and #1f
;	ld a,OP_NOP
;	jr nz,$+4
;	ld a,OP_ORC
;	ld (soundLoop.checkKempston),a
	jp nextPos

nextRow
.pos=$+1
	ld hl,0
	ld a,(hl)
	inc hl
	cp 2
	jr c,.ch0
	cp 128
	jr c,drumSound
	cp 255
	jp z,nextPos

.ch0
	ld d,1
	cp d
	jr z,.ch1
	or a
	jr nz,.ch0note
	ld b,a
	ld c,a
	jr .ch0set
.ch0note
	ld e,a
	and #0f
	ld b,a
	ld c,(hl)
	inc hl
	ld a,e
	and #f0
.ch0set
	ld (soundLoop.duty0),a
	ld (playRow.cnt0),bc
.ch1
	ld a,(hl)
	inc hl
	cp d
	jr z,.ch2
	or a
	jr nz,.ch1note
	ld b,a
	ld c,a
	jr .ch1set
.ch1note
	ld e,a
	and #0f
	ld b,a
	ld c,(hl)
	inc hl
	ld a,e
	and #f0
.ch1set
	ld (soundLoop.duty1),a
	ld (playRow.cnt1),bc
.ch2
	ld a,(hl)
	inc hl
	cp d
	jr z,.skip
	or a
	jr nz,.ch2note
	ld b,a
	ld c,a
	jr .ch2set
.ch2note
	ld e,a
	and #0f
	ld b,a
	ld c,(hl)
	inc hl
	ld a,e
	and #f0
.ch2set
	ld (soundLoop.duty2),a
	ld (playRow.cnt2),bc

.skip
	ld (.pos),hl
.skipDrum=$
	scf
	jp nc,playRow
	ld a,OP_NOP
	ld (.skipDrum),a

	ld hl,(playRow.speed)
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
	jr playRow.drum

drumSound
	ld (nextRow.pos),hl

	add a,a
	ld ixl,a
	ld ixh,0
	ld bc,drumSettings-4
	add ix,bc
	cp 14*2
	ld a,OP_SCF
	ld (nextRow.skipDrum),a
	jr nc,drumNoise

drumTone
	ld bc,2
	ld a,b
	ld de,#1001
	ld l,(ix)
.l0
	bit 0,b
	jr z,.l1
	dec e
	jr nz,.l1
	ld e,l
	exa
	ld a,l
	add a,(ix+1)
	ld l,a
	exa
	xor d
.l1
	out (#84),a
	djnz .l0
	dec c
	jp nz,.l0

	jp nextRow

drumNoise
	ld b,0
	ld h,b
	ld l,h
	ld de,#1001
.l0
	ld a,(hl)
	and d
	out (#84),a
	and (ix)
	dec e
	out (#84),a
	jr nz,.l1
	ld e,(ix+1)
	inc hl
.l1
	djnz .l0

	jp nextRow

nextPos
.pos=$+1
	ld hl,0
.read
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld a,d
	or e
	jr z,orderLoop
	ld (.pos),hl
	ex de,hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	ld (nextRow.pos),hl
	ld (playRow.speed),bc
	jp nextRow

orderLoop
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	jr nextPos.read

playRow
.speed=$+1
	ld de,0
.drum
.cnt0=$+1
	ld bc,0
.prevHL=$+1
	ld hl,0
	exx
.cnt1=$+1
	ld de,0
.cnt2=$+1
	ld sp,0
	exx

soundLoop



	add hl,bc	;11
	ld a,h		;4
	exx			;4
.duty0=$+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	add ix,de	;15
	out (#84),a	;11
	ld a,ixh	;8
.duty1=$+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	out (#84),a	;11
	add hl,sp	;11
	ld a,h		;4
.duty2=$+1
	cp 128		;7
	sbc a,a		;4
	and c		;4
	exx			;4
	dec e		;4
	out (#84),a	;11
	jp nz,soundLoop	;10=153t
	dec d		;4
	jp nz,soundLoop	;10
	


	ld (playRow.prevHL),hl

;	in a,(#1f)
;	and #1f
;	ld c,a
;	in a,(#fe)
;	cpl
;.checkKempston=$
;	or c
;	and #1f
;	jp z,nextRow

	jp nextRow

stopPlayer
.prevSP=$+1
	ld sp,0
	pop hl
	exx
	pop iy
	ei
	ret



drumSettings:
                DEFB  $01,$01     ; 1: Tone, Highest
                DEFB  $01,$02
                DEFB  $01,$04
                DEFB  $01,$08
                DEFB  $01,$20
                DEFB  $20,$04
                DEFB  $40,$04
                DEFB  $40,$08     ; 8: Lowest
                DEFB  $04,$80     ; 9: Special
                DEFB  $08,$80
                DEFB  $10,$80
                DEFB  $10,$02
                DEFB  $20,$02
                DEFB  $40,$02
                DEFB  $16,$01     ; 15: Noise, Highest
                DEFB  $16,$02
                DEFB  $16,$04
                DEFB  $16,$08
                DEFB  $16,$10
                DEFB  $00,$01
                DEFB  $00,$02
                DEFB  $00,$04
                DEFB  $00,$08
                DEFB  $00,$10     ; 24: Last drum

; ************************************************************************
; * Song data...
; ************************************************************************
BORDER_CLR:          EQU $0

; *** DATA ***
musicData:

; *** Song layout ***
LOOPSTART:            DEFW      PAT4
                      DEFW      PAT5
                      DEFW      PAT4
                      DEFW      PAT6
                      DEFW      PAT1
                      DEFW      PAT3
                      DEFW      PAT8
                      DEFW      PAT3
                      DEFW      PAT1
                      DEFW      PAT3
                      DEFW      PAT8
                      DEFW      PAT3
                      DEFW      PAT20
                      DEFW      PAT7
                      DEFW      PAT20
                      DEFW      PAT2
                      DEFW      PAT11
                      DEFW      PAT12
                      DEFW      PAT11
                      DEFW      PAT13
                      DEFW      PAT11
                      DEFW      PAT12
                      DEFW      PAT11
                      DEFW      PAT17
                      DEFW      PAT14
                      DEFW      PAT15
                      DEFW      PAT14
                      DEFW      PAT16
                      DEFW      PAT14
                      DEFW      PAT15
                      DEFW      PAT14
                      DEFW      PAT16
                      DEFW      PAT20
                      DEFW      PAT2
                      DEFW      PAT20
                      DEFW      PAT2
                      DEFW      PAT11
                      DEFW      PAT12
                      DEFW      PAT11
                      DEFW      PAT13
                      DEFW      PAT11
                      DEFW      PAT12
                      DEFW      PAT11
                      DEFW      PAT13
                      DEFW      PAT1
                      DEFW      PAT3
                      DEFW      PAT8
                      DEFW      PAT3
                      DEFW      PAT1
                      DEFW      PAT3
                      DEFW      PAT8
                      DEFW      PAT3
                      DEFW      PAT1
                      DEFW      PAT3
                      DEFW      PAT8
                      DEFW      PAT3
                      DEFW      PAT20
                      DEFW      PAT7
                      DEFW      PAT20
                      DEFW      PAT18
                      DEFW      PAT4
                      DEFW      PAT5
                      DEFW      PAT4
                      DEFW      PAT19
                      DEFW      $0000
                      DEFW      LOOPSTART

; *** Patterns ***
PAT1:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $15,$01    ,$82,$ED,$82,$76
                DEFB      $01    ,$82,$ED,$81,$A4
                DEFB      $01    ,$92,$ED,$80,$FA
                DEFB      $01    ,$93,$49,$80,$BB
                DEFB      $01    ,$A3,$49,$90,$D2
                DEFB      $01    ,$A3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$C3,$49,$01
                DEFB      $01    ,$C3,$49,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB      $01    ,$D3,$49,$00
                DEFB  $15,$86,$92,$E3,$50,$90,$D2
                DEFB      $87,$D0,$E3,$57,$01
                DEFB      $89,$D9,$F3,$50,$01
                DEFB      $86,$92,$F3,$49,$01
                DEFB      $87,$D0,$E3,$42,$01
                DEFB      $89,$D9,$E3,$3B,$01
                DEFB      $00    ,$D3,$42,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB  $15,$01    ,$C3,$50,$91,$A4
                DEFB      $01    ,$C3,$57,$01
                DEFB      $01    ,$B3,$50,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB  $09,$01    ,$A3,$42,$83,$49
                DEFB      $01    ,$A3,$3B,$81,$F4
                DEFB      $01    ,$93,$42,$81,$76
                DEFB      $01    ,$93,$49,$81,$3B
                DEFB      $01    ,$83,$50,$00
                DEFB      $01    ,$83,$57,$01
                DEFB      $01    ,$93,$50,$01
                DEFB      $01    ,$93,$49,$01
                DEFB  $15,$01    ,$A3,$42,$90,$D2
                DEFB      $01    ,$A3,$3B,$01
                DEFB      $01    ,$B3,$42,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB  $15,$86,$92,$C3,$50,$91,$A4
                DEFB      $87,$D0,$C3,$57,$01
                DEFB      $89,$D9,$D3,$50,$01
                DEFB      $86,$92,$D3,$49,$01
                DEFB      $87,$D0,$E3,$42,$01
                DEFB      $89,$D9,$E3,$3B,$01
                DEFB      $00    ,$F3,$42,$01
                DEFB      $01    ,$F3,$49,$01
                DEFB  $15,$01    ,$E3,$50,$90,$D2
                DEFB      $01    ,$E3,$57,$01
                DEFB      $01    ,$D3,$50,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB  $15,$01    ,$C3,$42,$82,$76
                DEFB      $01    ,$C3,$3B,$81,$A4
                DEFB      $01    ,$B3,$42,$80,$FA
                DEFB      $01    ,$B3,$49,$80,$BB
                DEFB      $01    ,$A3,$50,$90,$8C
                DEFB      $01    ,$A3,$57,$01
                DEFB      $01    ,$93,$50,$01
                DEFB      $01    ,$93,$49,$01
                DEFB      $01    ,$83,$42,$90,$FA
                DEFB      $01    ,$83,$3B,$01
                DEFB      $01    ,$93,$42,$01
                DEFB      $01    ,$93,$49,$01
                DEFB  $15,$86,$92,$A3,$50,$82,$76
                DEFB      $88,$C6,$A3,$57,$81,$A4
                DEFB      $8B,$0D,$B3,$50,$80,$FA
                DEFB      $86,$92,$B3,$49,$80,$BB
                DEFB      $88,$C6,$C3,$42,$91,$08
                DEFB      $8B,$0D,$C3,$3B,$01
                DEFB      $00    ,$D3,$42,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB  $15,$01    ,$E3,$50,$91,$18
                DEFB      $01    ,$E3,$57,$01
                DEFB      $01    ,$F3,$50,$01
                DEFB      $01    ,$F3,$49,$01
                DEFB  $09,$01    ,$E3,$42,$83,$49
                DEFB      $01    ,$E3,$3B,$81,$F4
                DEFB      $01    ,$D3,$42,$81,$76
                DEFB      $01    ,$D3,$49,$81,$3B
                DEFB      $01    ,$C3,$50,$00
                DEFB      $01    ,$C3,$57,$01
                DEFB      $01    ,$B3,$50,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB  $15,$01    ,$A3,$42,$90,$8C
                DEFB      $01    ,$A3,$3B,$01
                DEFB      $01    ,$93,$42,$01
                DEFB      $01    ,$93,$49,$01
                DEFB  $15,$86,$92,$83,$50,$91,$18
                DEFB      $88,$C6,$83,$57,$01
                DEFB      $8B,$0D,$93,$50,$01
                DEFB      $86,$92,$93,$49,$01
                DEFB      $88,$C6,$A3,$42,$01
                DEFB      $8B,$0D,$A3,$3B,$01
                DEFB      $00    ,$B3,$42,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB  $15,$01    ,$C3,$50,$90,$FA
                DEFB      $01    ,$C3,$57,$01
                DEFB      $01    ,$D3,$50,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $FF  ; End of Pattern

PAT2:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $15,$01    ,$83,$42,$82,$76
                DEFB      $01    ,$83,$3B,$81,$A4
                DEFB      $01    ,$93,$42,$80,$FA
                DEFB      $01    ,$93,$49,$80,$BB
                DEFB      $01    ,$A3,$50,$90,$BB
                DEFB      $01    ,$A3,$57,$01
                DEFB      $01    ,$B3,$50,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$C3,$42,$01
                DEFB      $01    ,$C3,$3B,$01
                DEFB      $01    ,$D3,$42,$01
                DEFB      $01    ,$D3,$49,$00
                DEFB  $15,$85,$DB,$E3,$50,$90,$BB
                DEFB      $87,$60,$E3,$57,$01
                DEFB      $88,$C6,$F3,$50,$01
                DEFB      $85,$DB,$F3,$49,$01
                DEFB      $87,$60,$E3,$42,$01
                DEFB      $88,$C6,$E3,$3B,$01
                DEFB      $00    ,$D3,$42,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB  $15,$01    ,$C3,$50,$91,$76
                DEFB      $01    ,$C3,$57,$01
                DEFB      $01    ,$B3,$50,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB  $09,$01    ,$A3,$42,$83,$49
                DEFB      $01    ,$A3,$3B,$81,$F4
                DEFB      $01    ,$93,$42,$81,$76
                DEFB      $01    ,$93,$49,$81,$3B
                DEFB      $01    ,$83,$50,$00
                DEFB      $01    ,$83,$57,$01
                DEFB      $01    ,$93,$50,$01
                DEFB      $01    ,$93,$49,$01
                DEFB  $15,$01    ,$A3,$42,$90,$BB
                DEFB      $01    ,$A3,$3B,$01
                DEFB      $01    ,$B3,$42,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB  $15,$85,$DB,$C3,$50,$91,$76
                DEFB      $87,$60,$C3,$57,$01
                DEFB      $88,$C6,$D3,$50,$01
                DEFB      $85,$DB,$D3,$49,$01
                DEFB      $87,$60,$E3,$42,$01
                DEFB      $88,$C6,$E3,$3B,$01
                DEFB      $00    ,$F3,$42,$01
                DEFB      $01    ,$F3,$49,$01
                DEFB  $15,$01    ,$E3,$50,$90,$BB
                DEFB      $01    ,$E3,$57,$01
                DEFB      $01    ,$D3,$50,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB  $15,$85,$DB,$C3,$42,$82,$76
                DEFB      $87,$60,$C3,$3B,$81,$A4
                DEFB      $89,$D9,$B3,$42,$80,$FA
                DEFB      $85,$DB,$B3,$49,$80,$BB
                DEFB      $87,$60,$A3,$50,$91,$76
                DEFB      $89,$D9,$A3,$57,$01
                DEFB      $00    ,$93,$50,$01
                DEFB      $01    ,$93,$49,$01
                DEFB      $01    ,$83,$42,$01
                DEFB      $01    ,$83,$3B,$01
                DEFB      $01    ,$00    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$82,$ED,$01
                DEFB      $01    ,$82,$ED,$01
                DEFB      $01    ,$92,$ED,$01
                DEFB      $01    ,$92,$ED,$01
                DEFB      $01    ,$A2,$ED,$01
                DEFB      $01    ,$A2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$C2,$ED,$01
                DEFB      $01    ,$C2,$ED,$01
                DEFB      $01    ,$D2,$ED,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $FF  ; End of Pattern

PAT3:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $15,$01    ,$83,$49,$82,$76
                DEFB      $01    ,$83,$49,$81,$A4
                DEFB      $01    ,$93,$49,$80,$FA
                DEFB      $01    ,$93,$B0,$80,$BB
                DEFB      $01    ,$A3,$B0,$90,$BB
                DEFB      $01    ,$A3,$B0,$01
                DEFB      $01    ,$B3,$B0,$01
                DEFB      $01    ,$B3,$B0,$01
                DEFB      $01    ,$C3,$B0,$01
                DEFB      $01    ,$C3,$B0,$01
                DEFB      $01    ,$D3,$B0,$01
                DEFB      $01    ,$00    ,$00
                DEFB  $15,$85,$DB,$E3,$B0,$90,$BB
                DEFB      $87,$60,$E3,$B0,$01
                DEFB      $88,$C6,$F3,$B0,$01
                DEFB      $85,$DB,$F3,$B0,$01
                DEFB      $87,$60,$E3,$B0,$01
                DEFB      $88,$C6,$E3,$B0,$01
                DEFB      $00    ,$D3,$B0,$01
                DEFB      $01    ,$D3,$B0,$01
                DEFB  $15,$01    ,$C3,$49,$91,$76
                DEFB      $01    ,$C3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB  $09,$01    ,$A3,$49,$83,$49
                DEFB      $01    ,$A3,$49,$81,$F4
                DEFB      $01    ,$93,$49,$81,$76
                DEFB      $01    ,$93,$49,$81,$3B
                DEFB      $01    ,$83,$49,$00
                DEFB      $01    ,$83,$49,$01
                DEFB      $01    ,$93,$49,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $15,$01    ,$A3,$49,$90,$BB
                DEFB      $01    ,$A3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB  $15,$85,$DB,$C2,$ED,$91,$76
                DEFB      $87,$60,$C2,$ED,$01
                DEFB      $88,$C6,$D2,$ED,$01
                DEFB      $85,$DB,$D2,$ED,$01
                DEFB      $87,$60,$E2,$ED,$01
                DEFB      $88,$C6,$E2,$ED,$01
                DEFB      $00    ,$F2,$ED,$01
                DEFB      $01    ,$F2,$ED,$01
                DEFB  $15,$01    ,$E2,$ED,$90,$BB
                DEFB      $01    ,$E2,$ED,$01
                DEFB      $01    ,$D2,$ED,$01
                DEFB      $01    ,$D2,$ED,$01
                DEFB  $15,$01    ,$C3,$49,$82,$76
                DEFB      $01    ,$C3,$49,$81,$A4
                DEFB      $01    ,$B3,$49,$80,$FA
                DEFB      $01    ,$B3,$49,$80,$BB
                DEFB      $01    ,$A3,$49,$90,$9D
                DEFB      $01    ,$A3,$49,$01
                DEFB      $01    ,$93,$49,$01
                DEFB      $01    ,$93,$49,$01
                DEFB  $15,$01    ,$83,$49,$91,$3B
                DEFB      $01    ,$83,$49,$01
                DEFB      $01    ,$93,$49,$01
                DEFB      $01    ,$93,$49,$00
                DEFB  $15,$85,$DB,$A3,$42,$91,$3B
                DEFB      $87,$60,$A3,$3B,$01
                DEFB      $89,$D9,$B3,$42,$01
                DEFB      $85,$DB,$B3,$49,$01
                DEFB      $87,$60,$C3,$50,$01
                DEFB      $89,$D9,$C3,$57,$01
                DEFB      $00    ,$D3,$50,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB      $01    ,$E3,$42,$90,$9D
                DEFB      $01    ,$E3,$3B,$01
                DEFB      $01    ,$F3,$42,$01
                DEFB      $01    ,$F3,$49,$01
                DEFB  $09,$01    ,$E3,$50,$83,$49
                DEFB      $01    ,$E3,$58,$81,$F4
                DEFB      $01    ,$D3,$50,$81,$76
                DEFB      $01    ,$D3,$49,$81,$3B
                DEFB      $01    ,$C3,$42,$00
                DEFB      $01    ,$C3,$3B,$01
                DEFB      $01    ,$B3,$42,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$A3,$50,$90,$D2
                DEFB      $01    ,$A3,$57,$01
                DEFB      $01    ,$93,$50,$01
                DEFB      $01    ,$93,$1A,$01
                DEFB  $15,$85,$DB,$82,$E6,$90,$DE
                DEFB      $87,$60,$82,$B5,$01
                DEFB      $89,$D9,$92,$94,$01
                DEFB      $85,$DB,$92,$76,$01
                DEFB      $87,$60,$A2,$59,$01
                DEFB      $89,$D9,$A2,$3F,$01
                DEFB      $00    ,$B2,$18,$01
                DEFB      $01    ,$B1,$F4,$01
                DEFB  $15,$01    ,$C1,$D1,$90,$EC
                DEFB      $01    ,$C1,$AF,$01
                DEFB      $01    ,$D1,$9D,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $FF  ; End of Pattern

PAT4:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $15,$00    ,$00    ,$82,$76
                DEFB      $01    ,$01    ,$81,$A4
                DEFB      $01    ,$01    ,$80,$FA
                DEFB      $01    ,$01    ,$80,$BB
                DEFB      $01    ,$01    ,$90,$D2
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB  $15,$86,$92,$01    ,$90,$D2
                DEFB      $87,$D0,$01    ,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $86,$92,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$91,$A4
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $09,$01    ,$01    ,$83,$49
                DEFB      $01    ,$01    ,$81,$F4
                DEFB      $01    ,$01    ,$81,$76
                DEFB      $01    ,$01    ,$81,$3B
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$90,$D2
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$86,$92,$01    ,$91,$A4
                DEFB      $87,$D0,$01    ,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $86,$92,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$90,$D2
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$82,$76
                DEFB      $01    ,$01    ,$81,$A4
                DEFB      $01    ,$01    ,$80,$FA
                DEFB      $01    ,$01    ,$80,$BB
                DEFB      $01    ,$01    ,$90,$8C
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$90,$FA
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$86,$92,$01    ,$82,$76
                DEFB      $88,$C6,$01    ,$81,$A4
                DEFB      $8B,$0D,$01    ,$80,$FA
                DEFB      $86,$92,$01    ,$80,$BB
                DEFB      $88,$C6,$01    ,$91,$08
                DEFB      $8B,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$91,$18
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $09,$01    ,$01    ,$83,$49
                DEFB      $01    ,$01    ,$81,$F4
                DEFB      $01    ,$01    ,$81,$76
                DEFB      $01    ,$01    ,$81,$3B
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$90,$8C
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$86,$92,$01    ,$91,$18
                DEFB      $88,$C6,$01    ,$01
                DEFB      $8B,$0D,$01    ,$01
                DEFB      $86,$92,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $8B,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$90,$FA
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT5:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $15,$01    ,$01    ,$82,$76
                DEFB      $01    ,$01    ,$81,$A4
                DEFB      $01    ,$01    ,$80,$FA
                DEFB      $01    ,$01    ,$80,$BB
                DEFB      $01    ,$01    ,$90,$BB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB  $15,$85,$DB,$01    ,$90,$BB
                DEFB      $87,$60,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $87,$60,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$91,$76
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $09,$01    ,$01    ,$83,$49
                DEFB      $01    ,$01    ,$81,$F4
                DEFB      $01    ,$01    ,$81,$76
                DEFB      $01    ,$01    ,$81,$3B
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$90,$BB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$85,$DB,$01    ,$91,$76
                DEFB      $87,$60,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $87,$60,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$90,$BB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$82,$76
                DEFB      $01    ,$01    ,$81,$A4
                DEFB      $01    ,$01    ,$80,$FA
                DEFB      $01    ,$01    ,$80,$BB
                DEFB      $01    ,$01    ,$90,$9D
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$91,$3B
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB  $15,$85,$DB,$01    ,$91,$3B
                DEFB      $87,$60,$01    ,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $87,$60,$01    ,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$90,$9D
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $09,$01    ,$01    ,$83,$49
                DEFB      $01    ,$01    ,$81,$F4
                DEFB      $01    ,$01    ,$81,$76
                DEFB      $01    ,$01    ,$81,$3B
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$90,$D2
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$85,$DB,$01    ,$90,$DE
                DEFB      $87,$60,$01    ,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $87,$60,$01    ,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$90,$EC
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT6:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $15,$01    ,$01    ,$82,$76
                DEFB      $01    ,$01    ,$81,$A4
                DEFB      $01    ,$01    ,$80,$FA
                DEFB      $01    ,$01    ,$80,$BB
                DEFB      $01    ,$01    ,$90,$BB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB  $15,$85,$DB,$01    ,$90,$BB
                DEFB      $87,$60,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $87,$60,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$91,$76
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $09,$01    ,$01    ,$83,$49
                DEFB      $01    ,$01    ,$81,$F4
                DEFB      $01    ,$01    ,$81,$76
                DEFB      $01    ,$01    ,$81,$3B
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$90,$BB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$85,$DB,$01    ,$91,$76
                DEFB      $87,$60,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $87,$60,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$90,$BB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$85,$DB,$01    ,$82,$76
                DEFB      $87,$60,$01    ,$81,$A4
                DEFB      $89,$D9,$01    ,$80,$FA
                DEFB      $85,$DB,$01    ,$80,$BB
                DEFB      $87,$60,$01    ,$91,$76
                DEFB      $89,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$82,$ED,$01
                DEFB      $01    ,$82,$ED,$01
                DEFB      $01    ,$92,$ED,$01
                DEFB      $01    ,$92,$ED,$01
                DEFB      $01    ,$A2,$ED,$01
                DEFB      $01    ,$A2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$C2,$ED,$01
                DEFB      $01    ,$C2,$ED,$01
                DEFB      $01    ,$D2,$ED,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $FF  ; End of Pattern

PAT7:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $15,$01    ,$83,$42,$82,$76
                DEFB      $01    ,$83,$3B,$81,$A4
                DEFB      $01    ,$93,$42,$80,$FA
                DEFB      $01    ,$93,$49,$80,$BB
                DEFB      $01    ,$A3,$50,$90,$BB
                DEFB      $01    ,$A3,$57,$01
                DEFB      $01    ,$B3,$50,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$C3,$42,$01
                DEFB      $01    ,$C3,$3B,$01
                DEFB      $01    ,$D3,$42,$01
                DEFB      $01    ,$D3,$49,$00
                DEFB  $15,$85,$DB,$E3,$50,$90,$BB
                DEFB      $87,$60,$E3,$57,$01
                DEFB      $88,$C6,$F3,$50,$01
                DEFB      $85,$DB,$F3,$49,$01
                DEFB      $87,$60,$E3,$42,$01
                DEFB      $88,$C6,$E3,$3B,$01
                DEFB      $00    ,$D3,$42,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB  $15,$01    ,$C3,$50,$91,$76
                DEFB      $01    ,$C3,$57,$01
                DEFB      $01    ,$B3,$50,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB  $09,$01    ,$A3,$42,$83,$49
                DEFB      $01    ,$A3,$3B,$81,$F4
                DEFB      $01    ,$93,$42,$81,$76
                DEFB      $01    ,$93,$49,$81,$3B
                DEFB      $01    ,$83,$50,$00
                DEFB      $01    ,$83,$57,$01
                DEFB      $01    ,$93,$50,$01
                DEFB      $01    ,$93,$49,$01
                DEFB  $15,$01    ,$A3,$42,$90,$BB
                DEFB      $01    ,$A3,$3B,$01
                DEFB      $01    ,$B3,$42,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB  $15,$85,$DB,$C3,$50,$91,$76
                DEFB      $87,$60,$C3,$57,$01
                DEFB      $88,$C6,$D3,$50,$01
                DEFB      $85,$DB,$D3,$49,$01
                DEFB      $87,$60,$E3,$42,$01
                DEFB      $88,$C6,$E3,$3B,$01
                DEFB      $00    ,$F3,$42,$01
                DEFB      $01    ,$F3,$49,$01
                DEFB  $15,$01    ,$E3,$50,$90,$BB
                DEFB      $01    ,$E3,$57,$01
                DEFB      $01    ,$D3,$50,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB  $15,$01    ,$C3,$42,$82,$76
                DEFB      $01    ,$C3,$3B,$81,$A4
                DEFB      $01    ,$B3,$42,$80,$FA
                DEFB      $01    ,$B3,$49,$80,$BB
                DEFB      $01    ,$A3,$50,$90,$9D
                DEFB      $01    ,$A3,$57,$01
                DEFB      $01    ,$93,$50,$01
                DEFB      $01    ,$93,$49,$01
                DEFB  $15,$01    ,$83,$42,$91,$3B
                DEFB      $01    ,$83,$3B,$01
                DEFB      $01    ,$93,$42,$01
                DEFB      $01    ,$93,$49,$00
                DEFB  $15,$85,$DB,$A3,$50,$91,$3B
                DEFB      $87,$60,$A3,$57,$01
                DEFB      $89,$D9,$B3,$50,$01
                DEFB      $85,$DB,$B3,$49,$01
                DEFB      $87,$60,$C3,$42,$01
                DEFB      $89,$D9,$C3,$3B,$01
                DEFB      $00    ,$D3,$42,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB      $01    ,$E3,$50,$90,$9D
                DEFB      $01    ,$E3,$57,$01
                DEFB      $01    ,$F3,$50,$01
                DEFB      $01    ,$F3,$49,$01
                DEFB  $09,$01    ,$E3,$42,$83,$49
                DEFB      $01    ,$E3,$3B,$81,$F4
                DEFB      $01    ,$D3,$42,$81,$76
                DEFB      $01    ,$D3,$49,$81,$3B
                DEFB      $01    ,$C3,$50,$00
                DEFB      $01    ,$C3,$57,$01
                DEFB      $01    ,$B3,$50,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$A3,$42,$90,$D2
                DEFB      $01    ,$A3,$3B,$01
                DEFB      $01    ,$93,$42,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $15,$85,$DB,$83,$E8,$90,$DE
                DEFB      $87,$60,$83,$E8,$01
                DEFB      $89,$D9,$93,$E8,$01
                DEFB      $85,$DB,$93,$E8,$01
                DEFB      $87,$60,$A3,$E8,$01
                DEFB      $89,$D9,$A3,$E8,$01
                DEFB      $00    ,$B3,$E8,$01
                DEFB      $01    ,$B3,$E8,$01
                DEFB  $15,$01    ,$C3,$E8,$90,$EC
                DEFB      $01    ,$C3,$E8,$01
                DEFB      $01    ,$D3,$E8,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $FF  ; End of Pattern

PAT8:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $15,$01    ,$83,$49,$82,$76
                DEFB      $01    ,$83,$49,$81,$A4
                DEFB      $01    ,$93,$B0,$80,$FA
                DEFB      $01    ,$93,$B0,$80,$BB
                DEFB      $01    ,$A3,$B0,$90,$D2
                DEFB      $01    ,$A3,$B0,$01
                DEFB      $01    ,$B3,$B0,$01
                DEFB      $01    ,$B3,$B0,$01
                DEFB      $01    ,$C3,$B0,$01
                DEFB      $01    ,$C3,$B0,$01
                DEFB      $01    ,$D3,$B0,$01
                DEFB      $01    ,$00    ,$00
                DEFB  $15,$86,$92,$E3,$B0,$90,$D2
                DEFB      $87,$D0,$E3,$B0,$01
                DEFB      $89,$D9,$F3,$B0,$01
                DEFB      $86,$92,$F3,$B0,$01
                DEFB      $87,$D0,$E3,$B0,$01
                DEFB      $89,$D9,$E3,$B0,$01
                DEFB      $00    ,$D3,$B0,$01
                DEFB      $01    ,$D3,$B0,$01
                DEFB  $15,$01    ,$C3,$B0,$91,$A4
                DEFB      $01    ,$C3,$B0,$01
                DEFB      $01    ,$B3,$E8,$01
                DEFB      $01    ,$B3,$E8,$01
                DEFB  $09,$01    ,$A3,$E8,$83,$49
                DEFB      $01    ,$A3,$E8,$81,$F4
                DEFB      $01    ,$93,$E8,$81,$76
                DEFB      $01    ,$93,$E8,$81,$3B
                DEFB      $01    ,$83,$E8,$00
                DEFB      $01    ,$83,$E8,$01
                DEFB      $01    ,$93,$E8,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $15,$01    ,$A3,$E8,$90,$D2
                DEFB      $01    ,$A3,$E8,$01
                DEFB      $01    ,$B3,$E8,$01
                DEFB      $01    ,$B3,$E8,$01
                DEFB  $15,$86,$92,$C3,$B0,$91,$A4
                DEFB      $87,$D0,$C3,$B0,$01
                DEFB      $89,$D9,$D3,$B0,$01
                DEFB      $86,$92,$D3,$B0,$01
                DEFB      $87,$D0,$E3,$B0,$01
                DEFB      $89,$D9,$E3,$B0,$01
                DEFB      $00    ,$F3,$B0,$01
                DEFB      $01    ,$F3,$B0,$01
                DEFB  $15,$01    ,$E3,$B0,$90,$D2
                DEFB      $01    ,$E3,$B0,$01
                DEFB      $01    ,$D3,$B0,$01
                DEFB      $01    ,$D3,$B0,$01
                DEFB  $15,$01    ,$C3,$49,$82,$76
                DEFB      $01    ,$C3,$49,$81,$A4
                DEFB      $01    ,$B3,$49,$80,$FA
                DEFB      $01    ,$B3,$49,$80,$BB
                DEFB      $01    ,$A3,$49,$90,$8C
                DEFB      $01    ,$A3,$49,$01
                DEFB      $01    ,$93,$49,$01
                DEFB      $01    ,$93,$49,$01
                DEFB      $01    ,$83,$49,$90,$FA
                DEFB      $01    ,$83,$49,$01
                DEFB      $01    ,$93,$49,$01
                DEFB      $01    ,$93,$49,$01
                DEFB  $15,$86,$92,$A3,$50,$82,$76
                DEFB      $88,$C6,$A3,$57,$81,$A4
                DEFB      $8B,$0D,$B3,$50,$80,$FA
                DEFB      $86,$92,$B3,$49,$80,$BB
                DEFB      $88,$C6,$C3,$42,$91,$08
                DEFB      $8B,$0D,$C3,$3B,$01
                DEFB      $00    ,$D3,$42,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB  $15,$01    ,$E2,$ED,$91,$18
                DEFB      $01    ,$E2,$ED,$01
                DEFB      $01    ,$F2,$ED,$01
                DEFB      $01    ,$F2,$ED,$01
                DEFB  $09,$01    ,$E2,$ED,$83,$49
                DEFB      $01    ,$E2,$ED,$81,$F4
                DEFB      $01    ,$D2,$ED,$81,$76
                DEFB      $01    ,$D2,$ED,$81,$3B
                DEFB      $01    ,$C2,$ED,$00
                DEFB      $01    ,$C2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB  $15,$01    ,$A2,$F4,$90,$8C
                DEFB      $01    ,$A2,$FB,$01
                DEFB      $01    ,$92,$F4,$01
                DEFB      $01    ,$92,$ED,$01
                DEFB  $15,$86,$92,$83,$49,$91,$18
                DEFB      $88,$C6,$83,$49,$01
                DEFB      $8B,$0D,$93,$49,$01
                DEFB      $86,$92,$93,$49,$01
                DEFB      $88,$C6,$A3,$49,$01
                DEFB      $8B,$0D,$A3,$49,$01
                DEFB      $00    ,$B3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB  $15,$01    ,$C3,$49,$90,$FA
                DEFB      $01    ,$C3,$49,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $FF  ; End of Pattern

PAT11:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $15,$00    ,$83,$49,$82,$76
                DEFB      $01    ,$83,$49,$81,$A4
                DEFB      $01    ,$93,$49,$80,$FA
                DEFB      $01    ,$93,$49,$80,$BB
                DEFB      $01    ,$A3,$49,$90,$D2
                DEFB      $01    ,$A3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$C3,$49,$01
                DEFB      $01    ,$C3,$49,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB      $01    ,$00    ,$00
                DEFB  $15,$86,$92,$E3,$49,$90,$D2
                DEFB      $87,$D0,$E3,$49,$01
                DEFB      $89,$D9,$F3,$49,$01
                DEFB      $86,$92,$F3,$49,$01
                DEFB      $87,$D0,$00    ,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$C3,$49,$91,$A4
                DEFB      $01    ,$C3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB  $09,$01    ,$A3,$49,$83,$49
                DEFB      $01    ,$A3,$49,$81,$F4
                DEFB      $01    ,$93,$49,$81,$76
                DEFB      $01    ,$93,$49,$81,$3B
                DEFB      $01    ,$83,$49,$00
                DEFB      $01    ,$83,$49,$01
                DEFB      $01    ,$93,$49,$01
                DEFB      $01    ,$93,$49,$01
                DEFB  $15,$01    ,$A3,$49,$90,$D2
                DEFB      $01    ,$A3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $15,$86,$92,$C3,$49,$91,$A4
                DEFB      $87,$D0,$C3,$49,$01
                DEFB      $89,$D9,$D3,$49,$01
                DEFB      $86,$92,$D3,$49,$01
                DEFB      $87,$D0,$00    ,$01
                DEFB      $89,$D9,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$90,$D2
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$C3,$49,$82,$76
                DEFB      $01    ,$C3,$49,$81,$A4
                DEFB      $01    ,$B3,$49,$80,$FA
                DEFB      $01    ,$B3,$49,$80,$BB
                DEFB      $01    ,$00    ,$90,$8C
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$82,$ED,$90,$FA
                DEFB      $01    ,$82,$ED,$01
                DEFB      $01    ,$92,$ED,$01
                DEFB      $01    ,$92,$ED,$01
                DEFB  $15,$86,$92,$A3,$49,$82,$76
                DEFB      $88,$C6,$A3,$49,$81,$A4
                DEFB      $8B,$0D,$B3,$49,$80,$FA
                DEFB      $86,$92,$B3,$49,$80,$BB
                DEFB      $88,$C6,$00    ,$91,$08
                DEFB      $8B,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$E3,$49,$91,$18
                DEFB      $01    ,$E3,$49,$01
                DEFB      $01    ,$F3,$49,$01
                DEFB      $01    ,$F3,$49,$01
                DEFB  $09,$01    ,$00    ,$83,$49
                DEFB      $01    ,$01    ,$81,$F4
                DEFB      $01    ,$01    ,$81,$76
                DEFB      $01    ,$01    ,$81,$3B
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$90,$8C
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$86,$92,$83,$49,$91,$18
                DEFB      $88,$C6,$83,$49,$01
                DEFB      $8B,$0D,$93,$49,$01
                DEFB      $86,$92,$93,$49,$01
                DEFB      $88,$C6,$00    ,$01
                DEFB      $8B,$0D,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$C3,$49,$90,$FA
                DEFB      $01    ,$C3,$49,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB  $FF  ; End of Pattern

PAT12:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $15,$01    ,$83,$B0,$82,$76
                DEFB      $01    ,$83,$B0,$81,$A4
                DEFB      $01    ,$93,$B0,$80,$FA
                DEFB      $01    ,$93,$B0,$80,$BB
                DEFB      $01    ,$A3,$B0,$90,$BB
                DEFB      $01    ,$A3,$B0,$01
                DEFB      $01    ,$B3,$B0,$01
                DEFB      $01    ,$B3,$B0,$01
                DEFB      $01    ,$C3,$B0,$01
                DEFB      $01    ,$C3,$B0,$01
                DEFB      $01    ,$D3,$B0,$01
                DEFB      $01    ,$00    ,$00
                DEFB  $15,$85,$DB,$E3,$B0,$90,$BB
                DEFB      $87,$60,$E3,$B0,$01
                DEFB      $88,$C6,$F3,$B0,$01
                DEFB      $85,$DB,$F3,$B0,$01
                DEFB      $87,$60,$00    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$C3,$B0,$91,$76
                DEFB      $01    ,$C3,$B0,$01
                DEFB      $01    ,$B3,$B0,$01
                DEFB      $01    ,$B3,$B0,$01
                DEFB  $09,$01    ,$00    ,$83,$49
                DEFB      $01    ,$01    ,$81,$F4
                DEFB      $01    ,$01    ,$81,$76
                DEFB      $01    ,$01    ,$81,$3B
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$90,$BB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$85,$DB,$C3,$B0,$91,$76
                DEFB      $87,$60,$C3,$B0,$01
                DEFB      $88,$C6,$D3,$B0,$01
                DEFB      $85,$DB,$D3,$B0,$01
                DEFB      $87,$60,$00    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$90,$BB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$C2,$ED,$82,$76
                DEFB      $01    ,$C2,$ED,$81,$A4
                DEFB      $01    ,$B2,$ED,$80,$FA
                DEFB      $01    ,$B2,$ED,$80,$BB
                DEFB      $01    ,$00    ,$90,$9D
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$83,$49,$91,$3B
                DEFB      $01    ,$83,$49,$01
                DEFB      $01    ,$93,$49,$01
                DEFB      $01    ,$93,$49,$00
                DEFB  $15,$85,$DB,$A3,$B0,$91,$3B
                DEFB      $87,$60,$A3,$B0,$01
                DEFB      $89,$D9,$B3,$B0,$01
                DEFB      $85,$DB,$B3,$B0,$01
                DEFB      $87,$60,$C3,$B0,$01
                DEFB      $89,$D9,$C3,$B0,$01
                DEFB      $00    ,$D3,$B0,$01
                DEFB      $01    ,$D3,$B0,$01
                DEFB      $01    ,$E3,$B0,$90,$9D
                DEFB      $01    ,$E3,$B0,$01
                DEFB      $01    ,$F3,$B0,$01
                DEFB      $01    ,$F3,$B0,$01
                DEFB  $09,$01    ,$E3,$49,$83,$49
                DEFB      $01    ,$E3,$49,$81,$F4
                DEFB      $01    ,$D3,$49,$81,$76
                DEFB      $01    ,$D3,$49,$81,$3B
                DEFB      $01    ,$C3,$49,$00
                DEFB      $01    ,$C3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$A3,$49,$90,$D2
                DEFB      $01    ,$A3,$49,$01
                DEFB      $01    ,$93,$49,$01
                DEFB      $01    ,$93,$1A,$01
                DEFB  $15,$85,$DB,$82,$ED,$90,$DE
                DEFB      $87,$60,$82,$C3,$01
                DEFB      $89,$D9,$92,$9B,$01
                DEFB      $85,$DB,$92,$76,$01
                DEFB      $87,$60,$A2,$52,$01
                DEFB      $89,$D9,$A2,$31,$01
                DEFB      $00    ,$B2,$11,$01
                DEFB      $01    ,$B1,$F4,$01
                DEFB  $15,$01    ,$C1,$D8,$90,$EC
                DEFB      $01    ,$C1,$BD,$01
                DEFB      $01    ,$D1,$A4,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $FF  ; End of Pattern

PAT13:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $15,$01    ,$82,$ED,$82,$76
                DEFB      $01    ,$82,$ED,$81,$A4
                DEFB      $01    ,$92,$ED,$80,$FA
                DEFB      $01    ,$92,$ED,$80,$BB
                DEFB      $01    ,$A2,$ED,$90,$BB
                DEFB      $01    ,$A2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$C2,$ED,$01
                DEFB      $01    ,$C2,$ED,$01
                DEFB      $01    ,$D2,$ED,$01
                DEFB      $01    ,$00    ,$00
                DEFB  $15,$85,$DB,$E2,$ED,$90,$BB
                DEFB      $87,$60,$E2,$ED,$01
                DEFB      $88,$C6,$F2,$ED,$01
                DEFB      $85,$DB,$F2,$ED,$01
                DEFB      $87,$60,$00    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$C2,$ED,$91,$76
                DEFB      $01    ,$C2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB  $09,$01    ,$00    ,$83,$49
                DEFB      $01    ,$01    ,$81,$F4
                DEFB      $01    ,$01    ,$81,$76
                DEFB      $01    ,$01    ,$81,$3B
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$90,$BB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$85,$DB,$C2,$ED,$91,$76
                DEFB      $87,$60,$C2,$ED,$01
                DEFB      $88,$C6,$D2,$ED,$01
                DEFB      $85,$DB,$D2,$ED,$01
                DEFB      $87,$60,$00    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$90,$BB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$C2,$76,$82,$76
                DEFB      $01    ,$C2,$76,$81,$A4
                DEFB      $01    ,$B2,$76,$80,$FA
                DEFB      $01    ,$B2,$76,$80,$BB
                DEFB      $01    ,$A2,$76,$90,$9D
                DEFB      $01    ,$A2,$76,$01
                DEFB      $01    ,$92,$76,$01
                DEFB      $01    ,$92,$76,$01
                DEFB  $15,$01    ,$82,$76,$91,$3B
                DEFB      $01    ,$82,$76,$01
                DEFB      $01    ,$92,$76,$01
                DEFB      $01    ,$92,$76,$00
                DEFB  $15,$85,$DB,$A2,$76,$91,$3B
                DEFB      $87,$60,$A2,$76,$01
                DEFB      $89,$D9,$B2,$76,$01
                DEFB      $85,$DB,$B2,$76,$01
                DEFB      $87,$60,$C2,$76,$01
                DEFB      $89,$D9,$C2,$76,$01
                DEFB      $00    ,$D2,$76,$01
                DEFB      $01    ,$D2,$76,$01
                DEFB      $01    ,$E2,$76,$90,$9D
                DEFB      $01    ,$E2,$76,$01
                DEFB      $01    ,$F2,$76,$01
                DEFB      $01    ,$F2,$76,$01
                DEFB  $09,$01    ,$E2,$76,$83,$49
                DEFB      $01    ,$E2,$76,$81,$F4
                DEFB      $01    ,$D2,$76,$81,$76
                DEFB      $01    ,$D2,$76,$81,$3B
                DEFB      $01    ,$C2,$76,$00
                DEFB      $01    ,$C2,$76,$01
                DEFB      $01    ,$B2,$76,$01
                DEFB      $01    ,$B2,$76,$01
                DEFB      $01    ,$A2,$76,$90,$D2
                DEFB      $01    ,$A2,$76,$01
                DEFB      $01    ,$92,$76,$01
                DEFB      $01    ,$92,$52,$01
                DEFB  $15,$85,$DB,$82,$31,$90,$DE
                DEFB      $87,$60,$82,$11,$01
                DEFB      $89,$D9,$91,$F4,$01
                DEFB      $85,$DB,$91,$D8,$01
                DEFB      $87,$60,$A1,$BD,$01
                DEFB      $89,$D9,$A1,$A4,$01
                DEFB      $00    ,$B1,$8D,$01
                DEFB      $01    ,$B1,$76,$01
                DEFB  $15,$01    ,$C1,$61,$90,$EC
                DEFB      $01    ,$C1,$4D,$01
                DEFB      $01    ,$D1,$3B,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $FF  ; End of Pattern

PAT14:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $15,$01    ,$82,$76,$82,$76
                DEFB      $01    ,$82,$76,$81,$A4
                DEFB      $01    ,$92,$76,$80,$FA
                DEFB      $01    ,$92,$ED,$80,$BB
                DEFB      $01    ,$A2,$ED,$90,$D2
                DEFB      $01    ,$A2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$00    ,$00
                DEFB  $15,$86,$92,$E2,$ED,$90,$D2
                DEFB      $87,$D0,$E2,$ED,$01
                DEFB      $89,$D9,$F2,$ED,$01
                DEFB      $86,$92,$F2,$ED,$01
                DEFB      $87,$D0,$E2,$ED,$01
                DEFB      $89,$D9,$E2,$ED,$01
                DEFB      $00    ,$D2,$ED,$01
                DEFB      $01    ,$D2,$ED,$01
                DEFB  $15,$01    ,$C2,$76,$91,$A4
                DEFB      $01    ,$C2,$76,$01
                DEFB      $01    ,$B2,$76,$01
                DEFB      $01    ,$B2,$76,$01
                DEFB  $09,$01    ,$A2,$76,$83,$49
                DEFB      $01    ,$A2,$76,$81,$F4
                DEFB      $01    ,$92,$76,$81,$76
                DEFB      $01    ,$92,$76,$81,$3B
                DEFB      $01    ,$82,$76,$00
                DEFB      $01    ,$82,$76,$01
                DEFB      $01    ,$92,$76,$01
                DEFB      $01    ,$92,$76,$01
                DEFB  $15,$01    ,$00    ,$90,$D2
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $15,$86,$92,$C2,$C3,$91,$A4
                DEFB      $87,$D0,$C2,$C3,$01
                DEFB      $89,$D9,$D2,$C3,$01
                DEFB      $86,$92,$D2,$C3,$01
                DEFB      $87,$D0,$E2,$C3,$01
                DEFB      $89,$D9,$E2,$C3,$01
                DEFB      $00    ,$F2,$C3,$01
                DEFB      $01    ,$F2,$C3,$01
                DEFB  $15,$01    ,$E2,$C3,$90,$D2
                DEFB      $01    ,$E2,$C3,$01
                DEFB      $01    ,$D2,$C3,$01
                DEFB      $01    ,$D2,$C3,$01
                DEFB  $15,$01    ,$C2,$ED,$82,$76
                DEFB      $01    ,$C2,$ED,$81,$A4
                DEFB      $01    ,$B2,$ED,$80,$FA
                DEFB      $01    ,$B2,$ED,$80,$BB
                DEFB      $01    ,$A2,$ED,$90,$8C
                DEFB      $01    ,$A2,$ED,$01
                DEFB      $01    ,$92,$ED,$01
                DEFB      $01    ,$92,$ED,$01
                DEFB      $01    ,$82,$ED,$90,$FA
                DEFB      $01    ,$82,$ED,$01
                DEFB      $01    ,$92,$ED,$01
                DEFB      $01    ,$92,$ED,$01
                DEFB  $15,$86,$92,$00    ,$82,$76
                DEFB      $88,$C6,$00    ,$81,$A4
                DEFB      $8B,$0D,$00    ,$80,$FA
                DEFB      $86,$92,$00    ,$80,$BB
                DEFB      $88,$C6,$00    ,$91,$08
                DEFB      $8B,$0D,$00    ,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $15,$01    ,$E2,$76,$91,$18
                DEFB      $01    ,$E2,$76,$01
                DEFB      $01    ,$F2,$76,$01
                DEFB      $01    ,$F2,$76,$01
                DEFB  $09,$01    ,$E2,$76,$83,$49
                DEFB      $01    ,$E2,$76,$81,$F4
                DEFB      $01    ,$D2,$76,$81,$76
                DEFB      $01    ,$D2,$76,$81,$3B
                DEFB      $01    ,$C2,$76,$00
                DEFB      $01    ,$C2,$76,$01
                DEFB      $01    ,$B2,$76,$01
                DEFB      $01    ,$B2,$76,$01
                DEFB  $15,$01    ,$00    ,$90,$8C
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $15,$86,$92,$82,$C3,$91,$18
                DEFB      $88,$C6,$82,$C3,$01
                DEFB      $8B,$0D,$92,$C3,$01
                DEFB      $86,$92,$92,$C3,$01
                DEFB      $88,$C6,$A2,$C3,$01
                DEFB      $8B,$0D,$A2,$C3,$01
                DEFB      $00    ,$B2,$C3,$01
                DEFB      $01    ,$B2,$C3,$01
                DEFB  $15,$01    ,$C2,$C3,$90,$FA
                DEFB      $01    ,$C2,$C3,$01
                DEFB      $01    ,$D2,$C3,$01
                DEFB      $01    ,$D2,$C3,$01
                DEFB  $FF  ; End of Pattern

PAT15:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $15,$01    ,$82,$ED,$82,$76
                DEFB      $01    ,$82,$ED,$81,$A4
                DEFB      $01    ,$92,$ED,$80,$FA
                DEFB      $01    ,$92,$ED,$80,$BB
                DEFB      $01    ,$A2,$ED,$90,$BB
                DEFB      $01    ,$A2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$00    ,$00
                DEFB  $15,$85,$DB,$E2,$ED,$90,$BB
                DEFB      $87,$60,$E2,$ED,$01
                DEFB      $88,$C6,$F2,$ED,$01
                DEFB      $85,$DB,$F2,$ED,$01
                DEFB      $87,$60,$E2,$ED,$01
                DEFB      $88,$C6,$E2,$ED,$01
                DEFB      $00    ,$D2,$ED,$01
                DEFB      $01    ,$D2,$ED,$01
                DEFB  $15,$01    ,$C2,$76,$91,$76
                DEFB      $01    ,$C2,$76,$01
                DEFB      $01    ,$B2,$76,$01
                DEFB      $01    ,$B2,$76,$01
                DEFB  $09,$01    ,$A2,$76,$83,$49
                DEFB      $01    ,$A2,$76,$81,$F4
                DEFB      $01    ,$92,$76,$81,$76
                DEFB      $01    ,$92,$76,$81,$3B
                DEFB      $01    ,$82,$76,$00
                DEFB      $01    ,$82,$76,$01
                DEFB      $01    ,$92,$76,$01
                DEFB      $01    ,$92,$76,$01
                DEFB  $15,$01    ,$00    ,$90,$BB
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $15,$85,$DB,$C2,$C3,$91,$76
                DEFB      $87,$60,$C2,$C3,$01
                DEFB      $88,$C6,$D2,$C3,$01
                DEFB      $85,$DB,$D2,$C3,$01
                DEFB      $87,$60,$E2,$C3,$01
                DEFB      $88,$C6,$E2,$C3,$01
                DEFB      $00    ,$F2,$C3,$01
                DEFB      $01    ,$F2,$C3,$01
                DEFB  $15,$01    ,$E2,$C3,$90,$BB
                DEFB      $01    ,$E2,$C3,$01
                DEFB      $01    ,$D2,$C3,$01
                DEFB      $01    ,$D2,$C3,$01
                DEFB  $15,$01    ,$C2,$31,$82,$76
                DEFB      $01    ,$C2,$31,$81,$A4
                DEFB      $01    ,$B2,$31,$80,$FA
                DEFB      $01    ,$B2,$31,$80,$BB
                DEFB      $01    ,$A2,$31,$90,$9D
                DEFB      $01    ,$A2,$31,$01
                DEFB      $01    ,$92,$31,$01
                DEFB      $01    ,$92,$31,$01
                DEFB  $15,$01    ,$82,$31,$91,$3B
                DEFB      $01    ,$82,$31,$01
                DEFB      $01    ,$92,$31,$01
                DEFB      $01    ,$92,$31,$00
                DEFB  $15,$85,$DB,$A2,$31,$91,$3B
                DEFB      $87,$60,$A2,$31,$01
                DEFB      $89,$D9,$B2,$31,$01
                DEFB      $85,$DB,$B2,$31,$01
                DEFB      $87,$60,$C2,$31,$01
                DEFB      $89,$D9,$C2,$31,$01
                DEFB      $00    ,$D2,$31,$01
                DEFB      $01    ,$D2,$31,$01
                DEFB      $01    ,$E2,$31,$90,$9D
                DEFB      $01    ,$E2,$31,$01
                DEFB      $01    ,$F2,$31,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $09,$01    ,$E2,$76,$83,$49
                DEFB      $01    ,$E2,$76,$81,$F4
                DEFB      $01    ,$D2,$76,$81,$76
                DEFB      $01    ,$D2,$76,$81,$3B
                DEFB      $01    ,$C2,$76,$00
                DEFB      $01    ,$C2,$76,$01
                DEFB      $01    ,$B2,$76,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$A2,$76,$90,$D2
                DEFB      $01    ,$A2,$76,$01
                DEFB      $01    ,$92,$76,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $15,$85,$DB,$82,$C3,$90,$DE
                DEFB      $87,$60,$82,$C3,$01
                DEFB      $89,$D9,$92,$C3,$01
                DEFB      $85,$DB,$92,$C3,$01
                DEFB      $87,$60,$A2,$C3,$01
                DEFB      $89,$D9,$A2,$C3,$01
                DEFB      $00    ,$B2,$C3,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $15,$01    ,$C2,$C3,$90,$EC
                DEFB      $01    ,$C2,$C3,$01
                DEFB      $01    ,$D2,$C3,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $FF  ; End of Pattern

PAT16:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $15,$01    ,$82,$ED,$82,$76
                DEFB      $01    ,$82,$ED,$81,$A4
                DEFB      $01    ,$92,$ED,$80,$FA
                DEFB      $01    ,$92,$ED,$80,$BB
                DEFB      $01    ,$A2,$ED,$90,$BB
                DEFB      $01    ,$A2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$C2,$ED,$01
                DEFB      $01    ,$C2,$ED,$01
                DEFB      $01    ,$D2,$ED,$01
                DEFB      $01    ,$D2,$ED,$00
                DEFB  $15,$85,$DB,$00    ,$90,$BB
                DEFB      $87,$60,$00    ,$01
                DEFB      $88,$C6,$00    ,$01
                DEFB      $85,$DB,$00    ,$01
                DEFB      $87,$60,$00    ,$01
                DEFB      $88,$C6,$00    ,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $15,$01    ,$C2,$76,$91,$76
                DEFB      $01    ,$C2,$76,$01
                DEFB      $01    ,$B2,$76,$01
                DEFB      $01    ,$B2,$76,$01
                DEFB  $09,$01    ,$A2,$76,$83,$49
                DEFB      $01    ,$A2,$76,$81,$F4
                DEFB      $01    ,$92,$76,$81,$76
                DEFB      $01    ,$92,$76,$81,$3B
                DEFB      $01    ,$82,$76,$00
                DEFB      $01    ,$82,$76,$01
                DEFB      $01    ,$92,$76,$01
                DEFB      $01    ,$92,$76,$01
                DEFB  $15,$01    ,$00    ,$90,$BB
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $15,$85,$DB,$C2,$C3,$91,$76
                DEFB      $87,$60,$C2,$C3,$01
                DEFB      $88,$C6,$D2,$C3,$01
                DEFB      $85,$DB,$D2,$C3,$01
                DEFB      $87,$60,$E2,$C3,$01
                DEFB      $88,$C6,$E2,$C3,$01
                DEFB      $00    ,$F2,$C3,$01
                DEFB      $01    ,$F2,$C3,$01
                DEFB  $15,$01    ,$E2,$C3,$90,$BB
                DEFB      $01    ,$E2,$C3,$01
                DEFB      $01    ,$D2,$C3,$01
                DEFB      $01    ,$D2,$C3,$01
                DEFB  $15,$01    ,$C3,$49,$82,$76
                DEFB      $01    ,$C3,$49,$81,$A4
                DEFB      $01    ,$B3,$49,$80,$FA
                DEFB      $01    ,$B3,$49,$80,$BB
                DEFB      $01    ,$A3,$49,$90,$9D
                DEFB      $01    ,$A3,$49,$01
                DEFB      $01    ,$93,$49,$01
                DEFB      $01    ,$93,$49,$01
                DEFB  $15,$01    ,$83,$49,$91,$3B
                DEFB      $01    ,$83,$49,$01
                DEFB      $01    ,$93,$49,$01
                DEFB      $01    ,$93,$49,$00
                DEFB  $15,$85,$DB,$00    ,$91,$3B
                DEFB      $87,$60,$00    ,$01
                DEFB      $89,$D9,$00    ,$01
                DEFB      $85,$DB,$00    ,$01
                DEFB      $87,$60,$00    ,$01
                DEFB      $89,$D9,$00    ,$01
                DEFB      $00    ,$00    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$E2,$ED,$90,$9D
                DEFB      $01    ,$E2,$ED,$01
                DEFB      $01    ,$F2,$ED,$01
                DEFB      $01    ,$F2,$ED,$01
                DEFB  $09,$01    ,$E2,$ED,$83,$49
                DEFB      $01    ,$E2,$ED,$81,$F4
                DEFB      $01    ,$D2,$ED,$81,$76
                DEFB      $01    ,$D2,$ED,$81,$3B
                DEFB      $01    ,$C2,$ED,$00
                DEFB      $01    ,$C2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$00    ,$90,$D2
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $15,$85,$DB,$82,$C3,$90,$DE
                DEFB      $87,$60,$82,$C3,$01
                DEFB      $89,$D9,$92,$C3,$01
                DEFB      $85,$DB,$92,$C3,$01
                DEFB      $87,$60,$A2,$C3,$01
                DEFB      $89,$D9,$A2,$C3,$01
                DEFB      $00    ,$B2,$C3,$01
                DEFB      $01    ,$B2,$C3,$01
                DEFB  $15,$01    ,$C2,$C3,$90,$EC
                DEFB      $01    ,$C2,$C3,$01
                DEFB      $01    ,$D2,$C3,$01
                DEFB      $01    ,$D2,$C3,$01
                DEFB  $FF  ; End of Pattern

PAT17:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $15,$01    ,$82,$ED,$82,$76
                DEFB      $01    ,$82,$ED,$81,$A4
                DEFB      $01    ,$92,$ED,$80,$FA
                DEFB      $01    ,$92,$ED,$80,$BB
                DEFB      $01    ,$A2,$ED,$90,$BB
                DEFB      $01    ,$A2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$C2,$ED,$01
                DEFB      $01    ,$C2,$ED,$01
                DEFB      $01    ,$D2,$ED,$01
                DEFB      $01    ,$00    ,$00
                DEFB  $15,$85,$DB,$E2,$ED,$90,$BB
                DEFB      $87,$60,$E2,$ED,$01
                DEFB      $88,$C6,$F2,$ED,$01
                DEFB      $85,$DB,$F2,$ED,$01
                DEFB      $87,$60,$00    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$C2,$ED,$91,$76
                DEFB      $01    ,$C2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB      $01    ,$B2,$ED,$01
                DEFB  $09,$01    ,$00    ,$83,$49
                DEFB      $01    ,$01    ,$81,$F4
                DEFB      $01    ,$01    ,$81,$76
                DEFB      $01    ,$01    ,$81,$3B
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$90,$BB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$85,$DB,$C2,$ED,$91,$76
                DEFB      $87,$60,$C2,$ED,$01
                DEFB      $88,$C6,$D2,$ED,$01
                DEFB      $85,$DB,$D2,$ED,$01
                DEFB      $87,$60,$00    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$90,$BB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$C2,$76,$82,$76
                DEFB      $01    ,$C2,$76,$81,$A4
                DEFB      $01    ,$B2,$76,$80,$FA
                DEFB      $01    ,$B2,$76,$80,$BB
                DEFB      $01    ,$A2,$76,$90,$9D
                DEFB      $01    ,$A2,$76,$01
                DEFB      $01    ,$92,$76,$01
                DEFB      $01    ,$92,$76,$01
                DEFB  $15,$01    ,$82,$76,$91,$3B
                DEFB      $01    ,$82,$76,$01
                DEFB      $01    ,$92,$76,$01
                DEFB      $01    ,$92,$76,$00
                DEFB  $15,$85,$DB,$A2,$76,$91,$3B
                DEFB      $87,$60,$A2,$76,$01
                DEFB      $89,$D9,$B2,$76,$01
                DEFB      $85,$DB,$B2,$76,$01
                DEFB      $87,$60,$C2,$76,$01
                DEFB      $89,$D9,$C2,$76,$01
                DEFB      $00    ,$D2,$76,$01
                DEFB      $01    ,$D2,$76,$01
                DEFB      $01    ,$E2,$31,$90,$9D
                DEFB      $01    ,$E2,$31,$01
                DEFB      $01    ,$F2,$31,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $09,$01    ,$E2,$76,$83,$49
                DEFB      $01    ,$E2,$76,$81,$F4
                DEFB      $01    ,$D2,$76,$81,$76
                DEFB      $01    ,$D2,$76,$81,$3B
                DEFB      $01    ,$C2,$76,$00
                DEFB      $01    ,$C2,$76,$01
                DEFB      $01    ,$B2,$76,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $01    ,$A2,$76,$90,$D2
                DEFB      $01    ,$A2,$76,$01
                DEFB      $01    ,$92,$76,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $15,$85,$DB,$82,$C3,$90,$DE
                DEFB      $87,$60,$82,$C3,$01
                DEFB      $89,$D9,$92,$C3,$01
                DEFB      $85,$DB,$92,$C3,$01
                DEFB      $87,$60,$A2,$C3,$01
                DEFB      $89,$D9,$A2,$C3,$01
                DEFB      $00    ,$B2,$C3,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $15,$01    ,$C2,$C3,$90,$EC
                DEFB      $01    ,$C2,$C3,$01
                DEFB      $01    ,$D2,$C3,$01
                DEFB      $01    ,$00    ,$01
                DEFB  $FF  ; End of Pattern

PAT18:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $15,$01    ,$83,$49,$82,$76
                DEFB      $01    ,$83,$49,$81,$A4
                DEFB      $01    ,$93,$49,$80,$FA
                DEFB      $01    ,$93,$49,$80,$BB
                DEFB      $01    ,$A3,$49,$90,$BB
                DEFB      $01    ,$A3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$C3,$49,$01
                DEFB      $01    ,$C3,$49,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB      $01    ,$D3,$49,$00
                DEFB  $15,$85,$DB,$E3,$49,$90,$BB
                DEFB      $87,$60,$E3,$49,$01
                DEFB      $88,$C6,$F3,$49,$01
                DEFB      $85,$DB,$F3,$49,$01
                DEFB      $87,$60,$E3,$49,$01
                DEFB      $88,$C6,$E3,$49,$01
                DEFB      $00    ,$D3,$49,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB  $15,$01    ,$C3,$49,$91,$76
                DEFB      $01    ,$C3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB  $09,$01    ,$A3,$49,$83,$49
                DEFB      $01    ,$A3,$49,$81,$F4
                DEFB      $01    ,$93,$49,$81,$76
                DEFB      $01    ,$93,$49,$81,$3B
                DEFB      $01    ,$83,$49,$00
                DEFB      $01    ,$83,$49,$01
                DEFB      $01    ,$93,$49,$01
                DEFB      $01    ,$93,$49,$01
                DEFB  $15,$01    ,$A3,$49,$90,$BB
                DEFB      $01    ,$A3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB  $15,$85,$DB,$C3,$49,$91,$76
                DEFB      $87,$60,$C3,$49,$01
                DEFB      $88,$C6,$D3,$49,$01
                DEFB      $85,$DB,$D3,$49,$01
                DEFB      $87,$60,$E3,$49,$01
                DEFB      $88,$C6,$E3,$49,$01
                DEFB      $00    ,$F3,$49,$01
                DEFB      $01    ,$F3,$49,$01
                DEFB  $15,$01    ,$E3,$49,$90,$BB
                DEFB      $01    ,$E3,$49,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB  $15,$85,$DB,$C3,$49,$82,$76
                DEFB      $87,$60,$C3,$49,$81,$A4
                DEFB      $89,$D9,$B3,$49,$80,$FA
                DEFB      $85,$DB,$B3,$49,$80,$BB
                DEFB      $87,$60,$A3,$49,$91,$76
                DEFB      $89,$D9,$A3,$49,$01
                DEFB      $00    ,$93,$49,$01
                DEFB      $01    ,$93,$49,$01
                DEFB      $01    ,$83,$49,$01
                DEFB      $01    ,$83,$49,$01
                DEFB      $01    ,$00    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$90,$BB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$90,$D2
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$90,$DE
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$90,$EC
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB  $FF  ; End of Pattern

PAT19:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $15,$01    ,$01    ,$82,$76
                DEFB      $01    ,$01    ,$81,$A4
                DEFB      $01    ,$01    ,$80,$FA
                DEFB      $01    ,$01    ,$80,$BB
                DEFB      $01    ,$01    ,$90,$BB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB  $15,$85,$DB,$01    ,$90,$BB
                DEFB      $87,$60,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $87,$60,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$91,$76
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $09,$01    ,$01    ,$83,$49
                DEFB      $01    ,$01    ,$81,$F4
                DEFB      $01    ,$01    ,$81,$76
                DEFB      $01    ,$01    ,$81,$3B
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$90,$BB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$85,$DB,$01    ,$91,$76
                DEFB      $87,$60,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $87,$60,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$01    ,$01    ,$90,$BB
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $15,$85,$DB,$01    ,$82,$76
                DEFB      $87,$60,$01    ,$81,$A4
                DEFB      $88,$C6,$01    ,$80,$FA
                DEFB      $85,$DB,$01    ,$80,$BB
                DEFB      $87,$60,$01    ,$91,$76
                DEFB      $88,$C6,$01    ,$01
                DEFB      $00    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$00
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT20:
                DEFW  713     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $15,$01    ,$82,$ED,$82,$76
                DEFB      $01    ,$82,$ED,$81,$A4
                DEFB      $01    ,$92,$ED,$80,$FA
                DEFB      $01    ,$93,$49,$80,$BB
                DEFB      $01    ,$A3,$49,$90,$D2
                DEFB      $01    ,$A3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB      $01    ,$C3,$49,$01
                DEFB      $01    ,$C3,$49,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB      $01    ,$D3,$49,$00
                DEFB  $15,$86,$92,$E3,$50,$90,$D2
                DEFB      $87,$D0,$E3,$57,$01
                DEFB      $89,$D9,$F3,$50,$01
                DEFB      $86,$92,$F3,$49,$01
                DEFB      $87,$D0,$E3,$42,$01
                DEFB      $89,$D9,$E3,$3B,$01
                DEFB      $00    ,$D3,$42,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB  $15,$01    ,$C3,$50,$91,$A4
                DEFB      $01    ,$C3,$57,$01
                DEFB      $01    ,$B3,$50,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB  $09,$01    ,$A3,$42,$83,$49
                DEFB      $01    ,$A3,$3B,$81,$F4
                DEFB      $01    ,$93,$42,$81,$76
                DEFB      $01    ,$93,$49,$81,$3B
                DEFB      $01    ,$83,$50,$00
                DEFB      $01    ,$83,$57,$01
                DEFB      $01    ,$93,$50,$01
                DEFB      $01    ,$93,$49,$01
                DEFB  $15,$01    ,$A3,$42,$90,$D2
                DEFB      $01    ,$A3,$3B,$01
                DEFB      $01    ,$B3,$42,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB  $15,$86,$92,$C3,$50,$91,$A4
                DEFB      $87,$D0,$C3,$57,$01
                DEFB      $89,$D9,$D3,$50,$01
                DEFB      $86,$92,$D3,$49,$01
                DEFB      $87,$D0,$E3,$42,$01
                DEFB      $89,$D9,$E3,$3B,$01
                DEFB      $00    ,$F3,$42,$01
                DEFB      $01    ,$F3,$49,$01
                DEFB  $15,$01    ,$E3,$50,$90,$D2
                DEFB      $01    ,$E3,$57,$01
                DEFB      $01    ,$D3,$50,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB  $15,$01    ,$C3,$42,$82,$76
                DEFB      $01    ,$C3,$3B,$81,$A4
                DEFB      $01    ,$B3,$42,$80,$FA
                DEFB      $01    ,$B3,$49,$80,$BB
                DEFB      $01    ,$A3,$50,$90,$8C
                DEFB      $01    ,$A3,$57,$01
                DEFB      $01    ,$93,$50,$01
                DEFB      $01    ,$93,$49,$01
                DEFB      $01    ,$83,$42,$90,$FA
                DEFB      $01    ,$83,$3B,$01
                DEFB      $01    ,$93,$42,$01
                DEFB      $01    ,$93,$49,$01
                DEFB  $15,$86,$92,$A3,$50,$82,$76
                DEFB      $88,$C6,$A3,$57,$81,$A4
                DEFB      $8B,$0D,$B3,$50,$80,$FA
                DEFB      $86,$92,$B3,$49,$80,$BB
                DEFB      $88,$C6,$C3,$42,$91,$08
                DEFB      $8B,$0D,$C3,$3B,$01
                DEFB      $00    ,$D3,$42,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB  $15,$01    ,$E3,$50,$91,$18
                DEFB      $01    ,$E3,$57,$01
                DEFB      $01    ,$F3,$50,$01
                DEFB      $01    ,$F3,$49,$01
                DEFB  $09,$01    ,$E3,$42,$83,$49
                DEFB      $01    ,$E3,$3B,$81,$F4
                DEFB      $01    ,$D3,$42,$81,$76
                DEFB      $01    ,$D3,$49,$81,$3B
                DEFB      $01    ,$C3,$50,$00
                DEFB      $01    ,$C3,$57,$01
                DEFB      $01    ,$B3,$50,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB  $15,$01    ,$A3,$42,$90,$8C
                DEFB      $01    ,$A3,$3B,$01
                DEFB      $01    ,$93,$42,$01
                DEFB      $01    ,$93,$49,$01
                DEFB  $15,$86,$92,$83,$50,$91,$18
                DEFB      $88,$C6,$83,$57,$01
                DEFB      $8B,$0D,$93,$50,$01
                DEFB      $86,$92,$93,$49,$01
                DEFB      $88,$C6,$A3,$42,$01
                DEFB      $8B,$0D,$A3,$3B,$01
                DEFB      $00    ,$B3,$42,$01
                DEFB      $01    ,$B3,$49,$01
                DEFB  $15,$01    ,$C3,$50,$90,$FA
                DEFB      $01    ,$C3,$57,$01
                DEFB      $01    ,$D3,$50,$01
                DEFB      $01    ,$D3,$49,$01
                DEFB  $FF  ; End of Pattern





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

	savebin "tritone_itiswhatitis.tap",tap_b,tap_e-tap_b


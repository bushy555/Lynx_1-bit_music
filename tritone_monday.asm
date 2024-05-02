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




musicData




; *** Song layout ***
LOOPSTART:            DEFW      PAT0
                      DEFW      PAT0
                      DEFW      PAT1
                      DEFW      PAT1
                      DEFW      PAT2
                      DEFW      PAT2
                      DEFW      PAT3
                      DEFW      PAT3
                      DEFW      PAT5
                      DEFW      PAT4
                      DEFW      PAT6
                      DEFW      PAT7
                      DEFW      PAT8
                      DEFW      PAT9
                      DEFW      PAT10
                      DEFW      PAT3
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
                      DEFW      PAT24
                      DEFW      PAT25
                      DEFW      PAT26
                      DEFW      PAT27
                      DEFW      PAT27
                      DEFW      PAT28
                      DEFW      PAT28
                      DEFW      PAT29
                      DEFW      PAT29
                      DEFW      PAT30
                      DEFW      PAT31
                      DEFW      $0000
                      DEFW      LOOPSTART

; *** Patterns ***
PAT0:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$00    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT1:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT2:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT3:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT4:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$85,$37,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$84,$E7,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$85,$37,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $83,$E8,$84,$E7,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$85,$37,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$85,$DB,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$85,$37,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT5:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$84,$E7,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT6:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$85,$37,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$83,$E8,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT7:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$85,$37,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$84,$E7,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$85,$37,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $83,$E8,$84,$E7,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$85,$37,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$85,$DB,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$85,$37,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT8:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$85,$37,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$84,$63,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$83,$E8,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT9:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$83,$49,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$85,$37,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$84,$E7,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT10:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$84,$E7,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$63,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$63,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT11:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $85,$DB,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $82,$ED,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $85,$DB,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $02,$83,$E8,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $83,$E8,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $03,$84,$63,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB      $88,$C6,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB      $84,$63,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB      $88,$C6,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $02,$83,$E8,$83,$E8,$01
                DEFB      $81,$76,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $81,$76,$84,$E7,$01
                DEFB      $83,$E8,$83,$E8,$01
                DEFB      $81,$76,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $02,$85,$DB,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $8B,$B6,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $85,$DB,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $8B,$B6,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $02,$83,$E8,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $83,$E8,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $03,$84,$63,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB      $88,$C6,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB      $84,$63,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB      $88,$C6,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $02,$83,$E8,$83,$E8,$01
                DEFB      $81,$76,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $81,$76,$84,$E7,$01
                DEFB      $83,$E8,$83,$E8,$01
                DEFB      $81,$76,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $FF  ; End of Pattern

PAT12:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $85,$DB,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $82,$ED,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $85,$DB,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $02,$83,$E8,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $83,$E8,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $03,$84,$63,$84,$63,$01
                DEFB      $01    ,$85,$37,$01
                DEFB      $88,$C6,$84,$63,$01
                DEFB      $01    ,$85,$37,$01
                DEFB      $84,$63,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB      $88,$C6,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $02,$83,$E8,$84,$63,$01
                DEFB      $81,$76,$85,$37,$01
                DEFB      $87,$D0,$84,$63,$01
                DEFB      $81,$76,$85,$37,$01
                DEFB      $83,$E8,$83,$E8,$01
                DEFB      $81,$76,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $02,$85,$DB,$84,$63,$01
                DEFB      $80,$FA,$85,$37,$01
                DEFB      $8B,$B6,$84,$63,$01
                DEFB      $80,$FA,$85,$37,$01
                DEFB      $85,$DB,$84,$63,$01
                DEFB      $80,$FA,$85,$37,$01
                DEFB      $8B,$B6,$84,$63,$01
                DEFB      $01    ,$85,$37,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $80,$FA,$85,$DB,$01
                DEFB      $87,$D0,$84,$E7,$01
                DEFB      $80,$FA,$85,$DB,$01
                DEFB      $83,$E8,$84,$E7,$01
                DEFB      $80,$FA,$85,$DB,$01
                DEFB      $87,$D0,$84,$E7,$01
                DEFB      $01    ,$85,$DB,$01
                DEFB  $03,$84,$63,$84,$63,$01
                DEFB      $01    ,$85,$37,$01
                DEFB      $88,$C6,$84,$63,$01
                DEFB      $01    ,$85,$37,$01
                DEFB      $84,$63,$84,$63,$01
                DEFB      $01    ,$85,$37,$01
                DEFB      $88,$C6,$84,$63,$01
                DEFB      $01    ,$85,$37,$01
                DEFB  $02,$83,$E8,$83,$E8,$01
                DEFB      $81,$76,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $81,$76,$84,$E7,$01
                DEFB      $83,$E8,$83,$E8,$01
                DEFB      $81,$76,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $FF  ; End of Pattern

PAT13:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$84,$63,$01
                DEFB      $80,$D2,$85,$37,$01
                DEFB      $85,$DB,$84,$63,$01
                DEFB      $80,$D2,$85,$37,$01
                DEFB      $82,$ED,$84,$63,$01
                DEFB      $80,$D2,$85,$37,$01
                DEFB      $85,$DB,$84,$63,$01
                DEFB      $01    ,$85,$37,$01
                DEFB  $02,$83,$E8,$83,$E8,$01
                DEFB      $80,$D2,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $80,$D2,$84,$E7,$01
                DEFB      $83,$E8,$83,$E8,$01
                DEFB      $80,$D2,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $03,$84,$63,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB      $88,$C6,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB      $84,$63,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB      $88,$C6,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $02,$83,$E8,$83,$49,$01
                DEFB      $81,$3B,$83,$E8,$01
                DEFB      $87,$D0,$83,$49,$01
                DEFB      $81,$3B,$83,$E8,$01
                DEFB      $83,$E8,$83,$49,$01
                DEFB      $81,$3B,$83,$E8,$01
                DEFB      $87,$D0,$83,$49,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB  $02,$85,$DB,$83,$49,$01
                DEFB      $80,$D2,$83,$E8,$01
                DEFB      $8B,$B6,$83,$49,$01
                DEFB      $80,$D2,$83,$E8,$01
                DEFB      $85,$DB,$83,$49,$01
                DEFB      $80,$D2,$83,$E8,$01
                DEFB      $8B,$B6,$83,$49,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB  $02,$83,$E8,$83,$49,$01
                DEFB      $80,$D2,$83,$E8,$01
                DEFB      $87,$D0,$83,$49,$01
                DEFB      $80,$D2,$83,$E8,$01
                DEFB      $83,$E8,$83,$49,$01
                DEFB      $80,$D2,$83,$E8,$01
                DEFB      $87,$D0,$83,$49,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB  $03,$84,$63,$83,$49,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB      $88,$C6,$83,$49,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB      $84,$63,$83,$49,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB      $88,$C6,$83,$49,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB  $02,$83,$E8,$83,$49,$01
                DEFB      $81,$3B,$83,$E8,$01
                DEFB      $87,$D0,$83,$49,$01
                DEFB      $81,$3B,$83,$E8,$01
                DEFB      $83,$E8,$83,$49,$01
                DEFB      $81,$3B,$83,$E8,$01
                DEFB      $87,$D0,$83,$49,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB  $FF  ; End of Pattern

PAT14:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$83,$49,$01
                DEFB      $80,$D2,$83,$E8,$01
                DEFB      $85,$DB,$83,$49,$01
                DEFB      $80,$D2,$83,$E8,$01
                DEFB      $82,$ED,$83,$49,$01
                DEFB      $80,$D2,$83,$E8,$01
                DEFB      $85,$DB,$83,$49,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB  $02,$83,$E8,$83,$49,$01
                DEFB      $80,$D2,$83,$E8,$01
                DEFB      $87,$D0,$83,$49,$01
                DEFB      $80,$D2,$83,$E8,$01
                DEFB      $83,$E8,$83,$49,$01
                DEFB      $80,$D2,$83,$E8,$01
                DEFB      $87,$D0,$83,$49,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB  $03,$84,$63,$84,$63,$01
                DEFB      $01    ,$85,$37,$01
                DEFB      $88,$C6,$84,$63,$01
                DEFB      $01    ,$85,$37,$01
                DEFB      $84,$63,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB      $88,$C6,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $02,$83,$E8,$84,$63,$01
                DEFB      $81,$3B,$85,$37,$01
                DEFB      $87,$D0,$84,$63,$01
                DEFB      $81,$3B,$85,$37,$01
                DEFB      $83,$E8,$83,$E8,$01
                DEFB      $81,$3B,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $02,$85,$DB,$84,$63,$01
                DEFB      $80,$D2,$85,$37,$01
                DEFB      $8B,$B6,$84,$63,$01
                DEFB      $80,$D2,$85,$37,$01
                DEFB      $85,$DB,$84,$63,$01
                DEFB      $80,$D2,$85,$37,$01
                DEFB      $8B,$B6,$84,$63,$01
                DEFB      $01    ,$85,$37,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $80,$D2,$85,$DB,$01
                DEFB      $87,$D0,$84,$E7,$01
                DEFB      $80,$D2,$85,$DB,$01
                DEFB      $83,$E8,$84,$E7,$01
                DEFB      $80,$D2,$85,$DB,$01
                DEFB      $87,$D0,$84,$E7,$01
                DEFB      $01    ,$85,$DB,$01
                DEFB  $03,$84,$63,$84,$63,$01
                DEFB      $01    ,$85,$37,$01
                DEFB      $88,$C6,$84,$63,$01
                DEFB      $01    ,$85,$37,$01
                DEFB      $84,$63,$84,$63,$01
                DEFB      $01    ,$85,$37,$01
                DEFB      $88,$C6,$84,$63,$01
                DEFB      $01    ,$85,$37,$01
                DEFB  $02,$83,$E8,$83,$E8,$01
                DEFB      $81,$3B,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $81,$3B,$84,$E7,$01
                DEFB      $83,$E8,$83,$E8,$01
                DEFB      $81,$3B,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $FF  ; End of Pattern

PAT15:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$84,$63,$01
                DEFB      $80,$A6,$85,$37,$01
                DEFB      $85,$DB,$84,$63,$01
                DEFB      $80,$A6,$85,$37,$01
                DEFB      $82,$ED,$84,$63,$01
                DEFB      $80,$A6,$85,$37,$01
                DEFB      $85,$DB,$84,$63,$01
                DEFB      $01    ,$85,$37,$01
                DEFB  $02,$83,$E8,$83,$E8,$01
                DEFB      $80,$A6,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $80,$A6,$84,$E7,$01
                DEFB      $83,$E8,$83,$E8,$01
                DEFB      $80,$A6,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $03,$84,$63,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB      $88,$C6,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB      $84,$63,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB      $88,$C6,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB  $02,$83,$E8,$83,$49,$01
                DEFB      $80,$FA,$83,$E8,$01
                DEFB      $87,$D0,$83,$49,$01
                DEFB      $80,$FA,$83,$E8,$01
                DEFB      $83,$E8,$83,$49,$01
                DEFB      $80,$FA,$83,$E8,$01
                DEFB      $87,$D0,$83,$49,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB  $02,$85,$DB,$83,$49,$01
                DEFB      $80,$A6,$83,$E8,$01
                DEFB      $8B,$B6,$83,$49,$01
                DEFB      $80,$A6,$83,$E8,$01
                DEFB      $85,$DB,$83,$49,$01
                DEFB      $80,$A6,$83,$E8,$01
                DEFB      $8B,$B6,$83,$49,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB  $02,$83,$E8,$83,$49,$01
                DEFB      $80,$A6,$83,$E8,$01
                DEFB      $87,$D0,$83,$49,$01
                DEFB      $80,$A6,$83,$E8,$01
                DEFB      $83,$E8,$83,$49,$01
                DEFB      $80,$A6,$83,$E8,$01
                DEFB      $87,$D0,$83,$49,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB  $03,$84,$63,$83,$49,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB      $88,$C6,$83,$49,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB      $84,$63,$83,$49,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB      $88,$C6,$83,$49,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB  $02,$83,$E8,$83,$49,$01
                DEFB      $80,$FA,$83,$E8,$01
                DEFB      $87,$D0,$83,$49,$01
                DEFB      $80,$FA,$83,$E8,$01
                DEFB      $83,$E8,$83,$49,$01
                DEFB      $80,$FA,$83,$E8,$01
                DEFB      $87,$D0,$83,$49,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB  $FF  ; End of Pattern

PAT16:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$83,$49,$01
                DEFB      $80,$A6,$83,$E8,$01
                DEFB      $85,$DB,$83,$49,$01
                DEFB      $80,$A6,$83,$E8,$01
                DEFB      $82,$ED,$83,$49,$01
                DEFB      $80,$A6,$83,$E8,$01
                DEFB      $85,$DB,$83,$49,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB  $02,$83,$E8,$83,$49,$01
                DEFB      $80,$A6,$83,$E8,$01
                DEFB      $87,$D0,$83,$49,$01
                DEFB      $80,$A6,$83,$E8,$01
                DEFB      $83,$E8,$83,$49,$01
                DEFB      $80,$A6,$83,$E8,$01
                DEFB      $87,$D0,$83,$49,$01
                DEFB      $01    ,$83,$E8,$01
                DEFB  $03,$84,$63,$82,$9B,$01
                DEFB      $01    ,$83,$49,$01
                DEFB      $88,$C6,$82,$9B,$01
                DEFB      $01    ,$83,$49,$01
                DEFB      $84,$63,$82,$9B,$01
                DEFB      $01    ,$83,$49,$01
                DEFB      $88,$C6,$82,$9B,$01
                DEFB      $01    ,$83,$49,$01
                DEFB  $02,$83,$E8,$84,$63,$01
                DEFB      $80,$FA,$85,$37,$01
                DEFB      $87,$D0,$84,$63,$01
                DEFB      $80,$FA,$85,$37,$01
                DEFB      $83,$E8,$84,$63,$01
                DEFB      $80,$FA,$85,$37,$01
                DEFB      $87,$D0,$84,$63,$01
                DEFB      $01    ,$85,$37,$01
                DEFB  $02,$85,$DB,$84,$63,$01
                DEFB      $80,$A6,$85,$37,$01
                DEFB      $8B,$B6,$84,$63,$01
                DEFB      $80,$A6,$85,$37,$01
                DEFB      $85,$DB,$84,$63,$01
                DEFB      $80,$A6,$85,$37,$01
                DEFB      $8B,$B6,$84,$63,$01
                DEFB      $01    ,$85,$37,$01
                DEFB  $02,$83,$E8,$84,$63,$01
                DEFB      $80,$A6,$85,$37,$01
                DEFB      $87,$D0,$84,$63,$01
                DEFB      $80,$A6,$85,$37,$01
                DEFB      $83,$E8,$84,$63,$01
                DEFB      $80,$A6,$85,$37,$01
                DEFB      $87,$D0,$84,$63,$01
                DEFB      $01    ,$85,$37,$01
                DEFB  $03,$84,$63,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB      $88,$C6,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB      $84,$63,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB      $88,$C6,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $02,$83,$E8,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $83,$E8,$83,$E8,$01
                DEFB      $80,$FA,$84,$E7,$01
                DEFB      $87,$D0,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $FF  ; End of Pattern

PAT17:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$83,$E8,$01
                DEFB      $80,$BB,$84,$E7,$01
                DEFB      $85,$DB,$83,$E8,$01
                DEFB      $80,$BB,$84,$E7,$01
                DEFB      $82,$ED,$83,$E8,$01
                DEFB      $80,$BB,$84,$E7,$01
                DEFB      $85,$DB,$83,$E8,$01
                DEFB      $01    ,$84,$E7,$01
                DEFB  $02,$83,$E8,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $87,$D0,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $83,$E8,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $87,$D0,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB  $03,$84,$63,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB      $88,$C6,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB      $84,$63,$00    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$83,$B0,$01
                DEFB      $81,$18,$84,$63,$01
                DEFB      $87,$D0,$83,$B0,$01
                DEFB      $81,$18,$84,$63,$01
                DEFB      $83,$E8,$83,$B0,$01
                DEFB      $81,$18,$84,$63,$01
                DEFB      $87,$D0,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB  $02,$85,$DB,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $8B,$B6,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $85,$DB,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $8B,$B6,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB  $02,$83,$E8,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $87,$D0,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $83,$E8,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $87,$D0,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB  $03,$84,$63,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB      $88,$C6,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB      $84,$63,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB      $88,$C6,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB  $02,$83,$E8,$83,$B0,$01
                DEFB      $81,$18,$84,$63,$01
                DEFB      $87,$D0,$83,$B0,$01
                DEFB      $81,$18,$84,$63,$01
                DEFB      $83,$E8,$83,$B0,$01
                DEFB      $81,$18,$84,$63,$01
                DEFB      $87,$D0,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB  $FF  ; End of Pattern

PAT18:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $85,$DB,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $82,$ED,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $85,$DB,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB  $02,$83,$E8,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $87,$D0,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $83,$E8,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $87,$D0,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB  $03,$84,$63,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB      $88,$C6,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB      $84,$63,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB      $88,$C6,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB  $02,$83,$E8,$83,$B0,$01
                DEFB      $81,$18,$84,$63,$01
                DEFB      $87,$D0,$83,$B0,$01
                DEFB      $81,$18,$84,$63,$01
                DEFB      $83,$E8,$83,$B0,$01
                DEFB      $81,$18,$84,$63,$01
                DEFB      $87,$D0,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB  $02,$85,$DB,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $8B,$B6,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $85,$DB,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $8B,$B6,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB  $02,$83,$E8,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $87,$D0,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $83,$E8,$83,$B0,$01
                DEFB      $80,$BB,$84,$63,$01
                DEFB      $87,$D0,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB  $03,$84,$63,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB      $88,$C6,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB      $84,$63,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB      $88,$C6,$83,$B0,$01
                DEFB      $01    ,$84,$63,$01
                DEFB  $02,$83,$E8,$00    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT19:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$00    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$85,$DB,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$85,$37,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT20:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$00    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$85,$37,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$84,$E7,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$84,$63,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$83,$E8,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT21:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$00    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$85,$DB,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$85,$37,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT22:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$00    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$85,$37,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $83,$E8,$84,$E7,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$84,$63,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$83,$E8,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT23:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$00    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$85,$DB,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$85,$37,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT24:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$00    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$85,$37,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $83,$E8,$84,$E7,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$84,$63,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$83,$E8,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT25:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$00    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$85,$DB,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$85,$37,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT26:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$00    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$00    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$84,$E7,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$85,$37,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $83,$E8,$84,$E7,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$84,$63,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$83,$E8,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT27:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$87,$D0,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$88,$C6,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$87,$D0,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$85,$DB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$76,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT28:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$87,$D0,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$88,$C6,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$87,$D0,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$D2,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$85,$DB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$3B,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT29:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$87,$D0,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$88,$C6,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$87,$D0,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$A6,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$85,$DB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$FA,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT30:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$85,$DB,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$86,$92,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$85,$DB,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$85,$37,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $FF  ; End of Pattern

PAT31:
                DEFW  900     ; Pattern tempo
                ;    Drum,Chan.1 ,Chan.2 ,Chan.3
                DEFB  $02,$82,$ED,$88,$C6,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $82,$ED,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$89,$D9,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$88,$C6,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$85,$DB,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $85,$DB,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $8B,$B6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $80,$BB,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $03,$84,$63,$00    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $84,$63,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB      $88,$C6,$01    ,$01
                DEFB      $01    ,$01    ,$01
                DEFB  $02,$83,$E8,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $83,$E8,$01    ,$01
                DEFB      $81,$18,$01    ,$01
                DEFB      $87,$D0,$01    ,$01
                DEFB      $01    ,$01    ,$01
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

	savebin "tritone_monday.tap",tap_b,tap_e-tap_b


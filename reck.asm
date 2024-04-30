 device zxspectrum128

	org $6500-13				; Origin
tap_b:	db $22,"NONAME",$22			;name		  	
	db "M"					;type		  	
	dw end-begin				;program length	  	
	dw begin				;load point		
	org $6500

;
;--------------------------------
; BUZZKICK
; ------------------------------




begin

	ld hl,musicdata1
	call play
	ret



	;engine code

play

	di

	ld (drumList+1),hl

	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a

	xor a
	ld (songSpeedComp+1),a
	ld (ch1out+1),a
	ld (ch2out+1),a

	ld a,128
	ld (ch1freq+1),a
	ld (ch2freq+1),a
	ld a,1
	ld (ch1delay1+1),a
	ld (ch2delay1+1),a
	ld a,16
	ld (ch1delay2+1),a
	ld (ch2delay2+1),a

	exx
	ld d,a
	ld e,a
	ld b,a
	ld c,a
	push hl
	exx

readRow

	ld c,(hl)
	inc hl

	bit 7,c
	jr z,noSpeed

	ld a,(hl)
	inc hl
	or a
	jr nz,noLoop

	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	jr readRow

noLoop

	ld (songSpeed+1),a

noSpeed

	bit 6,c
	jr z,noSustain1

	ld a,(hl)
	inc hl
	exx
	ld d,a
	ld e,a
	exx

noSustain1

	bit 5,c
	jr z,noSustain2

	ld a,(hl)
	inc hl
	exx
	ld b,a
	ld c,a
	exx

noSustain2

	bit 4,c
	jr z,noNote1

	ld a,(hl)
	ld d,a
	inc hl
	or a
	jr z,$+4
	ld a,$18
	ld (ch1out+1),a
	jr z,noNote1

	ld a,d
	ld (ch1freq+1),a
	srl a
	srl a
	ld (ch1delay2+1),a
	ld a,1
	ld (ch1delay1+1),a

	exx
	ld e,d
	exx

noNote1

	bit 3,c
	jr z,noNote2

	ld a,(hl)
	ld e,a
	inc hl
	or a
	jr z,$+4
;	ld a,$18
	ld	a, 32

	ld (ch2out+1),a
	jr z,noNote2

	ld a,e
	ld (ch2freq+1),a
	srl a
	srl a
	srl a
	ld (ch2delay2+1),a
	ld a,1
	ld (ch2delay1+1),a

	exx
	ld c,b
	exx

noNote2

	ld a,c
	and 7
	jr z,noDrum

playDrum

	push hl

	add a,a
	add a,a
	ld c,a
	ld b,0
drumList:
	ld hl,0
	add hl,bc

	ld a,(hl)				;length in 256-sample blocks
	ld b,a
	inc hl
	inc hl

	add a,a
	add a,a
	ld (songSpeedComp+1),a

	ld a,(hl)
	inc hl
	ld h,(hl)				;sample data
	ld l,a

	ld a,1
	ld (mask+1),a

	ld c,0
loop0
	ld a,(hl)				;7
mask:
	and 0					;7
	sub 1					;7
	sbc a,a					;4
	and $18					;7
	out ($84),a				;11
	ld a,(mask+1)			;13
	rlc a					;8
	ld (mask+1),a			;13
	jr nc,$+3				;7/12
	inc hl					;6

	jr $+2					;12
	jr $+2					;12
	jr $+2					;12
	jr $+2					;12
	nop						;4
	nop						;4
	ld a,0					;7

	dec c					;4
	jr nz,loop0			;7/12=168t
	djnz loop0

	pop hl

noDrum

songSpeed:
	ld a,0
	ld b,a
songSpeedComp:
	sub 0
	jr nc,$+3
	xor a
	ld c,a

	ld a,(songSpeedComp+1)
	sub b
	jr nc,$+3
	xor a
	ld (songSpeedComp+1),a

	ld a,c
	or a
	jp z,readRow

	ld c,a
	ld b,64

soundLoop

	ld a,3				;7
	dec a				;4
	jr nz,$-1			;7/12=50t
	jr $+2				;12

	dec d				;4
	jp nz,ch2			;10

ch1freq:
	ld d,0				;7

ch1delay1:
	ld a,0				;7
	dec a				;4
	jr nz,$-1			;7/12

ch1out:
	ld a,0				;7
	out ($84),a			;11

ch1delay2:
	ld a,0				;7
	dec a				;4
	jr nz,$-1			;7/12

	out ($84),a			;11

ch2

	ld a,3				;7
	dec a				;4
	jr nz,$-1			;7/12=50t
	jr $+2				;12

	dec e				;4
	jp nz,loop			;10

ch2freq:
	ld e,0				;7

ch2delay1:
	ld a,0				;7
	dec a				;4
	jr nz,$-1			;7/12

ch2out:
	ld a,0				;7
	out ($84),a			;11


ch2delay2:
	ld a,0				;7
	dec a				;4
	jr nz,$-1			;7/12

	out ($84),a			;11

loop

	dec b				;4
	jr nz,soundLoop		;7/12=168t

	ld b,64

envelopeDown

	exx

	dec e
	jp nz,noEnv1
	ld e,d

	ld hl,ch1delay2+1
	dec (hl)
	jr z,$+5
	ld hl,ch1delay1+1
	inc (hl)

noEnv1

	dec c
	jp nz,noEnv2
	ld c,b

	ld hl,ch2delay2+1
	dec (hl)
	jr z,$+5
	ld hl,ch2delay1+1
	inc (hl)

noEnv2

	exx

	dec c
	jp nz,soundLoop

	xor a
;	in a,($fe)
;	cpl
;	and $1f
;	jp z,readRow

	jp	readRow

	pop hl
	exx
	ei
	ret




musicData:
musicdata1:
 dw .song,0
.drums:
 dw 2,.drum0
 dw 4,.drum1
 dw 1,.drum2
 dw 4,.drum3
 dw 4,.drum4
 dw 4,.drum5
 dw 4,.drum6
.drum0:
 db $00,$00,$00,$00,$00,$00,$08,$c1,$ef,$e7,$ff,$ff,$ff,$ff,$0e,$00
 db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$ee,$ff,$ff,$ff
 db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$23,$00,$00,$00,$00,$00
 db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.drum1:
 db $00,$00,$fc,$ff,$ff,$03,$00,$00,$00,$00,$00,$00,$fe,$ff,$ff,$ff
 db $ff,$09,$00,$00,$00,$00,$f0,$ff,$ff,$ff,$6f,$25,$00,$00,$00,$00
 db $00,$00,$00,$dc,$ff,$ff,$ff,$0f,$00,$00,$00,$00,$00,$80,$cf,$ff
 db $ff,$ff,$14,$00,$00,$00,$00,$00,$80,$a4,$ee,$ff,$fb,$7b,$13,$00
 db $00,$00,$00,$00,$00,$80,$fe,$cf,$7f,$b6,$01,$00,$00,$00,$00,$00
 db $00,$80,$b4,$69,$c9,$0b,$00,$00,$40,$00,$00,$00,$00,$00,$f0,$f2
 db $30,$29,$14,$00,$00,$00,$00,$00,$00,$40,$80,$24,$1d,$3c,$84,$00
 db $00,$00,$00,$00,$00,$00,$00,$24,$40,$00,$54,$00,$00,$00,$00,$00
.drum2:
 db $00,$00,$15,$20,$55,$04,$09,$00,$00,$00,$02,$00,$00,$00,$84,$00
 db $00,$00,$40,$00,$00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.drum3:
.drum4:
.drum5:
.drum6:
.song:
.loop:
 db 249,28,3,99,252,252
 db 0
 db 40,5,252
 db 0
 db 19,126
 db 0
 db 24,0,126
 db 0
 db 26,106,0
 db 0
 db 24,0,106
 db 0
 db 27,126,0
 db 0
 db 24,0,126
 db 0
 db 25,252,252
 db 0
 db 8,252
 db 0
 db 19,126
 db 0
 db 24,0,126
 db 0
 db 26,189,0
 db 0
 db 24,168,189
 db 0
 db 27,106,168
 db 0
 db 24,141,106
 db 0
 db 25,252,252
 db 0
 db 8,252
 db 0
 db 19,126
 db 0
 db 24,0,126
 db 0
 db 26,106,0
 db 0
 db 24,0,106
 db 0
 db 27,126,0
 db 0
 db 24,0,126
 db 0
 db 25,252,252
 db 0
 db 8,252
 db 0
 db 19,126
 db 0
 db 24,0,126
 db 0
 db 26,189,0
 db 0
 db 26,168,189
 db 0
 db 27,106,168
 db 0
 db 26,141,106
 db 0
 db 25,252,252
 db 0
 db 8,252
 db 0
 db 19,126
 db 0
 db 24,0,126
 db 0
 db 26,106,0
 db 0
 db 24,0,106
 db 0
 db 27,126,0
 db 0
 db 24,0,126
 db 0
 db 25,252,252
 db 0
 db 8,252
 db 0
 db 19,126
 db 0
 db 24,0,126
 db 0
 db 26,189,0
 db 0
 db 24,168,189
 db 0
 db 27,106,168
 db 0
 db 24,141,106
 db 0
 db 25,252,252
 db 0
 db 8,252
 db 0
 db 19,126
 db 0
 db 24,0,126
 db 0
 db 26,106,0
 db 0
 db 24,0,106
 db 0
 db 27,126,0
 db 0
 db 24,0,126
 db 0
 db 25,252,252
 db 0
 db 8,252
 db 0
 db 19,126
 db 0
 db 26,0,126
 db 2
 db 26,189,0
 db 0
 db 26,168,189
 db 0
 db 27,106,168
 db 0
 db 26,141,106
 db 0
 db 57,99,212,53
 db 0
 db 0
 db 0
 db 27,106,59
 db 0
 db 16,0
 db 0
 db 26,89,53
 db 0
 db 16,0
 db 0
 db 19,106
 db 0
 db 16,0
 db 0
 db 25,212,212
 db 0
 db 0
 db 0
 db 27,106,44
 db 0
 db 16,0
 db 0
 db 18,159
 db 0
 db 16,141
 db 0
 db 27,89,53
 db 0
 db 24,119,59
 db 0
 db 25,212,141
 db 0
 db 0
 db 0
 db 27,106,212
 db 0
 db 16,0
 db 0
 db 26,89,44
 db 0
 db 16,0
 db 0
 db 27,106,106
 db 8,0
 db 24,0,106
 db 8,0
 db 25,212,106
 db 8,0
 db 8,106
 db 0
 db 27,106,119
 db 0
 db 24,0,106
 db 0
 db 26,159,100
 db 0
 db 26,141,141
 db 0
 db 19,89
 db 0
 db 18,119
 db 0
 db 25,252,63
 db 0
 db 0
 db 0
 db 27,126,70
 db 0
 db 16,0
 db 0
 db 26,106,63
 db 0
 db 16,0
 db 0
 db 19,126
 db 0
 db 16,0
 db 0
 db 25,252,252
 db 0
 db 0
 db 0
 db 27,126,53
 db 0
 db 16,0
 db 0
 db 18,189
 db 0
 db 16,168
 db 0
 db 27,106,63
 db 0
 db 24,141,70
 db 0
 db 25,252,168
 db 0
 db 0
 db 0
 db 27,126,252
 db 0
 db 16,0
 db 0
 db 26,106,53
 db 0
 db 16,0
 db 0
 db 27,126,64
 db 8,65
 db 24,0,66
 db 8,67
 db 25,252,68
 db 8,69
 db 8,70
 db 8,71
 db 27,126,150
 db 0
 db 26,0,126
 db 0
 db 26,189,119
 db 2
 db 26,168,168
 db 8,0
 db 26,106,212
 db 8,0
 db 26,141,141
 db 8,0
 db 25,212,53
 db 0
 db 0
 db 0
 db 27,106,59
 db 0
 db 16,0
 db 0
 db 26,89,53
 db 0
 db 16,0
 db 0
 db 19,106
 db 0
 db 16,0
 db 0
 db 25,212,212
 db 0
 db 0
 db 0
 db 27,106,44
 db 0
 db 16,0
 db 0
 db 18,159
 db 0
 db 16,141
 db 0
 db 27,89,53
 db 0
 db 24,119,59
 db 0
 db 25,212,141
 db 0
 db 0
 db 0
 db 27,106,212
 db 0
 db 16,0
 db 0
 db 26,89,44
 db 0
 db 16,0
 db 0
 db 27,106,106
 db 8,0
 db 24,0,106
 db 8,0
 db 25,212,106
 db 8,0
 db 8,106
 db 0
 db 27,106,119
 db 0
 db 24,0,106
 db 0
 db 26,159,100
 db 0
 db 26,141,141
 db 0
 db 19,89
 db 0
 db 18,119
 db 0
 db 25,252,63
 db 0
 db 0
 db 0
 db 27,126,70
 db 0
 db 16,0
 db 0
 db 26,106,63
 db 0
 db 16,0
 db 0
 db 19,126
 db 0
 db 16,0
 db 0
 db 25,252,252
 db 0
 db 0
 db 0
 db 27,126,53
 db 0
 db 16,0
 db 0
 db 18,189
 db 0
 db 16,168
 db 0
 db 27,106,63
 db 0
 db 24,141,70
 db 0
 db 25,252,168
 db 0
 db 0
 db 0
 db 27,126,252
 db 0
 db 16,0
 db 0
 db 26,106,53
 db 0
 db 16,0
 db 0
 db 27,126,126
 db 8,0
 db 24,0,126
 db 8,0
 db 25,252,126
 db 8,0
 db 9,126
 db 0
 db 25,126,141
 db 0
 db 8,126
 db 0
 db 120,24,24,252,94
 db 0
 db 0
 db 0
 db 24,127,83
 db 24,128,84
 db 26,129,85
 db 24,130,86
 db 89,12,212,212
 db 0
 db 42,12,212
 db 0
 db 19,106
 db 0
 db 8,106
 db 0
 db 18,89
 db 0
 db 8,89
 db 0
 db 19,106
 db 0
 db 24,0,106
 db 0
 db 25,212,212
 db 0
 db 8,212
 db 0
 db 19,106
 db 0
 db 8,106
 db 0
 db 18,119
 db 0
 db 8,119
 db 0
 db 2
 db 0
 db 2
 db 0
 db 25,212,212
 db 0
 db 8,212
 db 0
 db 19,106
 db 0
 db 8,106
 db 0
 db 18,89
 db 0
 db 8,89
 db 0
 db 19,106
 db 0
 db 8,106
 db 0
 db 17,79
 db 0
 db 24,0,79
 db 0
 db 27,79,0
 db 0
 db 24,0,79
 db 0
 db 26,98,0
 db 16,97
 db 26,96,89
 db 24,95,89
 db 27,94,92
 db 24,93,93
 db 26,92,94
 db 24,91,95
 db 121,3,4,168,98
 db 8,97
 db 0
 db 0
 db 19,84
 db 0
 db 8,84
 db 0
 db 122,99,99,84,70
 db 16,84
 db 18,84
 db 16,85
 db 19,86
 db 18,87
 db 16,88
 db 0
 db 89,3,168,168
 db 0
 db 40,4,168
 db 0
 db 19,84
 db 0
 db 8,84
 db 0
 db 122,99,99,84,70
 db 16,84
 db 18,84
 db 16,85
 db 19,86
 db 16,87
 db 18,88
 db 0
 db 25,168,168
 db 0
 db 42,4,168
 db 0
 db 83,12,63
 db 16,84
 db 40,16,63
 db 8,84
 db 18,70
 db 0
 db 24,84,70
 db 0
 db 11,84
 db 0
 db 0
 db 0
 db 81,99,63
 db 0
 db 56,99,0,63
 db 0
 db 27,63,0
 db 0
 db 24,0,63
 db 0
 db 24,71,0
 db 16,72
 db 24,73,71
 db 24,72,72
 db 26,71,73
 db 120,2,3,71,72
 db 2
 db 0
 db 121,3,99,212,53
 db 0
 db 1
 db 0
 db 27,106,59
 db 0
 db 16,0
 db 0
 db 26,89,53
 db 0
 db 16,0
 db 0
 db 19,106
 db 0
 db 16,0
 db 0
 db 25,212,212
 db 0
 db 0
 db 0
 db 27,106,44
 db 0
 db 16,0
 db 0
 db 18,159
 db 0
 db 16,141
 db 0
 db 27,89,53
 db 0
 db 24,119,59
 db 0
 db 25,212,141
 db 0
 db 0
 db 0
 db 27,106,212
 db 0
 db 16,0
 db 0
 db 26,89,44
 db 0
 db 16,0
 db 0
 db 27,106,106
 db 8,0
 db 24,0,106
 db 8,0
 db 25,212,106
 db 8,0
 db 8,106
 db 0
 db 27,106,119
 db 0
 db 24,0,106
 db 0
 db 26,159,100
 db 0
 db 26,141,141
 db 0
 db 19,89
 db 0
 db 18,119
 db 0
 db 25,252,63
 db 0
 db 0
 db 0
 db 27,126,70
 db 0
 db 16,0
 db 0
 db 26,106,63
 db 0
 db 16,0
 db 0
 db 19,126
 db 0
 db 16,0
 db 0
 db 25,252,252
 db 0
 db 0
 db 0
 db 27,126,53
 db 0
 db 16,0
 db 0
 db 18,189
 db 0
 db 16,168
 db 0
 db 27,106,63
 db 0
 db 24,141,70
 db 0
 db 25,252,168
 db 0
 db 0
 db 0
 db 27,126,252
 db 0
 db 16,0
 db 0
 db 26,106,53
 db 0
 db 16,0
 db 0
 db 27,126,126
 db 8,0
 db 24,0,126
 db 8,0
 db 25,252,126
 db 8,0
 db 8,126
 db 0
 db 27,126,141
 db 0
 db 24,0,126
 db 0
 db 26,189,119
 db 0
 db 26,168,168
 db 0
 db 19,106
 db 0
 db 18,141
 db 0
 db 25,212,53
 db 0
 db 0
 db 0
 db 27,106,59
 db 0
 db 16,0
 db 0
 db 26,89,53
 db 0
 db 16,0
 db 0
 db 19,106
 db 0
 db 16,0
 db 0
 db 25,212,212
 db 0
 db 0
 db 0
 db 27,106,44
 db 0
 db 16,0
 db 0
 db 18,159
 db 0
 db 16,141
 db 0
 db 27,89,53
 db 0
 db 24,119,59
 db 0
 db 25,212,141
 db 0
 db 0
 db 0
 db 27,106,212
 db 0
 db 16,0
 db 0
 db 26,89,44
 db 0
 db 16,0
 db 0
 db 27,106,106
 db 8,0
 db 24,0,106
 db 8,0
 db 25,212,106
 db 8,0
 db 8,106
 db 0
 db 27,106,119
 db 0
 db 24,0,106
 db 0
 db 26,159,100
 db 0
 db 26,141,141
 db 0
 db 19,89
 db 0
 db 18,119
 db 0
 db 25,252,63
 db 0
 db 0
 db 0
 db 27,126,70
 db 0
 db 16,0
 db 0
 db 26,106,63
 db 0
 db 16,0
 db 0
 db 19,126
 db 0
 db 16,0
 db 0
 db 25,252,252
 db 0
 db 0
 db 0
 db 27,126,53
 db 0
 db 16,0
 db 0
 db 18,189
 db 0
 db 16,168
 db 0
 db 27,106,63
 db 0
 db 24,141,70
 db 0
 db 89,12,252,168
 db 0
 db 0
 db 0
 db 11,252
 db 0
 db 0
 db 0
 db 10,53
 db 0
 db 0
 db 0
 db 43,3,126
 db 8,0
 db 88,1,126,126
 db 24,0,0
 db 25,126,126
 db 24,0,0
 db 24,126,126
 db 16,0
 db 27,126,141
 db 0
 db 24,141,126
 db 0
 db 26,126,119
 db 0
 db 58,12,119,168
 db 0
 db 83,12,238
 db 0
 db 2
 db 0
 db 121,3,44,252,63
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 24,0,0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 db 0
 dw $0080,.loop

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
	savebin "reck.tap",tap_b,tap_e-tap_b



 device zxspectrum128

	org $6500-13				; Origin
tap_b:	db $22,"NONAME",$22			;name		  	HEADER
	db "M"					;type		  	HEADER
	dw end-begin				;program length	  	HEADER
	dw begin				;load point		HEADER
	org $6500
begin:




; 	TriTone Digital Drums.
;
;       USE SJASM to assemble
; -----------------------------------------


	ld hl,music_data
	call play
	ret
	


play

	di

	ld (drumList),hl
	
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	
	push iy
	exx
	push hl
	ld (spOld),sp

	ld hl,0				;HL' equ acc3
	ld de,0				;DE' equ add2
	ld bc,$8080			;C' equ duty 1,B' equ duty 2
	exx
	ld de,0				;DE equ add1
	ld ix,0				;IX equ acc2
	ld iy,0				;IY equ acc1
	ld sp,0				;SP equ add3
	
	;BC is sample/frame counter
	;HL is the song data ptr, to minimize row transition gaps
	
playRow

	ld a,(hl)			;drum and speed
	inc hl
	
	or a
	jp nz,noLoop
	
	ld a,(hl)			;go loop
	inc hl
	ld h,(hl)
	ld l,a
	jp playRow
	
noLoop

	cp $20
	jp nc,playDrum

	and $1f
	ld (frames),a
	
	ld a,(hl)			;ch1
	inc hl
	or a
	jr z,skipCh1
	dec a
	jp nz,noteCh1
	
	ld de,0				;mute ch1
	ld iy,0
	exx
	ld c,0
	exx
	
	jp skipCh1
	
noteCh1

	inc a
	ld c,a
	and $f0
	exx
	ld c,a
	exx
	
	ld a,c
	and $0f
	ld d,a				;msb
	
	ld e,(hl)			;lsb
	inc hl

skipCh1
	
	ld a,(hl)			;ch2
	inc hl
	or a
	jr z,skipCh2
	dec a
	jp nz,noteCh2
	
	exx					;mute ch2
	ld de,0
	ld b,0
	exx
	ld ix,0
	
	jp skipCh2
	
noteCh2

	inc a
	ld c,a
	and $f0
	exx
	ld b,a
	exx
	
	ld a,c
	and $0f
	exx
	ld d,a				;msb
	exx
	
	ld a,(hl)
	inc hl
	exx
	ld e,a				;lsb
	exx
	
skipCh2

	ld a,(hl)			;ch3
	inc hl
	or a
	jr z,skipCh3
	dec a
	jp nz,noteCh3
	
	ld sp,0				;mute ch3
	exx
	ld hl,0
	exx
	ld (duty3),a
	
	jp skipCh3
	
noteCh3

	inc a
	ld c,a
	and $f0
	ld (duty3),a
	
	ld a,c
	and $0f
	ld b,a				;msb
	
	ld c,(hl)			;lsb
	inc hl
	ld (ch3sp),bc
	
ch3sp equ $+1
	ld sp,0

skipCh3
			
duty3 equ $+1
	ld bc,0				;B equ sample counter,C equ duty3

frames equ $+1
	ld a,0
	
frameLoop

	exa					;4
	
sampleLoop

	add iy,de			;15
	ld a,iyh			;8
	exx					;4
	cp c				;4
	sbc a,a				;4
	add ix,de			;15
	out ($84),a			;11
	
	ld a,ixh			;8
	cp b				;4
	sbc a,a				;4
	out ($84),a			;11

	add hl,sp			;11
	ld a,h				;4
	exx					;4
	cp c				;4
	sbc a,a				;4
	out ($84),a			;11

	nop					;4 for 8t alignment
	dec b				;4
	jp nz,sampleLoop	;10 equ 144t

	exa				;4
	dec a				;4
	jr nz,frameLoop		;12 equ extra 24t, also aligned to 8t

;	in a,($fe)			;check keyboard
;	cpl
;	and $1f
	jp playRow

	
	
stopPlayer

spOld equ $+1

	ld sp,0
	pop hl
	exx
	pop iy
	ei
	ret



playDrum

	ld (hlOld),hl
	
	rra
	rra
	rra
	and $1c

	ld c,a
	ld b,0
	
drumList equ $+1
	ld hl,0
	add hl,bc

	ld b,(hl)			;length in frames
	inc hl
	inc hl

	ld a,(hl)
	inc hl
	ld h,(hl)			;sample data
	ld l,a

	ld a,1
	ld (drumMask),a

	ld c,0
	
drumLoop

	ld a,(hl)			;7
	
drumMask equ $+1
	and 0				;7
	sub 1				;7
	sbc a,a				;4
	and $18				;7
	out ($84),a			;11
	
	ld a,(drumMask)		;13
	rlc a				;8
	ld (drumMask),a		;13
	
	jr nc,$+3			;7/12
	inc hl				;6

	jr $+2				;12
	jr $+2				;12
	nop					;4
	nop					;4
	ld a,0				;7

	dec c				;4
	jr nz,drumLoop		;7/12 equ 144t
	
	djnz drumLoop

hlOld equ $+1
	ld hl,0
	
	jp playRow
	
;compiled music data

music_data
	dw .song,0
.drums
	dw 4,.drum0
	dw 4,.drum1
	dw 4,.drum2
	dw 4,.drum3
	dw 4,.drum4
	dw 4,.drum5
	dw 4,.drum6
.song
.loop
	db $20
	db $07,$e3,$6a,$f5,$25,$01
	db $0b,$e3,$17,$f4,$a2,$00
	db $0b,$e3,$78,$f5,$33,$00
	db $0b,$e3,$ad,$f5,$82,$00
	db $40
	db $07,$e3,$78,$f5,$33,$00
	db $0b,$e3,$17,$f4,$a2,$00
	db $0b,$e3,$78,$f5,$33,$00
	db $0b,$e3,$ad,$f5,$82,$00
	db $0b,$e3,$78,$f5,$33,$00
	db $0b,$e3,$17,$f4,$a2,$00
	db $20
	db $07,$e3,$78,$f5,$33,$00
	db $0b,$e3,$ad,$f5,$82,$00
	db $40
	db $07,$e4,$e8,$f6,$f1,$00
	db $0b,$e2,$74,$f3,$78,$00
	db $0b,$e4,$e8,$f6,$f1,$00
	db $0b,$e2,$74,$f3,$78,$00
	db $20
	db $07,$e3,$6a,$f5,$25,$00
	db $0b,$f3,$09,$e4,$94,$00
	db $0b,$e3,$6a,$f5,$25,$00
	db $0b,$f3,$9f,$e5,$74,$00
	db $40
	db $07,$e3,$6a,$f5,$25,$00
	db $0b,$f3,$09,$e4,$94,$00
	db $0b,$e3,$6a,$f5,$25,$00
	db $0b,$f3,$9f,$e5,$74,$00
	db $0b,$e3,$6a,$f5,$25,$00
	db $0b,$f3,$09,$e4,$94,$00
	db $20
	db $07,$e3,$6a,$f5,$25,$00
	db $0b,$f3,$9f,$e5,$74,$00
	db $40
	db $07,$e4,$da,$f6,$e3,$00
	db $0b,$f2,$66,$e3,$6a,$00
	db $0b,$e4,$da,$f6,$e3,$00
	db $0b,$f2,$66,$e3,$6a,$00
	db $20
	db $07,$f3,$78,$e2,$74,$00
	db $0b,$f3,$46,$e2,$2f,$00
	db $40
	db $07,$f3,$17,$e2,$74,$00
	db $0b,$f2,$eb,$e2,$99,$00
	db $20
	db $07,$f2,$c1,$e2,$74,$00
	db $0b,$f2,$eb,$e2,$2f,$00
	db $40
	db $07,$f3,$78,$e2,$74,$00
	db $0b,$f3,$17,$e2,$99,$00
	db $20
	db $07,$f3,$78,$e2,$74,$00
	db $0b,$f3,$ad,$e2,$2f,$00
	db $40
	db $07,$f3,$e5,$e2,$74,$00
	db $0b,$f4,$20,$e2,$51,$00
	db $20
	db $07,$f4,$5f,$e2,$74,$00
	db $0b,$f4,$20,$e2,$2f,$00
	db $40
	db $07,$f3,$ad,$e2,$99,$00
	db $0b,$f3,$78,$e2,$74,$00
	db $40
	db $07,$c3,$6a,$e5,$25,$f6,$e3
	db $20
	db $07,$00,$00,$00
	db $40
	db $07,$00,$00,$00
	db $20
	db $07,$00,$00,$00
	db $40
	db $07,$00,$00,$00
	db $40
	db $07,$00,$00,$00
	db $20
	db $07,$00,$00,$00
	db $20
	db $07,$00,$00,$00
	db $40
	db $07,$00,$00,$00
	db $20
	db $07,$00,$00,$00
	db $40
	db $07,$00,$00,$00
	db $20
	db $07,$00,$00,$00
	db $40
	db $07,$00,$00,$00
	db $40
	db $07,$00,$00,$00
	db $20
	db $07,$00,$00,$00
	db $40
	db $07,$00,$00,$00
	db $20
	db $07,$00,$00,$00
	db $40
	db $07,$00,$00,$00
	db $20
	db $07,$00,$00,$00
	db $40
	db $07,$00,$00,$00
	db $0b,$c3,$78,$e2,$c1,$f3,$ad
	db $0b,$00,$00,$f3,$17
	db $0b,$00,$00,$f3,$ad
	db $0b,$00,$00,$f4,$20
	db $0b,$00,$00,$00
	db $0b,$00,$00,$f3,$78
	db $0b,$00,$00,$f4,$20
	db $0b,$00,$00,$f4,$a2
	db $0b,$00,$00,$00
	db $0b,$00,$00,$f3,$ad
	db $0b,$00,$00,$f4,$a2
	db $0b,$00,$00,$f5,$33
	db $0b,$00,$00,$00
	db $0b,$00,$00,$f4,$20
	db $0b,$00,$00,$f5,$33
	db $0b,$00,$00,$f5,$82
	db $0b,$00,$00,$00
	db $0b,$00,$00,$f4,$a2
	db $0b,$00,$00,$f5,$82
	db $0b,$00,$00,$f6,$2f
	db $0b,$c2,$eb,$e2,$51,$f3,$17
	db $0b,$00,$00,$f2,$99
	db $0b,$00,$00,$f3,$17
	db $0b,$00,$00,$f3,$78
	db $0b,$00,$00,$00
	db $0b,$00,$00,$f2,$eb
	db $0b,$00,$00,$f3,$78
	db $0b,$00,$00,$f3,$e5
	db $0b,$00,$00,$00
	db $0b,$00,$00,$f3,$17
	db $0b,$00,$00,$f3,$e5
	db $0b,$00,$00,$f4,$5f
	db $0b,$00,$00,$00
	db $0b,$00,$00,$f3,$78
	db $0b,$00,$00,$f4,$5f
	db $0b,$00,$00,$f4,$a2
	db $0b,$00,$00,$00
	db $0b,$00,$00,$f3,$e5
	db $0b,$00,$00,$f4,$a2
	db $0b,$00,$00,$f5,$33
	db $0b,$c3,$17,$e2,$74,$f3,$46
	db $0b,$00,$00,$f2,$c1
	db $0b,$00,$00,$f3,$46
	db $0b,$00,$00,$f3,$ad
	db $0b,$00,$00,$00
	db $0b,$00,$00,$f3,$17
	db $0b,$00,$00,$f3,$ad
	db $0b,$00,$00,$f4,$20
	db $0b,$00,$00,$00
	db $0b,$00,$00,$f3,$46
	db $0b,$00,$00,$f4,$20
	db $0b,$00,$00,$f4,$a2
	db $0b,$00,$00,$00
	db $0b,$00,$00,$f3,$ad
	db $0b,$00,$00,$f4,$a2
	db $0b,$00,$00,$f4,$e8
	db $0b,$00,$00,$00
	db $0b,$00,$00,$f4,$20
	db $0b,$00,$00,$f4,$e8
	db $0b,$00,$00,$f5,$82
	db $0b,$c3,$78,$e2,$c1,$f3,$ad
	db $0b,$00,$00,$f3,$17
	db $0b,$00,$00,$f3,$ad
	db $0b,$00,$00,$f4,$20
	db $0b,$00,$00,$00
	db $0b,$00,$00,$f3,$78
	db $0b,$00,$00,$f4,$20
	db $0b,$00,$00,$f4,$a2
	db $0b,$00,$00,$00
	db $0b,$00,$00,$f3,$ad
	db $0b,$00,$00,$f4,$a2
	db $0b,$00,$00,$f5,$33
	db $0b,$00,$00,$00
	db $0b,$00,$00,$f4,$20
	db $0b,$00,$00,$f5,$33
	db $0b,$00,$00,$f5,$82
	db $0b,$00,$00,$00
	db $0b,$00,$00,$f4,$a2
	db $0b,$00,$00,$f5,$82
	db $0b,$00,$00,$f6,$2f
	db $20
	db $07,$00,$00,$f3,$ad
	db $0b,$00,$00,$f3,$17
	db $0b,$00,$00,$f3,$ad
	db $0b,$00,$00,$f4,$20
	db $40
	db $07,$00,$00,$00
	db $0b,$00,$00,$f3,$78
	db $0b,$00,$00,$f4,$20
	db $0b,$00,$00,$f4,$a2
	db $0b,$00,$00,$00
	db $0b,$00,$00,$f3,$ad
	db $20
	db $07,$00,$00,$f4,$a2
	db $0b,$00,$00,$f5,$33
	db $40
	db $07,$00,$00,$00
	db $0b,$00,$00,$f4,$20
	db $0b,$00,$00,$f5,$33
	db $0b,$00,$00,$f5,$82
	db $40
	db $07,$00,$00,$00
	db $0b,$00,$00,$f4,$a2
	db $20
	db $07,$00,$00,$f5,$82
	db $0b,$00,$00,$f6,$2f
	db $20
	db $07,$c2,$eb,$e2,$51,$f3,$17
	db $0b,$00,$00,$f2,$99
	db $0b,$00,$00,$f3,$17
	db $0b,$00,$00,$f3,$78
	db $40
	db $07,$00,$00,$00
	db $0b,$00,$00,$f2,$eb
	db $0b,$00,$00,$f3,$78
	db $0b,$00,$00,$f3,$e5
	db $0b,$00,$00,$00
	db $0b,$00,$00,$f3,$17
	db $20
	db $07,$00,$00,$f3,$e5
	db $0b,$00,$00,$f4,$5f
	db $40
	db $07,$00,$00,$00
	db $0b,$00,$00,$f3,$78
	db $0b,$00,$00,$f4,$5f
	db $0b,$00,$00,$f4,$a2
	db $40
	db $07,$00,$00,$00
	db $0b,$00,$00,$f3,$e5
	db $20
	db $07,$00,$00,$f4,$a2
	db $0b,$00,$00,$f5,$33
	db $20
	db $07,$c3,$17,$e2,$74,$f3,$46
	db $0b,$00,$00,$f2,$c1
	db $0b,$00,$00,$f3,$46
	db $0b,$00,$00,$f3,$ad
	db $40
	db $07,$00,$00,$00
	db $0b,$00,$00,$f3,$17
	db $0b,$00,$00,$f3,$ad
	db $0b,$00,$00,$f4,$20
	db $0b,$00,$00,$00
	db $0b,$00,$00,$f3,$46
	db $20
	db $07,$00,$00,$f4,$20
	db $0b,$00,$00,$f4,$a2
	db $40
	db $07,$00,$00,$00
	db $0b,$00,$00,$f3,$ad
	db $0b,$00,$00,$f4,$a2
	db $0b,$00,$00,$f4,$e8
	db $40
	db $07,$00,$00,$00
	db $0b,$00,$00,$f4,$20
	db $20
	db $07,$00,$00,$f4,$e8
	db $0b,$00,$00,$f5,$82
	db $20
	db $07,$c3,$78,$e2,$c1,$f3,$ad
	db $0b,$00,$00,$f3,$17
	db $0b,$00,$00,$f3,$ad
	db $0b,$00,$00,$f4,$20
	db $40
	db $07,$00,$00,$00
	db $0b,$00,$00,$f3,$78
	db $0b,$00,$00,$f4,$20
	db $0b,$00,$00,$f4,$a2
	db $0b,$00,$00,$00
	db $0b,$00,$00,$f3,$ad
	db $20
	db $07,$00,$00,$f4,$a2
	db $0b,$00,$00,$f5,$33
	db $40
	db $07,$00,$00,$00
	db $0b,$00,$00,$f4,$20
	db $0b,$00,$00,$f5,$33
	db $0b,$00,$00,$f5,$82
	db $40
	db $07,$00,$00,$00
	db $0b,$00,$00,$f4,$a2
	db $20
	db $07,$00,$00,$f5,$82
	db $0b,$00,$00,$f6,$2f
	db $0b,$00,$e5,$33,$f6,$f1
	db $0b,$00,$00,$00
	db $0b,$00,$00,$00
	db $0b,$00,$00,$00
	db $0b,$00,$00,$00
	db $0b,$00,$00,$00
	db $0b,$00,$00,$00
	db $0b,$00,$00,$00
	db $0b,$00,$00,$00
	db $0b,$00,$00,$00
	db $0b,$00,$00,$00
	db $0b,$00,$00,$00
	db $0b,$00,$00,$00
	db $0b,$00,$00,$00
	db $0b,$00,$00,$00
	db $0b,$00,$00,$00
	db $0b,$00,$00,$00
	db $0b,$00,$00,$00
	db $0b,$00,$00,$00
	db $0b,$00,$00,$00
	db $0b,$00,$00,$00
	db $00
	dw .loop
.drum0
 db $00,$ff,$ff,$ff,$e0,$00,$00,$00,$00,$00,$00,$00,$03,$ff,$ff,$ff
 db $ff,$ff,$ff,$80,$00,$00,$00,$00,$00,$00,$00,$0f,$ff,$ff,$ff,$ff
 db $ff,$ff,$00,$00,$00,$00,$00,$00,$00,$00,$1f,$ff,$ff,$ff,$ff,$ff
 db $fc,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$ff,$ff,$ff,$ff,$ff
 db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$80,$00,$00,$00,$00,$00,$00,$00,$00
 db $00,$00,$00,$00,$00,$00,$00,$7f,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
 db $ff,$ff,$ff,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
 db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.drum1
 db $ff,$f8,$80,$00,$06,$71,$ff,$c0,$0f,$ff,$c6,$00,$00,$00,$e3,$c0
 db $f0,$7f,$07,$80,$03,$f8,$8c,$60,$c0,$00,$ff,$c7,$ff,$f8,$f1,$8c
 db $03,$c0,$60,$1f,$ce,$03,$07,$81,$ff,$f8,$3f,$00,$01,$80,$00,$00
 db $00,$00,$03,$ff,$ff,$ff,$ff,$ff,$80,$00,$00,$00,$00,$03,$ff,$ff
 db $ff,$ff,$ff,$80,$00,$00,$00,$00,$03,$ff,$ff,$ff,$ff,$ff,$80,$00
 db $00,$00,$00,$03,$ff,$ff,$ff,$ff,$ff,$80,$00,$00,$00,$00,$03,$ff
 db $ff,$ff,$ff,$ff,$80,$00,$00,$00,$00,$00,$00,$00,$00,$7f,$ff,$ff
 db $ff,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.drum2
.drum3
.drum4
.drum5
.drum6



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

	savebin "tritone_digi.tap",tap_b,tap_e-tap_b



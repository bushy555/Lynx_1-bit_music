 device zxspectrum128

	org $6500-13				; Origin
tap_b:	db $22,"NONAME",$22			;name		  	
	db "M"					;type		  	
	dw end-begin				;program length	  	
	dw begin				;load point		
	org $6500
begin:




;Octode beeper music engine by Shiru (shiru@mail.ru) 02'11
;Eight channels of tone
;One channel of interrupting drums, no ROM data required
;Feel free to do whatever you want with the code, it is PD




	ld hl,musicData
	call play
	ret


	;engine code

OP_NOP	equ #00
OP_RRA	equ #1f
OP_SCF	equ #37
OP_ORC	equ #b1


play
	di
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (readNotes.speed),de

	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (readNotes.ptr),de

	ld e,(hl)
	inc hl
	ld d,(hl)
	ld (readNotes.loop),de

	in a,(#1f)
	and #1f
	ld a,OP_NOP
	jr nz,$+4
	ld a,OP_ORC
	ld (soundLoop.checkKempston),a

readNotes
.ptr=$+1
	ld hl,0
	ld a,(hl)
	inc hl
	cp 240
	jr c,.noLoop
	cp 255
	jr nz,.drum
.loop=$+1
	ld hl,0
	ld (.ptr),hl
	jp soundLoop.checkKey

.drum
	ld (.ptr),hl
	ld b,8
	ld hl,.drum2
	ld (hl),OP_NOP
	inc hl
	djnz $-3
	sub 240
	jr z,.drum0
	ld b,a
	ld hl,.drum2
	ld (hl),OP_RRA
	inc hl
	djnz $-3
.drum0
	ld bc,100*256
.drum1
	ld a,c
.drum2=$
	rra
	rra
	rra
	rra
	rra
	rra
	rra
	rra
	xor b
	and 16
	out (#84),a
	bit 0,(ix)
	inc c
	inc c
	xor a
	out (#84),a
	djnz .drum1

	ld hl,(.ptr)

.noLoop
	ld b,(hl)
	inc hl

	ld c,OP_SCF

	xor a
	rr b
	jr nc,.ch1
	ld a,(hl)
	inc hl
	ld (soundLoop.frq0),a
	ld a,c
.ch1
	ld (soundLoop.off0),a

	xor a
	rr b
	jr nc,.ch2
	ld a,(hl)
	inc hl
	ld (soundLoop.frq1),a
	ld a,c
.ch2
	ld (soundLoop.off1),a

	xor a
	rr b
	jr nc,.ch3
	ld a,(hl)
	inc hl
	ld (soundLoop.frq2),a
	ld a,c
.ch3
	ld (soundLoop.off2),a

	xor a
	rr b
	jr nc,.ch4
	ld a,(hl)
	inc hl
	ld (soundLoop.frq3),a
	ld a,c
.ch4
	ld (soundLoop.off3),a

	xor a
	rr b
	jr nc,.ch5
	ld a,(hl)
	inc hl
	ld (soundLoop.frq4),a
	ld a,c
.ch5
	ld (soundLoop.off4),a

	xor a
	rr b
	jr nc,.ch6
	ld a,(hl)
	inc hl
	ld (soundLoop.frq5),a
	ld a,c
.ch6
	ld (soundLoop.off5),a

	xor a
	rr b
	jr nc,.ch7
	ld a,(hl)
	inc hl
	ld (soundLoop.frq6),a
	ld a,c
.ch7
	ld (soundLoop.off6),a

	xor a
	rr b
	jr nc,.chDone
	ld a,(hl)
	inc hl
	ld (soundLoop.frq7),a
	ld a,c
.chDone
	ld (soundLoop.off7),a

	ld (.ptr),hl

.prevBC=$+1
	ld bc,0
.speed=$+1
	ld hl,0
	and a

soundLoop
	xor a		;4

	dec b		;4
	jr z,.la0	;7/12
	nop			;4
	jr .lb0		;12
.la0
.frq0=$+1
	ld b,0		;7
.off0=$
	scf			;4
.lb0
	dec c		;4
	jr z,.la1	;7/12
	nop			;4
	jr .lb1		;12
.la1
.frq1=$+1
	ld c,0		;7
.off1=$
	scf			;4
.lb1
	dec d		;4
	jr z,.la2	;7/12
	nop			;4
	jr .lb2		;12
.la2
.frq2=$+1
	ld d,0		;7
.off2=$
	scf			;4
.lb2
	dec e		;4
	jr z,.la3	;7/12
	nop			;4
	jr .lb3		;12
.la3
.frq3=$+1
	ld e,0		;7
.off3=$
	scf			;4
.lb3
	exx			;4
	out (#84),a	;11
	dec b		;4
	jr z,.la4	;7/12
	nop			;4
	jr .lb4		;12
.la4
.frq4=$+1
	ld b,0		;7
.off4=$
	scf			;4
.lb4
	dec c		;4
	jr z,.la5	;7/12
	nop			;4
	jr .lb5		;12
.la5
.frq5=$+1
	ld c,0		;7
.off5=$
	scf			;4
.lb5
	dec d		;4
	jr z,.la6	;7/12
	nop			;4
	jr .lb6		;12
.la6
.frq6=$+1
	ld d,0		;7
.off6=$
	scf			;4
.lb6
	dec e		;4
	jr z,.la7	;7/12
	nop			;4
	jr .lb7		;12
.la7
.frq7=$+1
	ld e,0		;7
.off7=$
	scf			;4
.lb7
	exx			;4
	sbc a,a		;4
	and 16		;7
	out (#84),a	;11
	dec l		;4
	jp nz,soundLoop	;10=275t
	dec h		;4
	jp nz,soundLoop	;10

	ld (readNotes.prevBC),bc

	xor a
	out (#84),a

.checkKey
	in a,(#1f)
	and #1f
	ld c,a
	in a,(#84)
	cpl
.checkKempston=$
	or c
	and #1f
	jp z,readNotes

stopPlayer
	ld iy,#5c3a
	ld hl,#2758
	exx
	ei
	ret



musicData
	dw #0600
	dw .start
	dw .loop
.start
	db #00,#fe    ,#e7,#4d,#39,#30,#4d,#39,#30
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#90                ,#2b        ,#2b
	db #00,#00                                
	db #00,#6c        ,#2b,#40    ,#2b,#40    
	db #00,#00                                
	db #00,#90                ,#30        ,#30
	db #00,#00                                
	db #00,#24        ,#2b        ,#2b        
	db #00,#00                                
	db #00,#90                ,#26        ,#26
	db #00,#00                                
	db #00,#6e    ,#ad,#39,#48    ,#39,#48    
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#90                ,#33        ,#33
	db #00,#00                                
	db #00,#6c        ,#39,#4d    ,#39,#4d    
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#92    ,#f5        ,#3d        ,#3d
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#fe    ,#e7,#4d,#39,#30,#4d,#39,#30
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#90                ,#2b        ,#2b
	db #00,#00                                
	db #00,#6c        ,#2b,#40    ,#2b,#40    
	db #00,#00                                
	db #00,#90                ,#30        ,#30
	db #00,#00                                
	db #00,#24        ,#2b        ,#2b        
	db #00,#00                                
	db #00,#90                ,#26        ,#26
	db #00,#00                                
	db #00,#6c        ,#1c,#48    ,#1c,#48    
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#90                ,#19        ,#19
	db #00,#00                                
	db #00,#6c        ,#1c,#4d    ,#1c,#4d    
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#90                ,#1e        ,#1e
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#fe    ,#c2,#26,#18,#e7,#26,#18,#e7
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f3,#3f,#39,#e7,#61,#4d,#39,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#73                        
	db #00,#00                                
	db #f3,#23,#30,#e7            ,#61        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#4d,#39,#30            
	db #00,#1c        ,#4d,#39,#33            
	db #f3,#1e    ,#c2,#4d,#39,#30            
	db #00,#1c        ,#2b,#4d,#39            
	db #f3,#3d,#39    ,#30,#39,#26,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#91                        
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3d,#33    ,#33,#40,#2b,#67        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#30                ,#61        
	db #f2,#02    ,#81                        
	db #00,#00                                
	db #f3,#21,#2b                ,#56        
	db #00,#00                                
	db #f3,#02    ,#c2                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#67,#40,#56            
	db #00,#00                                
	db #f3,#21,#40                ,#81        
	db #00,#00                                
	db #f3,#3f,#30,#e7,#30,#4d,#39,#61        
	db #00,#1c        ,#39,#33,#4d            
	db #00,#1c        ,#4d,#61,#39            
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#e7                        
	db #00,#00                                
	db #f3,#21,#39                ,#73        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #f3,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3f,#39,#e7,#61,#4d,#39,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#73                        
	db #00,#00                                
	db #f3,#23,#30,#e7            ,#61        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#4d,#39,#30            
	db #00,#1c        ,#4d,#39,#33            
	db #f3,#1e    ,#c2,#4d,#39,#30            
	db #00,#1c        ,#2b,#4d,#39            
	db #f3,#3d,#39    ,#30,#39,#26,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#91                        
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3d,#33    ,#33,#40,#2b,#67        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#30                ,#61        
	db #f2,#02    ,#81                        
	db #00,#00                                
	db #f3,#21,#2b                ,#56        
	db #00,#00                                
	db #f3,#1e    ,#c2,#2b,#33,#20            
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#21,#40                ,#81        
	db #00,#00                                
	db #f3,#3f,#30,#e7,#30,#1c,#26,#61        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#e7                        
	db #00,#00                                
	db #f3,#21,#39                ,#73        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #f3,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3f,#39,#e7,#61,#4d,#39,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#73                        
	db #00,#00                                
	db #f3,#23,#30,#e7            ,#61        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#4d,#39,#30            
	db #00,#1c        ,#4d,#39,#33            
	db #f3,#1e    ,#c2,#4d,#39,#30            
	db #00,#1c        ,#2b,#4d,#39            
	db #f3,#3d,#39    ,#30,#39,#26,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#91                        
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3d,#33    ,#33,#40,#2b,#67        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#30                ,#61        
	db #f2,#02    ,#81                        
	db #00,#00                                
	db #f3,#21,#2b                ,#56        
	db #00,#00                                
	db #f3,#02    ,#c2                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#67,#40,#56            
	db #00,#00                                
	db #f3,#21,#40                ,#81        
	db #00,#00                                
	db #f3,#3f,#30,#e7,#30,#4d,#39,#61        
	db #00,#1c        ,#39,#33,#4d            
	db #00,#1c        ,#4d,#61,#39            
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#e7                        
	db #00,#00                                
	db #f3,#21,#39                ,#73        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #f3,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3f,#39,#e7,#61,#4d,#39,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#73                        
	db #00,#00                                
	db #f3,#23,#30,#e7            ,#61        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#4d,#39,#30            
	db #00,#1c        ,#4d,#39,#33            
	db #f3,#1e    ,#c2,#4d,#39,#30            
	db #00,#1c        ,#2b,#4d,#39            
	db #f3,#3d,#39    ,#30,#39,#26,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#91                        
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3d,#33    ,#33,#40,#2b,#67        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#30                ,#61        
	db #f2,#02    ,#81                        
	db #00,#00                                
	db #f3,#21,#2b                ,#56        
	db #00,#00                                
	db #f3,#1e    ,#c2,#2b,#33,#20            
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#21,#40                ,#81        
	db #00,#00                                
	db #f3,#3f,#30,#e7,#30,#1c,#26,#61        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#e7                        
	db #00,#00                                
	db #f3,#21,#39                ,#73        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #f3,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3d,#40    ,#33,#56,#40,#81        
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #00,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#21,#2b                ,#56        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f3,#00                                
	db #f3,#21,#40                ,#81        
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #00,#00                                
	db #f2,#02    ,#81                        
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#3d,#2b    ,#40,#56,#33,#56        
	db #00,#00                                
	db #00,#00                                
	db #f3,#3f,#30,#e7,#67,#40,#56,#61        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#3f,#33,#ce,#61,#4d,#39,#67        
	db #00,#00                                
	db #f3,#23,#39,#e7            ,#73        
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #00,#00                                
	db #f2,#02    ,#e7                        
	db #00,#00                                
	db #f3,#23,#30,#e7            ,#61        
	db #00,#00                                
	db #f3,#23,#26,#c2            ,#4d        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#23,#39,#e7            ,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f2,#23,#4d,#39            ,#9a        
	db #00,#00                                
	db #f3,#23,#73,#73            ,#e7        
	db #00,#00                                
	db #f2,#02    ,#9a                        
	db #f2,#00                                
	db #f3,#02    ,#81                        
	db #00,#00                                
	db #f2,#02    ,#ad                        
	db #f3,#00                                
	db #f2,#02    ,#9a                        
	db #f2,#00                                
	db #f3,#27,#39,#e7,#1c        ,#73        
	db #00,#21,#30                ,#61        
	db #00,#3d,#26    ,#30,#39,#4d,#4d        
	db #00,#21,#1c                ,#39        
	db #f2,#1e    ,#73,#4d,#39,#33            
	db #00,#00                                
	db #f3,#3f,#39,#e7,#4d,#2b,#39,#73        
	db #00,#21,#30                ,#61        
	db #f3,#3f,#26,#e7,#30,#4d,#39,#4d        
	db #00,#21,#1c                ,#39        
	db #00,#1c        ,#39,#33,#4d            
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#4d,#39,#61            
	db #00,#00                                
	db #f3,#1e    ,#c2,#56,#67,#40            
	db #00,#00                                
	db #f3,#3d,#39    ,#39,#61,#48,#73        
	db #00,#21,#30                ,#61        
	db #00,#3d,#24    ,#61,#33,#48,#48        
	db #00,#21,#1c                ,#39        
	db #f2,#02    ,#91                        
	db #00,#00                                
	db #f3,#3d,#39    ,#48,#39,#30,#73        
	db #00,#21,#30                ,#61        
	db #f3,#21,#24                ,#48        
	db #00,#21,#1c                ,#39        
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#25,#40    ,#1c        ,#81        
	db #00,#21,#33                ,#67        
	db #00,#3d,#2b    ,#40,#56,#30,#56        
	db #00,#21,#20                ,#40        
	db #f2,#1e    ,#81,#56,#33,#40            
	db #00,#00                                
	db #f3,#3d,#40    ,#2b,#40,#33,#81        
	db #00,#21,#33                ,#67        
	db #f3,#3f,#2b,#c2,#56,#40,#30,#56        
	db #00,#21,#20                ,#40        
	db #00,#1c        ,#40,#56,#33            
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#39,#56,#67            
	db #00,#00                                
	db #f3,#1c        ,#56,#67,#40            
	db #00,#00                                
	db #f3,#3f,#39,#e7,#61,#39,#4d,#73        
	db #00,#21,#30                ,#61        
	db #00,#3d,#26    ,#4d,#33,#61,#4d        
	db #00,#21,#1c                ,#39        
	db #f2,#02    ,#e7                        
	db #00,#00                                
	db #f3,#3d,#39    ,#4d,#61,#39,#73        
	db #00,#21,#30                ,#61        
	db #f3,#23,#26,#e7            ,#4d        
	db #00,#21,#1c                ,#39        
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #f3,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3d,#40    ,#33,#56,#40,#81        
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #00,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#21,#2b                ,#56        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f3,#00                                
	db #f3,#21,#40                ,#81        
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #00,#00                                
	db #f2,#02    ,#81                        
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#3d,#2b    ,#40,#56,#33,#56        
	db #00,#00                                
	db #00,#00                                
	db #f3,#3f,#30,#e7,#67,#40,#56,#61        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#3f,#33,#ce,#61,#4d,#39,#67        
	db #00,#00                                
	db #f3,#23,#39,#e7            ,#73        
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #00,#00                                
	db #f2,#02    ,#e7                        
	db #00,#00                                
	db #f3,#23,#30,#e7            ,#61        
	db #00,#00                                
	db #f3,#23,#26,#c2            ,#4d        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#23,#39,#e7            ,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f2,#23,#4d,#39            ,#9a        
	db #00,#00                                
	db #f3,#23,#73,#73            ,#e7        
	db #00,#00                                
	db #f2,#02    ,#9a                        
	db #f2,#00                                
	db #f3,#02    ,#81                        
	db #00,#00                                
	db #f2,#02    ,#ad                        
	db #f3,#00                                
	db #f2,#02    ,#9a                        
	db #f2,#00                                
	db #f3,#27,#39,#e7,#1c        ,#73        
	db #00,#21,#30                ,#61        
	db #00,#3d,#26    ,#30,#39,#4d,#4d        
	db #00,#21,#1c                ,#39        
	db #f2,#1e    ,#73,#4d,#39,#33            
	db #00,#00                                
	db #f3,#3f,#39,#e7,#4d,#2b,#39,#73        
	db #00,#21,#30                ,#61        
	db #f3,#3f,#26,#e7,#30,#4d,#39,#4d        
	db #00,#21,#1c                ,#39        
	db #00,#1c        ,#39,#33,#4d            
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#4d,#39,#61            
	db #00,#00                                
	db #f3,#1e    ,#c2,#56,#67,#40            
	db #00,#00                                
	db #f3,#3d,#39    ,#39,#61,#48,#73        
	db #00,#21,#30                ,#61        
	db #00,#3d,#24    ,#61,#33,#48,#48        
	db #00,#21,#1c                ,#39        
	db #f2,#02    ,#91                        
	db #00,#00                                
	db #f3,#3d,#39    ,#48,#39,#30,#73        
	db #00,#21,#30                ,#61        
	db #f3,#21,#24                ,#48        
	db #00,#21,#1c                ,#39        
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#25,#40    ,#1c        ,#81        
	db #00,#21,#33                ,#67        
	db #00,#3d,#2b    ,#40,#56,#30,#56        
	db #00,#21,#20                ,#40        
	db #f2,#1e    ,#81,#56,#33,#40            
	db #00,#00                                
	db #f3,#3d,#40    ,#2b,#40,#33,#81        
	db #00,#21,#33                ,#67        
	db #f3,#3f,#2b,#c2,#56,#40,#30,#56        
	db #00,#21,#20                ,#40        
	db #00,#1c        ,#40,#56,#33            
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#39,#56,#67            
	db #00,#00                                
	db #f3,#1c        ,#56,#67,#40            
	db #00,#00                                
	db #f3,#3f,#39,#e7,#61,#39,#4d,#73        
	db #00,#21,#30                ,#61        
	db #00,#3d,#26    ,#4d,#33,#61,#4d        
	db #00,#21,#1c                ,#39        
	db #f2,#02    ,#e7                        
	db #00,#00                                
	db #f3,#3d,#39    ,#4d,#61,#39,#73        
	db #00,#21,#30                ,#61        
	db #f3,#23,#26,#e7            ,#4d        
	db #00,#21,#1c                ,#39        
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #f3,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3d,#40    ,#33,#56,#40,#81        
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #00,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#21,#2b                ,#56        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f3,#00                                
	db #f3,#21,#40                ,#81        
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #00,#00                                
	db #f2,#02    ,#81                        
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#3d,#2b    ,#40,#56,#33,#56        
	db #00,#00                                
	db #00,#00                                
	db #f3,#3f,#30,#e7,#67,#40,#56,#61        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#3f,#33,#ce,#61,#4d,#39,#67        
	db #00,#00                                
	db #f3,#23,#39,#e7            ,#73        
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #00,#00                                
	db #f2,#02    ,#e7                        
	db #00,#00                                
	db #f3,#23,#30,#e7            ,#61        
	db #00,#00                                
	db #f3,#23,#26,#c2            ,#4d        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#23,#39,#e7            ,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f2,#23,#4d,#39            ,#9a        
	db #00,#00                                
	db #f3,#23,#73,#73            ,#e7        
	db #00,#00                                
	db #f2,#02    ,#9a                        
	db #f2,#00                                
	db #f3,#02    ,#81                        
	db #00,#00                                
	db #f2,#02    ,#ad                        
	db #f3,#00                                
	db #f2,#02    ,#9a                        
	db #f2,#00                                
	db #f3,#3f,#39,#e7,#61,#4d,#39,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#73                        
	db #00,#00                                
	db #f3,#23,#30,#e7            ,#61        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#4d,#39,#30            
	db #00,#1c        ,#4d,#39,#33            
	db #f3,#1e    ,#c2,#4d,#39,#30            
	db #00,#1c        ,#2b,#4d,#39            
	db #f3,#3d,#39    ,#30,#39,#26,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#91                        
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3d,#33    ,#33,#40,#2b,#67        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#30                ,#61        
	db #f2,#02    ,#81                        
	db #00,#00                                
	db #f3,#21,#2b                ,#56        
	db #00,#00                                
	db #f3,#1e    ,#c2,#2b,#33,#20            
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#21,#40                ,#81        
	db #00,#00                                
	db #f3,#3f,#30,#e7,#30,#1c,#26,#61        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#e7                        
	db #00,#00                                
	db #f3,#21,#39                ,#73        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #f3,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3f,#39,#e7,#61,#4d,#39,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#73                        
	db #00,#00                                
	db #f3,#23,#30,#e7            ,#61        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#4d,#39,#30            
	db #00,#1c        ,#4d,#39,#33            
	db #f3,#1e    ,#c2,#4d,#39,#30            
	db #00,#1c        ,#2b,#4d,#39            
	db #f3,#3d,#39    ,#30,#39,#26,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#91                        
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3d,#33    ,#33,#40,#2b,#67        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#30                ,#61        
	db #f2,#02    ,#81                        
	db #00,#00                                
	db #f3,#21,#2b                ,#56        
	db #00,#00                                
	db #f3,#02    ,#c2                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#67,#40,#56            
	db #00,#00                                
	db #f3,#21,#40                ,#81        
	db #00,#00                                
	db #f3,#3f,#30,#e7,#30,#4d,#39,#61        
	db #00,#1c        ,#39,#33,#4d            
	db #00,#1c        ,#4d,#61,#39            
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#e7                        
	db #00,#00                                
	db #f3,#21,#39                ,#73        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #f3,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3f,#39,#e7,#61,#4d,#39,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#73                        
	db #00,#00                                
	db #f3,#23,#30,#e7            ,#61        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#4d,#39,#30            
	db #00,#1c        ,#4d,#39,#33            
	db #f3,#1e    ,#c2,#4d,#39,#30            
	db #00,#1c        ,#2b,#4d,#39            
	db #f3,#3d,#39    ,#30,#39,#26,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#91                        
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3d,#33    ,#33,#40,#2b,#67        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#30                ,#61        
	db #f2,#02    ,#81                        
	db #00,#00                                
	db #f3,#21,#2b                ,#56        
	db #00,#00                                
	db #f3,#1e    ,#c2,#2b,#33,#20            
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#21,#40                ,#81        
	db #00,#00                                
	db #f3,#3f,#30,#e7,#30,#1c,#26,#61        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#e7                        
	db #00,#00                                
	db #f3,#21,#39                ,#73        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #f3,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #f3,#00                                
	db #f3,#03,#20,#40                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f3,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #f3,#00                                
	db #f3,#03,#20,#40                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #00,#03,#26,#4d                        
	db #00,#00                                
	db #00,#05,#2b    ,#56                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #00,#05,#24    ,#48                    
	db #00,#00                                
	db #00,#03,#20,#40                        
	db #00,#00                                
	db #00,#05,#24    ,#48                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #00,#05,#2b    ,#56                    
	db #00,#00                                
	db #00,#03,#26,#4d                        
	db #00,#00                                
	db #00,#05,#2b    ,#56                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #00,#05,#24    ,#48                    
	db #00,#00                                
	db #00,#03,#20,#40                        
	db #00,#00                                
	db #00,#05,#24    ,#48                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #00,#05,#2b    ,#56                    
	db #00,#00                                
	db #f3,#13,#26,#4d        ,#19            
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #f3,#00                                
	db #f3,#03,#20,#40                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #00,#00                                
	db #f2,#13,#26,#4d        ,#1c            
	db #00,#00                                
	db #f3,#15,#2b    ,#56    ,#19            
	db #00,#00                                
	db #f3,#13,#26,#4d        ,#20            
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #f3,#00                                
	db #f3,#03,#20,#40                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f3,#13,#26,#4d        ,#22            
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#15,#24    ,#48    ,#2b            
	db #f3,#00                                
	db #f3,#03,#20,#40                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #00,#00                                
	db #f2,#13,#26,#4d        ,#26            
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f3,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #f3,#00                                
	db #f3,#03,#20,#40                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #00,#00                                
	db #f2,#13,#26,#4d        ,#19            
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f3,#13,#26,#4d        ,#15            
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #f3,#00                                
	db #f3,#03,#20,#40                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #00,#00                                
	db #f2,#13,#26,#4d        ,#13            
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f3,#13,#26,#4d        ,#16            
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#15,#24    ,#48    ,#1c            
	db #f3,#00                                
	db #f3,#03,#20,#40                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #00,#00                                
	db #f2,#13,#26,#4d        ,#16            
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f3,#13,#26,#4d        ,#19            
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #f3,#00                                
	db #f3,#03,#20,#40                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f3,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #f3,#00                                
	db #f3,#03,#20,#40                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f3,#1b,#26,#4d    ,#67,#19            
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #f3,#00                                
	db #f3,#03,#20,#40                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #00,#00                                
	db #f2,#1b,#26,#4d    ,#73,#1c            
	db #00,#00                                
	db #f3,#1d,#2b    ,#56,#67,#19            
	db #00,#00                                
	db #f3,#1b,#26,#4d    ,#81,#20            
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #f3,#00                                
	db #f3,#03,#20,#40                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f3,#1b,#26,#4d    ,#89,#22            
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#1d,#24    ,#48,#ad,#2b            
	db #f3,#00                                
	db #f3,#03,#20,#40                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #00,#00                                
	db #f2,#1b,#26,#4d    ,#9a,#26            
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f3,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #f3,#00                                
	db #f3,#03,#20,#40                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #00,#00                                
	db #f2,#1b,#26,#4d    ,#67,#19            
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f3,#1b,#26,#4d    ,#56,#15            
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #f3,#00                                
	db #f3,#03,#20,#40                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #00,#00                                
	db #f2,#1b,#26,#4d    ,#4d,#13            
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f3,#1b,#26,#4d    ,#5b,#16            
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#1d,#24    ,#48,#73,#1c            
	db #f3,#00                                
	db #f3,#03,#20,#40                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #00,#00                                
	db #f2,#1b,#26,#4d    ,#5b,#16            
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f3,#1b,#26,#4d    ,#67,#19            
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #f3,#00                                
	db #f3,#03,#20,#40                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f3,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#2b    ,#56                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #00,#00                                
	db #f3,#05,#24    ,#48                    
	db #f3,#00                                
	db #f3,#03,#20,#40                        
	db #00,#00                                
	db #f2,#05,#24    ,#48                    
	db #00,#00                                
	db #f2,#03,#26,#4d                        
	db #f2,#00                                
	db #f2,#05,#2b    ,#56                    
	db #f2,#00                                
	db #f3,#3f,#39,#e7,#61,#4d,#39,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#73                        
	db #00,#00                                
	db #f3,#23,#30,#e7            ,#61        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#4d,#39,#30            
	db #00,#1c        ,#4d,#39,#33            
	db #f3,#1e    ,#c2,#4d,#39,#30            
	db #00,#1c        ,#2b,#4d,#39            
	db #f3,#3d,#39    ,#30,#39,#26,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#91                        
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3d,#33    ,#33,#40,#2b,#67        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#30                ,#61        
	db #f2,#02    ,#81                        
	db #00,#00                                
	db #f3,#21,#2b                ,#56        
	db #00,#00                                
	db #f3,#02    ,#c2                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#67,#40,#56            
	db #00,#00                                
	db #f3,#21,#40                ,#81        
	db #00,#00                                
	db #f3,#3f,#30,#e7,#30,#4d,#39,#61        
	db #00,#1c        ,#39,#33,#4d            
	db #00,#1c        ,#4d,#61,#39            
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#e7                        
	db #00,#00                                
	db #f3,#21,#39                ,#73        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #f3,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3f,#39,#e7,#61,#4d,#39,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#73                        
	db #00,#00                                
	db #f3,#23,#30,#e7            ,#61        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#4d,#39,#30            
	db #00,#1c        ,#4d,#39,#33            
	db #f3,#1e    ,#c2,#4d,#39,#30            
	db #00,#1c        ,#2b,#4d,#39            
	db #f3,#3d,#39    ,#30,#39,#26,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#91                        
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3d,#33    ,#33,#40,#2b,#67        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#30                ,#61        
	db #f2,#02    ,#81                        
	db #00,#00                                
	db #f3,#21,#2b                ,#56        
	db #00,#00                                
	db #f3,#1e    ,#c2,#2b,#33,#20            
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#21,#40                ,#81        
	db #00,#00                                
	db #f3,#3f,#30,#e7,#30,#1c,#26,#61        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#e7                        
	db #00,#00                                
	db #f3,#21,#39                ,#73        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #f3,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3f,#39,#e7,#61,#4d,#39,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#73                        
	db #00,#00                                
	db #f3,#23,#30,#e7            ,#61        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#4d,#39,#30            
	db #00,#1c        ,#4d,#39,#33            
	db #f3,#1e    ,#c2,#4d,#39,#30            
	db #00,#1c        ,#2b,#4d,#39            
	db #f3,#3d,#39    ,#30,#39,#26,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#91                        
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3d,#33    ,#33,#40,#2b,#67        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#30                ,#61        
	db #f2,#02    ,#81                        
	db #00,#00                                
	db #f3,#21,#2b                ,#56        
	db #00,#00                                
	db #f3,#02    ,#c2                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#67,#40,#56            
	db #00,#00                                
	db #f3,#21,#40                ,#81        
	db #00,#00                                
	db #f3,#3f,#30,#e7,#30,#4d,#39,#61        
	db #00,#1c        ,#39,#33,#4d            
	db #00,#1c        ,#4d,#61,#39            
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#e7                        
	db #00,#00                                
	db #f3,#21,#39                ,#73        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #f3,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3f,#39,#e7,#61,#4d,#39,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#73                        
	db #00,#00                                
	db #f3,#23,#30,#e7            ,#61        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#4d,#39,#30            
	db #00,#1c        ,#4d,#39,#33            
	db #f3,#1e    ,#c2,#4d,#39,#30            
	db #00,#1c        ,#2b,#4d,#39            
	db #f3,#3d,#39    ,#30,#39,#26,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#91                        
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3d,#33    ,#33,#40,#2b,#67        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#30                ,#61        
	db #f2,#02    ,#81                        
	db #00,#00                                
	db #f3,#21,#2b                ,#56        
	db #00,#00                                
	db #f3,#1e    ,#c2,#2b,#33,#20            
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#21,#40                ,#81        
	db #00,#00                                
	db #f3,#3f,#30,#e7,#30,#1c,#26,#61        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #f2,#02    ,#e7                        
	db #00,#00                                
	db #f3,#21,#39                ,#73        
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #f3,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3d,#40    ,#33,#56,#40,#81        
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #00,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#21,#2b                ,#56        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f3,#00                                
	db #f3,#21,#40                ,#81        
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #00,#00                                
	db #f2,#02    ,#81                        
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#3d,#2b    ,#40,#56,#33,#56        
	db #00,#00                                
	db #00,#00                                
	db #f3,#3f,#30,#e7,#67,#40,#56,#61        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#3f,#33,#ce,#61,#4d,#39,#67        
	db #00,#00                                
	db #f3,#23,#39,#e7            ,#73        
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #00,#00                                
	db #f2,#02    ,#e7                        
	db #00,#00                                
	db #f3,#23,#30,#e7            ,#61        
	db #00,#00                                
	db #f3,#23,#26,#c2            ,#4d        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#23,#39,#e7            ,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f2,#23,#4d,#39            ,#9a        
	db #00,#00                                
	db #f3,#23,#73,#73            ,#e7        
	db #00,#00                                
	db #f2,#02    ,#9a                        
	db #f2,#00                                
	db #f3,#02    ,#81                        
	db #00,#00                                
	db #f2,#02    ,#ad                        
	db #f3,#00                                
	db #f2,#02    ,#9a                        
	db #f2,#00                                
	db #f3,#27,#39,#e7,#1c        ,#73        
	db #00,#21,#30                ,#61        
	db #00,#3d,#26    ,#30,#39,#4d,#4d        
	db #00,#21,#1c                ,#39        
	db #f2,#1e    ,#73,#4d,#39,#33            
	db #00,#00                                
	db #f3,#3f,#39,#e7,#4d,#2b,#39,#73        
	db #00,#21,#30                ,#61        
	db #f3,#3f,#26,#e7,#30,#4d,#39,#4d        
	db #00,#21,#1c                ,#39        
	db #00,#1c        ,#39,#33,#4d            
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#4d,#39,#61            
	db #00,#00                                
	db #f3,#1e    ,#c2,#56,#67,#40            
	db #00,#00                                
	db #f3,#3d,#39    ,#39,#61,#48,#73        
	db #00,#21,#30                ,#61        
	db #00,#3d,#24    ,#61,#33,#48,#48        
	db #00,#21,#1c                ,#39        
	db #f2,#02    ,#91                        
	db #00,#00                                
	db #f3,#3d,#39    ,#48,#39,#30,#73        
	db #00,#21,#30                ,#61        
	db #f3,#21,#24                ,#48        
	db #00,#21,#1c                ,#39        
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#25,#40    ,#1c        ,#81        
	db #00,#21,#33                ,#67        
	db #00,#3d,#2b    ,#40,#56,#30,#56        
	db #00,#21,#20                ,#40        
	db #f2,#1e    ,#81,#56,#33,#40            
	db #00,#00                                
	db #f3,#3d,#40    ,#2b,#40,#33,#81        
	db #00,#21,#33                ,#67        
	db #f3,#3f,#2b,#c2,#56,#40,#30,#56        
	db #00,#21,#20                ,#40        
	db #00,#1c        ,#40,#56,#33            
	db #f3,#02    ,#ce                        
	db #f2,#1c        ,#39,#56,#67            
	db #00,#00                                
	db #f3,#1c        ,#56,#67,#40            
	db #00,#00                                
	db #f3,#3f,#39,#e7,#61,#39,#4d,#73        
	db #00,#21,#30                ,#61        
	db #00,#3d,#26    ,#4d,#33,#61,#4d        
	db #00,#21,#1c                ,#39        
	db #f2,#02    ,#e7                        
	db #00,#00                                
	db #f3,#3d,#39    ,#4d,#61,#39,#73        
	db #00,#21,#30                ,#61        
	db #f3,#23,#26,#e7            ,#4d        
	db #00,#21,#1c                ,#39        
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #f3,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3d,#40    ,#33,#56,#40,#81        
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #00,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#21,#2b                ,#56        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#e7                        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f3,#00                                
	db #f3,#21,#40                ,#81        
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #00,#00                                
	db #f2,#02    ,#81                        
	db #00,#00                                
	db #f3,#21,#30                ,#61        
	db #00,#00                                
	db #f3,#3d,#2b    ,#40,#56,#33,#56        
	db #00,#00                                
	db #00,#00                                
	db #f3,#3f,#30,#e7,#67,#40,#56,#61        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#3f,#33,#ce,#61,#4d,#39,#67        
	db #00,#00                                
	db #f3,#23,#39,#e7            ,#73        
	db #00,#00                                
	db #00,#21,#33                ,#67        
	db #00,#00                                
	db #f2,#02    ,#e7                        
	db #00,#00                                
	db #f3,#23,#30,#e7            ,#61        
	db #00,#00                                
	db #f3,#23,#26,#c2            ,#4d        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#23,#39,#e7            ,#73        
	db #00,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f2,#23,#4d,#39            ,#9a        
	db #00,#00                                
	db #f3,#23,#73,#73            ,#e7        
	db #00,#00                                
	db #f2,#02    ,#9a                        
	db #f2,#00                                
	db #f3,#02    ,#81                        
	db #00,#00                                
	db #f2,#02    ,#ad                        
	db #f3,#00                                
	db #f2,#02    ,#9a                        
	db #f2,#00                                
	db #f3,#3e    ,#26,#18,#1c,#1c,#1c        
	db #00,#00                                
	db #00,#00                                
	db #00,#30                ,#1c,#1c        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#3e    ,#18,#26,#1c,#1c,#1c        
	db #00,#00                                
	db #f3,#3e    ,#2b,#20,#19,#19,#19        
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#30                ,#20,#20        
	db #00,#00                                
	db #f3,#0e    ,#19,#20,#2b                
	db #00,#00                                
	db #f3,#31,#e7            ,#19,#19        
	db #00,#00                                
	db #00,#0e    ,#1c,#30,#26                
	db #00,#31,#e7            ,#1c,#1c        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#0f,#ce,#26,#1c,#30                
	db #00,#00                                
	db #f3,#0f,#c2,#1c,#30,#26                
	db #00,#00                                
	db #00,#01,#ce                            
	db #f3,#00                                
	db #f2,#01,#e7                            
	db #00,#00                                
	db #f3,#0e    ,#2b,#20,#19                
	db #00,#00                                
	db #f3,#3e    ,#26,#18,#1c,#1c,#1c        
	db #00,#00                                
	db #00,#00                                
	db #00,#30                ,#1c,#1c        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#3e    ,#18,#1c,#26,#18,#18        
	db #00,#00                                
	db #f3,#3e    ,#2b,#19,#20,#19,#19        
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#30                ,#15,#15        
	db #00,#00                                
	db #f3,#0e    ,#19,#2b,#20                
	db #00,#00                                
	db #f3,#31,#e7            ,#13,#13        
	db #00,#00                                
	db #00,#0e    ,#30,#1c,#26                
	db #00,#00                                
	db #f2,#01,#c2                            
	db #00,#00                                
	db #f3,#0e    ,#26,#1c,#30                
	db #00,#00                                
	db #f3,#0f,#ce,#1c,#30,#26                
	db #00,#00                                
	db #00,#01,#e7                            
	db #f3,#00                                
	db #f2,#0e    ,#2b,#20,#19                
	db #f3,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3e    ,#26,#18,#1c,#1c,#1c        
	db #00,#00                                
	db #00,#00                                
	db #00,#30                ,#1c,#1c        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#3e    ,#18,#26,#1c,#1c,#1c        
	db #00,#00                                
	db #f3,#3e    ,#2b,#20,#19,#19,#19        
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#30                ,#20,#20        
	db #00,#00                                
	db #f3,#0e    ,#19,#20,#2b                
	db #00,#00                                
	db #f3,#31,#e7            ,#19,#19        
	db #00,#00                                
	db #00,#0e    ,#1c,#30,#26                
	db #00,#31,#e7            ,#1c,#1c        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#0f,#ce,#26,#1c,#30                
	db #00,#00                                
	db #f3,#0f,#c2,#1c,#30,#26                
	db #00,#00                                
	db #00,#01,#ce                            
	db #f3,#00                                
	db #f2,#01,#e7                            
	db #00,#00                                
	db #f3,#0e    ,#2b,#20,#19                
	db #00,#00                                
	db #f3,#3e    ,#26,#18,#1c,#1c,#1c        
	db #00,#00                                
	db #00,#00                                
	db #00,#30                ,#1c,#1c        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#3e    ,#18,#1c,#26,#18,#18        
	db #00,#00                                
	db #f3,#3e    ,#2b,#19,#20,#19,#19        
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#30                ,#15,#15        
	db #00,#00                                
	db #f3,#0e    ,#19,#2b,#20                
	db #00,#00                                
	db #f3,#31,#e7            ,#13,#13        
	db #00,#00                                
	db #00,#0e    ,#30,#1c,#26                
	db #00,#00                                
	db #f2,#01,#c2                            
	db #00,#00                                
	db #f3,#0e    ,#26,#1c,#30                
	db #00,#00                                
	db #f3,#0f,#ce,#1c,#30,#26                
	db #00,#00                                
	db #00,#01,#e7                            
	db #f3,#00                                
	db #f2,#0e    ,#2b,#20,#19                
	db #f3,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3f,#33,#ce,#56,#44,#33,#67        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#2d                ,#5b        
	db #f2,#02    ,#67                        
	db #00,#00                                
	db #f3,#23,#2b,#ce            ,#56        
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#b7                        
	db #f2,#1c        ,#44,#33,#2b            
	db #00,#1c        ,#44,#33,#2d            
	db #f3,#1e    ,#ad,#44,#33,#2b            
	db #00,#1c        ,#26,#44,#33            
	db #f3,#3d,#33    ,#2b,#33,#22,#67        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#2d                ,#5b        
	db #f2,#02    ,#81                        
	db #00,#00                                
	db #f3,#21,#2b                ,#56        
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3f,#2d,#e7,#2d,#39,#26,#5b        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#2b                ,#56        
	db #f2,#02    ,#73                        
	db #00,#00                                
	db #f3,#23,#26,#e7            ,#4d        
	db #00,#00                                
	db #f3,#1e    ,#ad,#26,#2d,#1c            
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#b7                        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#23,#39,#e7            ,#73        
	db #00,#00                                
	db #f3,#3f,#2b,#ce,#2b,#19,#22,#56        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#2d                ,#5b        
	db #f2,#02    ,#ce                        
	db #00,#00                                
	db #f3,#23,#33,#e7            ,#67        
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #f3,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3f,#33,#ce,#56,#44,#33,#67        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#2d                ,#5b        
	db #f2,#02    ,#67                        
	db #00,#00                                
	db #f3,#23,#2b,#ce            ,#56        
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#b7                        
	db #f2,#1c        ,#44,#33,#2b            
	db #00,#1c        ,#44,#33,#2d            
	db #f3,#1e    ,#ad,#44,#33,#2b            
	db #00,#1c        ,#26,#44,#33            
	db #f3,#3d,#33    ,#2b,#33,#22,#67        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#2d                ,#5b        
	db #f2,#02    ,#81                        
	db #00,#00                                
	db #f3,#21,#2b                ,#56        
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3f,#2d,#e7,#2d,#39,#26,#5b        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#2b                ,#56        
	db #f2,#02    ,#73                        
	db #00,#00                                
	db #f3,#23,#26,#e7            ,#4d        
	db #00,#00                                
	db #f3,#02    ,#ad                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#b7                        
	db #f2,#1c        ,#5b,#39,#4d            
	db #00,#00                                
	db #f3,#23,#39,#e7            ,#73        
	db #00,#00                                
	db #f3,#3f,#2b,#ce,#2b,#44,#33,#56        
	db #00,#1c        ,#33,#2d,#44            
	db #00,#1c        ,#44,#56,#33            
	db #00,#21,#2d                ,#5b        
	db #f2,#02    ,#ce                        
	db #00,#00                                
	db #f3,#23,#33,#e7            ,#67        
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #f3,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3f,#33,#ce,#56,#44,#33,#67        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#2d                ,#5b        
	db #f2,#02    ,#67                        
	db #00,#00                                
	db #f3,#23,#2b,#ce            ,#56        
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#b7                        
	db #f2,#1c        ,#44,#33,#2b            
	db #00,#1c        ,#44,#33,#2d            
	db #f3,#1e    ,#ad,#44,#33,#2b            
	db #00,#1c        ,#26,#44,#33            
	db #f3,#3d,#33    ,#2b,#33,#22,#67        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#2d                ,#5b        
	db #f2,#02    ,#81                        
	db #00,#00                                
	db #f3,#21,#2b                ,#56        
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3f,#2d,#e7,#2d,#39,#26,#5b        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#2b                ,#56        
	db #f2,#02    ,#73                        
	db #00,#00                                
	db #f3,#23,#26,#e7            ,#4d        
	db #00,#00                                
	db #f3,#1e    ,#ad,#26,#2d,#1c            
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#b7                        
	db #f2,#00                                
	db #00,#00                                
	db #f3,#23,#39,#e7            ,#73        
	db #00,#00                                
	db #f3,#3f,#2b,#ce,#2b,#19,#22,#56        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#2d                ,#5b        
	db #f2,#02    ,#ce                        
	db #00,#00                                
	db #f3,#23,#33,#e7            ,#67        
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #f3,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3f,#33,#ce,#56,#44,#33,#67        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#2d                ,#5b        
	db #f2,#02    ,#67                        
	db #00,#00                                
	db #f3,#23,#2b,#ce            ,#56        
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#b7                        
	db #f2,#1c        ,#44,#33,#2b            
	db #00,#1c        ,#44,#33,#2d            
	db #f3,#1e    ,#ad,#44,#33,#2b            
	db #00,#1c        ,#26,#44,#33            
	db #f3,#3d,#33    ,#2b,#33,#22,#67        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#2d                ,#5b        
	db #f2,#02    ,#81                        
	db #00,#00                                
	db #f3,#21,#2b                ,#56        
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #00,#00                                
	db #f3,#3f,#2d,#e7,#2d,#39,#26,#5b        
	db #00,#00                                
	db #00,#00                                
	db #00,#21,#2b                ,#56        
	db #f2,#02    ,#73                        
	db #00,#00                                
	db #f3,#23,#26,#e7            ,#4d        
	db #00,#00                                
	db #f3,#02    ,#ad                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#02    ,#b7                        
	db #f2,#1c        ,#5b,#39,#4d            
	db #00,#00                                
	db #f3,#23,#39,#e7            ,#73        
	db #00,#00                                
	db #f3,#3f,#2b,#ce,#2b,#44,#33,#56        
	db #00,#1c        ,#33,#2d,#44            
	db #00,#1c        ,#44,#56,#33            
	db #00,#21,#2d                ,#5b        
	db #f2,#02    ,#ce                        
	db #00,#00                                
	db #f3,#23,#33,#e7            ,#67        
	db #00,#00                                
	db #f3,#02    ,#ce                        
	db #00,#00                                
	db #00,#00                                
	db #f3,#00                                
	db #f2,#00                                
	db #f3,#00                                
	db #f3,#00                                
.loop
 db 0,0
 db #ff





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
tap_e:	savebin "octode_goldenaxe.tap",tap_b,tap_e-tap_b


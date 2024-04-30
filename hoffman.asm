 device zxspectrum128

	org $6500-13				; Origin
tap_b:	db $22,"NONAME",$22			;name		  	
	db "M"					;type		  	
	dw end-begin				;program length	  	
	dw begin				;load point		
	org $6500
begin:

	ld hl,music_data
	call play
	ret
	
	
	
	;engine code

;squat by Shiru, 06'17
;Squeeker like, just without the output value table
;4 channels of tone with different duty cycle
;sample drums, non-interrupting
;customizeable noise percussion, interrupting


;music data is all 16-bit words, first control then a few optional ones

;control word is PSSSSSSS DDDN4321, where P equ percussion,S equ speed, D equ drum, N equ noise mode, 4321 equ channels
;D triggers non-interruping sample drum
;P trigger
;if 1, channel 1 freq follows
;if 2, channel 2 freq follows
;if 3, channel 3 freq follows
;if 4, channel 4 freq follows
;if N, channel 4 mode follows, it is either $0000 (normal) or $04cb (noise)
;if P, percussion follows, LSB equ volume, MSB equ pitch



RLC_H equ $04cb			;to enable noise mode
NOP_2 equ $0000			;to disable noise mode
RLC_HL equ $06cb		;to enable sample reading
ADD_IX_IX equ $29dd		;to disable sample reading


play

	di
	
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (loop_ptr),de
	
	ld (pattern_ptr),hl
	
	ld hl,ADD_IX_IX
	ld (sample_read),hl
	ld hl,NOP_2					;normal mode
	ld (noise_mode),hl
	
	ld ix,0						;needs to be 0 to skip sample reading

	ld c,0
	exx
	ld de,$0808					;sample bit counter and reload value

play_loop

pattern_ptr equ $+1
	ld sp,0
	
return_loop

	pop bc						;control word
								;B equ duration of the row (0 equ loop)
								;C equ flags DDDN4321 (Drum, Noise, 1-4 channel update)
	ld a,b
	or a
	jp nz,no_loop
	
loop_ptr equ $+1
	ld sp,0
	
	jp return_loop
	
no_loop

	ld a,c
	
	rra
	jr nc,skip_note_0
	
	pop hl
	ld (ch0_add),hl
	
skip_note_0

	rra
	jr nc,skip_note_1

	pop hl
	ld (ch1_add),hl
	
skip_note_1

	rra
	jr nc,skip_note_2
	
	pop hl
	ld (ch2_add),hl
	
skip_note_2

	rra
	jr nc,skip_note_3
	
	pop hl
	ld (ch3_add),hl
	
skip_note_3

	rra
	jr nc,skip_mode_change
	
	pop hl						;nop:nop or rlc h
	ld (noise_mode),hl

skip_mode_change

	and 7
	jp z,skip_drum
	
	ld hl,sample_list-2
	add a,a
	add a,l
	ld l,a
	ld a,(hl)
	inc l
	ld h,(hl)
	ld l,a
	ld (sample_ptr),hl
	ld hl,RLC_HL
	ld (sample_read),hl

skip_drum

	bit 7,b						;check percussion flag
	jp z,skip_percussion

	res 7,b						;clear percussion flag
	dec b						;compensate speed

	ld (noise_bc),bc
	ld (noise_de),de

	pop hl						;read percussion parameters

	ld a,l						;noise volume
	ld (noise_volume),a
	ld b,h						;noise pitch
	ld c,h
	ld de,$2174					;utz's rand seed			
	exx
	ld bc,811					;noise duration, takes as long as inner sound loop

noise_loop

	exx							;4
	dec c						;4
	jr nz,noise_skip			;7/12
	ld c,b						;4
	add hl,de					;11
	rlc h						;8		utz's noise generator idea
	inc d						;4		improves randomness
	jp noise_next				;10
	
noise_skip

	jr $+2						;12
	jr $+2						;12
	nop							;4
	nop							;4
	
noise_next

	ld a,h						;4
	
noise_volume equ $+1
	cp $80						;7
	sbc a,a						;4
	out ($84),a					;11

	exx							;4

	dec bc						;6
	ld a,b						;4
	or c						;4
	jp nz,noise_loop			;10 equ 106t

	exx

noise_bc equ $+1
	ld bc,0
noise_de equ $+1
	ld de,0



skip_percussion

	ld (pattern_ptr),sp

sample_ptr equ $+1
	ld hl,0

	ld c,0						;internal loop runs 256 times

sound_loop

sample_read equ $
	rlc (hl)					;15 	rotate sample bits in place, rl (hl) or add ix,ix (dummy operation)
	sbc a,a						;4		sbc a,a to make bit into 0 or 255, or xor a to keep it 0

	dec e						;4--+	count bits
	jp z,sample_cycle			;10 |
	jp sample_next				;10

sample_cycle

	ld e,d						;4	|	reload counter
	inc hl						;6--+	advance pointer --24t

sample_next

	exx							;4		squeeker type unrolled code
	ld b,a						;4		sample mask
	xor a						;4
	
	ld sp,sound_list			;10
		
	pop de						;10		ch0_acc
	pop hl						;10		ch0_add
	add hl,de					;11
	rla							;4
	ld (ch0_acc),hl				;16
						
	pop de						;10		ch1_acc
	pop hl						;10		ch1_add
	add hl,de					;11
	rla							;4
	ld (ch1_acc),hl				;16
	
	pop de						;10		ch2_acc
	pop hl						;10		ch2_add
	add hl,de					;11
	rla							;4
	ld (ch2_acc),hl				;16

	pop de						;10		ch3_acc
	pop hl						;10		ch3_add
	add hl,de					;11
	
noise_mode equ $
	ds 2,0						;8		rlc h for noise effects

	rla							;4
	ld (ch3_acc),hl				;16

	add a,c						;4		no table like in Squeeker, channels summed as is, for uneven 'volume'
	add a,$ff					;7
	sbc a,$ff					;7
	ld c,a						;4
	sbc a,a						;4

	or b						;4		mix sample
	
	out ($84),a					;11

		
	exx							;4

	dec c						;4
	jp nz,sound_loop			;10 equ 336t


	dec hl						;last byte of a 256 byte sample packet is 0 means it was the last packet
	ld a,(hl)
	inc hl
	or a						;check for 0
	jr nz,sample_no_stop

	ld hl,ADD_IX_IX
	ld (sample_read),hl			;disable sample reading

sample_no_stop

	djnz sound_loop

	ld (sample_ptr),hl
	
	jp play_loop
	
	
	

sample_list

	dw sample_1
	dw sample_2
	dw sample_3
	dw sample_4
	dw sample_5
	dw sample_6
	dw sample_7
	
;variables in the sound_list can't be reordered because of stack-based fetching

sound_list

ch0_add		dw 0
ch0_acc		dw 0
ch1_add		dw 0
ch1_acc		dw 0
ch2_add		dw 0
ch2_acc		dw 0
ch3_add		dw 0
ch3_acc		dw 0




;sample data
sample_1
	db 8,248,7,224,0,31,240,0
	db 255,252,0,1,255,255,0,0
	db 0,255,255,248,0,0,0,127
	db 255,255,240,0,0,0,0,255
	db 255,255,255,252,0,0,0,0
	db 0,3,255,255,255,255,255,240
	db 0,0,0,0,0,0,1,255
	db 255,255,255,255,255,0,0,0
	db 0,0,0,0,0,15,255,255
	db 255,255,255,255,254,0,0,128
sample_2
	db 0,0,16,0,33,80,0,32
	db 0,12,0,32,0,3,11,10
	db 194,24,4,4,0,32,0,192
	db 0,0,1,0,128,2,4,0
	db 0,0,0,16,8,16,16,0
	db 0,2,0,0,0,0,0,128
sample_3
	db 0,0,0,6,14,4,0,192
	db 96,224,200,0,104,1,1,1
	db 64,192,128,8,24,15,1,1
	db 0,224,192,16,18,1,2,0
	db 32,28,30,1,7,1,0,160
	db 240,64,29,1,1,129,128,128
sample_4
	db 57,54,7,128,6,64,96,32
	db 0,0,207,3,71,15,32,12
	db 16,64,144,96,0,0,208,135
	db 1,199,3,131,68,16,4,6
	db 0,0,10,30,120,62,31,102
	db 248,228,67,24,11,22,204,44
	db 48,193,192,225,65,192,192,192
	db 64,129,10,65,65,5,131,12
	db 232,248,100,224,152,2,6,17
	db 30,33,3,6,1,192,200,0
	db 0,32,28,14,0,0,0,128
sample_5
sample_6
sample_7

;compiled music data

music_data
	dw loop
pattern
loop
	dw $133f,$cd,$0,$0,$0,0
	dw $8d00,$110
	dw $1341,$0
	dw $8d00,$120
	dw $1321,$ee
	dw $f60
	dw $1341,$0
	dw $8d00,$120
	dw $1321,$ee
	dw $8d00,$110
	dw $1361,$0
	dw $f21,$1a8
	dw $1301,$0
	dw $f01,$1dc
	dw $1360
	dw $f01,$0
	dw $1321,$ee
	dw $8d01,$0,$110
	dw $1341,$ee
	dw $8d01,$0,$120
	dw $1321,$ee
	dw $f60
	dw $1341,$0
	dw $8d00,$110
	dw $1321,$ee
	dw $f00
	dw $1361,$0
	dw $f21,$1a8
	dw $1301,$0
	dw $f01,$1dc
	dw $1380
	dw $f81,$0
	dw $1321,$ee
	dw $8d00,$110
	dw $1341,$0
	dw $8d00,$120
	dw $1321,$ee
	dw $f60
	dw $1341,$0
	dw $8d00,$120
	dw $1321,$ee
	dw $8d00,$110
	dw $1361,$0
	dw $f21,$1a8
	dw $1301,$0
	dw $f01,$1dc
	dw $1360
	dw $f01,$0
	dw $1321,$ee
	dw $8d01,$0,$110
	dw $1341,$ee
	dw $8d01,$0,$120
	dw $1321,$ee
	dw $f60
	dw $1341,$0
	dw $8d00,$110
	dw $1321,$ee
	dw $f00
	dw $1361,$0
	dw $f21,$1a8
	dw $1301,$0
	dw $f01,$1dc
	dw $1380
	dw $f81,$0
	dw $1321,$ee
	dw $8d00,$110
	dw $1341,$0
	dw $8d00,$120
	dw $1321,$ee
	dw $f60
	dw $1341,$0
	dw $8d00,$120
	dw $1321,$ee
	dw $8d00,$110
	dw $1361,$0
	dw $f21,$1a8
	dw $1301,$0
	dw $f01,$1dc
	dw $1360
	dw $f01,$0
	dw $1321,$ee
	dw $8d01,$0,$110
	dw $1341,$ee
	dw $8d01,$0,$120
	dw $1321,$ee
	dw $f60
	dw $1341,$0
	dw $8d00,$110
	dw $1321,$ee
	dw $f00
	dw $1361,$0
	dw $f21,$1a8
	dw $1301,$0
	dw $f01,$1dc
	dw $1380
	dw $f81,$0
	dw $1321,$179
	dw $8d00,$110
	dw $1341,$0
	dw $8d00,$120
	dw $1321,$179
	dw $f60
	dw $1341,$0
	dw $8d00,$120
	dw $1321,$179
	dw $8d00,$110
	dw $1361,$0
	dw $f21,$179
	dw $1301,$0
	dw $f01,$179
	dw $1360
	dw $f01,$0
	dw $1321,$13d
	dw $8d01,$0,$110
	dw $1341,$13d
	dw $8d01,$0,$120
	dw $1321,$13d
	dw $f60
	dw $1341,$0
	dw $8d00,$110
	dw $1321,$164
	dw $f00
	dw $1361,$0
	dw $f21,$164
	dw $1301,$0
	dw $f01,$164
	dw $1380
	dw $f81,$0
	dw $1325,$ee,$b25
	dw $8d04,$0,$110
	dw $1349,$0,$b25
	dw $8d0c,$d41,$0,$120
	dw $1325,$ee,$0
	dw $f68,$d41
	dw $134d,$0,$ee1,$0
	dw $8d04,$0,$120
	dw $1329,$ee,$ee1
	dw $8d0c,$b25,$0,$110
	dw $1365,$0,$0
	dw $f29,$1a8,$b25
	dw $130d,$0,$d41,$0
	dw $f05,$1dc,$0
	dw $1368,$d41
	dw $f0d,$0,$ee1,$0
	dw $1325,$ee,$0
	dw $8d09,$0,$ee1,$110
	dw $134d,$ee,$b25,$0
	dw $8d05,$0,$0,$120
	dw $1329,$ee,$b25
	dw $f6c,$d41,$0
	dw $1345,$0,$0
	dw $8d08,$d41,$110
	dw $132d,$ee,$ee1,$0
	dw $f04,$0
	dw $1369,$0,$ee1
	dw $f2d,$1a8,$b25,$0
	dw $1305,$0,$0
	dw $f09,$1dc,$b25
	dw $138c,$d41,$0
	dw $f85,$0,$0
	dw $1329,$ee,$d41
	dw $8d0c,$ee1,$0,$110
	dw $1345,$0,$0
	dw $8d08,$ee1,$120
	dw $132d,$ee,$b25,$0
	dw $f64,$0
	dw $1349,$0,$b25
	dw $8d0c,$d41,$0,$120
	dw $1325,$ee,$0
	dw $8d08,$d41,$110
	dw $136d,$0,$ee1,$0
	dw $f25,$1a8,$0
	dw $1309,$0,$ee1
	dw $f0d,$1dc,$b25,$0
	dw $1364,$0
	dw $f09,$0,$b25
	dw $132d,$ee,$d41,$0
	dw $8d05,$0,$0,$110
	dw $1349,$ee,$d41
	dw $8d0d,$0,$ee1,$0,$120
	dw $1325,$ee,$0
	dw $f68,$ee1
	dw $134d,$0,$b25,$0
	dw $8d04,$0,$110
	dw $1329,$ee,$b25
	dw $f0c,$d41,$0
	dw $1365,$0,$0
	dw $f29,$1a8,$d41
	dw $130d,$0,$ee1,$0
	dw $f05,$1dc,$0
	dw $1388,$ee1
	dw $f8d,$0,$b25,$0
	dw $1325,$ee,$0
	dw $8d08,$b25,$110
	dw $134d,$0,$d41,$0
	dw $8d04,$0,$120
	dw $1329,$ee,$d41
	dw $f6c,$ee1,$0
	dw $1345,$0,$0
	dw $8d08,$ee1,$120
	dw $132d,$ee,$b25,$0
	dw $8d04,$0,$110
	dw $1369,$0,$b25
	dw $f2d,$1a8,$d41,$0
	dw $1305,$0,$0
	dw $f09,$1dc,$d41
	dw $136c,$ee1,$0
	dw $f05,$0,$0
	dw $1329,$ee,$ee1
	dw $8d0d,$0,$b25,$0,$110
	dw $1345,$ee,$0
	dw $8d09,$0,$b25,$120
	dw $132d,$ee,$d41,$0
	dw $f64,$0
	dw $1349,$0,$d41
	dw $8d0c,$ee1,$0,$110
	dw $1325,$ee,$0
	dw $f08,$ee1
	dw $136d,$0,$b25,$0
	dw $f25,$1a8,$0
	dw $1309,$0,$b25
	dw $f0d,$1dc,$d41,$0
	dw $1384,$0
	dw $f89,$0,$d41
	dw $132d,$179,$ee1,$0
	dw $8d04,$0,$110
	dw $1349,$0,$ee1
	dw $8d0c,$b25,$0,$120
	dw $1325,$179,$0
	dw $f68,$b25
	dw $134d,$0,$d41,$0
	dw $8d04,$0,$120
	dw $1329,$179,$d41
	dw $8d0c,$ee1,$0,$110
	dw $1365,$0,$0
	dw $f29,$179,$ee1
	dw $130d,$0,$b25,$0
	dw $f05,$179,$0
	dw $1368,$b25
	dw $f0d,$0,$d41,$0
	dw $1325,$13d,$0
	dw $8d09,$0,$d41,$110
	dw $134d,$13d,$ee1,$0
	dw $8d05,$0,$0,$120
	dw $1329,$13d,$ee1
	dw $f6c,$b25,$0
	dw $1345,$0,$0
	dw $8d08,$b25,$110
	dw $132d,$164,$d41,$0
	dw $f04,$0
	dw $1369,$0,$d41
	dw $f2d,$164,$ee1,$0
	dw $1305,$0,$0
	dw $f09,$164,$ee1
	dw $138c,$b25,$0
	dw $f85,$0,$0
	dw $132b,$ee,$1d4,$b25
	dw $8d0c,$d41,$0,$110
	dw $1347,$0,$0,$0
	dw $8d08,$d41,$120
	dw $132f,$ee,$1dc,$ee1,$0
	dw $f64,$0
	dw $134b,$0,$0,$ee1
	dw $8d0c,$b25,$0,$120
	dw $1327,$ee,$1dc,$0
	dw $8d08,$b25,$110
	dw $136f,$0,$0,$d41,$0
	dw $f27,$1a8,$350,$0
	dw $130b,$0,$0,$d41
	dw $f0f,$1dc,$3b8,$ee1,$0
	dw $1364,$0
	dw $f0b,$0,$0,$ee1
	dw $132f,$ee,$1dc,$b25,$0
	dw $8d07,$0,$0,$0,$110
	dw $134b,$ee,$1dc,$b25
	dw $8d0f,$0,$0,$d41,$0,$120
	dw $1327,$ee,$1dc,$0
	dw $f68,$d41
	dw $134f,$0,$0,$ee1,$0
	dw $8d04,$0,$110
	dw $132b,$ee,$1dc,$ee1
	dw $f8c,$b25,$0
	dw $1367,$0,$0,$0
	dw $f2b,$1a8,$350,$b25
	dw $138f,$0,$0,$d41,$0
	dw $8d07,$1dc,$3b8,$0,$180
	dw $9108,$d41,$180
	dw $f8f,$0,$0,$ee1,$0
	dw $1327,$ee,$1dc,$0
	dw $8d08,$ee1,$110
	dw $134f,$0,$0,$b25,$0
	dw $8d04,$0,$120
	dw $132b,$ee,$1dc,$b25
	dw $f6c,$d41,$0
	dw $1347,$0,$0,$0
	dw $8d08,$d41,$120
	dw $132f,$ee,$1dc,$ee1,$0
	dw $8d04,$0,$110
	dw $136b,$0,$0,$ee1
	dw $f2f,$1a8,$350,$b25,$0
	dw $1307,$0,$0,$0
	dw $f0b,$1dc,$3b8,$b25
	dw $136c,$d41,$0
	dw $f07,$0,$0,$0
	dw $132b,$ee,$1dc,$d41
	dw $8d0f,$0,$0,$ee1,$0,$110
	dw $1347,$ee,$1dc,$0
	dw $8d0b,$0,$0,$ee1,$120
	dw $132f,$ee,$1dc,$b25,$0
	dw $f64,$0
	dw $134b,$0,$0,$b25
	dw $8d0c,$d41,$0,$110
	dw $1327,$ee,$1dc,$0
	dw $f48,$d41
	dw $134f,$0,$0,$ee1,$0
	dw $f87,$1a8,$350,$0
	dw $916b,$0,$0,$ee1,$120
	dw $f8f,$1dc,$3b8,$b25,$0
	dw $9164,$0,$140
	dw $f8b,$0,$0,$b25
	dw $132f,$ee,$1dc,$d41,$0
	dw $8d04,$0,$110
	dw $134b,$0,$0,$d41
	dw $8d0c,$ee1,$0,$120
	dw $1327,$ee,$1dc,$0
	dw $f68,$ee1
	dw $134f,$0,$0,$b25,$0
	dw $8d04,$0,$120
	dw $132b,$ee,$1dc,$b25
	dw $8d0c,$d41,$0,$110
	dw $1367,$0,$0,$0
	dw $f2b,$1a8,$350,$d41
	dw $130f,$0,$0,$ee1,$0
	dw $f07,$1dc,$3b8,$0
	dw $1368,$ee1
	dw $f0f,$0,$0,$b25,$0
	dw $1327,$ee,$1dc,$0
	dw $8d0b,$0,$0,$b25,$110
	dw $134f,$ee,$1dc,$d41,$0
	dw $8d07,$0,$0,$0,$120
	dw $132b,$ee,$1dc,$d41
	dw $f6c,$ee1,$0
	dw $1347,$0,$0,$0
	dw $8d08,$ee1,$110
	dw $132f,$ee,$1dc,$b25,$0
	dw $f84,$0
	dw $136b,$0,$0,$b25
	dw $f2f,$1a8,$350,$d41,$0
	dw $1387,$0,$0,$0
	dw $8d0b,$1dc,$3b8,$d41,$180
	dw $910c,$ee1,$0,$180
	dw $f87,$0,$0,$0
	dw $132b,$179,$2f3,$ee1
	dw $8d0c,$b25,$0,$110
	dw $1347,$0,$0,$0
	dw $8d08,$b25,$120
	dw $132f,$179,$2f3,$d41,$0
	dw $f64,$0
	dw $134b,$0,$0,$d41
	dw $8d0c,$ee1,$0,$120
	dw $1327,$179,$2f3,$0
	dw $8d08,$ee1,$110
	dw $136f,$0,$0,$b25,$0
	dw $f27,$179,$2f3,$0
	dw $130b,$0,$0,$b25
	dw $f0f,$179,$2f3,$d41,$0
	dw $1364,$0
	dw $f0b,$0,$0,$d41
	dw $132f,$13d,$27b,$ee1,$0
	dw $8d07,$0,$0,$0,$110
	dw $134b,$13d,$27b,$ee1
	dw $8d0f,$0,$0,$b25,$0,$120
	dw $1327,$13d,$27b,$0
	dw $f68,$b25
	dw $134f,$0,$0,$d41,$0
	dw $8d04,$0,$110
	dw $132b,$164,$2c9,$d41
	dw $f4c,$ee1,$0
	dw $1347,$0,$0,$0
	dw $f2b,$164,$2c9,$ee1
	dw $918f,$350,$d39,$b25,$0,$110
	dw $8d87,$2c9,$b1d,$0,$110
	dw $918b,$236,$8d0,$b25,$110
	dw $8d8f,$216,$851,$d41,$0,$110
	dw $1327,$ee,$1d4,$0
	dw $8d08,$d41,$110
	dw $134f,$0,$0,$ee1,$0
	dw $8d07,$1dc,$3b8,$0,$120
	dw $132b,$ee,$1dc,$ee1
	dw $f6c,$b25,$0
	dw $1347,$0,$0,$0
	dw $8d0b,$77,$ee,$b25,$120
	dw $132f,$ee,$1dc,$d41,$0
	dw $8d04,$0,$110
	dw $136b,$0,$0,$d41
	dw $f2f,$1a8,$350,$ee1,$0
	dw $1304,$0
	dw $f0b,$1dc,$3b8,$ee1
	dw $136c,$b25,$0
	dw $f07,$3b8,$770,$0
	dw $132b,$ee,$1dc,$b25
	dw $8d0f,$0,$0,$d41,$0,$110
	dw $1347,$ee,$1dc,$0
	dw $8d0b,$1a8,$350,$d41,$120
	dw $132f,$1dc,$3b8,$ee1,$0
	dw $f64,$0
	dw $134b,$1a8,$350,$ee1
	dw $8d0c,$b25,$0,$110
	dw $1327,$ee,$1dc,$0
	dw $f88,$b25
	dw $136f,$0,$0,$d41,$0
	dw $f27,$1a8,$350,$0
	dw $138b,$0,$0,$d41
	dw $8d0f,$1dc,$3b8,$ee1,$0,$180
	dw $9104,$0,$180
	dw $f8b,$77,$ee,$ee1
	dw $132f,$ee,$1dc,$b25,$0
	dw $8d04,$0,$110
	dw $134b,$1dc,$3b8,$b25
	dw $8d0c,$d41,$0,$120
	dw $1327,$ee,$1dc,$0
	dw $f68,$d41
	dw $134f,$1a8,$350,$ee1,$0
	dw $8d04,$0,$120
	dw $132b,$ee,$1dc,$ee1
	dw $8d0c,$b25,$0,$110
	dw $1367,$0,$0,$0
	dw $f2b,$1a8,$350,$b25
	dw $130f,$ee,$1dc,$d41,$0
	dw $f07,$1dc,$3b8,$0
	dw $1368,$d41
	dw $f0f,$0,$0,$ee1,$0
	dw $1327,$1dc,$3b8,$0
	dw $8d0b,$0,$0,$ee1,$110
	dw $134f,$1dc,$3b8,$b25,$0
	dw $8d07,$0,$0,$0,$120
	dw $132b,$ee,$1dc,$b25
	dw $f6c,$d41,$0
	dw $1347,$1a8,$350,$0
	dw $8d08,$d41,$110
	dw $132f,$ee,$1dc,$ee1,$0
	dw $f44,$0
	dw $134b,$0,$0,$ee1
	dw $f8f,$1a8,$350,$b25,$0
	dw $9167,$0,$0,$0,$120
	dw $f8b,$1dc,$3b8,$b25
	dw $916c,$d41,$0,$140
	dw $f87,$77,$ee,$0
	dw $132b,$ee,$1d4,$d41
	dw $8d0c,$ee1,$0,$110
	dw $1347,$0,$0,$0
	dw $8d0b,$1dc,$3b8,$ee1,$120
	dw $132f,$ee,$1dc,$b25,$0
	dw $f64,$0
	dw $134b,$0,$0,$b25
	dw $8d0f,$77,$ee,$d41,$0,$120
	dw $1327,$ee,$1dc,$0
	dw $8d08,$d41,$110
	dw $136f,$0,$0,$ee1,$0
	dw $f27,$1a8,$350,$0
	dw $1308,$ee1
	dw $f0f,$1dc,$3b8,$b25,$0
	dw $1364,$0
	dw $f0b,$3b8,$770,$b25
	dw $132f,$ee,$1dc,$d41,$0
	dw $8d07,$0,$0,$0,$110
	dw $134b,$ee,$1dc,$d41
	dw $8d0f,$1a8,$350,$ee1,$0,$120
	dw $1327,$1dc,$3b8,$0
	dw $f68,$ee1
	dw $134f,$1a8,$350,$b25,$0
	dw $8d04,$0,$110
	dw $132b,$ee,$1dc,$b25
	dw $f8c,$d41,$0
	dw $1367,$0,$0,$0
	dw $f2b,$1a8,$350,$d41
	dw $138f,$0,$0,$ee1,$0
	dw $f07,$1dc,$3b8,$0
	dw $1308,$ee1
	dw $f8f,$77,$ee,$b25,$0
	dw $1327,$179,$2f3,$0
	dw $8d08,$b25,$110
	dw $134f,$2f3,$5e7,$d41,$0
	dw $8d04,$0,$120
	dw $132b,$179,$2f3,$d41
	dw $f6c,$ee1,$0
	dw $1347,$bc,$179,$0
	dw $8d08,$ee1,$120
	dw $132f,$179,$2f3,$b25,$0
	dw $8d04,$0,$110
	dw $136b,$0,$0,$b25
	dw $f2f,$179,$2f3,$d41,$0
	dw $1307,$0,$0,$0
	dw $f0b,$350,$6a0,$d41
	dw $136c,$ee1,$0
	dw $f07,$1a8,$350,$0
	dw $132b,$13d,$27b,$ee1
	dw $8d0f,$0,$0,$b25,$0,$110
	dw $1347,$13d,$27b,$0
	dw $8d0b,$0,$0,$b25,$120
	dw $132f,$13d,$27b,$d41,$0
	dw $f64,$0
	dw $134b,$0,$0,$d41
	dw $8d0c,$ee1,$0,$110
	dw $1327,$164,$2c9,$0
	dw $f88,$ee1
	dw $136f,$0,$0,$b25,$0
	dw $f27,$164,$2c9,$0
	dw $138b,$350,$d39,$b25
	dw $f0f,$2c9,$b1d,$d41,$0
	dw $1307,$236,$8d0,$0
	dw $f8b,$216,$851,$d41
	dw $132f,$ee,$1dc,$0,$0
	dw $8d00,$110
	dw $134c,$770,$b25
	dw $8d0c,$0,$0,$120
	dw $1320
	dw $f6c,$770,$b25
	dw $134c,$0,$0
	dw $8d00,$120
	dw $132c,$770,$b25
	dw $8d0c,$0,$0,$110
	dw $1363,$10b,$216
	dw $f2c,$770,$9ee
	dw $130c,$0,$0
	dw $f00
	dw $136f,$11b,$236,$770,$b25
	dw $f0c,$0,$0
	dw $1320
	dw $8d00,$110
	dw $134c,$770,$b25
	dw $8d0c,$0,$0,$120
	dw $1320
	dw $f6c,$770,$b25
	dw $134c,$0,$0
	dw $8d00,$110
	dw $132c,$770,$b25
	dw $f0c,$0,$0
	dw $1360
	dw $f2c,$770,$bcf
	dw $130f,$179,$2f3,$0,$0
	dw $f00
	dw $138c,$770,$bcf
	dw $f8c,$0,$0
	dw $1323,$13d,$27b
	dw $8d00,$110
	dw $134c,$770,$b25
	dw $8d0c,$0,$0,$120
	dw $1320
	dw $f6c,$770,$b25
	dw $134c,$0,$0
	dw $8d00,$120
	dw $132c,$770,$b25
	dw $8d0c,$0,$0,$110
	dw $1360
	dw $f2c,$770,$9ee
	dw $130c,$0,$0
	dw $f00
	dw $136c,$770,$b25
	dw $f0c,$0,$0
	dw $1323,$164,$2c9
	dw $8d00,$110
	dw $134c,$770,$b25
	dw $8d0c,$0,$0,$120
	dw $1320
	dw $f6c,$770,$b25
	dw $134c,$0,$0
	dw $8d00,$110
	dw $132c,$770,$b25
	dw $f0c,$0,$0
	dw $1360
	dw $f2c,$8d8,$d41
	dw $130f,$11b,$236,$0,$0
	dw $f00
	dw $138c,$8d8,$d41
	dw $f8c,$0,$0
	dw $1323,$ee,$1dc
	dw $8d00,$110
	dw $134c,$770,$b25
	dw $8d0c,$0,$0,$120
	dw $1320
	dw $f6c,$770,$b25
	dw $134c,$0,$0
	dw $8d00,$120
	dw $132c,$770,$b25
	dw $8d0c,$0,$0,$110
	dw $1363,$10b,$216
	dw $f2c,$770,$9ee
	dw $130c,$0,$0
	dw $f00
	dw $136f,$11b,$236,$770,$b25
	dw $f0c,$0,$0
	dw $1320
	dw $8d00,$110
	dw $134c,$770,$b25
	dw $8d0c,$0,$0,$120
	dw $1320
	dw $f6c,$770,$b25
	dw $134c,$0,$0
	dw $8d00,$110
	dw $132c,$770,$b25
	dw $f0c,$0,$0
	dw $1360
	dw $f2c,$770,$bcf
	dw $130f,$179,$2f3,$0,$0
	dw $f00
	dw $138c,$770,$bcf
	dw $f8c,$0,$0
	dw $1323,$13d,$27b
	dw $8d00,$110
	dw $134c,$770,$b25
	dw $8d0c,$0,$0,$120
	dw $1320
	dw $f6c,$770,$b25
	dw $134c,$0,$0
	dw $8d00,$120
	dw $132c,$770,$b25
	dw $8d0c,$0,$0,$110
	dw $1360
	dw $f2c,$770,$9ee
	dw $130f,$179,$2f3,$0,$0
	dw $f00
	dw $136c,$770,$b25
	dw $f0c,$0,$0
	dw $1323,$164,$2c9
	dw $8d00,$110
	dw $134c,$770,$b25
	dw $8d0c,$0,$0,$120
	dw $1320
	dw $f6c,$770,$b25
	dw $134c,$0,$0
	dw $8d00,$110
	dw $132c,$770,$b25
	dw $f0c,$0,$0
	dw $1360
	dw $f2c,$8d8,$d41
	dw $130f,$10b,$216,$0,$0
	dw $f00
	dw $138f,$11b,$236,$8d8,$d41
	dw $f8c,$0,$0
	dw $1323,$ee,$1dc
	dw $8d00,$110
	dw $134c,$770,$b25
	dw $8d0c,$0,$0,$120
	dw $1320
	dw $f6c,$770,$b25
	dw $134c,$0,$0
	dw $8d00,$120
	dw $132c,$770,$b25
	dw $8d0c,$0,$0,$110
	dw $1363,$10b,$216
	dw $f2c,$770,$9ee
	dw $130c,$0,$0
	dw $f00
	dw $136f,$11b,$236,$770,$b25
	dw $f0c,$0,$0
	dw $1320
	dw $8d00,$110
	dw $134c,$770,$b25
	dw $8d0c,$0,$0,$120
	dw $1320
	dw $f6c,$770,$b25
	dw $134c,$0,$0
	dw $8d00,$110
	dw $132c,$770,$b25
	dw $f0c,$0,$0
	dw $1360
	dw $f2c,$770,$bcf
	dw $130f,$179,$2f3,$0,$0
	dw $f00
	dw $138c,$770,$bcf
	dw $f8c,$0,$0
	dw $1323,$13d,$27b
	dw $8d00,$110
	dw $134c,$770,$b25
	dw $8d0c,$0,$0,$120
	dw $1320
	dw $f6c,$770,$b25
	dw $134c,$0,$0
	dw $8d00,$120
	dw $132c,$770,$b25
	dw $8d0c,$0,$0,$110
	dw $1360
	dw $f2c,$770,$9ee
	dw $130c,$0,$0
	dw $f00
	dw $136c,$770,$b25
	dw $f0c,$0,$0
	dw $1323,$164,$2c9
	dw $8d00,$110
	dw $134c,$770,$b25
	dw $8d0c,$0,$0,$120
	dw $1320
	dw $f6c,$770,$b25
	dw $134c,$0,$0
	dw $8d00,$110
	dw $132c,$770,$b25
	dw $f0c,$0,$0
	dw $1360
	dw $f2c,$8d8,$d41
	dw $130f,$11b,$236,$0,$0
	dw $f00
	dw $138c,$8d8,$d41
	dw $f8c,$0,$0
	dw $1323,$ee,$1dc
	dw $8d00,$110
	dw $134c,$770,$b25
	dw $8d0c,$0,$0,$120
	dw $1320
	dw $f6c,$770,$b25
	dw $134c,$0,$0
	dw $8d00,$120
	dw $132c,$770,$b25
	dw $8d0c,$0,$0,$110
	dw $1363,$10b,$216
	dw $f2c,$770,$9ee
	dw $130c,$0,$0
	dw $f00
	dw $136f,$11b,$236,$770,$b25
	dw $f0c,$0,$0
	dw $1320
	dw $8d00,$110
	dw $134c,$770,$b25
	dw $8d0c,$0,$0,$120
	dw $1320
	dw $f6c,$770,$b25
	dw $134c,$0,$0
	dw $8d00,$110
	dw $132c,$770,$b25
	dw $f0c,$0,$0
	dw $1363,$13d,$27b
	dw $f2c,$770,$bcf
	dw $130c,$0,$0
	dw $f00
	dw $138f,$164,$2c9,$770,$bcf
	dw $f8c,$0,$0
	dw $1320
	dw $8d00,$110
	dw $134c,$770,$b25
	dw $8d0c,$0,$0,$120
	dw $1320
	dw $f6c,$770,$b25
	dw $134c,$0,$0
	dw $8d00,$120
	dw $132c,$770,$b25
	dw $8d0c,$0,$0,$110
	dw $1363,$179,$2f3
	dw $f2c,$770,$9ee
	dw $130c,$0,$0
	dw $f00
	dw $136f,$1a8,$350,$770,$b25
	dw $f0c,$0,$0
	dw $1320
	dw $8d00,$110
	dw $134c,$770,$b25
	dw $8d0c,$0,$0,$120
	dw $1320
	dw $f6c,$770,$b25
	dw $134c,$0,$0
	dw $8d00,$110
	dw $132c,$770,$b25
	dw $f0c,$0,$0
	dw $1360
	dw $f2c,$8d8,$d41
	dw $130f,$1dc,$3b8,$0,$0
	dw $f03,$1a8,$350
	dw $138f,$13d,$27b,$8d8,$d41
	dw $f8f,$11b,$236,$0,$0
	dw $1323,$ee,$1dc
	dw $8d00,$110
	dw $914f,$0,$11b1,$770,$b25,$120
	dw $8d0c,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d6c,$770,$b25,$110
	dw $914f,$0,$ee1,$0,$0,$120
	dw $8d00,$140
	dw $132f,$ee,$1dc,$770,$b25
	dw $8d0c,$0,$0,$110
	dw $9163,$0,$0,$120
	dw $8d2f,$1a8,$350,$770,$9ee,$140
	dw $130f,$0,$164b,$0,$0
	dw $8d03,$1dc,$3b8,$110
	dw $916c,$770,$b25,$120
	dw $8d0f,$0,$179e,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d03,$0,$164b,$110
	dw $914f,$ee,$1dc,$770,$b25,$120
	dw $8d0f,$0,$11b1,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d6c,$770,$b25,$110
	dw $914f,$0,$ee1,$0,$0,$120
	dw $8d00,$140
	dw $132f,$ee,$1dc,$770,$b25
	dw $8d8c,$0,$0,$110
	dw $9163,$0,$1a83,$120
	dw $8d2f,$1a8,$350,$770,$bcf,$140
	dw $138f,$0,$0,$0,$0
	dw $8d03,$1dc,$3b8,$110
	dw $910e,$179e,$770,$bcf,$120
	dw $8d8f,$0,$0,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d00,$110
	dw $914f,$0,$11b1,$770,$b25,$120
	dw $8d0c,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d6c,$770,$b25,$110
	dw $914f,$0,$ee1,$0,$0,$120
	dw $8d00,$140
	dw $132f,$ee,$1dc,$770,$b25
	dw $8d0c,$0,$0,$110
	dw $9163,$0,$164b,$120
	dw $8d2f,$1a8,$350,$770,$9ee,$140
	dw $130f,$0,$0,$0,$0
	dw $8d03,$1dc,$3b8,$110
	dw $916e,$179e,$770,$b25,$120
	dw $8d0f,$0,$0,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d03,$0,$164b,$110
	dw $914f,$ee,$1dc,$770,$b25,$120
	dw $8d0f,$0,$11b1,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d6c,$770,$b25,$110
	dw $914f,$0,$ee1,$0,$0,$120
	dw $8d00,$140
	dw $132f,$ee,$1dc,$770,$b25
	dw $8d4c,$0,$0,$110
	dw $9143,$0,$b25,$120
	dw $8d8f,$1a8,$bcf,$8d8,$d41,$140
	dw $136f,$0,$179e,$0,$0
	dw $8d83,$1dc,$b25,$110
	dw $916e,$bcf,$8d8,$d41,$120
	dw $8d8f,$0,$ee1,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d00,$110
	dw $914f,$0,$11b1,$770,$b25,$120
	dw $8d0c,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d6c,$770,$b25,$110
	dw $914f,$0,$ee1,$0,$0,$120
	dw $8d00,$140
	dw $132f,$ee,$1dc,$770,$b25
	dw $8d0c,$0,$0,$110
	dw $9163,$0,$0,$120
	dw $8d2f,$1a8,$350,$770,$9ee,$140
	dw $130f,$0,$164b,$0,$0
	dw $8d03,$1dc,$3b8,$110
	dw $916c,$770,$b25,$120
	dw $8d0f,$0,$179e,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d03,$0,$164b,$110
	dw $914f,$ee,$1dc,$770,$b25,$120
	dw $8d0f,$0,$11b1,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d6c,$770,$b25,$110
	dw $914f,$0,$ee1,$0,$0,$120
	dw $8d00,$140
	dw $132f,$ee,$1dc,$770,$b25
	dw $8d8c,$0,$0,$110
	dw $9163,$0,$1a83,$120
	dw $8d2f,$1a8,$350,$770,$bcf,$140
	dw $138f,$0,$0,$0,$0
	dw $8d03,$1dc,$3b8,$110
	dw $910e,$179e,$770,$bcf,$120
	dw $8d8f,$0,$0,$0,$0,$140
	dw $1323,$179,$2f3
	dw $8d00,$110
	dw $914f,$0,$11b1,$770,$b25,$120
	dw $8d0c,$0,$0,$140
	dw $1323,$179,$2f3
	dw $8d6c,$770,$b25,$110
	dw $914f,$0,$ee1,$0,$0,$120
	dw $8d00,$140
	dw $132f,$179,$2f3,$770,$b25
	dw $8d0c,$0,$0,$110
	dw $9163,$0,$0,$120
	dw $8d2f,$179,$2f3,$770,$9ee,$140
	dw $130f,$0,$164b,$0,$0
	dw $8d03,$179,$2f3,$110
	dw $916c,$770,$b25,$120
	dw $8d0f,$0,$179e,$0,$0,$140
	dw $1323,$13d,$27b
	dw $8d03,$0,$0,$110
	dw $914f,$13d,$164b,$770,$b25,$120
	dw $8d0d,$0,$0,$0,$140
	dw $1323,$13d,$27b
	dw $8d6c,$770,$b25,$110
	dw $914f,$0,$13dc,$0,$0,$120
	dw $8d00,$140
	dw $132f,$164,$2c9,$770,$b25
	dw $8d4c,$0,$0,$110
	dw $9143,$0,$10b3,$120
	dw $8d8f,$2c9,$ee1,$8d8,$d41,$140
	dw $136f,$0,$10b3,$0,$0
	dw $8d83,$2c9,$ee1,$110
	dw $916e,$10b3,$8d8,$d41,$120
	dw $8d8f,$0,$11b1,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d00,$110
	dw $914f,$0,$11b1,$770,$b25,$120
	dw $8d0c,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d6c,$770,$b25,$110
	dw $914f,$0,$ee1,$0,$0,$120
	dw $8d00,$140
	dw $132f,$ee,$1dc,$770,$b25
	dw $8d0c,$0,$0,$110
	dw $9163,$0,$0,$120
	dw $8d2f,$1a8,$350,$770,$9ee,$140
	dw $130f,$0,$164b,$0,$0
	dw $8d03,$1dc,$3b8,$110
	dw $916c,$770,$b25,$120
	dw $8d0f,$0,$179e,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d03,$0,$164b,$110
	dw $914f,$ee,$1dc,$770,$b25,$120
	dw $8d0f,$0,$11b1,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d6c,$770,$b25,$110
	dw $914f,$0,$ee1,$0,$0,$120
	dw $8d00,$140
	dw $132f,$ee,$1dc,$770,$b25
	dw $8d8c,$0,$0,$110
	dw $9163,$0,$1a83,$120
	dw $8d2f,$1a8,$350,$770,$bcf,$140
	dw $138f,$0,$0,$0,$0
	dw $8d03,$1dc,$3b8,$110
	dw $910e,$179e,$770,$bcf,$120
	dw $8d8f,$0,$0,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d00,$110
	dw $914f,$0,$11b1,$770,$b25,$120
	dw $8d0c,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d6c,$770,$b25,$110
	dw $914f,$0,$ee1,$0,$0,$120
	dw $8d00,$140
	dw $132f,$ee,$1dc,$770,$b25
	dw $8d0c,$0,$0,$110
	dw $9163,$0,$164b,$120
	dw $8d2f,$1a8,$350,$770,$9ee,$140
	dw $130f,$0,$0,$0,$0
	dw $8d03,$1dc,$3b8,$110
	dw $916e,$179e,$770,$b25,$120
	dw $8d0f,$0,$0,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d03,$0,$164b,$110
	dw $914f,$ee,$1dc,$770,$b25,$120
	dw $8d0f,$0,$11b1,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d6c,$770,$b25,$110
	dw $914f,$0,$ee1,$0,$0,$120
	dw $8d00,$140
	dw $132f,$ee,$1dc,$770,$b25
	dw $8d4c,$0,$0,$110
	dw $9143,$0,$b25,$120
	dw $8d8f,$1a8,$bcf,$8d8,$d41,$140
	dw $136f,$0,$179e,$0,$0
	dw $8d83,$1dc,$b25,$110
	dw $916e,$bcf,$8d8,$d41,$120
	dw $8d8f,$0,$ee1,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d00,$110
	dw $914f,$0,$11b1,$770,$b25,$120
	dw $8d0c,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d6c,$770,$b25,$110
	dw $914f,$0,$ee1,$0,$0,$120
	dw $8d00,$140
	dw $132f,$ee,$1dc,$770,$b25
	dw $8d0c,$0,$0,$110
	dw $9163,$0,$0,$120
	dw $8d2f,$1a8,$350,$770,$9ee,$140
	dw $130f,$0,$164b,$0,$0
	dw $8d03,$1dc,$3b8,$110
	dw $916c,$770,$b25,$120
	dw $8d0f,$0,$179e,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d03,$0,$164b,$110
	dw $914f,$ee,$1dc,$770,$b25,$120
	dw $8d0f,$0,$11b1,$0,$0,$140
	dw $1323,$ee,$1dc
	dw $8d6c,$770,$b25,$110
	dw $914f,$0,$ee1,$0,$0,$120
	dw $8d00,$140
	dw $132f,$ee,$1dc,$770,$b25
	dw $8d8c,$0,$0,$110
	dw $9163,$0,$1a83,$120
	dw $8d2f,$1a8,$350,$770,$bcf,$140
	dw $138f,$0,$0,$0,$0
	dw $8d03,$1dc,$3b8,$110
	dw $910e,$179e,$770,$bcf,$120
	dw $8d8f,$0,$0,$0,$0,$140
	dw $1323,$179,$2f3
	dw $8d00,$110
	dw $914f,$0,$11b1,$770,$b25,$120
	dw $8d0c,$0,$0,$140
	dw $1323,$179,$2f3
	dw $8d6c,$770,$b25,$110
	dw $914f,$0,$ee1,$0,$0,$120
	dw $8d00,$140
	dw $132f,$179,$2f3,$770,$b25
	dw $8d0c,$0,$0,$110
	dw $9163,$0,$0,$120
	dw $8d2f,$179,$2f3,$770,$9ee,$140
	dw $130f,$0,$164b,$0,$0
	dw $8d03,$179,$2f3,$110
	dw $916c,$770,$b25,$120
	dw $8d0f,$0,$179e,$0,$0,$140
	dw $1323,$13d,$27b
	dw $8d03,$0,$0,$110
	dw $914f,$13d,$164b,$770,$b25,$120
	dw $8d0d,$0,$0,$0,$140
	dw $1323,$13d,$27b
	dw $8d6c,$770,$b25,$110
	dw $914f,$0,$13dc,$0,$0,$120
	dw $8d00,$140
	dw $132f,$164,$2c9,$770,$b25
	dw $8d4c,$0,$0,$110
	dw $9143,$0,$10b3,$120
	dw $8d8f,$2c9,$ee1,$8d8,$d41,$140
	dw $136f,$0,$10b3,$0,$0
	dw $8d83,$2c9,$ee1,$110
	dw $916e,$10b3,$8d8,$d41,$120
	dw $8d8f,$0,$11b1,$0,$0,$140
	dw 0


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

	savebin "hoffman.tap",tap_b,tap_e-tap_b


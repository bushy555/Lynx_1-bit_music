
	device zxspectrum128

	org $6500-13				; Origin
tap_b:	db $22,"NONAME",$22			;name		  	HEADER
	db "M"					;type		  	HEADER
	dw end-begin				;program length	  	HEADER
	dw begin				;load point		HEADER
	org $6500
begin:
;	xor a					;By default lynx makes a noise
;	out (%10000100),a			;so we mute the noise here!
	



; Star Tip 2 (C) 1987 Tim Follin/Your Sinclair.
; disassembled and commented by Matt B




; Star Tip 2 by Tim Follin.
; Printed in Your Sinclair program pistop
; in 1987.
;
; Z80 Disassembly by Craig Daines.
;
; Numerical values are printed in decimal.
; if this is inconvient, I provide the
; same disassembly with numerical values
; printed in hex (available as a seperate
; file).
;
; The routine starts at address 9C40
; (40000 decimal) and ends at address A17B
; (41339 decimal), and is 1340 bytes long.
; RANDOMIZE USR 40000 to hear it.



	ld hl,musicData
	call play
	ret

	;engine code

play:
	DI						; Disable interrupts.
	push hl
	pop ix	   				; IX points to the start of the music.
next:
	LD    A,(IX+0)			; Look at the next byte of music.
	INC   A
	JP    NZ,break			; If A is OFFh read a new envelope.
	INC   IX
	LD    H,(IX+1)			; Load the note length.
	LD    L,(IX+0)
	LD    (noteLength),HL
	INC   IX
	INC   IX
	LD    A,(IX+0)			; Load the attack rate.
	LD    (attackRate),A
	LD    A,(IX+1)			; Load the decay rate.
	LD    (decayRate),A
	LD    A,(IX+2)			; Decay target volume.
	LD    (decayTargetVolume),A
	INC   IX				; Move IX to next music data.
	INC   IX
	INC   IX
	JP    next
break:
	LD    A,(decayRate)		; Copy decay rate to decay count.
	LD    (decayCount),A
	LD    A,(attackRate)	; Copy attack rate to attack count.
	LD    (attackCount),A
	LD    BC,(noteLength)	; BC contains the note length.
	LD    H,(IX+0)			; H, L and D contain the note pitches.
	LD    L,(IX+1)
	LD    D,(IX+2)
	LD    E,10				; Only control volume every ten cycles.
	LD    A,1
	LD    (volumeControl),A	; Set volume to 1.
	LD    (attackDecay),A	; Set attack phase.
	CALL  subr				; Call subroutine that drives the beeper.
	XOR   A					; Zero accumulator.
	IN    A,(254)			; Read keyboard.
	CPL						; Complement result.
	AND   31				; Mask keyboard bits.
	JP    NZ, keyp			; Jump if a key is pressed.
	INC   IX				; Move IX 3 bytes along.
	INC   IX
	INC   IX
	LD    A,(IX+0)			; Check for a zero.
	AND   A
	JP    NZ, next			; Finished?
keyp:
	EI						; Re-enable interrupts.
	RET						; Return from music program.

subr:
	PUSH  BC				; Start of subroutine. Save the note length.
	LD    A,(volumeControl)	; Get the volume.
	LD    C,A
	DEC   H					; Decrement counter for first channel.
	JR    NZ,labl1			; Do we play the first note yet?
	XOR   A					; Zero A.
	out	($84), a
	LD    B,C				; B holds a delay.
wait1:
	DJNZ  wait1				; Wait for the first half of the duty cycle.
	LD    A,16				; Set beeper bit.
	out	($84), a
	SUB   C					; Subtract delay from 16.
	LD    B,A
wait2:
	DJNZ  wait2				; Wait for the second half of the duty cycle.
	LD    H,(IX+0)			; Re-load H with pitch for channel 1.
labl1:
	DEC   L
	JR    NZ,labl2			; Do we play the second note yet?
	XOR   A					; Zero A.
	out	($84), a
	LD    B,C
wait3:
	DJNZ  wait3				; Wait for the first half of the duty cycle.
	LD    A,16				; Set beeper bit.
	out	($84), a
	SUB   C					; Subtract delay from 16.
	LD    B,A
wait4:
	DJNZ  wait4				; Wait for the second half of the duty cycle.
	LD    L,(IX+1)			; Re-load L with pitch for channel 2.
labl2:
	DEC   D
	JR    NZ,labl3			; Do we play the third note yet?
	XOR   A					; Zero A.
	out	($84), a
	LD    B,C
wait5:
	DJNZ  wait5				; Wait for the first half of the duty cycle.
	LD    A,16				; Set beeper bit.
	out	($84), a
	SUB   C					; Subtract delay from 16.
	LD    B,A
wait6:
	DJNZ  wait6				; Wait for the second half of the duty cycle.
	LD    D,(IX+2)			; Re-load D with pitch for channel 3.
labl3:
	DEC   E					; Volume control loop.
	JP    NZ,labl5			; Only use every ten cycles.
	LD    E,10
	LD    A,(attackDecay)	; Attack (1) or Decay (0)?
	AND   A
	JP    Z,labl4
	LD    A,(attackCount)	; Load the current attack count.
	DEC   A					; Subtract 1.
	LD    (attackCount),A	; Save it.
	JP    NZ,labl5			; We're done if count is not zero.
	LD    A,(attackRate)	; Loat the attack rate.
	LD    (attackCount),A	; Save it in the attack count.
	LD    A,(volumeControl)	; Load the volume.
	INC   A					; Increase it.
	LD    (volumeControl),A	; Save it.
	CP    15				; Is it maxed out?
	JP    NZ,labl5			; If not, skip this next bit.
	DEC   A
	LD    (volumeControl),A	; Decrease volume.
	XOR   A
	LD    (attackDecay),A	; Switch to decay.
	JP    labl5				; Skip to the end of the loop.
labl4:
	LD    A,(decayCount)	; Load the decay count.
	DEC   A
	LD    (decayCount),A
	JP    NZ,labl5			; Is it zero yet?
	LD    A,(decayRate)		; Load decay rate.
	LD    (decayCount),A	; Store it in count.
	LD    A,(volumeControl)	; Load volume.
	DEC   A					; Decrease it.
	LD    B,A				; Store it in B.
	LD    A,(decayTargetVolume)	; Load decay target.
	CP    B					; Is volume on target?
	JP    Z,labl5
	LD    A,B				; Store new volume.
	LD    (volumeControl),A
labl5:
	POP   BC				; Restore BC
	DEC   BC				; Decrement BC
	LD    A,B				; Is the note finished?
	OR    C
	JP    NZ,subr			; If BC is not zero loop again.
	RET						; return from subroutine

; Workspace starts here.
; Initial values

noteLength:		dw $9600	; Note length counter.
volumeControl:		db $0C		; Volume control.
decayRate:		db $80		; Decay rate.
decayCount:		db $80		; Current decay count.
attackRate:		db $00		; Attack rate.
attackCount:		db $00		; Current attack count.
attackDecay:		db $00		; Attack (1) or decay (0) phase.
decayTargetVolume:	db $01		; Decay target volume.


	db $00, $00	

musicData:

40291 db $ff,$60,$09,$02,$01,$0A,$41,$52
40299 db $6d,$3d,$52,$6d,$41,$52
40304 db $6D,$49,$52,$6D,$FF,$00,$96,$01
40312 db $96,$01,$57,$62,$83,$FF,$00,$96
40320 db $FA,$00,$0F,$57,$62,$83,$FF,$60
40328 db $09,$04,$01,$0A,$53,$5D,$7C,$46
40336 db $5D,$7C,$3E,$5D,$7C,$46,$5D,$7C
40344 db $5D,$5D,$7C,$63,$5D,$7C,$5D,$53
40352 db $7C,$63,$53,$7C,$6E,$53,$7C,$7C
40360 db $53,$7C,$8C,$53,$7C,$7C,$53,$7C
40368 db $6F,$53,$7C,$53,$53,$7C,$FF,$60
40376 db $09,$04,$01,$0A,$64,$85,$C8,$59
40384 db $85,$C8,$54,$85,$C8,$42,$84,$C7
40392 db $54,$85,$C8,$59,$85,$C8,$64,$85
40400 db $C8,$70,$86,$C8,$4B,$96,$E1,$54
40408 db $96,$E1,$5F,$96,$E1,$64,$96,$E1
40416 db $71,$96,$E1,$7F,$97,$E1,$71,$96
40424 db $E1,$64,$96,$E1,$4E,$9D,$EB,$58
40432 db $9D,$EB,$4E,$9D,$EB,$42,$9C,$EA
40440 db $46,$9C,$EB,$58,$9C,$EB,$4E,$9D
40448 db $EB,$58,$9D,$EB,$4E,$9D,$EB,$63
40456 db $9D,$EB,$69,$9D,$EB,$84,$9D,$EB
40464 db $76,$9D,$EB,$76,$9D,$EB,$76,$9D
40472 db $EB,$76,$9D,$EB,$58,$63,$C7,$58
40480 db $53,$C6,$57,$41,$C5,$57,$37,$C3
40488 db $58,$63,$C7,$58,$53,$C6,$57,$41
40496 db $C5,$57,$37,$C3,$53,$63,$C7,$53
40504 db $53,$C6,$53,$41,$C5,$53,$37,$C3
40512 db $53,$63,$C7,$53,$53,$C6,$53,$41
40520 db $C5,$53,$37,$C3,$63,$63,$DF,$63
40528 db $5E,$DF,$63,$4A,$DF,$63,$3E,$DF
40536 db $63,$63,$DF,$63,$5E,$DF,$63,$4A
40544 db $DF,$63,$3E,$DF,$5D,$63,$DF,$5D
40552 db $5E,$DF,$5D,$4A,$DF,$5D,$3E,$DF
40560 db $5D,$63,$DF,$5D,$5E,$DF,$5D,$4A
40568 db $DF,$5D,$3E,$DF,$6F,$63,$C7,$6F
40576 db $53,$C6,$6F,$41,$C5,$6F,$37,$C3
40584 db $84,$63,$C7,$84,$53,$C6,$84,$41
40592 db $C5,$84,$37,$C3,$7D,$63,$DF,$7D
40600 db $5E,$DF,$7D,$4A,$DF,$7D,$3E,$DF
40608 db $94,$63,$DF,$94,$5E,$DF,$94,$4A
40616 db $DF,$94,$3E,$DF,$84,$63,$C7,$84
40624 db $53,$C6,$84,$41,$C5,$84,$37,$C3
40632 db $6F,$63,$C7,$6F,$53,$C6,$6F,$41
40640 db $C5,$6F,$37,$C3,$63,$63,$C7,$63
40648 db $53,$C6,$63,$41,$C5,$63,$37,$C3
40656 db $63,$63,$C7,$63,$53,$C6,$63,$41
40664 db $C5,$63,$37,$C3,$63,$63,$C7,$5E
40672 db $53,$C6,$63,$41,$C5,$5E,$37,$C3
40680 db $63,$63,$C7,$5E,$53,$C6,$63,$41
40688 db $C5,$5E,$37,$C3,$5D,$5D,$D2,$75
40696 db $58,$D2,$5C,$45,$CF,$58,$3A,$D0
40704 db $5D,$5D,$D2,$75,$58,$D2,$5C,$45
40712 db $CF,$58,$3A,$D0,$5D,$5D,$D2,$75
40720 db $58,$D2,$5C,$45,$CF,$58,$3A,$D0
40728 db $5C,$5C,$8B,$75,$58,$8B,$5C,$45
40736 db $8B,$58,$3A,$8B,$63,$63,$DE,$63
40744 db $5E,$DE,$63,$4A,$DD,$62,$3E,$DC
40752 db $63,$63,$DE,$63,$5E,$DE,$63,$4A
40760 db $6F,$62,$3E,$DC,$63,$63,$94,$63
40768 db $5E,$F8,$63,$4A,$94,$62,$3E,$F8
40776 db $63,$63,$F8,$63,$5E,$F8,$63,$4A
40784 db $F8,$62,$3E,$F8,$FF,$60,$09,$01
40792 db $01,$0D,$63,$63,$F8,$63,$5E,$F8
40800 db $63,$4A,$F8,$62,$3E,$F8,$63,$63
40808 db $F8,$63,$5E,$F8,$63,$4A,$F8,$62
40816 db $3E,$F8,$6F,$63,$F8,$6F,$5E,$F8
40824 db $6F,$4A,$F8,$6F,$3E,$F8,$6F,$63
40832 db $F8,$6F,$5E,$F8,$6F,$4A,$F8,$6F
40840 db $3E,$F8,$FF,$C0,$12,$01,$01,$0D
40848 db $4A,$59,$DE,$53,$63,$DC,$59,$6F
40856 db $DE,$53,$63,$DC,$63,$7C,$F9,$58
40864 db $6F,$F9,$4A,$58,$F9,$58,$6F,$F9
40872 db $FF,$60,$09,$01,$01,$0D,$57,$68
40880 db $83,$68,$68,$83,$83,$68,$83,$62
40888 db $68,$83,$68,$68,$83,$83,$68,$83
40896 db $62,$6F,$94,$6F,$6F,$94,$94,$6F
40904 db $94,$58,$6F,$94,$6F,$6F,$94,$94
40912 db $6F,$94,$57,$68,$83,$68,$68,$83
40920 db $83,$68,$83,$62,$68,$83,$68,$68
40928 db $83,$83,$68,$83,$62,$6F,$94,$6F
40936 db $6F,$94,$94,$6F,$94,$76,$6F,$94
40944 db $6F,$6F,$94,$94,$6F,$94,$FF,$60
40952 db $09,$01,$1E,$01,$6F,$94,$DE,$6F
40960 db $94,$DE,$6F,$94,$DE,$6F,$94,$DE
40968 db $7D,$A6,$DE,$6F,$94,$DE,$7D,$A6
40976 db $DE,$6F,$94,$DE,$5D,$8C,$DE,$6F
40984 db $8C,$DE,$6F,$8C,$DE,$6F,$8C,$DE
40992 db $7D,$8C,$DE,$6F,$8C,$DE,$5D,$8C
41000 db $DE,$6F,$8C,$DE,$53,$7C,$DE,$63
41008 db $7C,$DE,$7C,$7C,$DE,$95,$7C,$DE
41016 db $7C,$7C,$DE,$63,$7C,$DE,$53,$7C
41024 db $DE,$5D,$7C,$DE,$63,$7C,$DE,$7C
41032 db $7C,$DE,$6F,$6F,$DE,$6F,$6F,$DE
41040 db $6F,$6F,$DE,$6F,$6F,$DE,$6F,$6F
41048 db $DE,$6F,$6F,$DE,$6F,$6F,$DE,$6F
41056 db $6F,$DE,$6F,$6F,$DE,$FF,$C0,$12
41064 db $01,$00,$00,$E0,$E1,$E2,$E0,$E1
41072 db $E2,$FF,$60,$09,$01,$00,$28,$5D
41080 db $7C,$93,$E0,$E1,$E2,$E0,$E1,$E2
41088 db $5D,$7C,$93,$E0,$E1,$E2,$E0,$E1
41096 db $E2,$5D,$7C,$93,$E0,$E1,$E2,$FF
41104 db $80,$25,$01,$00,$1E,$62,$7C,$A5
41112 db $FF,$60,$09,$01,$00,$02,$3D,$7A
41120 db $B8,$45,$6E,$B8,$49,$7A,$B8,$36
41128 db $6D,$A3,$3D,$61,$A3,$41,$6D,$A3
41136 db $3D,$7A,$B8,$45,$6E,$B8,$49,$7A
41144 db $B8,$36,$6D,$A3,$3D,$61,$A3,$41
41152 db $6D,$A3,$FF,$C0,$12,$01,$00,$28
41160 db $E0,$E1,$E2,$E0,$E1,$E2,$FF,$60
41168 db $09,$01,$00,$28,$5D,$7C,$93,$E0
41176 db $E1,$E2,$E0,$E1,$E2,$5D,$7C,$93
41184 db $E0,$E1,$E2,$E0,$E1,$E2,$5D,$7C
41192 db $93,$E0,$E1,$E2,$FF,$80,$25,$01
41200 db $00,$1E,$52,$6D,$82,$FF,$60,$09
41208 db $01,$00,$02,$3D,$7A,$B8,$45,$6E
41216 db $B8,$49,$7A,$B8,$36,$6D,$A3,$3D
41224 db $61,$A3,$41,$6D,$A3,$45,$8A,$CF
41232 db $4E,$7C,$CF,$53,$8B,$D0,$3D,$7A
41240 db $B8,$45,$6E,$B8,$49,$7A,$B8,$4E
41248 db $9C,$EA,$58,$8C,$EA,$5E,$9D,$EB
41256 db $45,$8A,$CF,$4E,$7C,$CF,$53,$8B
41264 db $D0,$3D,$7A,$B8,$45,$6E,$B8,$49
41272 db $7A,$B8,$36,$6D,$A3,$3D,$61,$A3
41280 db $41,$6D,$A3,$30,$60,$90,$36,$56
41288 db $90,$39,$60,$90,$36,$56,$90,$30
41296 db $60,$90,$36,$56,$90,$39,$60,$90
41304 db $36,$56,$90,$30,$60,$90,$36,$56
41312 db $90,$39,$60,$90,$36,$56,$90,$30
41320 db $60,$90,$36,$56,$90,$39,$60,$90
41328 db $36,$56,$90,$FF,$00,$96,$00,$80
41336 db $01,$39,$60,$90,$00,$00,$00,$00




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

	savebin "startip2.tap",tap_b,tap_e-tap_b




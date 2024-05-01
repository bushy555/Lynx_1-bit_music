 device zxspectrum128

	org $6500-13				; Origin
tap_b:	db $22,"NONAME",$22			;name		  	
	db "M"					;type		  	
	dw end-begin				;program length	  	
	dw begin				;load point		
	org $6500
begin:




; Star Tip 2 (C) 1987 Tim Follin/Your Sinclair.
; disassembled and commented by Matt B


;	org $8000
;
;	;test code
;	
;begin
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
;	IN    A,(254)			; Read keyboard.
;	CPL						; Complement result.
;	AND   31				; Mask keyboard bits.
;	JP    NZ, keyp			; Jump if a key is pressed.
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
	OUT   ($84),A			; Set beeper low.


	LD    B,C				; B holds a delay.
wait1:
	DJNZ  wait1				; Wait for the first half of the duty cycle.
	
	LD    A,0				; Set beeper bit.
	OUT   ($84),A			; Set beeper high.



	SUB   C					; Subtract delay from 16.
	LD    B,A
wait2:
	DJNZ  wait2				; Wait for the second half of the duty cycle.
	LD    H,(IX+0)			; Re-load H with pitch for channel 1.
labl1:
	DEC   L
	JR    NZ,labl2			; Do we play the second note yet?
	XOR   A					; Zero A.
	OUT   ($84),A			; Set beeper low.



	LD    B,C
wait3:
	DJNZ  wait3				; Wait for the first half of the duty cycle.
	LD    A,32				; Set beeper bit.
	OUT   ($84),A			; Set beeper high.


	SUB   C					; Subtract delay from 16.
	LD    B,A
wait4:
	DJNZ  wait4				; Wait for the second half of the duty cycle.
	LD    L,(IX+1)			; Re-load L with pitch for channel 2.
labl2:
	DEC   D
	JR    NZ,labl3			; Do we play the third note yet?
	XOR   A					; Zero A.
	OUT   ($84),A			; Set beeper low.



	LD    B,C
wait5:
	DJNZ  wait5				; Wait for the first half of the duty cycle.
	LD    A,32				; Set beeper bit.
	OUT   ($84),A			; Set beeper high.


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

noteLength:			dw $9600	; Note length counter.
volumeControl:		db $0C		; Volume control.
decayRate:			db $80		; Decay rate.
decayCount:			db $80		; Current decay count.
attackRate:			db $00		; Attack rate.
attackCount:		db $00		; Current attack count.
attackDecay:		db $00		; Attack (1) or decay (0) phase.
decayTargetVolume:	db $01		; Decay target volume.


musicData
	db $ff,$00,$0f,$01,$19,$01
	db $57,$56,$57
	db $44,$43,$44
	db $40,$3f,$40
	db $44,$43,$44
	db $57,$56,$57
	db $44,$43,$44
	db $40,$3f,$40
	db $44,$43,$44
	db $57,$56,$57
	db $44,$43,$44
	db $40,$3f,$40
	db $44,$43,$44
	db $57,$56,$57
	db $44,$43,$44
	db $40,$3f,$40
	db $44,$43,$44
	db $69,$68,$57
	db $69,$68,$57
	db $6f,$6e,$5c
	db $ff,$00,$1e,$01,$19,$01
	db $69,$68,$57
	db $ff,$00,$3c,$01,$19,$01
	db $57,$56,$44
	db $ff,$00,$0f,$01,$19,$01
	db $69,$68,$57
	db $69,$68,$57
	db $6f,$6e,$5c
	db $ff,$00,$1e,$01,$19,$01
	db $69,$68,$57
	db $ff,$00,$3c,$01,$19,$01
	db $69,$68,$4d
	db $ff,$00,$05,$01,$01,$0c
	db $29,$28,$29
	db $2b,$2a,$2b
	db $38,$37,$38
	db $44,$43,$44
	db $57,$56,$57
	db $5c,$5b,$5c
	db $ff,$00,$05,$01,$01,$08
	db $29,$28,$29
	db $2b,$2a,$2b
	db $38,$37,$38
	db $44,$43,$44
	db $57,$56,$57
	db $5c,$5b,$5c
	db $ff,$00,$05,$01,$01,$04
	db $29,$28,$29
	db $2b,$2a,$2b
	db $38,$37,$38
	db $44,$43,$44
	db $57,$56,$57
	db $5c,$5b,$5c
	db $ff,$00,$05,$01,$01,$02
	db $29,$28,$29
	db $2b,$2a,$2b
	db $38,$37,$38
	db $44,$43,$44
	db $57,$56,$57
	db $5c,$5b,$5c
	db $ff,$00,$78,$c8,$19,$0c
	db $57,$56,$57
	db $ff,$00,$78,$01,$c8,$01
	db $57,$56,$57
	db $00




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
tap_e:	savebin "follin_demo.tap",tap_b,tap_e-tap_b


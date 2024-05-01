;



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
	






;	Tim Follin. Agent X.
;	Found on zx sprectrum.co.uk forum & up & running within ten minutes. 5/7/23. Dave.

	org	$8000

	DI
	LD HL,ECTA
	LD B,16
ECF1:
	LD (HL),85
	INC HL
	LD (HL),1
	INC HL
	LD (HL),31
	INC HL
	DJNZ ECF1
	LD HL,TABLE
INSC:
	LD BC,65533
	LD A,(HL)
	INC HL
	out	($84), a
	LD BC,49149
	LD A,(HL)
	INC HL
	out	($84), a
	LD A,(HL)
	AND A
	JP NZ,INSC
	LD IX,ABLOCK    ;CHORD
	LD (CHREP),IX
	LD IY,BBLOCK    ;BASS
	LD A,1
	LD (MELO+1),A
	LD (SHAZ+1),A
	LD (REPBA+1),A
	LD (REPME+1),A
	LD (REPCH+1),A
	LD (PRT+1),A
	LD (BAREP),IY
	LD A,(INIM)
	LD (INOM),A
	LD A,(ATTAM)
	LD (SISM+1),A
	LD A,(DECAM)
	LD (FIM+1),A
	EXX 
	LD DE,CBLOCK    ;MELODY
	LD (MEREP),DE
	EXX 
STAR:
	LD A,(IX+0)
	CP 2
	JP NZ,STT2
	INC IX
	LD A,(IX+0)
	INC A
	LD (REPCH+1),A
	INC IX
	LD (CHREP),IX
	LD A,(IX+0)
	JP STT3
STT2:
	CP 1
	JP NZ,STT3
REPCH:
	LD A,1
	DEC A
	JP NZ,ZOK
	INC IX
	JP STAR
ZOK:
	LD (REPCH+1),A
	LD IX,(CHREP)
	LD A,(IX+0)
STT3:
	AND A
	JP Z,BASIC
	CP 255
	JP NZ,NEXT
	INC IX
	INC IX
	LD A,(IX-1)
	DEC A
	JP Z,ENVIN
	DEC A
	JP Z,BEATN
	DEC A
	JP Z,BEATF
	DEC A
	JP Z,BEA1
	DEC A
	JP Z,BEA2
	DEC A
	JP Z,BEA3
	DEC A
	JP Z,BEA4
	DEC A
	JP Z,BEASP
	DEC A
	JP Z,ECON
	DEC A
	JP Z,ECOF
	DEC A
	JP Z,WAIS
	JP STAR
ECON:
	LD A,1
	LD (ECMI+1),A
	LD (ECHO+1),A
	JP STAR
ECOF:
	XOR A
	LD (ECMI+1),A
	LD (ECHO+1),A
	JP STAR
WAIS:
	LD A,(IX+0)
	INC IX
	LD (ROC1+1),A
	LD (ROC2+1),A
	JP STAR
BEASP:
	LD A,(IX+0)
	INC IX
	LD (BSP+1),A
	JP STAR
BEA1:
	LD HL,TAB1
	LD (BTAP+1),HL
	JP BEATN
BEA2:
	LD HL,TAB2
	LD (BTAP+1),HL
	JP BEATN
BEA3:
	LD HL,TAB3
	LD (BTAP+1),HL
	JP BEATN
BEA4:
	LD HL,TAB4
	LD (BTAP+1),HL
	JP BEATN
BEATN:
	XOR A
	LD (EAD+1),A
	LD A,1
	LD (BECO+1),A
	JP STAR
BEATF:
	XOR A
	LD (EAD+1),A
	XOR A
	LD (BECO+1),A
	JP STAR
ENVIN:
	LD A,(IX+0)
	LD (ININ),A
	LD (INOU),A
	LD A,(IX+1)
	LD (ATTAK),A
	LD A,(IX+2)
	LD (DECAY),A
	LD A,(IX+3)
	LD (SUS+1),A
	INC IX
	INC IX
	INC IX
	INC IX
	JP STAR
NEXT:
	LD A,(ININ)
	LD (INOU),A
	LD A,(ATTAK)
	LD (SISP+1),A
	LD A,(DECAY)
	LD (FIN+1),A
	LD E,(IX+0)
	LD H,(IX+1)
	INC IX
	INC IX
ECMI:
	LD A,0
	DEC A
	JP Z,EC2
	LD D,(IX+0)
	INC IX
EC2:
	LD A,(INOU)
	AND A
	JP Z,FINIT
	LD A,D
	LD (SMCD+1),A
	SRL A
	SRL A
	SRL A
	LD (SDS+1),A
	LD (CPD1+1),A
	LD A,E
	LD (SMCE+1),A
	SRL A
	SRL A
	SRL A
	LD (SES+1),A
	LD (CPE+1),A
	LD A,H
	LD (SMCH+1),A
	SRL A
	SRL A
	SRL A
	LD (SHS+1),A
	LD (CPH+1),A
	LD A,1
	LD (SMXD+1),A
	LD (SMXE+1),A
	LD (SMXH+1),A
IRT:
	LD A,0
	LD (ND4+1),A
	LD A,(IX+0)
	INC IX
POT:
	EX AF,AF'
WUPS:
	LD A,0
	INC A
	LD (WUPS+1),A
WANU:
	CP 1
	JP NZ,JOBS
	XOR A
	LD (WUPS+1),A
BROC:
	LD B,0
BCOR:
	LD A,(SMMCL+1)
	DEC A
	JP Z,JOBS
	LD (SMMCL+1),A
	LD A,(SMFL+1)
	INC A
	LD (SMFL+1),A
	DJNZ BCOR
JOBS:
	LD A,(INOM)
	AND A
	JP Z,FIM
SISM:
	LD A,0
	DEC A
	LD (SISM+1),A
	JP NZ,AMP
	LD A,(ATTAM)
	LD (SISM+1),A
MROC1:
	LD B,0
MCOR1:
	LD A,(SMXC+1)
	INC A
CPC:
	CP 0
	JP Z,FLIM
	LD (SMXC+1),A
	LD A,(SCS+1)
	DEC A
	LD (SCS+1),A
	DJNZ MCOR1
	JP AMP
FIM:
	LD A,0
	DEC A
	LD (FIM+1),A
	JP NZ,AMP
	LD A,(DECAM)
	LD (FIM+1),A
MROC2:
	LD B,0
MCOR2:
	LD A,(SMXC+1)
	DEC A
	JP Z,AMP
	LD (SMXC+1),A
	LD A,(SCS+1)
	INC A
	LD (SCS+1),A
	DJNZ MCOR2
AMP:
	LD A,(OLNO+1)
	LD B,A
	LD A,(COMP+1)
	CP B
	JP Z,BECO
PRS:
	LD B,4
OLNO:
	LD A,0
COMP:
	CP 0
	JP Z,FIX
	JP C,GUP
	DEC A
	DEC A
GUP:
	INC A
	LD (OLNO+1),A
	DJNZ OLNO
FIX:
	LD B,A
	CALL SORT
BECO:
	LD A,0
	DEC A
	CP 255
	JP Z,SHAZ
	LD (BECO+1),A
	AND A
	JP NZ,SHAZ
	PUSH HL
	PUSH DE
	PUSH BC
BTAP:
	LD HL,TAB1
	LD D,0
EAD:
	LD E,0
	ADD HL,DE
	LD A,E
	ADD A,2		; ADD 2
	LD (EAD+1),A
	LD A,(HL)
	LD C,A
BSP:
	LD B,3
	DEC B
	JP Z,NOK
OK:
	ADD A,C 	; ADD C
	DJNZ OK
NOK:
	LD (BECO+1),A
	INC HL
	PUSH HL
	LD A,(HL)
	INC A
	DEC A
	CALL Z,BASS
	DEC A
	CALL Z,TINK
	DEC A
	CALL Z,SNAR
	DEC A
	CALL Z,HIGHHAT
	DEC A
	CALL Z,FONK
	POP HL
	INC HL
	LD A,(HL)
	CP 255
	JP NZ,DOK
	XOR A
	LD (EAD+1),A
DOK:
	POP BC
	POP DE
	POP HL
SHAZ:
	LD A,0
	DEC A
	LD (SHAZ+1),A
	JP NZ,MELO
IZI:
	LD A,(IY+0)
	CP 2
	JP NZ,JJHD
	INC IY
	LD A,(IY+0)
	INC A
	LD (REPBA+1),A
	INC IY
	LD (BAREP),IY
	JP IZI
JJHD:
	CP 1
	JP NZ,HAHA
REPBA:
	LD A,1
	DEC A
	JP Z,TIF
	LD (REPBA+1),A
	LD IY,(BAREP)
	JP IZI
TIF:
	INC IY
	JP IZI
HAHA:
	CP 3
	JP NZ,SNIAP
	INC IY
	LD A,(IY+0)
	LD (WANU+1),A
	DEC A
	LD (WUPS+1),A
	INC IY
	JP IZI
SNIAP:
	CP 4
	JP NZ,PAINS
	INC IY
	LD A,(IY+0)
	LD (BROC+1),A
	INC IY
	JP IZI
PAINS:
	LD (SMCL+1),A
	SRL A
	LD (SMMCL+1),A
	LD A,1
	LD (SMFL+1),A
	LD A,(IY+1)
	LD (SHAZ+1),A
	INC IY
	INC IY
MELO:
	LD A,0
	DEC A
	LD (MELO+1),A
	JP NZ,ECHO
	LD A,1
	LD (SISM+1),A
	LD (FIM+1),A
	LD A,(INIM)
	LD (INOM),A
	EXX 
JSH:
	LD A,(DE)
	CP 2
	JP NZ,FITF
	INC DE
	LD A,(DE)
	INC A
	LD (REPME+1),A
	INC DE
	LD (MEREP),DE
	JP JSH
FITF:
	CP 1
	JP NZ,NTFF
REPME:
	LD A,1
	DEC A
	JP Z,HSJ
	LD (REPME+1),A
	LD DE,(MEREP)
	JP JSH
HSJ:
	INC DE
	JP JSH
NTFF:
	LD A,(DE)
	CP 3
	JP NZ,FITN
	INC DE
	LD A,(DE)
	INC DE
	DEC A
	JP Z,PORON
	DEC A
	JP Z,POROF
	DEC A
	JP Z,PORSP
	DEC A
	JP Z,MEEN
	DEC A
	JP Z,SDFE
	DEC A
	JP Z,SOC1
	DEC A
	JP Z,TOBY
	DEC A
	JP Z,VIDEL
	DEC A
	JP Z,VITI
	JP JSH
TOBY:
	LD A,(DE)
	LD (MROC1+1),A
	LD (MROC2+1),A
	INC DE
	JP JSH
VITI:
	LD A,(DE)
	LD (VISP+1),A
	LD A,1
	LD (VIPS+1),A
	INC DE
	PUSH HL
	PUSH BC
	EX DE,HL
	LD BC,8
	LD DE,VIBTA
	LDIR 
	EX DE,HL
	POP BC
	POP HL
	JP JSH
VIDEL:
	LD A,(DE)
	INC DE
	LD (IVA+1),A
	JP JSH
SOC1:
	LD A,(DE)
	LD (CHOR+1),A
	INC DE
	JP JSH
SDFE:
	LD A,(DE)
	INC DE
	LD (DELAY+1),A
	JP JSH
PORSP:
	LD A,(DE)
	LD (PRS+1),A
	INC DE
	JP JSH
PORON:
	LD A,1
	LD (PRT+1),A
	JP JSH
POROF:
	XOR A
	LD (PRT+1),A
	JP JSH
MEEN:
	LD A,(DE)
	LD (INIM),A
	LD (INOM),A
	INC DE
	LD A,(DE)
	LD (ATTAM),A
	INC DE
	LD A,(DE)
	LD (DECAM),A
	INC DE
	LD A,1
	LD (SISM+1),A
	LD (FIM+1),A
	JP JSH
FITN:
	INC DE
	LD (COMP+1),A
	LD B,A
PRT:
	LD A,0
	AND A
	JP NZ,NOPO
	LD A,B
	EXX 
	LD L,A
	EXX 
	CALL SORT
	LD A,(SMCC+1)
	LD (OLNO+1),A
NOPO:
	LD A,(DE)
	LD (MELO+1),A
	INC DE
	EXX 
ECHO:
	LD A,0
	DEC A
	JR NZ,OHWELL
	PUSH HL
	PUSH BC
POINT:
	LD A,0
	INC A
	AND 15
	LD (POINT+1),A
	LD HL,ECTA
	LD C,A
	ADD A,A		; ADD A
	ADD A,C		; ADD C
	LD C,A
	LD B,0
	ADD HL,BC
	LD A,(SMCC+1)
	LD (HL),A
	INC HL
	LD A,(SMXC+1)
	LD (HL),A
	INC HL
	LD A,(SCS+1)
	LD (HL),A
	LD A,(POINT+1)
DELAY:
	SUB 15
	AND 15
	LD HL,ECTA
	LD C,A
	ADD A,A		; ADD A
	ADD A,C		; ADD C
	LD C,A
	ADD HL,BC
	LD A,(HL)
CHOR:
	SUB 0
	LD (SMCD+1),A
	INC HL
	LD A,(HL)
	SRL A
	LD B,A
	SRL A
	SRL A
	SRL A
	ADD A,B		; ADD B
	OR 1
	LD (SMXD+1),A
	INC HL
	LD A,(HL)
	SRL A
	LD B,A
	SRL A
	SRL A
	SRL A
	ADD A,B		; ADD B
	OR 1
	LD (SDS+1),A
	POP BC
	POP HL
OHWELL:
	CALL KOP
	XOR A
	IN A,(254)
	CPL
	AND 31
	JP NZ,BASIC
VIB:
	LD A,0
	DEC A
	LD (VIB+1),A
	JP NZ,TDKBO
	LD A,(SMCC+1)
	CP 254
	JP Z,TDKBO
	LD A,1
	LD (VIB+1),A
VIPS:
	LD A,1
	DEC A
	LD (VIPS+1),A
	JP NZ,TDKBO
VISP:
	LD A,0
	LD (VIPS+1),A
	PUSH HL
	LD HL,VIBTA
	LD A,L
VIAD:
	ADD A,0		; ADD 0
	LD L,A
	LD A,(VIAD+1)
	INC A
	AND 7
	LD (VIAD+1),A
	LD B,(HL)
	LD A,(SMCC+1)
	ADD A,B		; ADD B
	LD (SMCC+1),A
	POP HL
TDKBO:
	LD A,(INOU)
	CP 0
	JP Z,FIN
	CP 2
	JP Z,ND4
SISP:
	LD A,0
	DEC A
	LD (SISP+1),A
	JP NZ,ND4
	LD A,(ATTAK)
	LD (SISP+1),A
ROC1:
	LD B,0
COR1:
	LD A,(SMXD+1)
	INC A
CPD1 equ $
	CP 0
	JP Z,ND1
	LD (SMXD+1),A
	LD A,(SDS+1)
	DEC A
	LD (SDS+1),A
ND1:
	LD A,(SMXE+1)
	INC A
CPE:
	CP 0
	JP Z,ND2
	LD (SMXE+1),A
	LD A,(SES+1)
	DEC A
	LD (SES+1),A
ND2:
	LD A,(SMXH+1)
	INC A
CPH:
	CP 0
	JP Z,FLIP
	LD (SMXH+1),A
	LD A,(SHS+1)
	DEC A
	LD (SHS+1),A
	DJNZ COR1
ND4:
	LD A,0
	XOR 1
	LD (ND4+1),A
	JP Z,MOOD
	EX AF,AF'
	JP POT
MOOD:
	EX AF,AF'
	DEC A
	JP NZ,POT
	JP STAR

BASIC:
	LD IY,23610
	LD BC,65533
	LD A,0
	out	($84), a
;	LD BC,49149
;	LD A,32
;	LD	($6800), A
	EI 
	RET 

SORT:
	LD A,(INOM)
	AND A
	JP Z,XIF
	LD A,B
	LD (SMCC+1),A
	SRL A
	SRL A
	LD B,A
	SRL A
	SRL A
	ADD A,B		; ADD B
	LD (SCS+1),A
	LD (CPC+1),A
	LD A,1
	LD (SMXC+1),A
	JP IVA
XIF:
	LD A,B
	LD (SMCC+1),A
	SRL A
	SRL A
	LD B,A
	SRL A
	SRL A
	ADD A,B		; ADD B
	LD (SMXC+1),A
	LD (CPC+1),A
	LD A,1
	LD (SCS+1),A
IVA:
	LD A,0
	LD (VIB+1),A
	XOR A
	LD (VIAD+1),A
	RET

FLIP:
	XOR A
	LD (INOU),A
	JP ND4

FLIM:
	XOR A
	LD (INOM),A
	JP AMP

FINIT:
	LD A,D
	LD (SMCD+1),A
	SRL A
	SRL A
	SRL A
	LD (SMXD+1),A
	LD A,E
	LD (SMCE+1),A
	SRL A
	SRL A
	SRL A
	LD (SMXE+1),A
	LD A,H
	LD (SMCH+1),A
	SRL A
	SRL A
	SRL A
	LD (SMXH+1),A
	LD A,1
	LD (SDS+1),A
	LD (SES+1),A
	LD (SHS+1),A
	JP IRT

FIN:
	LD A,0
	DEC A
	LD (FIN+1),A
	JP NZ,ND4
	LD A,(DECAY)
	LD (FIN+1),A
ROC2:
	LD B,0
COR2:
	LD A,(SMXD+1)
	DEC A
	JP Z,ND5
	LD (SMXD+1),A
	LD A,(SDS+1)
	INC A
	LD (SDS+1),A
ND5:
	LD A,(SMXE+1)
	DEC A
	JP Z,ND6
	LD (SMXE+1),A
	LD A,(SES+1)
	INC A
	LD (SES+1),A
ND6:
	LD A,(SMXH+1)
	DEC A
SUS:
	CP 0
	JP Z,THIT
	LD (SMXH+1),A
	LD A,(SHS+1)
	INC A
	LD (SHS+1),A
	DJNZ COR2
	JP ND4

THIT:
	LD A,2
	LD (INOU),A
	JP ND4

BASS:
	LD BC,700
BAD:
	DEC BC
	LD A,B
	OR C
	JP NZ,BAD
	LD A,16
	out	($84), a
	LD A,200
BAD3:
	DEC A
	JP NZ,BAD3
	LD A,210
	LD (KOP+1),A
	RET

SNAR:
	LD HL,0
	LD B,10
SN1:
	LD A,16
	out	($84), a
	LD A,(HL)
	INC HL
	AND 128
	ADD A,16	; ADD 16
SN2:
	DEC A
	JP NZ,SN2
	XOR A
	out	($84), a
	LD A,20
SN3:
	DEC A
	JP NZ,SN3
	DJNZ SN1
	RET

HIGHHAT:
	LD BC,65533
	LD A,16
	out	($84), a
	LD BC,49149
	LD A,1
	out	($84), a
	LD C,5
	LD HL,10
HIN:
	LD A,16

	out	($84), a
	LD B,(HL)
	INC HL
HIEL:
	DJNZ HIEL
	XOR A

	out	($84), a
	LD B,(HL)
	INC HL
HEIR:
	DJNZ HEIR
	PUSH BC
	LD BC,120
HINE:
	DEC BC
	LD A,B
	OR C
	JP NZ,HINE
	POP BC
	DEC C
	JP NZ,HIN
	LD A,240
	LD (KOP+1),A
	RET

TINK:
	LD C,30
	LD HL,1000
TIN:
	LD A,16

	out	($84), a
	LD B,C
TIEL:
	DJNZ TIEL
	XOR A

	out	($84), a
	LD A,31
	SUB C
	LD B,A
TEIR:
	DJNZ TEIR
	LD A,(HL)
	AND 33
	LD B,A
	INC HL
TILE:
	DJNZ TILE
	DEC C
	JP NZ,TIN
	RET

FONK:
	LD HL,2000
	LD C,25
SO1:
	LD A,16
	out	($84), a
	LD B,30
SO2:
	DJNZ SO2
	XOR A

	out	($84), a
	LD A,(HL)
	INC HL
	AND 128
	LD B,A
SO3:
	DJNZ SO3
	DEC C
	JP NZ,SO1
	LD A,150
	LD (KOP+1),A
	RET

SMCL:
	LD L,0
HELP:
	LD A,0
	INC A
	AND 3
	LD (HELP+1),A
	JP NZ,L4
	LD A,16

	out	($84), a
SMMCL:
	LD A,0
D4:
	DEC A
	JP NZ,D4
	XOR A

	out	($84), a
SMFL:
	LD A,1
DILL:
	DEC A
	JP NZ,DILL
	JP L4

KOP:
	LD B,0
	XOR A
	LD (KOP+1),A
	CALL TOP
	CALL TOP
	CALL TOP
	CALL TOP
	INC C
TOP:
	DEC C
	JR Z,SMCC
LB:
	DEC D
	JR Z,SMCD
L1:
	DEC E
	JR Z,SMCE
L2:
	DEC H
	JR Z,SMCH
L3:
	DEC L
	JR Z,SMCL
L4:
	NOP
	NOP
	DJNZ TOP
	RET

SMCH:
	LD H,0
	LD A,16
	out	($84), a
SMXH:
	LD A,0
D3:
	DEC A
	JP NZ,D3
	XOR A
	out	($84), a
SHS:
	LD A,0
MU3:
	DEC A
	JP NZ,MU3
	JP L3

SMCE:
	LD E,0
	LD A,16
	out	($84), a
SMXE:
	LD A,0
D2:
	DEC A
	JP NZ,D2
	XOR A
	out	($84), a

SES:
	LD A,0
MU2:
	DEC A
	JP NZ,MU2
	JP L2
SMCD:
	LD D,0
	LD A,16
	out	($84), a
SMXD:
	LD A,0
D1:
	DEC A
	JP NZ,D1
	XOR A
	out	($84), a
SDS:
	LD A,0
MU1:
	DEC A
	JP NZ,MU1
	JP L1
SMCC:
	LD C,0
	LD A,16
	out	($84), a

SMXC:
	LD A,0
DD3:
	DEC A
	JP NZ,DD3
	XOR A
	out	($84), a
SCS:
	LD A,0
MU4:
	DEC A
	JP NZ,MU4
	JP LB

INOU:	DB 0
ININ:	DB 0
ATTAK:	DB 20
DECAY:	DB 20
INOM:	DB 0
INIM:	DB 0
ATTAM:	DB 1
DECAM:	DB 15
;	DB 0				unused
;HLST:	DW 0			unused
MEREP:	DB 0,0;,0		Melody repeat	(last 0 redundant, unused)
BAREP:	DB 0,0;,0		Bass Repeat		(last 0 redundant, unused)
CHREP:	DB 0,0;,0,255	Chord Repear	(last 0,255 redundant, unused)

TAB1:
	DB 58,0,3,3,2,3,1,3
	DB 255;,255			last 255 redundant, unused

TAB2:
	DB 8,0,8,3,4,0,4,0
	DB 2,3,4,0,2,5
	DB 8,0,2,3,6,0
	DB 4,0,4,0
	DB 4,3,2,0,2,0
	DB 8,0,2,3,4,0,2,5
	DB 4,0,2,0,2,0
	DB 2,3,2,0,4,0
	DB 8,0,8,3,4,0,2,0
	DB 4,3,2,3,4,0,255;,255		last 255 redundant, unused

TAB3:
	DB 3,0,2,0,1,0
	DB 3,3,2,0,1,0
	DB 2,0,1,0,2,0,1,0
	DB 3,3,2,0,1,0
	DB 3,0,2,0,1,0
	DB 2,3,1,0,2,0,1,0
	DB 2,0,1,0,2,3,1,0
	DB 3,3,2,0,1,3
	DB 3,0,2,0,1,0
	DB 3,3,2,0,1,3
	DB 2,0,1,0,2,0,1,0
	DB 3,3,2,0,1,0
	DB 255;,255				last 255 redundant, unused

TAB4:
	DB 1,3,1,3,2,3,2,3,2,3
	DB 255;,255				last 255 redundant, unused

TABLE:
	DB 7,21,8,16,9,16,10,16
	DB 11,0,12,11,6,8,2,80
	DB 3,66,0,0

VIBTA:
	DB 2,1,255,254,254,255
	DB 1,2

ECTA:	DS 48,0		; DS 49		48 spaces (not 49), 16x3 

; CHORD
ABLOCK:
	DEFB $FF, $0B, $01, $FF
	DEFB $09, $FF, $01, $00
	DEFB $00, $03, $00, $FF
	DEFB $08, $03, $FF, $04
	DEFB $DF, $E0, $03, $C5
	DEFB $C6, $5D, $FF, $01
	DEFB $01, $00, $00, $00
	DEFB $FF, $08, $03, $FF
	DEFB $06, $FF, $0A, $C9
	DEFB $65, $C9, $48, $02
	DEFB $04, $FF, $0B, $10
	DEFB $FF, $01, $00, $00
	DEFB $05, $01, $55, $71
	DEFB $A0, $03, $55, $71
	DEFB $A0, $0A, $FF, $0B
	DEFB $01, $55, $71, $A0
	DEFB $0E, $50, $6B, $97
	DEFB $09, $FF, $0B, $10
	DEFB $55, $71, $A0, $03
	DEFB $55, $71, $A0, $0F
	DEFB $FF, $0B, $01, $55
	DEFB $71, $A0, $09, $5A
	DEFB $71, $97, $09, $01
	DEFB $02, $03, $FF, $01
	DEFB $01, $00, $00, $00
	DEFB $FF, $0B, $01, $55
	DEFB $71, $87, $04, $FF
	DEFB $01, $00, $00, $04
	DEFB $01, $47, $5F, $71
	DEFB $03, $FF, $0B, $10
	DEFB $4B, $5A, $71, $06
	DEFB $FF, $0B, $01, $55
	DEFB $71, $87, $03, $FF
	DEFB $0B, $10, $5A, $71
	DEFB $97, $06, $FF, $0B
	DEFB $01, $4B, $65, $78
	DEFB $03, $FF, $0B, $10
	DEFB $55, $71, $87, $06
	DEFB $FF, $0B, $01, $55
	DEFB $71, $87, $03, $FF
	DEFB $0B, $10, $5A, $71
	DEFB $97, $02, $01, $FF
	DEFB $0B, $01, $FF, $01
	DEFB $00, $00, $04, $00
	DEFB $02, $01, $55, $71
	DEFB $87, $1B, $4B, $65
	DEFB $78, $09, $55, $71
	DEFB $87, $1B, $5A, $71
	DEFB $97, $09, $01, $FF
	DEFB $09, $02, $02, $55
	DEFB $87, $1B, $4B, $78
	DEFB $09, $55, $87, $1B
	DEFB $5A, $97, $09, $01
	DEFB $FF, $0A, $FF, $0B
	DEFB $01, $02, $01, $FF
	DEFB $01, $00, $00, $04
	DEFB $01, $55, $64, $87
	DEFB $3D, $FF, $01, $01
	DEFB $01, $00, $00, $5A
	DEFB $71, $97, $0B, $01
	DEFB $FF, $02, $02, $01
	DEFB $FF, $01, $00, $00
	DEFB $04, $01, $55, $71
	DEFB $87, $36, $5A, $71
	DEFB $97, $12, $01, $02
	DEFB $03, $FF, $01, $01
	DEFB $00, $04, $01, $55
	DEFB $64, $87, $39, $FF
	DEFB $01, $00, $00, $00
	DEFB $00, $55, $6B, $8F
	DEFB $06, $5A, $71, $97
	DEFB $2D, $01, $5A, $71
	DEFB $97, $12, $55, $6B
	DEFB $8F, $12, $5A, $71
	DEFB $97, $48, $FF, $01
	DEFB $00, $00, $05, $09
	DEFB $FF, $02, $55, $65
	DEFB $87, $48, $5A, $71
	DEFB $97, $48, $65, $7F
	DEFB $AA, $48, $5A, $71
	DEFB $97, $48, $FF, $01
	DEFB $00, $00, $00, $00
	DEFB $43, $5A, $7F, $36
	DEFB $FF, $08, $00, $FF
	DEFB $06, $43, $5A, $7F
	DEFB $06, $FF, $06, $47
	DEFB $5F, $87, $06, $FF
	DEFB $06, $4C, $65, $8F
	DEFB $06, $FF, $06, $50
	DEFB $6B, $97, $24, $55
	DEFB $71, $97, $1C, $FF
	DEFB $08, $02, $FF, $07
	DEFB $55, $71, $97, $08
	DEFB $FF, $01, $00, $00
	DEFB $04, $00, $FF, $0B
	DEFB $01, $FF, $08, $03
	DEFB $FF, $06, $02, $02
	DEFB $55, $71, $87, $1B
	DEFB $4B, $65, $78, $09
	DEFB $55, $71, $87, $1B
	DEFB $5A, $71, $97, $09
	DEFB $01, $FF, $09, $02
	DEFB $04, $55, $87, $1B
	DEFB $4B, $78, $09, $55
	DEFB $87, $1B, $5A, $97
	DEFB $09, $01, $02, $07
	DEFB $64, $65, $12, $01
	DEFB $FF, $03, $C5, $C6
	DEFB $4E, $FF, $08, $00
	DEFB $FF, $07, $FF, $01
	DEFB $01, $08, $00, $00
	DEFB $55, $71, $1E, $FF
	DEFB $08, $02, $FF, $05
	DEFB $02, $03, $FF, $01
	DEFB $00, $00, $04, $00
	DEFB $55, $71, $20, $55
	DEFB $71, $16, $FF, $01
	DEFB $01, $01, $00, $00
	DEFB $4B, $78, $0A, $01
	DEFB $02, $0B, $FF, $01
	DEFB $00, $00, $04, $00
	DEFB $65, $87, $20, $65
	DEFB $87, $16, $FF, $01
	DEFB $01, $01, $00, $00
	DEFB $5A, $8F, $0A, $01
	DEFB $FF, $0A, $FF, $01
	DEFB $01, $01, $0C, $00
	DEFB $FF, $08, $00, $65
	DEFB $6B, $87, $60, $00
	DEFB $FF

; BASS
BBLOCK:
	DEFB $03, $03, $04, $01
	DEFB $DF, $06, $C6, $BA
	DEFB $03, $01, $04, $04
	DEFB $02, $05, $C9, $09
	DEFB $C9, $06, $C9, $03
	DEFB $65, $06, $65, $03
	DEFB $87, $09, $C9, $09
	DEFB $C9, $06, $C9, $03
	DEFB $65, $06, $97, $03
	DEFB $8F, $06, $87, $03
	DEFB $C9, $09, $C9, $06
	DEFB $C9, $03, $65, $09
	DEFB $87, $09, $C9, $09
	DEFB $C9, $06, $C9, $03
	DEFB $E2, $09, $D6, $09
	DEFB $01, $02, $03, $04
	DEFB $09, $C9, $06, $C9
	DEFB $0C, $04, $07, $65
	DEFB $06, $65, $0C, $04
	DEFB $09, $C9, $06, $C9
	DEFB $0C, $E2, $06, $E2
	DEFB $09, $D6, $03, $01
	DEFB $03, $01, $04, $04
	DEFB $02, $0D, $C9, $09
	DEFB $C9, $06, $C9, $03
	DEFB $97, $09, $8F, $06
	DEFB $87, $03, $C9, $09
	DEFB $C9, $06, $C9, $03
	DEFB $AA, $09, $E2, $06
	DEFB $D6, $03, $01, $02
	DEFB $0F, $C9, $09, $AA
	DEFB $09, $97, $09, $AA
	DEFB $09, $C9, $09, $AA
	DEFB $09, $97, $09, $AA
	DEFB $06, $65, $03, $01
	DEFB $C9, $09, $AA, $09
	DEFB $97, $09, $AA, $09
	DEFB $BE, $09, $A0, $09
	DEFB $8F, $09, $A0, $09
	DEFB $02, $13, $C9, $09
	DEFB $AA, $09, $97, $09
	DEFB $AA, $09, $01, $A0
	DEFB $06, $A0, $09, $A0
	DEFB $03, $50, $06, $50
	DEFB $09, $50, $03, $A0
	DEFB $06, $A0, $09, $A0
	DEFB $03, $50, $09, $6B
	DEFB $09, $A0, $06, $A0
	DEFB $09, $A0, $03, $50
	DEFB $06, $50, $09, $50
	DEFB $03, $04, $01, $03
	DEFB $00, $A0, $0C, $AA
	DEFB $0C, $B4, $0C, $BE
	DEFB $90, $03, $01, $04
	DEFB $02, $02, $09, $C9
	DEFB $09, $AA, $09, $97
	DEFB $09, $8F, $09, $87
	DEFB $09, $78, $09, $71
	DEFB $09, $6B, $09, $65
	DEFB $09, $71, $09, $87
	DEFB $09, $8F, $09, $97
	DEFB $09, $AA, $09, $E2
	DEFB $09, $D6, $09, $01
	DEFB $03, $03, $04, $01
	DEFB $C6, $D8, $03, $01
	DEFB $04, $01, $02, $03
	DEFB $C9, $10, $65, $10
	DEFB $97, $04, $87, $04
	DEFB $71, $04, $87, $04
	DEFB $71, $04, $65, $04
	DEFB $C9, $10, $65, $10
	DEFB $65, $04, $71, $04
	DEFB $87, $04, $71, $04
	DEFB $87, $04, $97, $04
	DEFB $87, $04, $97, $04
	DEFB $87, $04, $71, $04
	DEFB $01, $02, $0B, $F0
	DEFB $10, $78, $10, $B4
	DEFB $04, $A0, $04, $87
	DEFB $04, $A0, $04, $87
	DEFB $04, $78, $04, $F0
	DEFB $10, $78, $10, $78
	DEFB $04, $87, $04, $A0
	DEFB $04, $87, $04, $A0
	DEFB $04, $B4, $04, $A0
	DEFB $04, $B4, $04, $A0
	DEFB $04, $87, $04, $01
	DEFB $04, $01, $03, $00
	DEFB $F0, $FF

; MELODY
CBLOCK:
	DEFB $03, $07, $01, $03
	DEFB $06, $00, $03, $05
	DEFB $0D, $03, $02, $03
	DEFB $03, $0B, $03, $04
	DEFB $01, $14, $01, $03
	DEFB $08, $01, $03, $09
	DEFB $03, $EE, $00, $00
	DEFB $00, $12, $00, $00
	DEFB $00, $3F, $C0, $03
	DEFB $09, $01, $02, $01
	DEFB $FF, $FE, $FE, $FF
	DEFB $01, $02, $03, $04
	DEFB $01, $00, $00, $03
	DEFB $08, $00, $03, $05
	DEFB $00, $C9, $90, $03
	DEFB $04, $01, $06, $00
	DEFB $43, $81, $03, $04
	DEFB $00, $00, $01, $03
	DEFB $01, $C9, $0F, $03
	DEFB $02, $02, $01, $4C
	DEFB $03, $47, $03, $4C
	DEFB $03, $55, $03, $65
	DEFB $03, $71, $03, $65
	DEFB $03, $71, $03, $87
	DEFB $03, $71, $03, $87
	DEFB $03, $97, $03, $87
	DEFB $24, $97, $03, $8F
	DEFB $03, $97, $03, $AA
	DEFB $03, $C9, $03, $AA
	DEFB $03, $97, $03, $8F
	DEFB $03, $87, $03, $71
	DEFB $09, $87, $03, $71
	DEFB $03, $87, $03, $71
	DEFB $03, $87, $03, $71
	DEFB $03, $8F, $03, $78
	DEFB $03, $97, $03, $7F
	DEFB $03, $A0, $03, $87
	DEFB $03, $01, $43, $24
	DEFB $02, $03, $47, $03
	DEFB $43, $03, $47, $03
	DEFB $43, $03, $47, $03
	DEFB $43, $03, $01, $55
	DEFB $06, $65, $03, $71
	DEFB $06, $65, $03, $71
	DEFB $06, $87, $03, $71
	DEFB $06, $87, $03, $8F
	DEFB $03, $97, $03, $AA
	DEFB $03, $97, $03, $AA
	DEFB $03, $C9, $03, $AA
	DEFB $03, $C9, $03, $D6
	DEFB $03, $02, $01, $E2
	DEFB $09, $C9, $09, $01
	DEFB $E2, $09, $C9, $D8
	DEFB $03, $04, $01, $00
	DEFB $00, $C9, $90, $03
	DEFB $07, $07, $03, $04
	DEFB $00, $00, $01, $02
	DEFB $01, $E2, $03, $C9
	DEFB $03, $C9, $03, $AA
	DEFB $03, $C9, $03, $C9
	DEFB $03, $E2, $03, $C9
	DEFB $03, $C9, $03, $97
	DEFB $06, $AA, $03, $E2
	DEFB $03, $C9, $03, $C9
	DEFB $03, $AA, $03, $C9
	DEFB $03, $C9, $03, $E2
	DEFB $03, $C9, $03, $C9
	DEFB $03, $E2, $06, $D6
	DEFB $03, $01, $03, $07
	DEFB $05, $02, $01, $71
	DEFB $03, $64, $03, $64
	DEFB $03, $55, $03, $64
	DEFB $03, $64, $03, $71
	DEFB $03, $64, $03, $64
	DEFB $03, $4C, $06, $55
	DEFB $03, $71, $03, $64
	DEFB $03, $64, $03, $55
	DEFB $03, $64, $03, $64
	DEFB $03, $71, $03, $64
	DEFB $03, $64, $03, $71
	DEFB $06, $6B, $03, $01
	DEFB $5F, $01, $03, $07
	DEFB $01, $03, $05, $0C
	DEFB $03, $03, $01, $03
	DEFB $01, $02, $03, $4C
	DEFB $19, $4B, $01, $4A
	DEFB $02, $49, $03, $48
	DEFB $03, $47, $04, $48
	DEFB $03, $49, $03, $4A
	DEFB $02, $4B, $01, $7F
	DEFB $19, $01, $C9, $23
	DEFB $03, $02, $03, $04
	DEFB $01, $00, $00, $64
	DEFB $6C, $03, $07, $04
	DEFB $03, $05, $00, $03
	DEFB $04, $00, $01, $01
	DEFB $03, $07, $02, $02
	DEFB $03, $C9, $06, $87
	DEFB $09, $5A, $03, $87
	DEFB $09, $55, $06, $87
	DEFB $09, $64, $03, $87
	DEFB $09, $5A, $06, $87
	DEFB $03, $71, $06, $87
	DEFB $03, $01, $03, $07
	DEFB $01, $03, $02, $03
	DEFB $04, $01, $00, $00
	DEFB $C9, $90, $C9, $51
	DEFB $03, $04, $00, $01
	DEFB $01, $47, $06, $4C
	DEFB $03, $55, $06, $64
	DEFB $03, $71, $06, $64
	DEFB $03, $71, $06, $87
	DEFB $03, $97, $06, $8F
	DEFB $03, $97, $06, $AA
	DEFB $03, $C9, $06, $E2
	DEFB $03, $02, $03, $03
	DEFB $07, $04, $03, $04
	DEFB $00, $00, $01, $C9
	DEFB $06, $71, $09, $C9
	DEFB $03, $78, $09, $C9
	DEFB $06, $87, $09, $C9
	DEFB $03, $97, $09, $AA
	DEFB $09, $C9, $09, $E2
	DEFB $06, $C9, $09, $C9
	DEFB $09, $C9, $09, $C9
	DEFB $09, $C9, $03, $03
	DEFB $04, $00, $00, $00
	DEFB $03, $07, $01, $47
	DEFB $09, $4B, $36, $4B
	DEFB $03, $47, $03, $4B
	DEFB $03, $47, $03, $4B
	DEFB $03, $47, $03, $4B
	DEFB $03, $47, $03, $4B
	DEFB $03, $47, $03, $4B
	DEFB $03, $47, $03, $01
	DEFB $03, $05, $0D, $02
	DEFB $03, $4C, $03, $5A
	DEFB $03, $71, $03, $01
	DEFB $02, $03, $47, $03
	DEFB $55, $03, $6B, $03
	DEFB $01, $02, $0F, $4C
	DEFB $03, $5A, $03, $71
	DEFB $03, $01, $03, $02
	DEFB $03, $05, $00, $03
	DEFB $04, $01, $00, $00
	DEFB $03, $03, $01, $C9
	DEFB $50, $8F, $01, $03
	DEFB $04, $00, $00, $00
	DEFB $03, $01, $97, $06
	DEFB $03, $02, $AA, $03
	DEFB $C9, $06, $E2, $09
	DEFB $C9, $09, $AA, $03
	DEFB $97, $06, $8F, $03
	DEFB $87, $09, $71, $06
	DEFB $87, $03, $71, $06
	DEFB $64, $09, $64, $0C
	DEFB $03, $03, $01, $4C
	DEFB $03, $03, $01, $47
	DEFB $03, $4C, $12, $03
	DEFB $02, $55, $03, $65
	DEFB $06, $71, $03, $65
	DEFB $12, $55, $09, $4B
	DEFB $09, $55, $09, $4B
	DEFB $01, $03, $01, $47
	DEFB $11, $4B, $12, $03
	DEFB $02, $55, $06, $65
	DEFB $03, $71, $06, $64
	DEFB $09, $71, $03, $87
	DEFB $06, $97, $03, $02
	DEFB $05, $8F, $03, $97
	DEFB $03, $01, $7F, $06
	DEFB $65, $03, $55, $09
	DEFB $3F, $12, $3F, $06
	DEFB $55, $03, $64, $09
	DEFB $7F, $12, $02, $07
	DEFB $38, $03, $4B, $03
	DEFB $5A, $03, $01, $02
	DEFB $0B, $38, $01, $4B
	DEFB $01, $5A, $01, $01
	DEFB $02, $01, $2D, $01
	DEFB $38, $01, $4B, $01
	DEFB $5A, $01, $71, $01
	DEFB $97, $01, $B4, $01
	DEFB $E2, $01, $B4, $01
	DEFB $97, $01, $71, $01
	DEFB $5A, $01, $4B, $01
	DEFB $38, $01, $2D, $01
	DEFB $01, $2D, $01, $38
	DEFB $01, $4B, $01, $5A
	DEFB $01, $71, $01, $97
	DEFB $01, $03, $08, $00
	DEFB $03, $04, $01, $00
	DEFB $00, $50, $B4, $03
	DEFB $04, $00, $00, $08
	DEFB $43, $6C, $03, $08
	DEFB $00, $03, $09, $01
	DEFB $FE, $FF, $01, $02
	DEFB $02, $01, $FF, $FE
	DEFB $03, $05, $00, $03
	DEFB $02, $03, $07, $01
	DEFB $03, $04, $00, $00
	DEFB $05, $47, $02, $43
	DEFB $22, $4C, $02, $47
	DEFB $02, $4C, $02, $55
	DEFB $03, $65, $12, $71
	DEFB $06, $65, $0C, $55
	DEFB $06, $65, $03, $4B
	DEFB $06, $65, $03, $47
	DEFB $06, $65, $03, $43
	DEFB $06, $65, $03, $3F
	DEFB $06, $65, $03, $3C
	DEFB $06, $65, $03, $39
	DEFB $06, $65, $03, $02
	DEFB $01, $36, $02, $32
	DEFB $03, $36, $02, $32
	DEFB $05, $39, $03, $43
	DEFB $03, $01, $4C, $03
	DEFB $47, $03, $4C, $03
	DEFB $55, $03, $4C, $03
	DEFB $55, $03, $65, $03
	DEFB $55, $03, $65, $03
	DEFB $71, $03, $55, $03
	DEFB $6B, $03, $65, $12
	DEFB $02, $05, $55, $03
	DEFB $65, $03, $71, $03
	DEFB $01, $65, $24, $03
	DEFB $05, $0C, $03, $03
	DEFB $0E, $03, $01, $6B
	DEFB $02, $65, $03, $6B
	DEFB $02, $65, $62, $03
	DEFB $04, $01, $01, $00
	DEFB $3C, $1E, $03, $04
	DEFB $00, $00, $00, $39
	DEFB $06, $03, $04, $01
	DEFB $01, $04, $43, $1E
	DEFB $03, $04, $00, $00
	DEFB $00, $4C, $05, $55
	DEFB $04, $03, $04, $01
	DEFB $01, $04, $03, $08
	DEFB $20, $5A, $48, $03
	DEFB $05, $0B, $03, $04
	DEFB $00, $00, $03, $02
	DEFB $01, $65, $06, $4B
	DEFB $09, $55, $06, $4B
	DEFB $09, $5A, $06, $55
	DEFB $09, $65, $06, $5A
	DEFB $09, $71, $03, $65
	DEFB $06, $71, $03, $01
	DEFB $03, $05, $0E, $03
	DEFB $02, $02, $03, $43
	DEFB $03, $47, $03, $4C
	DEFB $03, $50, $03, $55
	DEFB $03, $5A, $03, $5F
	DEFB $03, $65, $03, $6B
	DEFB $03, $71, $03, $78
	DEFB $03, $7F, $03, $01
	DEFB $03, $03, $05, $03
	DEFB $05, $0B, $03, $01
	DEFB $02, $03, $03, $02
	DEFB $C9, $01, $03, $01
	DEFB $65, $23, $01, $03
	DEFB $02, $02, $01, $65
	DEFB $06, $71, $03, $65
	DEFB $09, $55, $09, $65
	DEFB $06, $71, $03, $65
	DEFB $09, $C9, $09, $65
	DEFB $12, $01, $03, $01
	DEFB $03, $05, $00, $65
	DEFB $24, $71, $12, $6B
	DEFB $12, $65, $24, $5A
	DEFB $12, $71, $12, $65
	DEFB $24, $71, $12, $6B
	DEFB $12, $65, $24, $03
	DEFB $02, $5A, $06, $55
	DEFB $03, $5A, $09, $71
	DEFB $09, $65, $09, $01
	DEFB $03, $07, $01, $03
	DEFB $02, $03, $05, $0D
	DEFB $03, $04, $01, $14
	DEFB $01, $03, $08, $01
	DEFB $03, $09, $03, $EE
	DEFB $00, $00, $00, $12
	DEFB $00, $00, $00, $3F
	DEFB $9C, $03, $09, $01
	DEFB $02, $01, $FF, $FE
	DEFB $FE, $FF, $01, $02
	DEFB $03, $08, $00, $03
	DEFB $05, $07, $03, $04
	DEFB $00, $00, $04, $A0
	DEFB $01, $03, $03, $02
	DEFB $03, $01, $3C, $2F
	DEFB $03, $02, $02, $03
	DEFB $3C, $04, $4B, $04
	DEFB $5A, $04, $4B, $04
	DEFB $43, $30, $01, $3C
	DEFB $04, $4B, $04, $5A
	DEFB $04, $02, $01, $43
	DEFB $02, $4B, $02, $43
	DEFB $24, $3C, $04, $39
	DEFB $04, $32, $04, $3C
	DEFB $04, $4B, $04, $3C
	DEFB $04, $43, $02, $4B
	DEFB $02, $43, $3C, $01
	DEFB $02, $01, $50, $02
	DEFB $5A, $02, $50, $24
	DEFB $47, $04, $43, $04
	DEFB $3C, $04, $47, $04
	DEFB $5A, $04, $47, $04
	DEFB $50, $02, $5A, $02
	DEFB $50, $3C, $01, $02
	DEFB $03, $78, $02, $87
	DEFB $02, $78, $0C, $6B
	DEFB $02, $78, $02, $6B
	DEFB $0C, $5A, $02, $50
	DEFB $02, $5A, $0C, $50
	DEFB $02, $5A, $02, $50
	DEFB $0C, $01, $03, $05
	DEFB $0C, $03, $08, $18
	DEFB $03, $04, $01, $01
	DEFB $00, $47, $18, $03
	DEFB $04, $00, $00, $00
	DEFB $43, $08, $03, $04
	DEFB $01, $01, $00, $50
	DEFB $18, $03, $04, $00
	DEFB $00, $00, $5A, $04
	DEFB $65, $04, $03, $04
	DEFB $01, $01, $00, $6B
	DEFB $18, $03, $04, $00
	DEFB $00, $00, $65, $08
	DEFB $03, $04, $01, $01
	DEFB $03, $03, $08, $00
	DEFB $78, $A0, $03, $04
	DEFB $00, $00, $02, $03
	DEFB $05, $00, $02, $03
	DEFB $32, $04, $3C, $04
	DEFB $50, $04, $35, $04
	DEFB $43, $04, $50, $04
	DEFB $32, $04, $3C, $04
	DEFB $50, $04, $35, $04
	DEFB $43, $04, $50, $04
	DEFB $32, $04, $3C, $04
	DEFB $35, $04, $43, $04
	DEFB $01, $03, $05, $0C
	DEFB $02, $03, $78, $04
	DEFB $50, $1C, $78, $04
	DEFB $50, $04, $3C, $0C
	DEFB $50, $0C, $35, $04
	DEFB $32, $04, $35, $04
	DEFB $43, $04, $5A, $30
	DEFB $01, $03, $02, $F0
	DEFB $10, $A0, $10, $87
	DEFB $14, $6B, $1C, $5A
	DEFB $FF



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

	savebin "agentx.tap",tap_b,tap_e-tap_b




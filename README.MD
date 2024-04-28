
camputers Lynx
==============

1-bit music files (.TAP files) for the Camputers Lynx 8-bit computer from 1983.
Below is a snippet of info that is needed to change from the ZX Speccy 1-bit players to drive the speaker for the Lynx.

Use the Lynx emulator, "JYNX". Works well.

---

Assemble using SJASMPLUS.
origin	$6500
bit 4 port $0084.   bit 7 must be 0

BASIC RUN:	DEF USR0=&6500
		a=usr(0)

Use JYNX emulator, and .TAP file will auto-execute.



---



 device zxspectrum128

	org $6500-13				; Origin
tap_b:	db $22,"NONAME",$22			;name		  	
	db "M"					;type		  	
	dw end-begin				;program length	  	
	dw begin				;load point		
	org $6500
begin:

...
	OUT ($84), a
...

end

tap_e:	savebin "letsgo.tap",tap_b,tap_e-tap_b


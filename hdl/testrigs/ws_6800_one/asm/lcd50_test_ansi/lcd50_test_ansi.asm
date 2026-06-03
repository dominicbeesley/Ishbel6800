		.include "hardware.inc"

		.dpage


		.text
START:
		lds	#STACK
			
		ldx	#crtc_regs
		clrb
lp1:		stab	VIDCRTC_IX
		ldaa	0,X
		staa	VIDCRTC_DAT
		inx
		incb
		cmpb	#16
		bne	lp1


		swi


		.data
crtc_regs:	.byte	168	; 0  Horz total chars
		.byte	128	; 1  Horz disp chars
		.byte   140	; 2  HSync pos
		.byte	3	; 3  HSync width
		.byte	40	; 4  V total
		.byte   0	; 5  V adj
		.byte   37	; 6  V disp
		.byte   38	; 7  VSync pos
		.byte   0	; 8  Interlace
		.byte   15	; 9  Max RA
		.byte   0x6C	; 10  Cursor start, blink, slow
		.byte   0x0F	; 11 Cursor end
		.word	0	; 12 start addr
		.word   0	; 14 cursor addr   


HERE:
	.equ	STACK, HERE + 0x100
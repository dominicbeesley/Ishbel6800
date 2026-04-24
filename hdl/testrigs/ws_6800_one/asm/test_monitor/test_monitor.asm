
		.equ FT245_STAT, 0xE000
		.equ FT245_DATA, 0xE001

		.equ FT245_RXF, 0x01
		.equ FT245_TXE, 0x02

		.org 0xF000

handle_irq:	rti
handle_swi:	rti
handle_nmi:	rti

str:		.byte "Hello Dossytronics", 0

handle_res:	lds	#0x1FF
		ldx	#str

@lp:		ldaa	0,X
		beq	@end
		ldab	#FT245_TXE
@txe:		bitb	FT245_STAT	
		bne	@txe
		staa	FT245_DATA
		inx
		bra	@lp

@end:		jmp	handle_res


		.org 0xFFF8
hw_irq:		.word	handle_irq
hw_swi:		.word	handle_swi
hw_nmi:		.word	handle_nmi
hw_res:		.word	handle_res




		.org 0xFF00
handle_irq:	rti
handle_swi:	rti
handle_nmi:	rti


handle_res:	lds	#0x100
		cli
		nop
		swi
		ldaa	#0x23
		ldab	#0x25
		ldx	#0x6789

here:			
		inca
		incb
		inx

		jmp	here
		


		.org 0xFFF8
hw_irq:		.word	handle_irq
hw_swi:		.word	handle_swi
hw_nmi:		.word	handle_nmi
hw_res:		.word	handle_res

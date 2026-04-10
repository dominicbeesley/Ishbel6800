


		.org 0xF000
handle_irq:	rti
handle_swi:	rti
handle_nmi:	rti


handle_res:	ldx	#0x100
		txs
		sei


		ldaa	#0x23
		ldab	#0x25
		ldx	#0x6789

here:		
		swi

		inca
		incb
		inx

		staa	0xEFFF		; debug / stop
		wai


		.org 0xFFF8
hw_irq:		.word	handle_irq
hw_swi:		.word	handle_swi
hw_nmi:		.word	handle_nmi
hw_res:		.word	handle_res

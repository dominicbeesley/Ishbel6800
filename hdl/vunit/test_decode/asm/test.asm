


		.org 0xF000
handle_irq:	rti
handle_swi:	rti
handle_nmi:	rti


handle_res:	ldx	#0x100
		lds	#0x1234
		ldx	0xF004
		lds	0xF006

		stx 	0x1000
		sts 	0x1002

		txs
		sts 	0x2001
		swi

		ldx	#0
		swi
		ldx	#1
		swi
		ldx	#0x8008
		swi

		tsx
		nop
		nop
		stx	0x1000
		nop
		nop
		swi

		sei
		swi
		
		cli
		swi
		
		sev
		swi
		
		clv
		swi

		sec
		swi
		
		clc
		swi


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

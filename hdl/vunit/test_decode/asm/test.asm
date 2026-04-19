


		.org 0xF000
handle_irq:	rti
handle_swi:	rti
handle_nmi:	rti


const_AA:	.byte	0xAA
const_55:	.byte	0x55
const_23:	.byte	0x23
const_01:	.byte	0x01
const_FF:	.byte	0xFF

handle_res:	ldx	#0x100
		lds	#0x1234
		ldx	handle_res + 1
		lds	handle_res + 3

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
		swi
		ldab	#0x85
		swi
		
		eora 	#0x55
		swi

		oraa 	#0x01
		swi

		anda	const_23
		swi

		eora	const_FF
		swi

		adda	#23
		swi
		adca	#23
		swi
		adca	#23
		swi

		sec
		suba	const_55
		swi
		sbca	const_23
		swi
		sbca	const_55
		swi

		staa	0x80
		swi
		stab	0x81
		swi

		ldx	#0x8000
		dex
		swi 

		ldx 	#0xFFFF
		inx
		swi

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

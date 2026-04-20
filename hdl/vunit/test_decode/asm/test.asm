


		.org 0xF000

handle_irq:	rti
handle_swi:	rti
handle_nmi:	rti


const_AA:	.byte	0xAA
const_55:	.byte	0x55
const_23:	.byte	0x23
const_01:	.byte	0x01
const_FF:	.byte	0xFF

rtn_low:		inx
		rts

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

		lda	#0xFF
		tap
		swi
		lda	#0x00
		tap
		swi

		tpa
		swi

		lda	#0x74
		adca	#0x7F
		tpa
		swi

		ldx	#0xF8
		ldaa	#23
		staa	0, X
		inx
		ldaa	#56
		staa	7, X
		dex

		lda	0xF8
		lda	0x100

		lda	0,X
		inx
		inx
		inx
		inx
		inx
		inx
		inx
		inx
		lda	0,X

		sts	0
		ins
		sts	0
		lds	#1
		sts	0
		des

		lds	#0x1FF
		swi

		lda	#24
		staa	0x200
		lda	#48
		swi
		pula

		lda	#0x22
		psha
		ldb	0x200
		swi


		lda	#<here
		psha
		lda	#>here
		psha

		nop
		nop
		rts

here:		nop
		nop
		swi
		
		jmp 	there
		nop 
		nop

there:		nop
		nop

		jsr	test_bsr_back


		ldx	#test_routine-10
		jsr	10,X



		inca
		incb
		inx

		staa	0xEFFF		; debug / stop
		wai


		.align	8
		.skip	0x99
test_routine4:	rts
test_routine:	inx
		bsr	test_routine2
		bsr	test_routine3
		bsr	test_routine4
test_routine2:	rts
		.align	6
test_bsr_back:	bsr	test_routine
		inx
		rts
test_routine3:	inx
		rts



one:		bra two
two:		bra two
three:		bra two

		.org 0xFFF8
hw_irq:		.word	handle_irq
hw_swi:		.word	handle_swi
hw_nmi:		.word	handle_nmi
hw_res:		.word	handle_res

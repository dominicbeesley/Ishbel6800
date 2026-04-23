
		.equ	TESTEXT1, 0x300
		.equ	TESTEXT2, 0x380


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

		stx 	TESTEXT1
		sts 	TESTEXT1 + 2

		txs
		sts 	TESTEXT2
		swi

		ldx	#0
		swi
		ldx	#1
		swi
		ldx	TESTEXT2
		swi

		tsx
		nop
		nop
		stx	TESTEXT1
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

		lda	#0
		jsr	flags_test

		lda	#0x80
		jsr	flags_test

		lda	#0xFC
		tap
		jsr	flags_test

		lda	#10
		cmpa	#10
		bge	@ok1
@nok0:		bra	@nok0
@nok1:		bra 	@nok1
@nok11:		bra	@nok11		
@ok1:		bgt	@nok1
		blt	@nok11
		ble	@ok11

@ok11:		cmpa	#9
		bge	@ok2
		bgt	@ok2
@nok2:		bra	@nok2		
@nok3:		bra	@nok3

@ok2:		blt	@nok3
		ble	@nok3
@ok3:
		
		;;;;; GROUP II MEM TESTS ;;;;;


		lda	#0x7E
		staa	TESTEXT1
		inc	TESTEXT1
		swi
		inc	TESTEXT1
		swi
		inc	TESTEXT1
		swi
		dec 	TESTEXT1
		swi
		dec	TESTEXT1
		swi
		dec	TESTEXT1
		swi

		lda	#0x02
		staa	TESTEXT2
		dec	TESTEXT2
		swi
		dec	TESTEXT2
		swi
		dec	TESTEXT2
		swi
		inc	TESTEXT2
		swi
		inc	TESTEXT2
		swi
		inc	TESTEXT2
		swi

		lda	#0x80
		staa	TESTEXT2
		rol	TESTEXT2
		swi
		rol	TESTEXT2
		swi
		rol	TESTEXT2
		swi
		ror	TESTEXT2
		swi
		ror	TESTEXT2
		swi
		ror	TESTEXT2
		swi

		asl	TESTEXT2
		swi
		asl	TESTEXT2
		swi
		asl	TESTEXT2
		swi

		lda	#0x80
		staa	TESTEXT2
		clc
		asr	TESTEXT2
		swi
		asr	TESTEXT2
		swi
		asr	TESTEXT2
		asr	TESTEXT2
		asr	TESTEXT2
		asr	TESTEXT2
		asr	TESTEXT2
		swi
		asr	TESTEXT2
		swi			
		asr	TESTEXT2
		swi			
		

		lda	#0x00
		staa	TESTEXT1
		clc
		sev
		com	TESTEXT1
		swi
		com	TESTEXT1
		swi

		lda	#0x23
		staa	TESTEXT1
		com	TESTEXT1
		swi
		com	TESTEXT1
		swi

		lda	#0x88
		staa	TESTEXT1
		com	TESTEXT1
		swi
		com	TESTEXT1
		swi

		lda	#0xFF
		staa	TESTEXT1
		com	TESTEXT1
		swi
		com	TESTEXT1
		swi

		lda	#0x00
		staa	TESTEXT1
		clc
		sev
		neg	TESTEXT1
		swi
		neg	TESTEXT1
		swi

		lda	#0x23
		staa	TESTEXT1
		neg	TESTEXT1
		swi
		neg	TESTEXT1
		swi

		lda	#0x88
		staa	TESTEXT1
		neg	TESTEXT1
		swi
		neg	TESTEXT1
		swi

		lda	#0xFF
		staa	TESTEXT1
		neg	TESTEXT1
		swi
		neg	TESTEXT1
		swi

		; test check that it doesn't do write
		lda	#0xFF
		staa	TESTEXT1
		lda	#0
		tst	TESTEXT1
		swi

		lda	TESTEXT1
		swi

		clr	TESTEXT1
		lda	TESTEXT1


		;;;;;;;; GROUP II ACC tests ;;;;;;;;;;

		lda	#0x7E
		inca
		swi
		inca
		swi
		inca
		swi
		deca
		swi
		deca
		swi
		deca
		swi

		ldb	#0x02
		decb
		swi
		decb
		swi
		decb
		swi
		incb
		swi
		incb
		swi
		incb
		swi

		lda	#0x80
		rola
		swi
		rola
		swi
		rola
		swi
		rora
		swi
		rora
		swi
		rora
		swi

		asla
		swi
		asla
		swi
		asla
		swi

		lda	#0x80
		clc
		asra
		swi
		asra
		swi
		asra
		asra
		asra
		asra
		asra
		swi
		asra
		swi			
		asra
		swi			
		

		lda	#0x00
		clc
		sev
		coma
		swi
		coma
		swi

		lda	#0x23
		coma
		swi
		coma
		swi

		lda	#0x88
		coma
		swi
		coma
		swi

		ldb	#0xFF
		comb
		swi
		comb
		swi

		lda	#0x00
		clc
		sev
		nega
		swi
		nega
		swi

		lda	#0x23
		nega
		swi
		nega
		swi

		lda	#0x88
		nega
		swi
		nega
		swi

		lda	#0xFF
		nega
		swi
		nega
		swi

		; 0x80 should be the only value to set V
		clc
		clv
		lda	#0x80
		swi
		nega
		swi
		

		lda	#0xFF
		tsta
		swi

		clra
		tsta
		swi


		lda	#0x23
		ldb	#0x23
		sba
		swi

		lda	#0x23
		ldb	#0x23
		cba
		swi

		lda	#0x23
		ldb	#0x70
		sba
		swi

		lda	#0x23
		ldb	#0x70
		cba
		swi


		tab
		swi
		sec
		lda	#0x23
		ldb	#0x70
		swi
		tba
		swi

		clc
		lda	#0x23
		ldb	#0x80
		swi
		tab
		swi
		lda	#0x23
		ldb	#0x80
		tba
		swi


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

flags_test:	
		sec
		sev
		jsr	flags_test2
		clc
		sev
		jsr	flags_test2
		sec
		clv
		jsr	flags_test2
		clc
		clv
		jsr	flags_test2

		jsr	flags_test3

flags_test3:
		beq	@z
		bmi	@nzmi
		swi 
		rts
@nzmi:		swi
		rts

@z:		bmi	@zmi
		swi
		rts
@zmi:		swi
		rts


flags_test2:
		bcc	@cc
		bvc	@csvc
		swi
		rts
@csvc:		swi
		rts

@cc:		bvc	@ccvc
		swi
		rts

@ccvc:		swi
		rts

		.org 0xFFF8
hw_irq:		.word	handle_irq
hw_swi:		.word	handle_swi
hw_nmi:		.word	handle_nmi
hw_res:		.word	handle_res

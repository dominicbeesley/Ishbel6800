		.org 0xF000

handle_irq:	rti
handle_swi:	rti
handle_nmi:	rti


		; this gets relocated to 0x100 - it's self modifying
test_prog:
		LDAA	#0x00
		TAP
		LDAA	#0x00
		CLV
		DAA
		PSHA
		PULA
		TPA
		STAA	0x80
		INC	0x0104
		BNE	test_prog
		LDAA	0x0101
		EORA	#0x01
		STAA	0x0101
		ANDA	#0x01
		BNE	test_prog
		LDAA	0x0101
		EORA	#0x20
		STAA	0x0101
		ANDA	#0x20
		BNE	test_prog
		LDAA	0x0105
		EORA	#0x01
		STAA	0x0105
		ANDA	#0x01
		BNE	test_prog
		SWI            
@here:		JMP	@here
test_prog_end:


handle_res:	LDS	#0x100+test_prog_end-test_prog-1
		LDX	#test_prog_end-1
@lp:		LDAA	0,X
		PSHA
		DEX
		CPX 	#test_prog-1
		BNE	@lp
		JMP 	0x100


		.org 0xFFF8
hw_irq:		.word	handle_irq
hw_swi:		.word	handle_swi
hw_nmi:		.word	handle_nmi
hw_res:		.word	handle_res
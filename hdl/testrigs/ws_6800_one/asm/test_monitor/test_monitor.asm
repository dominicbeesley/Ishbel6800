
		.equ	ZP_SENDXX, 0
		.equ	ZP_SENDXV, 2

		.equ	ZP_LPCTR,  4

		.equ FT245_STAT,	0x8000
		.equ FT245_DATA,	0x8001

		.equ FT245_RXF,		0x01
		.equ FT245_TXE,		0x02

		.equ LCD32_REG, 	0x8100
		.equ LCD32_DATA, 	0x8102

		.org 0xE000

handle_irq:	rti
handle_swi:	rti
handle_nmi:	rti

str:		.byte "Hello Dossytronics", 0

handle_res:	lds	#0x1FF

		inc	ZP_LPCTR


		ldx	#lcd32_init0
		jsr	lcd32sendXregs
		ldx	#200
		jsr	delayXms

		ldx	#lcd32_init1
		jsr	lcd32sendXregs
		ldx	#50
		jsr	delayXms

		ldx	#lcd32_init2
		jsr	lcd32sendXregs
		ldx	#50
		jsr	delayXms

		ldx	#lcd32_init3
		jsr	lcd32sendXregs
		ldx	#50
		jsr	delayXms

		ldx	#lcd32_init4
		jsr	lcd32sendXregs


		ldb	#0x20
		ldx	#0
		jsr	lcd32_wrreg

		ldb	#0x21
		ldx	#0
		jsr	lcd32_wrreg

		ldx	#0
		clra
		ldab	#0x22
		staa	LCD32_REG	; index MSB
		stab	LCD32_REG+1	; index LSB	
		lda	ZP_LPCTR	
		clrb
lp11:		staa	LCD32_DATA	
		stab	LCD32_DATA+1
		incb
		bne	sk11
		inca
sk11:		dex
		bne 	lp11




		ldx	#4000
		jsr	delayXms

		ldx	#str
		jsr	send_strX
		jmp	handle_res


send_strX:
.0:		ldaa	0,X
		beq	.2
		jsr	send_charA
		inx
		bra	.0
.2:		rts

send_charA:	psha
		ldab	#FT245_TXE
.1:		bitb	FT245_STAT	
		bne	.1
		staa	FT245_DATA
		pulb
		rts

	; need ~ 2500 cycles
delay1ms:	psha		;4
		clra		;2
.0:		deca		;512
		nop		;512
		nop		;512
		bne	.0	;1024
		pula		;4
		rts		;4
delayXms:	jsr	delay1ms
		dex
		bne	delayXms
		rts

	; reg in B, value in X, clears A
lcd32_wrreg:	clra
		staa	LCD32_REG	; index MSB
		stab	LCD32_REG+1	; index LSB
		stx	LCD32_DATA
		rts

lcd32sendXregs:
.0:		stx	ZP_SENDXX
		ldab	0,X
		cmpb	#0xFF
		beq	.1
		ldx	1,X
		jsr	lcd32_wrreg
		ldx	ZP_SENDXX
		inx
		inx
		inx
		bra	.0
.1:		rts



	.macro	LCD32REGVAL index, value
		.byte	\index
		.word	\value
	.endm

lcd32_init0:
        LCD32REGVAL	0xE5, 0x78F0	; /* set SRAM internal timing */
        LCD32REGVAL	0x01, 0x0100	; /* set Driver Output Control */
        LCD32REGVAL	0x02, 0x0700	; /* set 1 line inversion */
        LCD32REGVAL	0x03, 0x1030	; /* set GRAM write direction and BGR=1 */
        LCD32REGVAL	0x04, 0x0000	; /* Resize register */
        LCD32REGVAL	0x08, 0x0207	; /* set the back porch and front porch */
        LCD32REGVAL	0x09, 0x0000	; /* set non-display area refresh cycle ISC[3:0] */
        LCD32REGVAL	0x0A, 0x0000	; /* FMARK function */
        LCD32REGVAL	0x0C, 0x0000	; /* RGB interface setting */
        LCD32REGVAL	0x0D, 0x0000	; /* Frame marker Position */
        LCD32REGVAL	0x0F, 0x0000	; /* RGB interface polarity */
        ; /*************Power On sequence ****************/
        LCD32REGVAL	0x10, 0x0000	; /* SAP, BT[3:0], AP, DSTB, SLP, STB */
        LCD32REGVAL	0x11, 0x0007	; /* DC1[2:0], DC0[2:0], VC[2:0] */
        LCD32REGVAL	0x12, 0x0000	; /* VREG1OUT voltage */
        LCD32REGVAL	0x13, 0x0000	; /* VDV[4:0] for VCOM amplitude */
        LCD32REGVAL	0x07, 0x0001	;
        		.byte 0xFF

	;;;;;;;        delay_ms(200); ;;;;;
lcd32_init1:
        ; /* Dis-charge capacitor power voltage */
        LCD32REGVAL	0x10, 0x1090	; /* SAP, BT[3:0], AP, DSTB, SLP, STB */
        LCD32REGVAL	0x11, 0x0227	; /* Set DC1[2:0], DC0[2:0], VC[2:0] */
        		.byte 0xFF
      	;;;; delay_ms(50);                           /* Delay 50ms */
lcd32_init2:
        LCD32REGVAL	0x12, 0x001F	; PON=1, VHR3..0=1
        		.byte 0xFF
	;;;; delay_ms(50);                           /* Delay 50ms */
lcd32_init3:
        LCD32REGVAL	0x13, 0x1500	; /* VDV[4:0] for VCOM amplitude */
        LCD32REGVAL	0x29, 0x0027	; /* 04 VCM[5:0] for VCOMH */
        LCD32REGVAL	0x2B, 0x000D	; /* Set Frame Rate */
        		.byte 0xFF
        ;;;; delay_ms(50);                           /* Delay 50ms */
lcd32_init4:
        LCD32REGVAL	0x20, 0x0000	; /* GRAM horizontal Address */
        LCD32REGVAL	0x21, 0x0000	; /* GRAM Vertical Address */
        ; /* ----------- Adjust the Gamma Curve ---------- */
        LCD32REGVAL	0x30, 0x0000	;
        LCD32REGVAL	0x31, 0x0707	;
        LCD32REGVAL	0x32, 0x0307	;
        LCD32REGVAL	0x35, 0x0200	;
        LCD32REGVAL	0x36, 0x0008	;
        LCD32REGVAL	0x37, 0x0004	;
        LCD32REGVAL	0x38, 0x0000	;
        LCD32REGVAL	0x39, 0x0707	;
        LCD32REGVAL	0x3C, 0x0002	;
        LCD32REGVAL	0x3D, 0x1D04	;
        ; /* ------------------ Set GRAM area --------------- */
        LCD32REGVAL	0x50, 0x0000	; /* Horizontal GRAM Start Address */
        LCD32REGVAL	0x51, 0x00EF	; /* Horizontal GRAM End Address */
        LCD32REGVAL	0x52, 0x0000	; /* Vertical GRAM Start Address */
        LCD32REGVAL	0x53, 0x013F	; /* Vertical GRAM Start Address */
        LCD32REGVAL	0x60, 0xA700	; /* Gate Scan Line */
        LCD32REGVAL	0x61, 0x0001	; /* NDL,VLE, REV */
        LCD32REGVAL	0x6A, 0x0000	; /* set scrolling line */
        ; /* -------------- Partial Display Control --------- */
        LCD32REGVAL	0x80, 0x0000	;
        LCD32REGVAL	0x81, 0x0000	;
        LCD32REGVAL	0x82, 0x0000	;
        LCD32REGVAL	0x83, 0x0000	;
        LCD32REGVAL	0x84, 0x0000	;
        LCD32REGVAL	0x85, 0x0000	;
        ; /* -------------- Panel Control ------------------- */
        LCD32REGVAL	0x90, 0x0010	;
        LCD32REGVAL	0x92, 0x0600	;
        LCD32REGVAL	0x07, 0x0133	; /* 262K color and display ON */
			.byte 0xFF

		.org 0xFFF8
hw_irq:		.word	handle_irq
hw_swi:		.word	handle_swi
hw_nmi:		.word	handle_nmi
hw_res:		.word	handle_res

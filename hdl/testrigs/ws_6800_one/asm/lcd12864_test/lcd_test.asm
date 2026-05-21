		.include "hardware.inc"

		.dpage

		.text
START:
		lds	#STACK


		ldx	#40
		jsr	delayXms

		ldaa	#0x30
		staa	LCD_12864_REG	; reset, select 8 bit

		jsr	delay1ms

		ldaa	#0x30
		staa	LCD_12864_REG	; reset, select 8 bit

		jsr	delay1ms

		ldaa	#0x0E
		staa	LCD_12864_REG	; display on with blinking cursor

		jsr	delay1ms

		ldaa	#01
		staa	LCD_12864_REG	; clear, set addr

		ldx	#100
		jsr	delayXms

		ldaa	#0x06
		staa	LCD_12864_REG	; entry mode

		jsr	delay1ms

		ldaa	#'I'
		staa	LCD_12864_DATA

		jsr	delay1ms

		ldaa	#'s'
		staa	LCD_12864_DATA

		jsr	delay1ms

		ldaa	#'h'
		staa	LCD_12864_DATA

		jsr	delay1ms

		ldaa	#'b'
		staa	LCD_12864_DATA

		jsr	delay1ms

		ldaa	#'e'
		staa	LCD_12864_DATA

		jsr	delay1ms
		ldaa	#'l'
		staa	LCD_12864_DATA

		jsr	delay1ms

		ldaa	#0x03
		staa	LCD_12864_DATA

		jsr	delay1ms
		

		swi


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



HERE:
	.equ	STACK, HERE + 0x100
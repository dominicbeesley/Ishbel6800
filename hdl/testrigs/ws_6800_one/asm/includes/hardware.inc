		.equ FT245_STAT,	0x8000
		.equ FT245_DATA,	0x8001

		.equ FT245_RXF,		0x01
		.equ FT245_TXE,		0x02

		.equ LCD_12864_REG, 	0x8200
		.equ LCD_12864_DATA, 	0x8201

		.equ VIA_orb,		0x8300
		.equ VIA_ora,		0x8301
		.equ VIA_ddrb,		0x8302
		.equ VIA_ddra,		0x8303
		.equ VIA_t1cl,		0x8304
		.equ VIA_t1ch,		0x8305
		.equ VIA_t1ll,		0x8306
		.equ VIA_t1lh,		0x8307
		.equ VIA_t2cl,		0x8308
		.equ VIA_t2ch,		0x8309
		.equ VIA_sr,		0x830A
		.equ VIA_acr,		0x830B
		.equ VIA_pcr,		0x830C
		.equ VIA_ifr,		0x830D
		.equ VIA_ier,		0x830E
		.equ VIA_ora_nh,	0x830F

;***********************************************************************
;*  VIA constants                                                      *
;***********************************************************************

		.equ VIA_IFR_BIT_ANY,	0x80
		.equ VIA_IFR_BIT_T1,	0x40
		.equ VIA_IFR_BIT_T2,	0x20
		.equ VIA_IFR_BIT_CB1,	0x10
		.equ VIA_IFR_BIT_CB2,	0x08
		.equ VIA_IFR_BIT_SR,	0x04
		.equ VIA_IFR_BIT_CA1,	0x02
		.equ VIA_IFR_BIT_CA2,	0x01

		.equ VIA_ACR_SHIFTMODE_0,	0x00
		.equ VIA_ACR_SHIFTMODE_1,	0x04
		.equ VIA_ACR_SHIFTMODE_2,	0x08
		.equ VIA_ACR_SHIFTMODE_3,	0x0C
		.equ VIA_ACR_SHIFTMODE_4,	0x10
		.equ VIA_ACR_SHIFTMODE_5,	0x14
		.equ VIA_ACR_SHIFTMODE_6,	0x18
		.equ VIA_ACR_SHIFTMODE_7,	0x1C

		.equ VIA_ACR_T2_COUNT_PB6,	0x20

		.equ VIA_ACR_T1_MASK,		0xC0
		.equ VIA_ACR_T1_CONT,		0x40
		.equ VIA_ACR_T1_SSHOT,		0x80
		.equ VIA_ACR_T1_SQUARE,		0xC0





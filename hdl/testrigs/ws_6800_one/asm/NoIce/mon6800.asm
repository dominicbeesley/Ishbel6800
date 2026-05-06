		.include "hardware.inc"

; Dominic Beesley May 6 2026
;
; This is a heavily frigged version of John Hartmann's 6801 monitor
;
; This file will produce a mainly empty MOS ROM at 0xE000 with hardware vectors at
; FFF8-FFFF and expects WS_ONE_6800 hardware (see hardware.inc)
;
;  Hardware definitions
		
		.equ RAM_START,	0x7F00		;START OF MONITOR RAM
		.equ ROM_START,	0xE000		;START OF MONITOR CODE
		.equ HARD_VECT,	0xFFF8		;START OF HARDWARE VECTORS
;
;
;============================================================================
;  HARDWARE PLATFORM CUSTOMIZATIONS
;============================================================================
;
;  Put you UART equates here


		;
;============================================================================
;  RAM definitions:
		.section	RAM, "aurwn"
;; ;
;; ;  Initial user stack
;; ;  (Size and location is user option - at least 7 bytes to accept an SWI!)
;; ;  6800 SP points at NEXT BYTE TO USE, rather than at last used byte
;; ;  like most processors.  Thus, init SP to TOP-1 of stack space
;; 		.space	63
;; INITSTACK:      .space	1
		.equ	INITSTACK, 0x7EFF

VECTOR_IRQ:	.space   2
VECTOR_NMI:	.space   2

;
;  Monitor stack
;  (Calculated use is at most 7 bytes [TODO:CHECK].  Leave plenty of spare)
;  6800 SP points at NEXT BYTE TO USE, rather than at last used byte
;  like most processors.  Thus, init SP to TOP-1 of stack space
		.space	15
MONSTACK:	.space	1
;
;  Target registers:  order must match that in TRGHC11.C
TASK_REGS:
REG_STATE:	.space     1
REG_PAGE:	.space     1
REG_SP:		.space     2
REG_X:		.space     2
REG_B:		.space     1               	;B BEFORE A, SO D IS LEAST SIG. FIRST
REG_A:		.space     1
REG_CC:		.space     1
REG_PC:		.space     2
TASK_REGS_END:
		.equ	TASK_REG_SZ,	TASK_REGS_END - TASK_REGS
;
;  Communications buffer
;  (Must be at least as long as the longer of TASK_REG_SZ or TSTG_SIZE.
;  At least 19 bytes recommended.  Larger values may improve speed of NoICE
;  download and memory move commands.)
		.equ	COMBUF_SIZE, 128		;DATA SIZE FOR COMM BUFFER
COMBUF:		.space	2+COMBUF_SIZE+1		;BUFFER ALSO HAS FN, LEN, AND CHECK
;
WKSP_PTR1:	.space	2
WKSP_PTR2:	.space	2
WKSP_PTR3:	.space	2
WKSP_PTR4:	.space	2

RAM_END:						;ADDRESS OF TOP+1 OF RAM
;
;===========================================================================
		.section CODE, "acrx"
;
;  Power on reset
RESET:
;
;  Set CPU mode to safe state
		SEI                             ;INTERRUPTS OFF (WE MAY JUMP HERE)

		LDX	#NMI_ENT
		STX	VECTOR_NMI
		LDX	#IRQ_ENTRY
		STX	VECTOR_IRQ

		CLR	REG_STATE               ;STATE 0 = "RESET"
RES10:
		LDS     #MONSTACK               ;CLEAN STACK IS HAPPY STACK

		; clear interrupts from VIA
		LDAA	#0x7F
		STAA	VIA_ier
		STAA	VIA_ifr

;
;  Initialize your UART here

		LDAA	#'!'
		STAA	FT245_DATA


		; WSONE uses FT245 nothing to setup - send a test string...

		LDAA	#'I'
		JSR	PUTCHAR
		LDAA	#'s'
		JSR	PUTCHAR
		LDAA	#'h'
		JSR	PUTCHAR


;
;  Initialize user registers
		LDAA    #INITSTACK/256
		STAA	REG_SP+1                ;INIT USER'S STACK POINTER MSB
		LDAA    #INITSTACK%256
		STAA	REG_SP                  ;LSB
		CLRA
		STAA	REG_PC
		STAA	REG_PC+1
		STAA	REG_A
		STAA	REG_B
		STAA	REG_X
		STAA	REG_X+1
;
;  Initialize memory paging variables and hardware (if any)
		STAA	REG_PAGE		;NO PAGE YET
;;*     STAA     PAGEIMAGE
;;*     STAA     PAGELATCH              set hardware page
;
;  Initialize non-zero registers
		LDAA    #0x10			;disable interrupts in user program
		STAA	REG_CC
;
;  Set function code for "GO".  Then if we are here because of a reset
;  (such as a COP timeout) after being told to GO, we will come
;  back with registers so user can see the reset
		LDAA    #FN_RUN_TARG
		STAA	COMBUF
		JMP	RETURN_REGS		;DUMP REGS, ENTER MONITOR
;
;===========================================================================
;  Get a character to A
;
;  Return A=char, CY=0 if data received
;         CY=1 if timeout (0.5 seconds)
;
;  Uses 6 bytes of stack including return address
;
GETCHAR:
GC10:
;(Disable timeout in most cases...)
		LDAA	FT245_STAT      	;READ DEVICE STATUS
		ASRA
		BCS	GC10            	;NOT READY YET.
;
;  Data received:  return CY=0. data in A
		CLC				;CY=0
		LDAA	FT245_DATA      	;READ DATA
		RTS
;
;===========================================================================
;  Output character in A
;
;  Uses 5 bytes of stack including return address
;
PUTCHAR:
		PSHA
		LDA	#FT245_TXE
PC10:		BITA	FT245_STAT      	;CHECK TX STATUS
		BNE	PC10
		PULA
		STAA	FT245_DATA      	;TRANSMIT CHAR.
		RTS
;
;======================================================================
;  Response string for GET TARGET STATUS request
;  Reply describes target:
TSTG:		.byte	11			;2: PROCESSOR TYPE = 6801
		.byte	COMBUF_SIZE		;3: SIZE OF COMMUNICATIONS BUFFER
		.byte	0x00			;4: hasn't CALL
		.word	0			;5,6: BOTTOM OF PAGED MEM
		.word	0			;7,8: TOP OF PAGED MEM
		.byte	B1-B0			;9 BREAKPOINT INSTR LENGTH
B0:		SWI				;10+ BREKAPOINT INSTRUCTION
B1:      	.byte	"6800 monitor V1.1 Dossy", 0
						;DESCRIPTION, ZERO
		.byte	0
		.byte	0                       	;page of CALL breakpoint
		.word	0			;address of CALL breakpoint in native order
TSTG_END:
		.equ	TSTG_SIZE, TSTG_END-TSTG;SIZE OF STRING
;
;======================================================================
;  HARDWARE PLATFORM INDEPENDENT EQUATES AND CODE
;
;  Communications function codes.
		.equ	FN_GET_STAT,	0xFF	;reply with device info
		.equ	FN_READ_MEM,	0xFE	;reply with data
		.equ	FN_WRITE_MEM,	0xFD	;reply with status (+/-)
		.equ	FN_RD_REG,	0xFC	;reply with registers
		.equ	FN_WR_REG,	0xFB	;reply with status
		.equ	FN_RUN_TARG,	0xFA	;reply (delayed) with registers
		.equ	FN_SET_BYTE,	0xF9	;reply with data (truncate if error)
		.equ	FN_IN,		0xF8	;input from port
		.equ	FN_OUT,		0xF7	;output to port
;
		.equ	FN_MIN,		0xF0	;MINIMUM RECOGNIZED FUNCTION CODE
		.equ	FN_ERROR,	0xF0	;error reply to unknown op-code
;
;===========================================================================
;  Common handler for default interrupt handlers
;  Enter with A=interrupt code = processor state
;  All registers stacked, PC=next instruction
INT_ENTRY:
		STAA	REG_STATE       	;SAVE STATE
;
;  Save registers from stack to reg block for return to master
;  Host wants least significant bytes first, so flip as necessary
		PULA
		STAA	REG_CC          	;CONDITION CODES
		PULA
		STAA	REG_B
		PULA
		STAA	REG_A
		PULA
		STAA	REG_X+1         	;MSB
		PULA
		STAA	REG_X           	;LSB
;
;  If this is a breakpoint (state = 1), then back up PC to point at SWI
;  (If SWI2, SWI3, or another instruction is used for breakpoint,
;  then DEX multiple times to match B1-B0 in TSTG
		PULA
		PULB				;PC AFTER INTERRUPT
		STAA	WKSP_PTR1
		STAB	WKSP_PTR1+1
		LDX	WKSP_PTR1
		LDAA	REG_STATE
		CMPA    #1
		BNE	NOTBP           	;BR IF NOT A BREAKPOINT
		DEX				;ELSE BACK UP TO POINT AT SWI LOCATION
NOTBP:		STX	REG_PC
		; swap endianness!
		LDAA	REG_PC
		LDAB	REG_PC+1
		STAA	REG_PC+1        	;MSB
		STAB	REG_PC          	;LSB
		TSX				;USER STACK POINTER PLUS 1
		DEX				;MAKE IT JUST LIKE THE REAL SP
		STX	REG_SP
		; swap endianness
		LDAA	REG_SP
		LDAB	REG_SP+1
		STAB	REG_SP          	;SAVE USER'S STACK POINTER (LSB)
		STAA	REG_SP+1        	;MSB
;
;  Change to our own stack
		LDS     #MONSTACK       	;AND USE OURS INSTEAD
;
;  Save memory page
;;*     LDAA    PAGEIMAGE       GET CURRENT USER PAGE
		LDAA    #0              	;... OR ZERO IF UNPAGED TARGET
		STAA	REG_PAGE        	;SAVE USER'S PAGE
;
;  Return registers to master
		JMP	RETURN_REGS
;
;===========================================================================
;  Main loop:  wait for command frame from master
;
;  Uses 7 bytes of stack before jump to handlers
;
MAIN:    	LDS     #MONSTACK		;CLEAN STACK IS HAPPY STACK
		LDX     #COMBUF			;BUILD MESSAGE HERE
;
;  First byte is a function code
		JSR	GETCHAR			;GET A FUNCTION
		BCS	MAIN			;JIF TIMEOUT: RESYNC
		CMPA    #FN_MIN
		BLO	MAIN			;JIF BELOW MIN: ILLEGAL FUNCTION
		STAA	0,X			;SAVE FUNCTION CODE
		INX
;
;  Second byte is data byte count (may be zero)
		JSR	GETCHAR			;GET A LENGTH BYTE
		BCS	MAIN			;JIF TIMEOUT: RESYNC
		CMPA    #COMBUF_SIZE
		BHI	MAIN			;JIF TOO LONG: ILLEGAL LENGTH
		STAA	0,X			;SAVE LENGTH
		INX
		CMPA    #0
		BEQ	MA80			;SKIP DATA LOOP IF LENGTH = 0
;
;  Loop for data
		TAB				;SAVE LENGTH FOR LOOP
MA10:		JSR	GETCHAR                 ;GET A DATA BYTE
		BCS	MAIN                    ;JIF TIMEOUT: RESYNC
		STAA	0,X                     ;SAVE DATA BYTE
		INX
		DECB
		BNE	MA10
;
;  Get the checksum
MA80:		JSR	GETCHAR			;GET THE CHECKSUM
		BCS	MAIN			;JIF TIMEOUT: RESYNC
		PSHA				;SAVE CHECKSUM
;
;  Compare received checksum to that calculated on received buffer
;  (Sum should be 0)
		JSR	CHECKSUM
		PULB
		ABA
		BNE	MAIN			;JIF BAD CHECKSUM
;
;  Process the message.
		LDX     #COMBUF
		LDAA	0,X			;GET THE FUNCTION CODE
		LDAB	1,X			;GET THE LENGTH
		INX
		INX				;X POINTS AT DATA
		CMPA    #FN_GET_STAT
		BEQ	TARGET_STAT
		CMPA    #FN_READ_MEM
		BEQ	JREAD_MEM
		CMPA    #FN_WRITE_MEM
		BEQ	JWRITE_MEM
		CMPA    #FN_RD_REG
		BEQ	JREAD_REGS
		CMPA    #FN_WR_REG
		BEQ	JWRITE_REGS
		CMPA    #FN_RUN_TARG
		BEQ	JRUN_TARGET
		CMPA    #FN_SET_BYTE
		BEQ	JSET_BYTES
		CMPA    #FN_IN
		BEQ	JIN_PORT
		CMPA    #FN_OUT
		BEQ	JOUT_PORT
;
;  Error: unknown function.  Complain
		LDAA    #FN_ERROR
		STAA	COMBUF          	;SET FUNCTION AS "ERROR"
		LDAA    #1
		JMP	SEND_STATUS     	;VALUE IS "ERROR"
;
;  long jumps to handlers
JREAD_MEM:	JMP	READ_MEM
JWRITE_MEM:	JMP	WRITE_MEM
JREAD_REGS:	JMP	READ_REGS
JWRITE_REGS:	JMP	WRITE_REGS
JRUN_TARGET:	JMP	RUN_TARGET
JSET_BYTES:	JMP	SET_BYTES
JIN_PORT:	JMP	IN_PORT
JOUT_PORT:	JMP	OUT_PORT
		;===========================================================================
;
;  Target Status:  FN, len
;
;  Entry with A=function code, B=data size, X=COMBUF+2
;
TARGET_STAT:
		LDX     #TSTG			;DATA FOR REPLY
		STX	WKSP_PTR1
		LDX     #COMBUF			;POINTER TO RETURN BUFFER
		LDAB    #TSTG_SIZE		;LENGTH OF REPLY
		STAB	1,X			;SET SIZE IN REPLY BUFFER

TS10:		LDX	WKSP_PTR1
		LDAA	0,X			;MOVE REPLY DATA TO BUFFER
		INX
		STX	WKSP_PTR1
		LDX	WKSP_PTR2
		STAA	2,X
		INX
		STX	WKSP_PTR2
		DECB
		BNE	TS10
;
;  Compute checksum on buffer, and send to master, then return
		JMP	SEND
		;===========================================================================
;
;  Read Memory:  FN, len, page, Alo, Ahi, Nbytes
;
;  Entry with A=function code, B=data size, X=COMBUF+2
;
READ_MEM:
;
;  Set page
;;      LDAA    0,X
;;      STAA    PAGEIMAGE
;;      STAA    PAGELATCH
;
;  Get address
		LDAA	2,X			;MSB OF ADDRESS IN A
		STAA	WKSP_PTR2
		LDAA	1,X			;LSB OF ADDRESS IN B
		STAA	WKSP_PTR2+1	
;
;  Prepare return buffer: FN (unchanged), LEN, DATA
		LDAB	3,X			;NUMBER OF BYTES TO RETURN
		STAB	COMBUF+1		;RETURN LENGTH = REQUESTED DATA
		BEQ	GLP90			;JIF NO BYTES TO GET

		STX	WKSP_PTR1

;
;  Read the requested bytes from local memory
GLP:		LDX	WKSP_PTR2
		LDAA	0,X			;GET BYTE
		INX
		STX	WKSP_PTR2
		LDX	WKSP_PTR1
		STAA	0,X			;STORE TO RETURN BUFFER
		INX
		STX	WKSP_PTR1
		DECB
		BNE	GLP
;
;  Compute checksum on buffer, and send to master, then return
GLP90:		JMP	SEND
		;===========================================================================
;
;  Write Memory:  FN, len, page, Alo, Ahi, (len-3 bytes of Data)
;
;  Entry with A=function code, B=data size, X=COMBUF+2
;
;  Uses 6 bytes of stack
;
WRITE_MEM:
;
;  Set page
;;      LDAA    0,X
;;      STAA    PAGEIMAGE
;;      STAA    PAGELATCH
;
;  Get address
		LDAA	2,X			;MSB OF ADDRESS IN A
		LDAB	1,X			;LSB OF ADDRESS IN B
		STAA	WKSP_PTR2
		STAB	WKSP_PTR2+1
		STAA	WKSP_PTR4
		STAB	WKSP_PTR4+1
;
;  Prepare return buffer: FN (unchanged), LEN, DATA
		LDAB	COMBUF+1		;NUMBER OF BYTES TO RETURN
		SUBB    #3			;MINUS PAGE AND ADDRESS
		BEQ	WLP50			;JIF NO BYTES TO PUT

		STX	WKSP_PTR1
		STX	WKSP_PTR3
		PSHB				;Save count

;
;  Write the specified bytes to local memory
WLP:		LDX	WKSP_PTR1
		LDAA	3,X			;GET BYTE TO WRITE
		INX
		STX	WKSP_PTR1
		LDX	WKSP_PTR2
		STAA	0,X			;STORE THE BYTE AT AAAA,Y
		INX
		STX	WKSP_PTR2
		DECB
		BNE	WLP
;
;  Compare to see if the write worked
		PULB				;POP count
WLP20:		LDX	WKSP_PTR3
		LDAA	3,X			;GET BYTE JUST WRITTEN
		INX
		STX	WKSP_PTR3
		LDX	WKSP_PTR4
		CMPA	0,X
		BNE	WLP80			;BR IF WRITE FAILED
		INX
		STX	WKSP_PTR4
		DECB
		BNE	WLP20
;
;  Write succeeded:  return status = 0
WLP50:   	LDAA    #0			;RETURN STATUS = 0
		BRA	WLP90
;
;  Write failed:  return status = 1
WLP80:		LDAA    #1
;
;  Return OK status
WLP90:		JMP	SEND_STATUS
		;===========================================================================
;
;  Read registers:  FN, len=0
;
;  Entry with A=function code, B=data size, X=COMBUF+2
;
READ_REGS:
;
;  Enter here from SWI after "RUN" and "STEP" to return task registers
;  CAUTION:  in this case, assume no registers!
RETURN_REGS:
		LDX     #TASK_REGS		;POINTER TO REGISTERS
		STX	WKSP_PTR2
		LDAB    #TASK_REG_SZ		;NUMBER OF BYTES
		STAB	COMBUF+1		;SAVE RETURN DATA LENGTH
;
;  Copy the registers
		LDX     #COMBUF+2		;POINTER TO RETURN BUFFER
		STX	WKSP_PTR1
GRLP:		LDX	WKSP_PTR2
		LDAA	0,X			;GET BYTE TO A
		INX
		STX	WKSP_PTR2
		LDX	WKSP_PTR1
		STAA	0,X			;STORE TO RETURN BUFFER
		INX
		STX	WKSP_PTR1
		DECB
		BNE	GRLP
;
;  Compute checksum on buffer, and send to master, then return
		JMP	SEND
		;===========================================================================
;
;  Write registers:  FN, len, (register image)
;
;  Entry with A=function code, B=data size, X=COMBUF+2
;
WRITE_REGS:
;
		LDAB	COMBUF+1		;NUMBER OF BYTES
		BEQ	WRR80			;JIF NO REGISTERS
;
;  Copy the registers
		STX	WKSP_PTR1
		LDX     #TASK_REGS		;POINTER TO REGISTERS
		STX	WKSP_PTR2

WRRLP:		LDX	WKSP_PTR1
		LDAA	0,X			;GET BYTE TO A
		INX
		STX	WKSP_PTR1
		LDX	WKSP_PTR2
		STAA	0,X			;STORE TO REGISTER RAM
		INX
		STX	WKSP_PTR2
		DECB
		BNE	WRRLP
;
;  Return OK status
WRR80:   	LDAA    #0
		JMP	SEND_STATUS
		;===========================================================================
;
;  Run Target:  FN, len
;
;  Entry with A=function code, B=data size, X=COMBUF+2
;
RUN_TARGET:
;
;  Restore user's page
;;      LDAA    REG_PAGE                USER'S PAGE
;;      STAA    PAGEIMAGE               SET IMAGE
;;      STAA    PAGELATCH               SET PAGING REGISTER
;
;  Switch to user stack
		LDAB	REG_SP			;BACK TO USER STACK
		LDAA	REG_SP+1
		STAA	WKSP_PTR1
		STAB	WKSP_PTR1+1
		LDX	WKSP_PTR1
		INX				;PRE-CORRECT FOR TXS
		TXS				;SP = X-1
;
;  Restore registers
		LDAA	REG_PC			;SAVE LS USER PC FOR RTI
		PSHA
		LDAA	REG_PC+1		;SAVE MS USER PC FOR RTI
		PSHA
;
;NOTE: no Y!
		LDAA	REG_X
		PSHA
		LDAA	REG_X+1
		PSHA
;
		LDAA	REG_A
		PSHA
		LDAA	REG_B
		PSHA
;
		LDAA	REG_CC			;`SAVE USER CONDITION CODES FOR RTI
		PSHA

		CLR	REG_STATE

;
;  Return to user
		RTI
;
;===========================================================================
;
;  Set target byte(s):  FN, len { (page, alow, ahigh, data), (...)... }
;
;  Entry with A=function code, B=data size, X=COMBUF+2
;
;  Return has FN, len, (data from memory locations)
;
;  If error in insert (memory not writable), abort to return short data
;
;  This function is used primarily to set and clear breakpoints
;
;  Uses 2 bytes of stack
;
SET_BYTES:
		STX	WKSP_PTR1		;READ pointer for COMBUF for incoming requests
		LDX     #COMBUF+1               ;POINTER TO RETURN BUFFER
		CLR	0,X			;SET RETURN COUNT AS ZERO
		INX				;POINT AT FIRST RETURN DATA BYTE
		STX	WKSP_PTR3
		LSRB
		LSRB				;LEN/4 = NUMBER OF BYTES TO SET
		BEQ	SB99			;JIF NO BYTES (COMBUF+1 = 0)
;
;  Loop on inserting bytes
SB10:		PSHB				;SAVE LOOP COUNTER
		;
;  Set page
;;      LDAA    0,X
;;      STAA    PAGEIMAGE
;;      STAA    PAGELATCH
;
;  Get address
		LDX	WKSP_PTR1
		LDAB	3,X			;GET BYTE TO STORE

		LDAA	2,X			;MSB OF ADDRESS IN A
		STAA	WKSP_PTR2
		LDAA	1,X			;LSB OF ADDRESS IN B
		STAA	WKSP_PTR2+1
		INX
		INX
		INX
		INX
		STX	WKSP_PTR1

		LDX	WKSP_PTR2		; MEMORY pointer
;
;  Read current data at byte location
		LDAA	0,X
;
;  Insert new data at byte location
		STAB	0,X			;WRITE TARGET MEMORY
;
;  Verify write
		CMPB	0,X			;READ TARGET MEMORY
		PULB				;RESTORE LOOP COUNTER (CC'S INTACT)
		BNE	SB90			;BR IF INSERT FAILED: ABORT
;
;  Save target byte in return buffer
		LDX	WKSP_PTR3
		STAA	0,X
		INX				;ADVANCE TO NEXT RETURN BYTE
		STX	WKSP_PTR3
		INC	COMBUF+1		;COUNT ONE RETURN BYTE
;
;  Loop for next byte
		CMPB	COMBUF+1
		BNE	SB10			;LOOP FOR ALL BYTES
;
;  Return buffer with data from byte locations
SB90:
;
;  Compute checksum on buffer, and send to master, then return
SB99:		JMP	SEND
		;===========================================================================
;
;  Input from port:  FN, len, PortAddressLo, PAhi (=0)
;
;  While the HC11 has no input or output instructions, we retain these
;  to allow write-without-verify
;
;  Entry with A=function code, B=data size, X=COMBUF+2
;
IN_PORT:
;
;  Get port address
		LDAA	1,X			;MSB OF ADDRESS IN A
		STAA	WKSP_PTR1
		LDAA	0,X			;LSB OF ADDRESS IN B
		STAA	WKSP_PTR1+1
		LDX	WKSP_PTR1
;
;  Read the requested byte from local memory
		LDAA	0,X
;
;  Return byte read as "status"
		JMP	SEND_STATUS
		;===========================================================================
;
;  Output to port:  FN, len, PortAddressLo, PAhi (=0), data
;
;  Entry with A=function code, B=data size, X=COMBUF+2
;
OUT_PORT:
;
;
;  Get data
		LDAA	2,X
		PSHA
;  Get port address
		LDAA	1,X			;MSB OF ADDRESS IN A
		STAA	WKSP_PTR1
		LDAA	0,X			;LSB OF ADDRESS IN B
		STAA	WKSP_PTR1+1
		LDX	WKSP_PTR1
		PULA
;
;  Write value to port
		STAA	0,X
;
;  Do not read port to verify (some I/O devices don't like it)
;
;  Return status of OK
		CLRA
		JMP	SEND_STATUS
		;===========================================================================
;  Build status return with value from "A"
;
SEND_STATUS:
		STAA	COMBUF+2		;SET STATUS
		LDAA    #1
		STAA	COMBUF+1		;SET LENGTH
		BRA	SEND
		;===========================================================================
;  Append checksum to COMBUF and send to master
;
SEND:		JSR	CHECKSUM		;GET A=CHECKSUM, X->checksum location
		NEGA
		STAA	0,X			;STORE NEGATIVE OF CHECKSUM
;
;  Send buffer to master
		LDX     #COMBUF			;POINTER TO DATA
		LDAB	1,X			;LENGTH OF DATA
		ADDB    #3			;PLUS FUNCTION, LENGTH, CHECKSUM
SND10:		LDAA	0,X
		JSR	PUTCHAR			;SEND A BYTE
		INX
		DECB
		BNE	SND10
;
		JMP	MAIN			;BACK TO MAIN LOOP
		;===========================================================================
;  Compute checksum on COMBUF.  COMBUF+1 has length of data,
;  Also include function byte and length byte
;
;  Returns:
;       A = checksum
;       X = pointer to next byte in buffer (checksum location)
;       B is scratched
;
;  Uses 2 bytes of stack including return address
;
CHECKSUM:
		LDX     #COMBUF			;pointer to buffer
		LDAB	1,X			;length of message
		ADDB    #2			;plus function, length
		LDAA    #0			;init checksum to 0
CHK10:		ADDA	0,X
		INX
		DECB
		BNE	CHK10			;loop for all
		RTS				;return with checksum in A
		;**********************************************************************

;
;  Non-RAM vectored
SWI_ENTRY:	LDAA    #1
		JMP	INT_ENTRY
IRQ_ENTRY:	LDAA    #6
		JMP	INT_ENTRY
NMI_ENT:	LDAA	REG_STATE
		BNE	EXIT_NMI
		LDAA    #2
		JMP	INT_ENTRY
EXIT_NMI:	RTI

C_IRQ_ENTRY:	LDX	#VECTOR_IRQ
		JMP	0,X
C_NMI_ENTRY:	LDX	#VECTOR_NMI
		JMP	0,X


;
;  INTERRUPT VECTORS
		.section HARD_VECS, "acrx"
;
;  The remaining interrupts are permanently trapped to the monitor
		.word	C_IRQ_ENTRY		;fff8 IRQ
		.word	SWI_ENTRY		;fffa SWI/breakpoint
		.word	C_NMI_ENTRY		;fffc NMI
		.word	RESET			;fffe reset
;


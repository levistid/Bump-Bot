;
; ECE375_Lab3.asm
;
; Created: 2/1/2024 12:01:51 PM
; Author : Levi Stidham
;


	;***********************************************************
;*	
;*
;*	 Author: Levi Stidham
;*	   Date: 02/01/2024
;*
;***********************************************************

.include "m32U4def.inc"			; Include definition file

;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16				; Multipurpose register is required for LCD Driver
.def	counter = r17			;Coutner register
.def	temp = r23				; Temperary register
.def	waitcnt = r18			; wait count register
.def	ilcnt = r19				; inner loop counter
.def	olcnt = r24				; Outer Loop Counter  r14&r15 are for the marquee style funct. 
.def	inputregister = r25		; handles inputs

;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; Beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000					; Beginning of IVs
		rjmp INIT				; Reset interrupt

.org	$0056					; End of Interrupt Vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:							; The initialization routine
		;Initialize LCD
		rcall LCDInit			; Initialize LCD Display
		rcall LCDBacklighton	;Turn on LCD backlight
		rcall LCDClr			;Clear the LCD


		ldi	mpr, low(RAMEND)	; Initialize Stack Pointer
		out SPL, mpr
		ldi mpr, high(RAMEND)
		out SPH, mpr
 

		;Initialize Port D for input
		ldi mpr, $00			;Initialize Port D DDRD for input
		out DDRD, mpr			;Input
		ldi mpr, $FF			;Initialize Port D DDRD
		out PORTD, mpr			;All inputs for PORTD are tri state 

		;Initialize Port B for output
		ldi	mpr, $FF			;set up portB DDRB
		out DDRB, mpr			;output
		ldi mpr, $00			; Initialize Port B DDRB
		out PORTB, mpr			; places all Port B outputs low.

		; NOTE that there is no RET or RJMP from INIT,
		; this is because the next instruction executed is the
		; first instruction of the main program

;***********************************************************
;*	Main Program
;***********************************************************
MAIN:								; The Main program
		
		call	Button_Int			;set up buttons for inputs.

		in mpr, PIND				; Put PIND input in mpr
		cpi mpr, 0b1110_1111					; Check if a button (d4) was pressed
		brne Check_D5				
		call D4					; Go to D4 function
		rjmp MAIN					; Return to MAIN

Check_D5:
		cpi	mpr, 0b1101_1111				;Check if D5 was pressed
		brne	Check_D7			
		call	D5					;Go to D5 function
		rjmp	MAIN				;return to MAIN

Check_D7:
		cpi	mpr, 0b0111_1111				;check if D7 was pressed
		brne	MAIN				
		call	D7					;go to D7 function
		rjmp	MAIN				;Return to main

		call	LCDWrite			;Write message/name to LCD.

		rjmp	MAIN			; jump back to main and create an infinite
								; while loop.  Generally, every main program is an
								; infinite while loop, never let the main program
								; just run off

;***********************************************************
;*	Functions and Subroutines
;***********************************************************


;----------------------------------------------------------------
; Sub:	Button_Initialization
; Desc:	place buttons into the upper half of the mpr. Buttons will be active low
;----------------------------------------------------------------
Button_Int:
	in		mpr, PIND			;Input from PIN D
	andi	mpr,0b11111111		; clear bits
	ret


;----------------------------------------------------------------
; Sub:	Wait
; Desc:	A wait loop that is 16 + 159975*waitcnt cycles or roughly
;		waitcnt*10ms.  Just initialize wait for the specific amount
;		of time in 10ms intervals. Here is the general eqaution
;		for the number of clock cycles in the wait loop:
;			(((((3*ilcnt)-1+4)*olcnt)-1+4)*waitcnt)-1+16
;----------------------------------------------------------------
Wait:
		push	waitcnt			; Save wait register
		push	ilcnt			; Save ilcnt register
		push	olcnt			; Save olcnt register

Loop:	ldi		olcnt, 224		; load olcnt register
OLoop:	ldi		ilcnt, 237		; load ilcnt register
ILoop:	dec		ilcnt			; decrement ilcnt
		brne	ILoop			; Continue Inner Loop
		dec		olcnt		; decrement olcnt
		brne	OLoop			; Continue Outer Loop
		dec		waitcnt		; Decrement wait
		brne	Loop			; Continue Wait loop

		pop		olcnt		; Restore olcnt register
		pop		ilcnt		; Restore ilcnt register
		pop		waitcnt		; Restore wait register
		ret				; Return from subroutine



;-----------------------------------------------------------
; Func: D4
; Desc: clear content
;	
;-----------------------------------------------------------
D4: 
;button D4

	rcall LCDClr		;Clear both lines
	 

	ret 



;-----------------------------------------------------------
; Func: D5
; Desc: Display name on top line, message on the bottom line
;	
;-----------------------------------------------------------
;Static_Display

D5:
	rcall LCDClr						;Start by clearing both lines of the LCD of data
	 
	 ;Initialize Y and Z registers, move strings from PM to DM
	ldi		ZL, Low(STRING_BEG01<<1)	; Z register points to low byte of string in PM
	ldi		ZH, High(STRING_BEG01<<1)	; Z register points to hight bytes of string in PM
	ldi		YL, Low($0100)				; Y register points to low byte location for line 1 $0100 comes from LCDDriver
	ldi		YH, High($0100)				; Y register points to high bytes location for line 1. $0100 comes from LCDDriver.
	ldi		counter, 12					; Load constant 16 to r23. Using 16 characters because that is the maximum size possible. My name is only 12 chars (including space between names)
			
Top_Line: 
	
	lpm		mpr, z+						;load data from Z. Post increment to go through byte by byte. 
	st		Y+, mpr						;Store data from r16 to DM. Shift by 1 post increment.
	DEC		counter						; decrease counter
	brne	Top_Line					;Continue loop if counter isn't 0
	

	. ;Initialize Y and Z registers, move strings from PM to DM
	ldi		ZL, Low(STRING_BEG02<<1)	; Z register points to low byte of string in PM
	ldi		ZH, High(STRING_BEG02<<1)	; Z register points to hight bytes of string in PM
	ldi		YL, Low($0110)				; Y register points to low byte location for line 1 $0110 comes from LCDDriver
	ldi		YH, High($0110)				; Y register points to high bytes location for line 1. $0110 comes from LCDDriver.
	ldi		counter, 14					; Load constant 16 to r23. Using 16 because it is the maximum size possible. The phrase I picked has 14 chars
Bottom_Line:
	
	lpm		mpr, Z+						; load data from Z register. Post increment to go byte by byte.
	st		Y+, mpr						;Store data from r16 to DM. Shift by 1, post increment.
	DEC		counter						;decrease counter by 1.
	brne	Bottom_Line					;Continue loop if counter is not  yet 0.
	rcall LCDWrite						;write to lcd
	ret									;exit function


;-----------------------------------------------------------
; Func: D7	
; Desc: Marquee style scrolling message 
;	
;-----------------------------------------------------------
D7:
	;Push a bunch of stuff to the stack
	push	waitcnt						; r12	
	push	ilcnt						; r19
	push	olcnt						; r24
	push	ZH							; r31
	push	ZL							; r30
	push	YH							; r29
	push	YL							; r28
	push	mpr


	ldi XH, $01
	ldi XL, $20

	ldi counter, 32
	lop:
		ld mpr, -X						;decrement x after loading to mpr
		push mpr						; push mpr to stack
		dec r17							; decrement r17 (counter)
		brne lop				
	
		ldi XL, $01						;put last byte to first byte
		ldi counter, 31					; loop counter

	lop2:
		pop mpr							
		st X+, mpr						; store mpr at x, increment x
		dec r17							; decrement counter
		brne lop2

		pop mpr							
		ldi XL, $00						; load data from $00 on XL
		st X, mpr						; store all mpr on X 

	ldi		ZL, Low(STRING_BEG01<<1)	;ZL to the low bits
	ldi		ZH, High(STRING_BEG01<<1)	;ZH to high bits
	ldi		YH, High($0100)			
	ldi		YL, Low($0100)		

	ldi		ZH, High(STRING_BEG02<<1)	
	ldi		ZL, Low(STRING_BEG02<<1)	;Set Z to end of line 2
	ldi		YH, $00
	ldi		YL, $01						;Upper and lower DM locations

	ld		mpr, Y+						;load data from first spot of line 1
	ldi		ilcnt, low($0110)			;set up conditional check loop

	MarqueeLoop:
		

		
		ldi		waitcnt, 25				;.25s wait time 
		call	LCDWrite				;Write that down Patrick! Write that down!
		call	wait					; hold your horses. Lets take a pause.

		pop		mpr

		pop		YL
		pop		YH
		pop		ZL
		pop		ZH							;popping the variables from the stack.
		pop		olcnt						
		pop		ilcnt						 
		pop		waitcnt						
		ret								; Bye! Have fun back in the main function!






;***********************************************************
;*	Stored Program Data
;***********************************************************

;-----------------------------------------------------------
; An example of storing a string. Note the labels before and
; after the .DB directive; these can help to access the data
;-----------------------------------------------------------
STRING_BEG01:
.DB		"Levi Stidham"		; Declaring data in ProgMem
STRING_END01:
STRING_BEG02:
.DB		"What up world "	;declaring data in ProgMem
STRING_END02:

;***********************************************************
;*	Additional Program Includes
;***********************************************************
.include "LCDDriver.asm"		; Include the LCD Driver

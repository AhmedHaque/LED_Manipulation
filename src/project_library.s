	.data

memory_for_read_str:.string "                 ",0

	.text
	.global uart_init
	.global tiva_init
	.global pwm_init
	.global timer_interrupt_init
	.global read_tiva_pushbutton
	.global illuminate_RGB_LED
	.global read_string
	.global output_string
	.global string2int
	.global read_character
	.global adc_init
U0FR: 	.equ 0x18	; UART0 Flag Register

ptr_to_readstr:			.word memory_for_read_str

pwm_init:
	PUSH {r4-r12, lr}
	MOV r5, #0xE000
    MOVT r5, #0x400F
	;Enable the clock for port F
	LDRB r6, [r5, #0x608] ;RCGCGPIO
	ORR r6, #32
	STRB r6, [r5, #0x608]

	MOV r5, #0x5000
    MOVT r5, #0x4002

	LDR r4, [r5, #0x420] ;Setting the GPIO AFSEL register as 1 to allow PWM control
	ORR r4, r4, #0xE
	STR r4, [r5, #0x420]

	LDR r4, [r5, #0x52C] ; GPIOPCTL
	MOV r3, #0x5550
	ORR r4, r4, r3
	STR r4, [r5, #0x52C]

	MOV r0, #0xE000
	MOVT r0, #0x400F ;change based on table on 1351

	LDR r4, [r0, #0x640] ;RCGCPWM for clock mode
	ORR r4, r4, #0x2
	STR r4, [r0, #0x640]

	LDR r4, [r0, #0x060] ; Setting Div value on the RCC in the System Control USEPWMDIV/PWMDIV
	MOV r5, #0x6000
	MOVT r5, #0x0001
	ORR r4, r4, r5
	STR r4, [r0, #0x060]

	MOV r0, #0x9000
	MOVT r0, #0x4002

	LDR r4, [r0, #0x0C0] ;PWM2CTL
	MOV r4, #0x0
	STR r4, [r0, #0x0C0]

	LDR r4, [r0, #0x100] ;PWM3CTL
	MOV r4, #0x0
	STR r4, [r0, #0x100]

	LDR r4, [r0, #0x0E4] ;PWM2GENB
	MOV r5, #0x40A
	ORR r4, r4, r5
	STR r4, [r0, #0x0E4]

	LDR r4, [r0, #0x120] ;PWM3GENA
	ORR r4, r4, #0x4A
	STR r4, [r0, #0x120]

	LDR r4, [r0, #0x124] ;PWM3GENB
	MOV r5, #0x40A
	ORR r4, r4, r5
	STR r4, [r0, #0x124]

	LDR r4, [r0, #0x0D0] ;PWM2LOAD
	MOV r5, #0x406
	ORR r4, r4, r5
	STR r4, [r0, #0x0D0]

	LDR r4, [r0, #0x110] ;PWM3LOAD
	MOV r5, #0x406
	ORR r4, r4, r5
	STR r4, [r0, #0x110]

	LDR r4, [r0, #0x0DC] ;PWM2CMPB RED
	ORR r4, r4, #(0xFF << 1)
	STR r4, [r0, #0x0DC]

	LDR r4, [r0, #0x118] ;PWM2CMPA BLUE
	ORR r4, r4, #(0xFF << 1)
	STR r4, [r0, #0x118]

	LDR r4, [r0, #0x11C] ;PWM3CMPB GREEN
	ORR r4, r4, #(0xFF << 1)
	STR r4, [r0, #0x11C]

	LDR r4, [r0, #0x0C0] ;PWM2CTL
	MOV r4, #0x1
	STR r4, [r0, #0x0C0]

	LDR r4, [r0, #0x100] ;PWM3CTL
	MOV r4, #0x1
	STR r4, [r0, #0x100]

	LDR r4, [r0, #0x008] ;PWMENABLE
	ORR r4, r4, #0xE0
	STR r4, [r0, #0x008]


	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

uart_init:
	;-----------------------------
	;Initializes the user UART for use
	;_____________________________
	PUSH {r4-r12,lr}	; Spill registers to stack

          ; Your code is placed here
	MOV r4, #0xE000
	MOVT r4, #0x400F
	LDR r5, [r4, #0x618] ;Provide clock to UART0
	ORR r5, r5, #1
	STR r5, [r4, #0x618]

	LDR r5, [r4, #0x608] ;Enable clock to PortA
	ORR r5, r5, #1
	STR r5, [r4, #0x608]

	MOV r4, #0xC000 ;Disable UART0 Control
	MOVT r4, #0x4000
	LDR r5, [r4, #0x30]
	AND r5, r5, #0
	STR r5, [r4, #0x30]

	 ;Set UART0_IBRD_R for 115,200 baud
	LDR r5, [r4, #0x24]
	ORR r5, r5, #8
	STR r5, [r4, #0x24]

	;Set UART0_FBRD_R for 115,200 baud
	LDR r5, [r4, #0x28]
	ORR r5, r5, #44
	STR r5, [r4, #0x28]

	;Use System Clock
	LDR r5, [r4, #0xFC8]
	AND r5, r5, #0
	STR r5, [r4, #0xFC8]

	;Use 8-bit word length, 1 stop bit, no parity
	LDR r5, [r4, #0x2C]
	ORR r5, r5, #0x60
	STR r5, [r4, #0x2C]

	;Enable UART0 Control
	LDR r5, [r4, #0x30]
	MOV r7, #0x301
	ORR r5, r5, r7
	STR r5, [r4, #0x30]

	MOV r4, #0x4000 ;Make PA0 and PA1 as Digital Ports
	MOVT r4, #0x4000
	LDR r5, [r4, #0x51C]
	ORR r5, r5, #0x03
	STR r5, [r4, #0x51C]

	LDR r5, [r4, #0x420] ;Change PA0,PA1 to Use an Alternate Function
	ORR r5, r5, #0x03
	STR r5, [r4, #0x420]

	LDR r5, [r4, #0x52C] ;Configure PA0 and PA1 for UART
	ORR r5, r5, #0x11
	STR r5, [r4, #0x52C]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr


tiva_init:
	;-----------------------------------------------
	;HELPER FUNCTION FOR gpio_btn_and_LED_init
	;_______________________________________________

	PUSH {r4-r12,lr}	; Spill registers to stack

	;-----------------------------
	;ENABLE THE CLOCK IN PORT F
	;_____________________________
	MOV r5, #0xE000
    MOVT r5, #0x400F
	;Enable the clock for port F
	LDRB r6, [r5, #0x608] ;RCGCGPIO
	ORR r6, #32
	STRB r6, [r5, #0x608]



	;-----------------------------
	;ENABLE THE PINS FOR IO IN PORT F
	;_____________________________
	MOV r5, #0x5000
	MOVT r5, #0x4002
	;Enabling the pins
	LDRB r6, [r5, #0x400]
	ORR r6, #0xE	;we set bits 1, 2, and 3 to 1 so that we set the rgb pins for output
	BIC r6, #0x30 ;we bitclear the 4th bit(starting from 0) so that it is 0 for input
	STRB r6, [r5, #0x400]

	;-----------------------------------------------
	;SETTING THE PINS FOR IO IN PORT F TO BE DIGITAL
	;_______________________________________________
	;r5 ALREADY has Port F's address in it!!!
	LDRB r6, [r5, #0x51C]
	ORR r6, #0x3E ;Setting all the bits to be 1 so they can be in digital mode
	STRB r6, [r5, #0x51C]

	; Enabling the Pull Up Resistor for the button.
	LDRB r6, [r5, #0x510]
	ORR r6, r6, #0x30
	STRB r6, [r5, #0x510]

	BL gpio_interrupt_init

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr


gpio_interrupt_init:

	; Your code to initialize the SW1 interrupt goes here
	; Don't forget to follow the procedure you followed in Lab #4
	; to initialize SW1.
	MOV r0, #0x5000
	MOVT r0, #0x4002 ; Port F address

	;If we want to enable Level Sensitivity we set bit 4 to 1
	;To enable Edge Sensitivity in SW1 we set bit 4 to 0
	LDRB r1, [r0, #0x404]
	AND r1, r1, #0x00
	STRB r1, [r0, #0x404]

	;If we want to enable both Edges Trigger we set bit 4 to 1
	;To enable GPIO Interrupt Event in SW1 we set bit 4 to 0
	LDRB r1, [r0, #0x408]
	AND r1, r1, #0x00
	STRB r1, [r0, #0x408]

	;To set high(rising edge) we set bit 4 to 1 (button release)
	;To set low(falling edge) we set bit 4 to 0 (Button Press)
	LDRB r1, [r0, #0x40C]
	AND r1, r1, #0x00
	STRB r1, [r0, #0x40C]

	;To enable interrupt we set bit 4 to 1
	;To disable interrupt we set bit 4 to 0
	LDRB r1, [r0, #0x410]
	ORR r1, r1, #0x30
	STRB r1, [r0, #0x410]

	MOV r0,#0xE000
	MOVT r0, #0xE000

	; Setting bit 5 in the processor to allow GPIO Port F interrupt
	LDR r1, [r0, #0x100]
	MOV r2, #0x0
	MOVT r2, #0x4000
	ORR r1, r1, r2
	STR r1, [r0, #0x100]

	MOV pc, lr

timer_interrupt_init:
	PUSH {r4-r12, lr}
	MOV r0, #0xE000
	MOVT r0, #0x400F

	LDRB r1, [r0, #0x604]
	ORR r1, r1, #0x1
	STRB r1, [r0, #0x604]

	MOV r0, #0x0000
	MOVT r0, #0x4003

	LDRB r1, [r0, #0x00C]
	BIC r1, r1, #0x1
	STRB r1, [r0, #0x00C]

	LDRB r1, [r0, #0x000]
	MOV r5, #0x7
	BIC r1, r1, r5
	STRB r1, [r0, #0x000]

	LDRB r1, [r0, #0x004]
	ORR r1, r1, #0x2
	STRB r1, [r0, #0x004]

	MOV r1, #0xF8
	STR r1, [r0, #0x028]

	LDRB r1, [r0, #0x018]
	ORR r1, r1, #0x1
	STRB r1, [r0, #0x018]

	MOV r0, #0xE000
	MOVT r0, #0xE000

	LDR r1, [r0, #0x100]
	MOV r2, #0x0000
	MOVT r2, #0x0008
	ORR r1, r1, r2
	STR r1, [r0, #0x100]

	MOV r0, #0x0000
	MOVT r0, #0x4003

	LDRB r1, [r0, #0x00C]
	ORR r1, r1, #0x1
	STRB r1, [r0, #0x00C]

	POP {r4-r12, lr}
	MOV pc, lr

read_tiva_pushbutton:
	;---------------------------------------------------------------------------
	;Reads from the momentary push button (SW1) on the Tiva board, and
	;returns a one (1) in r0 if the button is currently being pressed
	;, and a zero (0) if it is not.
	;___________________________________________________________________________

	PUSH {r4-r12,lr}	; Spill registers to stack

	;Port F's address
	MOV r5, #0x5000
	MOVT r5, #0x4002


	;READ from data register to see when button is pushed
	LDRB r6, [r5, #0x3FC]
	AND r6, r6, #0x30
	EOR r0, r6, #0x11 ; When this bit is 0, the button is being pressed
	CMP r0, #0x10
	BEQ set_to_one
	EOR r0, r6, #0x1
	CMP r0, #0x1
	BEQ set_to_two

set_to_zero:
	MOV r0, #0
	B end_of_tiva

set_to_one:
	MOV r0, #1
	B end_of_tiva

set_to_two:
	MOV r0, #2
						;when this bit is 1, the button is not being pressed
end_of_tiva:			;we will return a 1 into r0 if the button is being pressed
						;and we will return a 0 into r0 if the button is not being pressed
	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr


illuminate_RGB_LED:
	;---------------------------------------------------------------------------
	;Illuminates the RBG LED on the TIVA board. The color to be displayed is
	;passed into the routine in r0 as such:
	;	0 -> OFF
	;	1 -> Red
	;	2 -> Green
	;	3 -> Blue
	;	4 -> Purple
	;	5 -> Yellow
	;	6 -> White
	; Port F, Pin 1 - Red, Pin 2 - Blue, Pin 3 - Green
	; Port F address: 0x40025000
	;___________________________________________________________________________

	PUSH {r4-r12,lr}	; Spill registers to stack

	;r10 is where we will put the color choice
	MOV r10, #0

	;OFF
	CMP r0, #0
	BEQ TURN_ON_LIGHTS

	;RED
	CMP r0, #1
	BEQ SET_RED

	;GREEN
	CMP r0, #2
	BEQ SET_GREEN

	;BLUE
	CMP r0, #3
	BEQ SET_BLUE

	;PURPLE
	CMP r0, #4
	BEQ SET_PURPLE

	;YELLOW
	CMP r0, #5
	BEQ SET_YELLOW

	;WHITE
	CMP r0, #6
	BEQ SET_WHITE

	;IF NO COLOR IS CHOSEN,
	;WE WILL DEFAULT TO WHITE
	B SET_WHITE

SET_RED:
	;Turning on RED pin to make RED
	MOV r10, #0x2
	B TURN_ON_LIGHTS

SET_GREEN:
	;Turning on GREEN pin to make GREEN
	MOV r10, #0x8
	B TURN_ON_LIGHTS

SET_BLUE:
	;Turning on BLUE pin to make BLUE
	MOV r10, #0x4
	B TURN_ON_LIGHTS

SET_PURPLE:
	;Turning on RED and BLUE pin to make PURPLE
	MOV r10, #0x6
	B TURN_ON_LIGHTS

SET_YELLOW:
	;Turning on RED and GREEN pin to make YELLOW
	MOV r10, #0xA
	B TURN_ON_LIGHTS

SET_WHITE:
	;Turning on RED and GREEN and BLUE pin to make WHITE
	MOV r10, #0xE
	B TURN_ON_LIGHTS



TURN_ON_LIGHTS:
	;Port F's address
	MOV r5, #0x5000
	MOVT r5, #0x4002

    LDRB r6, [r5, #0x3FC]
	BIC r6, #0xE ;I BIT CLEAR HERE IN CASE A BIT THAT NEEDS
				;TO BE 0 HAS BEEN PREVIOUSLY SET TO 1

	ORR r6, r6, r10 ; SETTING THE PINS FOR GPIO DATA REGISTER USE
	STRB r6, [r5, #0x3FC]

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

output_character:
	;---------------------------------------------------------------------------
	;Transmits a character passed into the routine in r0 to PuTTy via the UART.
	;___________________________________________________________________________
	PUSH {r4-r12,lr}	; Spill registers to stack

	MOV r5, #0xC000
	MOVT r5, #0x4000

load_r1: LDRB r1, [r5, #U0FR]
	MOV r3, #32 ; this is so we can do the masking on bit #5,
	MOV r4, #0
	AND r4, r1, r3	;AND r1 and r3 and store result in r4, if r4 is 32 that means
					; mask bit(bit #5)is 1 and not 0, if it is 0 that means r4 = 0 and we are good to write

	CMP r4, #32
	BEQ load_r1 ; redo loop until mask bit is 0

	STRB r0, [r5]

	;0x4000C000 is the base address

          ; Your code is placed here

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr

output_string:
    ;-------------------------------------------------------------------------------------------------
    ;Displays a null-terminated string in PuTTy. The base address of the string should be
    ;passed into the routine in r0.
    ;__________________________________________________________________________________________________


    PUSH {r4-r12,lr}    ; Spill registers to stack

          ; Your code is placed here
    MOV r10, r0 ;put r0 in r10 cuz r0 changes with output_character
    MOV r11, #0  ;offset counter
outputting: LDRB r8, [r10, r11]
    CMP r8, #0x00 ;Compare with NULL
    BEQ end_output_string
    MOV r0, r8
    BL output_character
    ADD r11, r11, #1
    B outputting

end_output_string:


    MOV r0, r10 ;put r0 back cuz why not.

    POP {r4-r12,lr}      ; Restore registers from stack
    MOV pc, lr

read_character:
	;---------------------------------------------------------------------------
	;Reads a character from PuTTy via the UART, and returns the character in r0.
	;___________________________________________________________________________
	PUSH {r4-r12,lr}	; Spill registers to stack

	MOV r5, #0xC000
	MOVT r5, #0x4000

read_bro: LDRB r1, [r5, #U0FR]
	MOV r3, #16 ; this is so we can do the masking on bit #4,
	MOV r4, #0
	AND r4, r1, r3	;AND r1 and r3 and store result in r4, if r4 is 16 that means
					; mask bit(bit #4)is 1 and not 0, if it is 0 that means r4 = 0 and we are good to write

	CMP r4, #16
	BEQ read_bro ; redo loop until mask bit is 0

	LDRB r0, [r5]
		; Your code to receive a character obtained from the keyboard
		; in PuTTy is placed here.  The character is returned in r0.

	POP {r4-r12,lr}  	; Restore registers from stack
	MOV pc, lr


read_string:
    ;-------------------------------------------------------------------------------------------------
    ;Reads a string entered in PuTTy and stores it as a null-terminated string in memory.
    ;The user terminates the string by hitting Enter. The base address of the string should be passed
    ;into the routine in r0. The carriage return should NOT be stored in the string.
    ;__________________________________________________________________________________________________

    PUSH {r4-r12,lr}    ; Spill registers to stack

          ; Your code is placed here
    BL free_memory_for_read_str
    MOV r10, r0 ;put r0 in r10 cuz r0 changes with read_character and output_character
    MOV r11, #0
reading:
    BL read_character
    CMP r0, #13 ;Carriage Return
    BEQ end_read_string
    BL output_character


    STRB r0, [r10, r11]
    ADD r11, r11, #1
    B reading

end_read_string:
    MOV r0, #0x0A
    BL output_character
    MOV r0, #0x0D
    BL output_character


    MOV r0, #0x00
    STRB r0, [r10, r11]

    MOV r0, r10 ;put r0 back

    POP {r4-r12,lr}      ; Restore registers from stack
    MOV pc, lr

free_memory_for_read_str:
    PUSH {r4-r12,lr}

    LDR r0, ptr_to_readstr
    MOV r4, #0
    MOV r5, #17

clear_loop:
    STRB r4, [r0], #1
    SUB r5, r5, #1
    CMP r5, #0
    BNE clear_loop

    POP {r4-r12,lr}
    MOV pc, lr

string2int:
	PUSH {r4-r12,lr} 	; Store any registers in the range of r4 through r12
				; that are used in your routine.  Include lr if this
				; routine calls another routine.

		; Your code for your string2int routine is placed here
	MOV r1, #0
	MOV r8, #0
	MOV r10, #10 ;storing 10 in r10 as we cannot use immediate values for MUL

MainStringInt: LDRB r5, [r0, r1]
	CMP r5, #0x00
	BEQ END ;If NULL END THE PROGRAM
	CMP r5, #44
	BEQ COMMACHECKER ;MAKE SURE TO SKIP THE COMMA

	SUB r2, r5, #0x30 ;r2 has the number we just turned into an int

	ADD r8, r8, r2 	  ;r8 has the total number

	;now we have to check if there is a number after the one we
	; just loaded so we know if we have to multiply r8 by 10
	ADD r1, r1, #1 ;Increment our counter by 1 to see what is ahead
					; so that we can know if we need to multiply r8 by 10

	LDRB r5, [r0, r1]
	CMP r5, #0x00
	BEQ MainStringInt  ;If NULL Dont multiple by 10

	MUL r8, r8, r10
	B MainStringInt

END: MOV r0, r8
	POP {r4-r12,lr}   	; Restore registers all registers preserved in the
				; PUSH at the top of this routine from the stack.
	mov pc, lr


; Additional subroutines may be included here
COMMACHECKER:
	ADD r1, r1, #1
	B MainStringInt


adc_init:
	PUSH {r4-r12, lr}

	; Set ADC Clock - RCGCADC
	MOV r1, #0xE000
	MOVT r1, #0x400F
	MOV r0, #0x01
	STRB r0, [r1, #0x638]
	; Set GPIO Clock - RCGCGPIO
	MOV r0, #0x10			; Enable Clock for Ports E
	STRB r0, [r1, #0x608]
	; GPIO Alternate Function - GPIOAFSEL
	MOV r1, #0x4000   		; Port E
	MOVT r1, #0x4002
	LDRB r0, [r1, #0x420]	; Alternate Select
	ORR r0, r0, #0x04		; PE2 Alt
	STRB r0, [r1, #0x420]
	; GPIO Digital Enable - GPIODEN
	LDRB r0, [r1, #0x51C]	; Digital Enable
	BIC r0, r0, #0x04		; PE2
	STRB r0, [r1, #0x51C]
	; GPIO Analog Mode Select - GPIOAMSEL
	LDRB r0, [r1, #0x528]	; Analog Mode Select
	ORR r0, r0, #0x4
	STRB r0, [r1, #0x528]

	; ADC Active Sample Sequencer - ADCACTSS
	MOV r1, #0x8000
	MOVT r1, #0x4003
	LDRB r0, [r1, #0x0]
	BIC r0, r0, #0x08		; Disable SS3
	STRB r0, [r1, #0x0]
	; ADC Event Multiplexer Select - ADCEMUX
	LDR r0, [r1, #0x14]
	MOV r0, #0xF000 		; Cont Select
	STR r0, [r1, #0x14]
	; ADC Sample Seq Input Mux Select 3 - ADCSSMUX3
	LDRB r0, [r1, #0xA0]
	MOV r0, #0x01 			; Pin AIN1
	STRB r0, [r1, #0xA0]
	; ADC Sample Seq Control 3 - ADCSSCTL3
	LDRB r0, [r1, #0xA4]
	ORR r0, r0, #0x4
	STRB r0, [r1, #0xA4]
	; ADC Sample Average Control - ADCSAC
	MOV r0, #0x6
	STRB r0, [r1, #0x30]
	; ADC Active Sample Sequencer - ADCACTSS
	LDRB r0, [r1, #0x0]
	ORR r0, r0, #0x8
	STRB r0, [r1, #0x0]

	POP {r4-r12, lr}
	mov pc, lr

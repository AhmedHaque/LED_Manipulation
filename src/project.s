	.data

red_value:		.byte 0x00
green_value:	.byte 0x00
blue_value:		.byte 0x00
red_counter:	.byte 0x00
green_counter:	.byte 0x00
blue_counter:	.byte 0x00
button_counter: .byte 0x00

red_value_selection:	.string 0xC, "Updated Red", 0xA, 0xD,0
green_value_selection:	.string "Updated Green", 0xA, 0xD,0
blue_value_selection:	.string "Updated Blue", 0xA, 0xD,0
quit:					.string "Bye", 0xA, 0xD,0
red:					.space 256
green:					.space 256
blue:					.space 256
quitted:				.space 256

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
	.global Advanced_RGB_LED
	.global read_character
	.global Switch_Handler
	.global adc_init

ptr_to_button_counter:	.word button_counter
ptr_to_red_value: 		.word red_value
ptr_to_green_value:		.word green_value
ptr_to_blue_value:		.word blue_value
ptr_to_red: 			.word red
ptr_to_green:			.word green
ptr_to_blue:			.word blue
ptr_to_red_counter:		.word red_counter
ptr_to_green_counter:	.word green_counter
ptr_to_blue_counter:	.word blue_counter
ptr_to_quit:			.word quit
ptr_to_quitted:			.word quitted

ptr_to_red_value_selection:		.word red_value_selection
ptr_to_green_value_selection:	.word green_value_selection
ptr_to_blue_value_selection:	.word blue_value_selection

Advanced_RGB_LED:
	PUSH {lr}
	BL uart_init
	BL pwm_init
	BL adc_init
	BL tiva_init
Advanced_RGB_LED_loop:
	LDR r5, ptr_to_button_counter
	LDRB r4,[r5]
	CMP r4, #0
	BEQ red_setting

	CMP r4, #1
	BEQ blue_setting

	CMP r4, #2
	BEQ green_setting
looper:
	BL poll_adc
	B Advanced_RGB_LED_loop


ending:
	LDR r0, ptr_to_quit
	BL output_string


	POP {r4-r12, lr}
	MOV pc, lr


red_setting:
	MOV r1, #0x9000
	MOVT r1, #0x4002

	;PWM2CMPB RED
	LSR r0, r0, #4
	STR r0, [r1, #0x0DC]

	LDR r0, ptr_to_red_value_selection
	BL output_string

	B looper

blue_setting:
	MOV r1, #0x9000
	MOVT r1, #0x4002

	;PWM2CMPB BLUE
	LSR r0, r0, #4
	STR r0, [r1, #0x118]

	LDR r0, ptr_to_blue_value_selection
	BL output_string

	B looper

green_setting:
	MOV r1, #0x9000
	MOVT r1, #0x4002

	;PWM2CMPB GREEN
	LSR r0, r0, #4
	STR r0, [r1, #0x11C]

	LDR r0, ptr_to_green_value_selection
	BL output_string

	B looper

poll_adc:
    PUSH {r4-r12, lr}
	; Will return result in r0
	MOV r1, #0x8000
	MOVT r1, #0x4003		; ADC0 Base
	; ADC Processor Sample Sequence Initiate - ADCPSSI
	LDRB r0, [r1, #0x28]
	ORR r0, r0, #0x8		; SS3 Initiate
	STRB r0, [r1, #0x28]

loop_adc:
	LDRB r0, [r1, #0x4]
	AND r0, r0, #0x08			; Check for bit 3
	CMP r0, #0x0
	BEQ loop_adc			; Not cleared

	; ADC Sample Sequence Result FIFO 3 - ADCSSFIFO3
	LDRH r0, [r1, #0x0A8]
	BIC r0, r0, #0xF000		; Clear last 4 bits

	LDRB r2, [r1, #0xC]
	ORR r2, r2, #0x8
	STRB r2, [r1, #0xC]

	POP {r4-r12, lr}
	MOV pc, lr

Switch_Handler:

	; Your code for your GPIO handler goes here.
	; Remember to preserver registers r4-r12 by pushing then popping
	; them to & from the stack at the beginning & end of the handler
	PUSH {r4-r12, lr}
	MOV r0, #0x5000
	MOVT r0, #0x4002

	LDRB r1, [r0, #0x41C] ; Clear Interrupt
	ORR r1, #0x10
	STRB r1, [r0, #0x41C]

	BL read_tiva_pushbutton
	CMP r0, #0x1
	BEQ end_SW1_handler

	CMP r0, #0x2
	BEQ ending

end_SW1_handler:
	LDR r1, ptr_to_button_counter
	LDRB r0, [r1]
	CMP r0, #2
	ITE EQ
	MOVEQ r0, #0
	ADDNE r0, #1

	STRB r0, [r1]

	POP {r4-r12, lr}
	BX lr       	; Return

	.end

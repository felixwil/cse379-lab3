	.data

	.global prompt
	.global results
	.global num_1_string
	.global num_2_string

prompt0:	.string "This program calculates the average of two numbers.", 0
prompt:	.string "input the first number and press enter: ", 0
prompt2:	.string "input the second number and press enter: ", 0
prompt3:	.string "The average of the numbers: ", 0
prompt4:	.string "continue? (q) ", 0
quitresult:	.string "continue? (q) ", 0
result:	.string "Your results are reported here: ", 0
num_1_string: 	.string "Place holder string for your first number", 0
num_2_string:  	.string "Place holder string for your second number", 0

	.text

	.global lab3
U0FR: 	.equ 0x18	; UART0 Flag Register

ptr_to_prompt0:		.word prompt0
ptr_to_prompt:		.word prompt
ptr_to_prompt2:		.word prompt2
ptr_to_prompt3:		.word prompt3
ptr_to_prompt4:		.word prompt4
ptr_to_quitresult:		.word quitresult
ptr_to_result:		.word result
ptr_to_num_1_string:	.word num_1_string
ptr_to_num_2_string:	.word num_2_string

lab3:
	PUSH {lr}   ; Store lr to stack
	ldr r4, ptr_to_prompt
	ldr r5, ptr_to_result
	ldr r6, ptr_to_num_1_string
	ldr r7, ptr_to_num_2_string

	BL uart_init

	ldr r4, ptr_to_prompt0
 	MOV r0, r4
 	BL output_string
	ldr r4, ptr_to_prompt

	MOV r0, r4
	BL output_string

	MOV r0, r6
	BL read_string

	MOV r0, r6
	BL string2int

	MOV r10, r0

	ldr r4, ptr_to_prompt2
 	MOV r0, r4
 	BL output_string
	ldr r4, ptr_to_prompt

	MOV r0, r6
	BL read_string

	MOV r0, r6
	BL string2int

	MOV r11, r0

	ADD r0, r10, r11
	ASR r0, r0, #1

	MOV r1, r5
	BL int2string

	ldr r4, ptr_to_prompt3
 	MOV r0, r4
 	BL output_string
	ldr r4, ptr_to_prompt

	MOV r0, r5
	BL output_string

	ldr r4, ptr_to_prompt4
 	MOV r0, r4
 	BL output_string
	ldr r4, ptr_to_prompt

	BL read_character

	CMP r0, #0x71 ; 'q'
	BNE lab3

	POP {lr}	  ; Restore lr from stack
	mov pc, lr

read_string:
	PUSH {lr}   ; Store register lr on stack

	MOV r1, r0

readstringloop:
	BL read_character
	BL output_character

	CMP r0, #0x0d
	BEQ exitreadstring

	STRB r0, [r1]
	ADD r1, r1, #1

	B readstringloop

exitreadstring:

	MOV r0, #0x0a
	BL output_character

	MOV r0, #0
	STRB r0, [r1]

	POP {lr}
	mov pc, lr


output_string:
	PUSH {lr}   ; Store register lr on stack

	MOV r1, r0

outputstringloop:
	LDRB r0, [r1]

	CMP r0, #0
	BEQ exitoutputstring

	BL output_character

	ADD r1, r1, #1

	B outputstringloop

exitoutputstring:

	MOV r0, #0x0d
	BL output_character
	MOV r0, #0x0a
	BL output_character

	POP {lr}
	mov pc, lr

read_character:
	PUSH {lr}   ; Store register lr on stack

	MOV r9, r7

checkread:
	MOV r7, #0xC018 ; r7 = checkaddr
	MOVT r7, #0x4000
	LDRB r3, [r7]
	AND r3, r3, #0x10
	CMP r3, #0
	BGT checkread

	MOV r8, #0xC000
	MOVT r8, #0x4000
	LDRB r0, [r8]

	MOV r7, r9

	POP {lr}
	mov pc, lr


output_character:
	PUSH {lr}   ; Store register lr on stack

	MOV r9, r7

checkdisplay:
	MOV r7, #0xC018 ; r7 = checkaddr
	MOVT r7, #0x4000
	LDRB r3, [r7]
	AND r3, r3, #0x20
	CMP r3, #0
	BGT checkdisplay

	MOV r8, #0xC000
	MOVT r8, #0x4000
	STRB r0, [r8]

	MOV r7, r9

	POP {lr}
	mov pc, lr


uart_init:
	PUSH {lr}  ; Store register lr on stack

	MOV r0, #0xe618
	MOVT r0, #0x400f
	MOV r1, #1
	STRW r1, [r0]

	MOV r0, #0xe608
	MOVT r0, #0x400f
	MOV r1, #1
	STRW r1, [r0]

	MOV r0, #0xc030
	MOVT r0, #0x4000
	MOV r1, #0
	STRW r1, [r0]

	MOV r0, #0xc024
	MOVT r0, #0x4000
	MOV r1, #8
	STRW r1, [r0]

	MOV r0, #0xc028
	MOVT r0, #0x4000
	MOV r1, #44
	STRW r1, [r0]

	MOV r0, #0xcfc8
	MOVT r0, #0x4000
	MOV r1, #0
	STRW r1, [r0]

	MOV r0, #0xc02c
	MOVT r0, #0x4000
	MOV r1, #0x60
	STRW r1, [r0]

	MOV r0, #0xc030
	MOVT r0, #0x4000
	MOV r1, #0x0301
	STRW r1, [r0]

	MOV r0, #0x451c
	MOVT r0, #0x4000
	LDRB r1, [r0]
	ORR r1, r1, #0x03
	STRW r1, [r0]

	MOV r0, #0x4420
	MOVT r0, #0x4000
	LDRB r1, [r0]
	ORR r1, r1, #0x03
	STRW r1, [r0]

	MOV r0, #0x452c
	MOVT r0, #0x4000
	LDRB r1, [r0]
	ORR r1, r1, #0x11
	STRW r1, [r0]

	POP {lr}
	mov pc, lr

int2string:
	PUSH {lr}   ; Store register lr on stack

	;ADD r1, r1, #6

	MOV r9, r4
	MOV r10, r5
	MOV r11, r6

	MOV r5, #10
	MOV r6, r0
	MOV r2, #0

charactercounterloop:

  	ADD r2, r2, #1;  increment i
  	SDIV r6, r6, r5; number //= 10 (floor divide by 10)

  	CMP r6, #0;
  	BGT charactercounterloop; return to the top

  	ADD r1, r1, r2
  	SUB r1, r1, #1
  	STRB r6, [r1, #1]

nextplace:

	MOV r4, r0
  	sdiv r2, r4, r5
	mul r3, r2, r5 ; r4 %= 10
	sub r4, r4, r3

	ADD r4, r4, #0x30
	STRB r4, [r1]
	SUB r1, r1, #1
	MOV r11, #10
	SDIV r0, r0, r11

	CMP r0, #0
	BNE nextplace

	MOV r4, r9
	MOV r5, r10
	MOV r6, r11

	POP {lr}
	mov pc, lr


string2int:
	PUSH {lr}   ; Store register lr on stack

	;SUB r1, r1, #6

	MOV r2, #0

nextload:
	LDRB r1, [r0]
	CMP r1, #0x0
	BEQ exitstring1intloop

	MOV r11, #10
	MUL r2, r2, r11   ; r2 *= 10
	SUB r3, r1, #0x30 ; r2 = r1-'0'
	ADD r2, r2, r3

	ADD r0, r0, #1

	B nextload
exitstring1intloop:

	MOV r0, r2

	POP {lr}
	mov pc, lr

	.end



	/*
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

output_character:
	PUSH {lr}   ; Store register lr on stack

checkdisplay:
	MOV r7, #0xC018 ; r7 = checkaddr
	MOVT r7, #0x4000
	LDRB r3, [r7]
	AND r3, r3, #0x20
	CMP r3, #0
	BGT checkdisplay

	MOV r8, #0xC000
	MOVT r8, #0x4000
	STRB r0, [r8]
		; Your code to output a character to be displayed in PuTTy
		; is placed here.  The character to be displayed is passed
		; into the routine in r0.

	POP {lr}
	mov pc, lr



read_character:
	PUSH {lr}   ; Store register lr on stack

		; Your code to receive a character obtained from the keyboard
		; in PuTTy is placed here.  The character is received in r0.

checkread:
	MOV r7, #0xC018 ; r7 = checkaddr
	MOVT r7, #0x4000
	LDRB r3, [r7]
	AND r3, r3, #0x10
	CMP r3, #0
	BGT checkread

	MOV r8, #0xC000
	MOVT r8, #0x4000
	LDRB r0, [r8]

	POP {lr}
	mov pc, lr


	.end
	*/

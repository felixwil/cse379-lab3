	.data

	.global prompt
	.global results
	.global num_1_string
	.global num_2_string

prompt0:	.string "This program calculates the average of two numbers.", 0 ; instructing the user about the purpose of the program
prompt:	.string "input the first number and press enter: ", 0 ; asking for the first number
prompt2:	.string "input the second number and press enter: ", 0 ; asking for second
prompt3:	.string "The average of the numbers: ", 0 ; telling the user what the output means
prompt4:	.string "continue? (q) ", 0 ; asking the user if they want to continue the program or exit
quitresult:	.string "continue? (q)", 0 ; result of prompt4 input (deprecated/unused)
result:	.string "Your results are reported here: ", 0 ; storing the result of the calculations here as a string
num_1_string: 	.string "Place holder string for your first number", 0 ; result storage for 1st number as string
num_2_string:  	.string "Place holder string for your second number", 0 ; result storage for 2nd number as string

	.text

	.global lab3
U0FR: 	.equ 0x18	; UART0 Flag Register

; instantiating pointers to each of the above strings
ptr_to_prompt0:		.word prompt0
ptr_to_prompt:		.word prompt
ptr_to_prompt2:		.word prompt2
ptr_to_prompt3:		.word prompt3
ptr_to_prompt4:		.word prompt4
ptr_to_quitresult:		.word quitresult ; (deprecated/unused)
ptr_to_result:		.word result
ptr_to_num_1_string:	.word num_1_string
ptr_to_num_2_string:	.word num_2_string

lab3:
	PUSH {lr}   ; Store lr to stack
	ldr r4, ptr_to_prompt
	ldr r5, ptr_to_result
	ldr r6, ptr_to_num_1_string
	ldr r7, ptr_to_num_2_string

	; branch & link to our uart_init method
	BL uart_init

	; saving r4 so we don't break things
	; we just use r4 a lot as a reg to swap str pointers into
	ldr r4, ptr_to_prompt0 ; this prompt tells the user what the program does
 	MOV r0, r4
 	BL output_string
	ldr r4, ptr_to_prompt
	; restoring saved pointer to r4

	; prompt user for the first number
	MOV r0, r4
	BL output_string

	; read in their response
	MOV r0, r6
	BL read_string

	; convert it to an integer
	MOV r0, r6
	BL string2int

	; store the user's integer in r10
	MOV r10, r0

	; prompt user for the second number
	; we have to save the pointers again
	ldr r4, ptr_to_prompt2
 	MOV r0, r4
 	BL output_string
	ldr r4, ptr_to_prompt ; restore the pointer

	; read in their second number
	MOV r0, r6
	BL read_string

	; convert to int again
	MOV r0, r6
	BL string2int

	; save the second number in r11
	MOV r11, r0

	; add them together and divide by 2 to take the average
	ADD r0, r10, r11
	ASR r0, r0, #1

	; convert the result of the calculation back into a string
	MOV r1, r5 ; r5 is the char buffer for the result
	BL int2string

	; telling the user what the outputted number is
	ldr r4, ptr_to_prompt3
 	MOV r0, r4
 	BL output_string
	ldr r4, ptr_to_prompt

	; finally outputting the string buffer stored in r5
	; this contains the stringified result of the calculations
	MOV r0, r5
	BL output_string

	; save pointers and prompt the user if they want to continue or not
	ldr r4, ptr_to_prompt4
 	MOV r0, r4
 	BL output_string
	ldr r4, ptr_to_prompt

	; if the user presses q the program will exit.
	; the user doesn't need to press enter
	BL read_character

	CMP r0, #0x71 ; 'q'
	BNE lab3 ; if they didn't want to quit go back to the top.

	POP {lr}	  ; Restore lr from stack
	mov pc, lr

read_string:
	PUSH {lr}   ; Store register lr on stack

	MOV r1, r0 ; copying the pointer

readstringloop:
	BL read_character ; read a character
	BL output_character
	; output the character immediately so the user can see what they're typing

	CMP r0, #0x0d ; exit if the user hits enter
	BEQ exitreadstring

	STRB r0, [r1]  ; write the character to the string buffer
	ADD r1, r1, #1 ; increment the point

	B readstringloop ; go up

exitreadstring:

	; newline for formatting
	; carriage return has already been outputted above, so we don't need to do that.
	MOV r0, #0x0a
	BL output_character

	MOV r0, #0 ; add the null char
	STRB r0, [r1]

	POP {lr}
	mov pc, lr


output_string:
	PUSH {lr}   ; Store register lr on stack

	MOV r1, r0 ; copying the pointer

outputstringloop:
	LDRB r0, [r1] ; getting the char at the pointer (ptr[0])

	CMP r0, #0 ; if the char is null char, exit
	BEQ exitoutputstring

	BL output_character ; call the output char function to transmit r0 over uart

	ADD r1, r1, #1 ; increment char pointer

	B outputstringloop ; go back up

exitoutputstring:

	; outputting '\r\n' to make formatting nicer
	MOV r0, #0x0d
	BL output_character
	MOV r0, #0x0a
	BL output_character

	POP {lr}
	mov pc, lr

read_character:
	PUSH {lr}   ; Store register lr on stack

	MOV r9, r7 ; save reg

checkread:
	MOV r7, #0xC018 ; r7 = checkaddr
	MOVT r7, #0x4000
	LDRB r3, [r7]     ; r3 = r7[0]
	AND r3, r3, #0x10 ; bit twiddling
	CMP r3, #0
	BGT checkread

	MOV r8, #0xC000
	MOVT r8, #0x4000
	LDRB r0, [r8] ; r0 = (r8 = 0x4000C000)[0]

	MOV r7, r9 ; restore saved reg

	POP {lr}
	mov pc, lr


output_character:
	PUSH {lr}   ; Store register lr on stack

	MOV r9, r7 ; saving reg

checkdisplay:
	MOV r7, #0xC018   ; r7 = checkaddr
	MOVT r7, #0x4000
	LDRB r3, [r7] 	  ; r3 = r7[0]
	AND r3, r3, #0x20 ; bit twiddling
	CMP r3, #0
	BGT checkdisplay

	MOV r8, #0xC000
	MOVT r8, #0x4000
	STRB r0, [r8] ; (r8 = 0x4000C000)[0] = r0

	MOV r7, r9 ; restore saved reg

	POP {lr}
	mov pc, lr


uart_init:
	PUSH {lr}  ; Store register lr on stack

	; copied comments from lab3wrapper.c obviously

    /* Provide clock to UART0  */
	; (*((volatile uint32_t *)(0x400FE618))) = 1;
	MOV r0, #0xe618
	MOVT r0, #0x400f
	MOV r1, #1
	STRW r1, [r0]

	/* Enable clock to PortA  */
	; (*((volatile uint32_t *)(0x400FE608))) = 1;
	MOV r0, #0xe608
	MOVT r0, #0x400f
	MOV r1, #1
	STRW r1, [r0]

	/* Disable UART0 Control  */
	; (*((volatile uint32_t *)(0x4000C030))) = 0;
	MOV r0, #0xc030
	MOVT r0, #0x4000
	MOV r1, #0
	STRW r1, [r0]
	
	/* Set UART0_IBRD_R for 115,200 baud */
	; (*((volatile uint32_t *)(0x4000C024))) = 8;
	MOV r0, #0xc024
	MOVT r0, #0x4000
	MOV r1, #8
	STRW r1, [r0]

	/* Set UART0_FBRD_R for 115,200 baud */
	; (*((volatile uint32_t *)(0x4000C028))) = 44;
	MOV r0, #0xc028
	MOVT r0, #0x4000
	MOV r1, #44
	STRW r1, [r0]

	/* Use System Clock */
	; (*((volatile uint32_t *)(0x4000CFC8))) = 0;
	MOV r0, #0xcfc8
	MOVT r0, #0x4000
	MOV r1, #0
	STRW r1, [r0]

	/* Use 8-bit word length, 1 stop bit, no parity */
	; (*((volatile uint32_t *)(0x4000C02C))) = 0x60;
	MOV r0, #0xc02c
	MOVT r0, #0x4000
	MOV r1, #0x60
	STRW r1, [r0]

	/* Enable UART0 Control  */
	; (*((volatile uint32_t *)(0x4000C030))) = 0x301;
	MOV r0, #0xc030
	MOVT r0, #0x4000
	MOV r1, #0x0301
	STRW r1, [r0]

	/* Make PA0 and PA1 as Digital Ports  */
	; (*((volatile uint32_t *)(0x4000451C))) |= 0x03;
	MOV r0, #0x451c
	MOVT r0, #0x4000
	LDRB r1, [r0]
	ORR r1, r1, #0x03
	STRW r1, [r0]

	/* Change PA0,PA1 to Use an Alternate Function  */
	; (*((volatile uint32_t *)(0x40004420))) |= 0x03;
	MOV r0, #0x4420
	MOVT r0, #0x4000
	LDRB r1, [r0]
	ORR r1, r1, #0x03
	STRW r1, [r0]

	/* Configure PA0 and PA1 for UART  */
	; (*((volatile uint32_t *)(0x4000452C))) |= 0x11;
	MOV r0, #0x452c
	MOVT r0, #0x4000
	LDRB r1, [r0]
	ORR r1, r1, #0x11
	STRW r1, [r0]

	POP {lr}
	mov pc, lr

int2string:
	PUSH {lr}   ; Store register lr on stack

	; r0: int, r1: char*

	MOV r9, r4
	MOV r10, r5 ; saving registers that will be overwritten into higher registers
	MOV r11, r6

	MOV r5, #10
	MOV r6, r0  ; initialising variables & constants.  We don't want to change r0 yet so we copy that
	MOV r2, #0

charactercounterloop:

  	ADD r2, r2, #1;  increment i
  	SDIV r6, r6, r5; number //= 10 (floor divide by 10)

  	CMP r6, #0 ; if r6 is now 0 (we've checked all decimal digits)
  	BGT charactercounterloop; return to the top

	; we have to shift the pointer in the character buffer by 
	; the size of the number and then count backwards
  	ADD r1, r1, r2
  	SUB r1, r1, #1 ; shift back by 1 to correct for off by 1 error
  	STRB r6, [r1, #1] ; putting a null character at the end before we go backwards

nextplace:
	; modulo code {
	MOV r4, r0
  	sdiv r2, r4, r5
	mul r3, r2, r5 ; r4 %= 10
	sub r4, r4, r3
	; }

	; converting r4 from 0-9 to an ascii char '0'-'9'
	; 0x30 == '0' etc
	ADD r4, r4, #0x30
	STRB r4, [r1]  ; storing into the buffer
	SUB r1, r1, #1 ; decrementing the pointer (because the digits are read in reverse)
	MOV r11, #10
	SDIV r0, r0, r11
	; could've just used r5 again instead of r11 I guess but I'm not going to change
	; without being able to test in lab (commenting at home)

	CMP r0, #0 ; same loop condition as above.  (r0 // 10) == 0 means we've exhausted all digits
	BNE nextplace ; go back up

	MOV r4, r9
	MOV r5, r10 ; restoring used registers
	MOV r6, r11

	POP {lr} ; returning
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

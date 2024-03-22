; Lab: M09 Console Input Output
; Course: CIS 261
; File: m09.asm

.386					; Tells MASM to use Intel 80386 instruction set.
.MODEL FLAT				; Flat memory model
option casemap:none		; Treat labels as case-sensitive

EXTERN _Beep@8:NEAR
EXTERN _GetLastError@0:NEAR
EXTERN _Sleep@4:NEAR

INCLUDE IO.H						; header file for input/output

.CONST								; Constant data segment
	DEFAULT_BASE_FREQ		EQU		80			; initial base frequence (for testing)
	DEFAULT_FREQ_ARRAY_SIZE EQU		9			; how many max beeps possible
	DEFAULT_FREQ			EQU		240			; milliseconds
	LOWER_Y_DEC				EQU		121			; decimal of lowercase y in ascii

	QUES_BEEP_COUNT			BYTE	"How many beeps would you like to produce? ", 0
	QUES_BASE_FREQ			BYTE	"What would you like to use as the base frequency? ", 0
	QUES_LOOP_COND			BYTE	"Would you like to run the program again? (y/n) ", 0
	NOT_IN_RANGE			BYTE	"*** ERROR: Input is out of range", 0
	EXIT_MSG				BYTE	"*** DONE: End of Program", 0
	ENDLINE					BYTE	13, 10, 0

.STACK 100h									; (default is 1-kilobyte stack)

.DATA										; Begin initialized data segment
    buffer			BYTE    12 DUP (?)
    dtoa_buffer		BYTE    11 DUP (?), 0

	frequencies		DWORD	DEFAULT_FREQ_ARRAY_SIZE  DUP (DEFAULT_FREQ)		; frequencies in Hz
	beep_count		BYTE	LENGTHOF frequencies

	base_freq		BYTE	DEFAULT_BASE_FREQ
	loop_count		BYTE	?

.CODE										; Begin code segment
_main PROC									; Beginning of code
	; ---------------------------------------------------
	; ask the user for the number of beeps they want TODO
	; store the value in [beep_count]
	; validate that entered 0 < count <= LENGTHOF frequencies
	; ---------------------------------------------------

input_beep_count:
	output	QUES_BEEP_COUNT					; ask for number of beeps to produce
	input	buffer, LENGTHOF buffer			; take in input of length buffer
	atod	buffer							; convert ASCII to Decimal and put in EAX
	mov		[beep_count], al				; move Decimal number in al register of EAX into beep_count address

	cmp beep_count, 1						; compare variable to 1
	jl		invalid_input					; if less jump to invalid_input label

	cmp beep_count, LENGTHOF frequencies	; compare variable to LENGTHOF frequencies
	jg		invalid_input					; if greater jump to invalid_input

	jmp		ask_for_freq					; jmp to ask the user for freq

invalid_input:
	output	NOT_IN_RANGE
	output	ENDLINE
	jmp		input_beep_count

ask_for_freq:
	; ---------------------------------
	; ask the user for freq values
	; ---------------------------------

	output	QUES_BASE_FREQ				; ask for base frequency
	input	buffer, LENGTHOF buffer		; take in input of length buffer
	atod	buffer						; convert ASCII to Decimal and put in EAX

	mov		[base_freq], al				; move Decimal number in al register of EAX into base_freq address

; mov values into registers
    mov cl, [beep_count]				; init loop counter
    mov esi, OFFSET frequencies			; init data pointer
@@:
	; ---------------------------------------------------------------------- -
	; replace the following ADD command with user input for freq values
	; ---------------------------------------------------------------------- -
	add		al, al				; increase frequency by value of eax which is base_freq
	mov		[esi], al			; set frequency

	add		esi, TYPE DWORD		; increment data pointer
    dec		cl					; decrement loop counter 
    jnz		@B					; if CL not zero, continue

	; -------------------------------------------------------
	; loop to generate beeps from the array of freq in memory
	; -------------------------------------------------------
    mov cl, [beep_count]				; init loop counter
    mov esi, OFFSET frequencies			; init data pointer
@@:
	mov eax, [esi]		; get frequency
	mov ebx, 500		; duration 500ms

	; ------------------------------------------------------------------
	; display the tone frequency and duration on the console screen
	; ------------------------------------------------------------------
	dtoa	dtoa_buffer, eax				; convert a 32 bit signed int in eax to string (ascii)
	output	dtoa_buffer

	dtoa	dtoa_buffer, ebx				; convert a 32 bit signed int in eax to string (ascii)
	output	dtoa_buffer

	output	ENDLINE

	mov [loop_count], cl		; move value in cl register to loop_count
	call make_beep
	mov cl, [loop_count]		; move back into cl register after calling make_beep

	add esi, TYPE DWORD	; increment data pointer
    dec cl				; decrement loop counter
	jz @F
	jmp @B

	; ----------------------------------------------------------------------------------------------------------
	; ask the user if they want to repeat. If yes, jump back to the top of the code
	; ----------------------------------------------------------------------------------------------------------
@@:
	output	QUES_LOOP_COND				; ask if they would like to run the program again
	input	buffer, 1					; take in input of length 1 and put it into buffer
	mov		al, buffer					; mov buffer into al register

	cmp		al, LOWER_Y_DEC				; compare al which contains the input in dec to to lowercase y in dec
	je		input_beep_count				; if equal jump to top of code

	output	EXIT_MSG
	ret

_main ENDP

				; to call this procedure
				; pass frequency in EAX
				; & pass duration in EBX
make_beep PROC
	pushad		; preserve all registers
	push eax	; preserve frequency because beep changes EAX

	; Beep(frequency, duration)
	push ebx	; duration
	push eax	; frequency
	call _Beep@8

	; handle errors
	or eax, eax					; if (eax != 0)
	jnz @F						; then everything is okay
	call _GetLastError@0		; the error code will be loaded in EAX

	; ---------------------------
	; display the error code
	; ---------------------------
	dtoa	dtoa_buffer, eax				; convert a 32 bit signed int in eax to string (ascii)
	output	dtoa_buffer

@@:
	pop eax						; restore frequency
	popad						; restore all gp (general purpose) registers

	push eax					; sleep interval in ms
	call _Sleep@4

	ret
make_beep ENDP
END _main						; Marks the end of the module and sets the program entry point label

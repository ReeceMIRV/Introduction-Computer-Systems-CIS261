; Lab: M08 Console Input Output
; Course: CIS 261
; File: m08.asm

.386                ; Tells MASM to use Intel 80386 instruction set.
.MODEL FLAT         ; Flat memory model
option casemap:none ; Treat labels as case-sensitive

INCLUDE IO.H        ; header file for input/output

.CONST								; Constant data segment
	QUEST_INT_I			BYTE	"Enter an 8-bit unsigned integer: ", 0
	QUEST_INT_II		BYTE	"Enter another unsigned integer: ", 0
	SUM					BYTE	"							Sum: ", 0

	QUEST_SDB_I			BYTE	"Enter a 32-bit signed integer (signed double): ", 0
	QUEST_SDB_II		BYTE	"Enter another signed integer (signed double): ", 0
	DIFF				BYTE	"								   Difference: ", 0

    ENDLINE				BYTE    ";", 13, 10, 0
    OVERFLOW			BYTE    "*** Wrong Input Format, Please Try Again!", 0
	ARITHMETIC_OVERFLOW	BYTE	"*** Arithmetic Overflow, Please Try Again!", 0

.STACK 100h     ; (default is 1-kilobyte stack)

.DATA				; Begin initialized data segment
    buffer			BYTE    12 DUP (?)
    dtoa_buffer		BYTE    11 DUP (?), 0

	first_int		BYTE	0	; first integer (8 bits / 1 byte) 
	second_int		BYTE	0	; second integer (8 bits / 1 byte)
	int_sum			BYTE	0	; sum of first & second int

	first_db		SDWORD	0	; first signed double (32 bits / 4 bytes)
	second_db		SDWORD	0	; second signed double (32 bits / 4 bytes)
	db_diff			SDWORD	0	; difference of first & second signed double

.CODE							; Begin code segment
_main PROC						; Beginning of code

enter_first_db:

@@:
	output	QUEST_SDB_I					; ask for the first signed double integer
	input	buffer, LENGTHOF buffer		; take in input of length buffer
	atod	buffer						; assume input is 32-bit int and convert it to int in EAX
	jno		@F							; if (OF == 0) then conversion to int succeeded, jump forward
	output	OVERFLOW					; else overflow
	output	ENDLINE						;	   endline
	jmp		@B							; jump backwards to @@

@@:
	; we have our first 32 bit input ready
	mov		[first_db], eax				; move input thats stored in eax into the address of first_db


enter_second_db:

@@:
	output	QUEST_SDB_II				; ask for the second signed double integer
	input	buffer, LENGTHOF buffer		; take in input of length buffer
	atod	buffer						; assume input is 32-bit int and convert it to int in EAX
	jno		@F							; if (OF == 0) then conversion to int succeeded, jump forward
	output	OVERFLOW					; else overflow
	output	ENDLINE						;	   endline
	jmp		@B							; jump backwards to @@

@@:
	; we have our second 32 bit input ready
	mov		[second_db], eax			; move input thats stored in eax into the address of first_db

;; compute 32bit difference

	mov		eax, [first_db]				; load first dbl into memory
	mov		[db_diff], eax				; move item in eax (first_db) into address of db_diff
	
	mov		eax, [second_db]			; load second db into memory
	sub		[db_diff], eax				; sub the second_db which is found in eax to first_db which is found in db_diff

	jno		@F							; jump forward if no overflow
	output	ARITHMETIC_OVERFLOW			; else arithmetic_overflow
	output	ENDLINE						;	   endline
	jmp		enter_first_db

@@:

;; print (display) 32bit difference
	dtoa	dtoa_buffer, [db_diff]		; convert 32 bit signed int to string(ascii)

	output	DIFF						; print const string DIFF
	output	dtoa_buffer					; print the converted ascii string of int_sum
	output	ENDLINE

	ret
    
_main ENDP
END _main        ; Marks the end of the module and sets the program entry point label

; CIS-261
; M11.ASM
; Demo program for Lab M11: Extended Precision Techniques

.386                ; Tells MASM to use Intel 80386 instruction set.
.MODEL FLAT         ; Flat memory model
option casemap:none ; Treat labels as case-sensitive

INCLUDE IO.H        ; header file for input/output

.STACK 100h			; (default is 1-kilobyte stack)

.const													; Constant data segment
	SUM_HEX			BYTE	"HEX SUM: ", 0
	DIFF_HEX		BYTE	"HEX DIFF: ", 0

	ENDLINE			BYTE	13, 10, 0
	TXT_LINE        BYTE	"_____________________________________________________", 0

.DATA													; Begin initialized data segment
    buffer			BYTE    12			DUP (?), 0		; memory to get user input
    dtoa_buffer		BYTE    11			DUP (?), 0		; memory for converting integers to text


	; Define a lookup table containing the hexadecimal values for 0 through 15
	HexTable db '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'

	str_format db "%c", 0



	op1				QWORD	0A2B2A40675981234h			; first 64-bit operand for addition
	op2				QWORD	08010870001234502h			; second 64-bit operand for addition

	sum   DWORD 3 dup(?)			; 96-bit sum = ????????????????????????h

									; 36 57 bb 76 | 06 2b c3 22 | 01 00 00 00 == sum in little endian storage order
									; 00 00 00 01 | 22 c3 2b 06 | 76 bb 57 36 == sum in hex value


	op3   DWORD 3 dup(2)            ; 96-bit oper to sub  20000000200000002h  == subtrahend in hex
									; 00 00 00 01 | 22 c3 2b 06 | 76 bb 57 36 == sum (minuend) in hex value
									; 00 00 00 02 | 00 00 00 02 | 00 00 00 02 == subtrahend in little endian storage
									; --------------------------------------- == subtract 
									; 34 57 bb 76 | 04 2b c3 22 | ff ff ff ff == result in little endian storage order

.CODE           ; Begin code segment
_main PROC      ; Beginning of code
    ;------------------------------------------------------------------------------
    ;        add two 64 bit numbers and store the result as 96 bit sum
    ;-----------------------------------------------------------------------------
    mov EAX, DWORD PTR [op1]         ; EAX = low bits of first 64 bit integer
    mov EBX, DWORD PTR [op1 + 4]     ; EBX = high bits of first 64 bit integer

    
    mov ECX, DWORD PTR [op2]         ; ECX = low bits of second 64 bit integer
    mov EDX, DWORD PTR [op2 + 4]     ; EDX = High bits of second 64 bit integer

    add EAX, ECX                     ; EAX = EAX + ECX adds low bits of the two 64 bit integers
    adc EBX, EDX                     ; EBX = EBX + EDX + CF adds high bits of the two 64 bit integers 

    mov DWORD PTR [sum], EAX         ; store the low bits sum
    mov DWORD PTR [sum + 4], EBX     ; store the high bits sum
    adc DWORD PTR [sum + 8], 0       ; adds sum + 8 + CF

	;---------------------------------------------------------------------------------
    ;    display sum to console in hexadecimal format
    ;--------------------------------------------------------------------------------
	output	SUM_HEX

	; Convert the bits in AL to hexadecimal
	movzx eax, al								; zero extend AL into EAX
	and eax, 0Fh								; isolate the low 4 bits in EAX
	movzx edx, byte ptr [HexTable + eax]		; index into the lookup table using the low 4 bits
												; and store the result in EDX

	; At this point, EDX contains the hexadecimal value for the bits in AL
    ;dtoa    dtoa_buffer, edx					; convert
    ;output  edx									; print numeric result


;;;; ; buffer is a byte array large enough to hold the string representation of the number
;;;; ; in EDX, including a sign character and a null terminator
;;;; 
;;;; ; check the sign of the number in EDX
;;;; mov     al, dl                      ; move the low byte of EDX to AL
;;;; and     al, 80h                     ; check the high bit of DL
;;;; jz      positive                    ; jump to "positive" if the high bit is not set
;;;; 
;;;; ; the number is negative, set the high bit of the buffer to '-' and negate EDX
;;;; mov     [buffer], '-'               ; store '-' in the buffer
;;;; neg     edx                         ; negate EDX
;;;; 
;;;; positive:
;;;; ; initialize loop counter to zero
;;;; xor ecx, ecx; clear ECX
;;;; 
;;;; ; divide EDX by 10 and store the remainder in AL
;;;; mov     al, 10; move the divisor to AL
;;;; idiv    al; divide EDX by ALand store the remainder in AL
;;;; 
;;;; ; add '0' to the value in AL to obtain the ASCII code for the corresponding decimal digit
;;;; add     al, '0'; add '0' to AL
;;;; 
;;;; ;;;; store the value in AL in the buffer at the position indicated by the loop counter
;;;; ;;;; mov[buffer + ecx], al; store AL in the buffer at the position indicated by ECX
;;;; 
;;;; mov buffer, dl
;;;; 
;;;; ; append a null terminator to the end of the string
;;;; mov     byte ptr [buffer + ecx], 0  ; store a null terminator at the end of the buffer



    ;--------------------------------------------------------------------------------
    ;    subtract two 96 bit numbers and store the result as 96 bit difference
    ;---------------------------------------------------------------------------------
    mov EAX, DWORD PTR [op3 + 0]      ; EAX = low bits of 96 bit op3
    sub DWORD PTR [sum + 0], EAX      ; subtract the low bits 

    mov EAX, DWORD PTR [op3 + 4]      ; EAX = middle bits of 96 bit op3
    sbb DWORD PTR [sum + 4], EAX      ; subtract the middle bits and carry flag

    mov EAX, DWORD PTR [op3 + 8]      ; EAX = high bits of 96 bit op3
    sbb DWORD PTR [sum + 8], EAX      ; subtract the high bits and carry flag

	;--------------------------------------------------------------------------------
    ;    display diff to console in hexadecimal format
    ;---------------------------------------------------------------------------------

    ret
    
_main ENDP

END _main        ; Marks the end of the module and sets the program entry point label

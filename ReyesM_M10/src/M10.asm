; CIS-261
; M10.ASM
; Lab M10

.386                ; Tells MASM to use Intel 80386 instruction set.
.MODEL FLAT         ; Flat memory model
option casemap:none ; Treat labels as case-sensitive

INCLUDE IO.H        ; header file for input/output

.STACK 100h     ; (default is 1-kilobyte stack)

.const          ; Constant data segment
    TXT_LINE                BYTE    "_____________________________________________________", 0
    PROMPT_PAUSE            BYTE    "Hit enter to continue...", 0
    PROMPT_MULTIPLIER       BYTE    "Input multiplier: ", 0

	PROMPT_MULTIPLICAND_C	BYTE	"How many multiplicants would you like to use? (Range: 1-3) ", 0
	MULTIP_START_RANGE		EQU		1
	MULTIP_END_RANGE		EQU		3

    PROMPT_MULTIPLICAND_K   BYTE    "Input first multiplicand: ", 0
    PROMPT_MULTIPLICAND_M   BYTE    "Input second multiplicand: ", 0
    PROMPT_MULTIPLICAND_N   BYTE    "Input third multiplicand: ", 0

    BAD_FORMAT              BYTE    "*** Bad format, please retry!", 0
	NOT_IN_RANGE            BYTE    "*** Not in range, please retry!", 0
    TXT_BAD_MULTIPLICAND    BYTE    "A multiplicand (2^m) should be between 0 and 31", 0
    ENDL    BYTE 13, 10, 0

.DATA													; Begin initialized data segment
    buffer			BYTE    12			DUP (?), 0		; memory to get user input
    dtoa_buffer		BYTE    11			DUP (?), 0		; memory for converting integers to text

    multiplier			DWORD		0
    k_multiplicand		BYTE		0
    m_multiplicand		BYTE		0
    n_multiplicand		BYTE		0
    product				DWORD		?

	multip_count		BYTE		3

    bit_buffer  BYTE    64 dup( ' ' ), 0 ; output buffer
    
.CODE           ; Begin code segment
_main PROC      ; Beginning of code
repeat_forever:
    output TXT_LINE
    output  ENDL
;;;;;;;;;;;;;;;;;
multiplier_input:
;;;;;;;;;;;;;;;;;
    output  PROMPT_MULTIPLIER           ; ask for input
    input   buffer, SIZEOF buffer       ; get input
    atod    buffer                      ; convert input to the value in EAX
    jno     @F
    ; handle the error
    output  BAD_FORMAT                  ; show error message
    output  ENDL
    jmp     multiplier_input
@@:
    mov     DWORD PTR [multiplier], EAX ; store the value

;;;;;;;;;;;;;;;;;;;
multiplicand_count:
;;;;;;;;;;;;;;;;;;;
    output  PROMPT_MULTIPLICAND_C       ; ask for multiplicand count
    input   buffer, SIZEOF buffer       ; get input
    atod    buffer                      ; convert input to the value in EAX
    jno     @F
										; handle the error
    output  BAD_FORMAT                  ; show error message
    output  ENDL
    jmp     multiplicand_count

@@:
	cmp		eax, MULTIP_START_RANGE		; compare input in eax to start range
	jl		out_of_range				; if less then jump to label out_of_range

	cmp		eax, MULTIP_END_RANGE		; compare input in eax to end range
	jg		out_of_range				; if greater then jump to label out_of_range
	jmp		@F							; if no errors then jump forward

out_of_range:							; handle error: out of range
	output	NOT_IN_RANGE
	output	ENDL
	jmp multiplicand_count

@@:
    mov     DWORD PTR [multip_count], EAX ; store the value

;;;;;;;;;;;;;;;;;;;;;
multiplicand_k_input:
;;;;;;;;;;;;;;;;;;;;;
    output  PROMPT_MULTIPLICAND_K       ; ask for input
    input   buffer, SIZEOF buffer       ; get input
    atod    buffer                      ; convert input to the value in EAX
    jno     @F
    ; handle the error
    output  BAD_FORMAT                  ; show error message
    output  ENDL
    jmp     multiplicand_k_input
@@:
    ; EAX contains number of bits to shift
    ; validate this value
    cmp     EAX, 31                     ; if ( EAX <= 31 )  
    jna     @F                          ; everything is okay
    ; handle bad input
    output  TXT_BAD_MULTIPLICAND        ; show error message
    output  ENDL
    jmp     multiplicand_k_input    
@@: 
    mov     BYTE PTR [k_multiplicand], AL   ; store the value


; validate whether  multiplicand is 1 to jump to computation
	cmp		[multip_count], 1			; compare input in al register to multiplicand count
	je		computation					; if equals 1 then jump to computation

;;;;;;;;;;;;;;;;;;;;;
multiplicand_m_input:
;;;;;;;;;;;;;;;;;;;;;
    output  PROMPT_MULTIPLICAND_M       ; ask for input
    input   buffer, SIZEOF buffer       ; get input
    atod    buffer                      ; convert input to the value in EAX
    jno     @F
    ; handle the error
    output  BAD_FORMAT                  ; show error message
    output  ENDL
    jmp     multiplicand_m_input
@@:
    ; EAX contains number of bits to shift
    ; validate this value
    cmp     EAX, 31                     ; if ( EAX <= 31 )
    jna     @F                          ; everything is okay
    ; handle bad input
    output  TXT_BAD_MULTIPLICAND        ; show error message
    output  ENDL
    jmp     multiplicand_m_input    
@@:            
    mov     BYTE PTR [m_multiplicand], AL   ; store the value

; validate whether  multiplicand is 1 to jump to computation
	cmp		[multip_count], 2			; compare input in al register to multiplicand count
	je		computation					; if equals 2 then jump to computation

;;;;;;;;;;;;;;;;;;;;;
multiplicand_n_input:
;;;;;;;;;;;;;;;;;;;;;
    output  PROMPT_MULTIPLICAND_N       ; ask for input
    input   buffer, SIZEOF buffer       ; get input
    atod    buffer                      ; convert input to the value in EAX
    jno     @F
    ; handle the error
    output  BAD_FORMAT                  ; show error message
    output  ENDL
    jmp     multiplicand_n_input
@@:
    ; EAX contains number of bits to shift
    ; validate this value
    cmp     EAX, 31                     ; if (EAX <= 31)
    jna     @F                          ; everything is okay
    ; handle bad input
    output  TXT_BAD_MULTIPLICAND        ; show error message
    output  ENDL
    jmp     multiplicand_n_input    
@@:            
    mov     BYTE PTR [n_multiplicand], AL ; store the value

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
computation:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
;-------------------------------------------------------------
; product = multiplier * (2^k_multiplicand) +
;           multiplier * (2^m_multiplicand) +
;           multiplier * (2^n_multiplicand)
;---------------------------------------------------------------

    mov [product], 0            ; clear result
    mov eax, [multiplier]       ; load the multiplier
    mov cl, [k_multiplicand]
    shl eax, cl                 ; multiplier * 2^k
    mov [product], eax          ; accumulate intermediate value

; validate whether  multiplicand is 1 to stop & display results
	cmp		[multip_count], 1			; compare input in al register to multiplicand count
	je		display_results				; if equals 1 then jump to computation

    mov eax, [multiplier]       ; reload the multiplier
    mov cl, [m_multiplicand]
    shl eax, cl                 ; multiplier * 2^m
    add [product], eax          ; accumulate intermediate value

; validate whether  multiplicand is 2 to stop & display results
	cmp		[multip_count], 2			; compare input in al register to multiplicand count
	je		display_results				; if equals 2 then jump to computation

    mov eax, [multiplier]       ; reload the multiplier
    mov cl, [n_multiplicand]
    shl eax, cl                 ; multiplier * 2^n
    add [product], eax          ; accumulate intermediate value

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
display_results:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; display in decimal form
    dtoa    dtoa_buffer, [product] ; convert
    output  dtoa_buffer         ; print numeric result
    output  ENDL                ; print new line

    ; display in binary form
    mov eax, [product]
    call    eax_2_bit_buffer
    output  bit_buffer          ; print binary digits
    output  ENDL                ; print new line

    output  PROMPT_PAUSE
    input   buffer, SIZEOF buffer   ; pause before exit

    ; repeat forever!
    jmp     repeat_forever
    ;ret
_main ENDP

; Procedure to calculate positions of white space
; Input is ECX, the position counter
; We want to insert space after every 4th binary digit
; The procedure returns CF (Carry Flag)
; CF=1 indicates the need to insert space
; CF=0 cleared otherwise
is_space_needed PROC
    push eax    ; preserve the registers
    push edx
    push ecx
    mov eax, ecx    ; now EAX is the position counter
    xor edx, edx    ; set EDX = 0
    mov ecx, 4      ; position where space is need
    div ecx         ; DX = EAX % ECX, AX = EAX / ECX
    test    edx, edx    ; if ( EDX != 0 )
    clc                 ; CF = 0 - assume that space is not needed
    jne @F              ; then no space is needed
    stc                 ; CF = 1 - indicates the need to insert space
@@:
    pop ecx ; restore registers
    pop edx
    pop eax
    ret
is_space_needed ENDP

; Procedure to convert EAX to bits in bit_buffer
; EAX contains integer to convert
eax_2_bit_buffer PROC
    push eax                ;  preserve registers
    push ecx
    push esi
    mov ecx, 32             ; number of bits in EAX
    mov esi, OFFSET bit_buffer
next_bit:
    call is_space_needed    ; returns CF if extra space is needed
    jnc @F
    inc esi                 ; "insert" space by skipping one position
@@:
    shl eax, 1              ; shift high bit into Carry flag
    mov BYTE PTR [esi], '0' ; display zero by default
    jnc next_byte           ; if no Carry, advance to next byte
    mov BYTE PTR [esi], '1' ; otherwise display 1
next_byte:
    inc esi                 ; next buffer position
    loop next_bit           ; shift another bit to left

    pop esi ; restore registers
    pop ecx
    pop eax
    ret
eax_2_bit_buffer ENDP

END _main        ; Marks the end of the module and sets the program entry point label

; CIS-261
; M10.ASM
; Prototype program for Lab M10

.386                ; Tells MASM to use Intel 80386 instruction set.
.MODEL FLAT         ; Flat memory model
option casemap:none ; Treat labels as case-sensitive

INCLUDE IO.H        ; header file for input/output

.const          ; Constant data segment
    ENDL    BYTE 13, 10, 0

.STACK 100h     ; (default is 1-kilobyte stack)

.DATA           ; Begin initialized data segment
    Value       DWORD   1234ABCDh    ; sample binary value
    bit_buffer  BYTE    64 dup( ' ' ), 0 ; output buffer
    
.CODE           ; Begin code segment
_main PROC      ; Beginning of code
    mov     eax, [Value]          ; value to display
    call    eax_2_bit_buffer
    output  bit_buffer          ; print binary digits
    output  ENDL                ; print new line
    ret
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



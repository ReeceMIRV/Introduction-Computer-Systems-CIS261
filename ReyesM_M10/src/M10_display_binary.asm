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
    bit_buffer  BYTE    32 dup(0), 0 ; output buffer
    
.CODE           ; Begin code segment
_main PROC      ; Beginning of code
    mov     eax, [Value]          ; value to display
    call    eax_2_bit_buffer
    output  bit_buffer          ; print binary digits
    output  ENDL                ; print new line
    ret
_main ENDP

; Procedure to convert EAX to bits in bit_buffer
; EAX contains integer to convert
eax_2_bit_buffer PROC
    mov ecx, 32             ; number of bits in EAX
    mov esi, OFFSET bit_buffer
next_bit:
    shl eax, 1              ; shift high bit into Carry flag
    mov BYTE PTR [esi], '0' ; display zero by default
    jnc next_byte           ; if no Carry, advance to next byte
    mov BYTE PTR [esi], '1' ; otherwise display 1
next_byte:
    inc esi                 ; next buffer position
    loop next_bit           ; shift another bit to left
    ret
eax_2_bit_buffer ENDP

END _main        ; Marks the end of the module and sets the program entry point label



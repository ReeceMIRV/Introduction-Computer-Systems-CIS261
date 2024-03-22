; CIS-261
; Week05.asm
; The Simplest ASM Program Which Does Nothing

.386                     ; Tells MASM to use Intel 80386 instruction set.
.MODEL FLAT              ; Flat memory model
option casemap:none      ; Treat labels as case-sensitive

.const                   ; Constant data segment
    FAV_NUM    EQU 7     ; Favorite Number Constant

.STACK 100h              ; (default is 1-kilobyte stack)

.DATA                    ; Begin initialized data segment
    value    dword 0     ; int value = 0;

.CODE                    ; Begin code segment
_main PROC               ; Beginning of code

MY_LOOP:                 ; do {
    inc value            ; ++value
    cmp value, FAV_NUM   ; if ( value - FAV_NUM == 0)
    je move_to_AX        ; then jump to move_to_AX
loop MY_LOOP             ; } while ( value < FAV_NUM )

move_to_AX:
    mov EAX, value       ; move value into EAX register
    ret
    
_main ENDP

END _main                ; Marks the end of the module and sets the program entry point label
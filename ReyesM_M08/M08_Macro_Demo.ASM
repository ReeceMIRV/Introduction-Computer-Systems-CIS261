; CIS-261
; M08_Macro_Demo.ASM
; Demo program of IO.H and IO.ASM usage
; @topic W080093 IO.H and IO.ASM usage demo
; @brief <a href="http://www.c-jump.com/bcc/c261c/MLabs/M08console/M08console.html" target="_blank">Console Input/Output</a> OUTPUT, INPUT, SZLEN, DTOA, ITOA, ATOI usage

.386                ; Tells MASM to use Intel 80386 instruction set.
.MODEL FLAT         ; Flat memory model
option casemap:none ; Treat labels as case-sensitive

INCLUDE IO.H        ; header file for input/output

.CONST          ; Constant data segment
    TXTPROMPT   BYTE    "Please enter up to 10 characters of text: ", 0
    TXTENTERED  BYTE    "                          You've entered: ", 0
    TXTLENGTH   BYTE    "            Number of characters entered: ", 0
    INPROMPT    BYTE    "                 Please enter an integer: ", 0
    ENDL        BYTE    ";", 13, 10, 0
    OVERFLOW    BYTE    "*** Bad number, please try again!", 0

.STACK 100h     ; (default is 1-kilobyte stack)

.DATA           ; Begin initialized data segment
    buffer      BYTE    12 DUP (?)
    dtoa_buffer BYTE    11 DUP (?), 0
    atoa_buffer BYTE    6  DUP (?), 0

.CODE           ; Begin code segment
_main PROC      ; Beginning of code

    output  TXTPROMPT        ; Please enter up to 10 characters of text...
    input   buffer, 12       ; ...read zero to 10 ASCII characters
    output  TXTENTERED       ; ...You've entered...
    output  buffer           ; ...print the input
    output  ENDL             ; new line
    
    szlen   buffer           ; Calculate length of user input, put result in eax
    dtoa    dtoa_buffer, eax ; convert 32-bit signed integer to string
    output  TXTLENGTH        ; Number of characters entered...
    output  dtoa_buffer      ; ...print numeric result
    output  ENDL             ; new line

    itoa    atoa_buffer, ax  ; Convert 16-bit signed integer to string
    output  TXTLENGTH        ; Number of characters entered...
    output  atoa_buffer      ; ...print numeric result
    output  ENDL             ; new line

@@:
    output  INPROMPT         ; Please enter an integer...
    input   buffer, 12       ; ...read zero to 10 ASCII characters
    atoi    buffer           ; convert "[+/-]123" to 2's complement (result in AX)
    jno     @F               ; check overflow flag
    output  OVERFLOW         ; print error message
    output  ENDL             ; new line
    jmp     @B               ; back to the prompt
@@:
    itoa    atoa_buffer, ax  ; Convert 16-bit signed integer to string
    output  TXTENTERED       ; ...You've entered...
    output  atoa_buffer      ; print result
    output  ENDL             ; new line
 
    ret
    
_main ENDP
END _main        ; Marks the end of the module and sets the program entry point label

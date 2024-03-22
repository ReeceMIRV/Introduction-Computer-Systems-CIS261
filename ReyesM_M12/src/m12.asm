; CIS-261
; M12.asm
; Lab M12, invoking C standard library functions from MASM

.386                  ; Tells MASM to use Intel 80386 instruction set.
.MODEL FLAT, stdcall  ; Flat memory model
option casemap:none   ; Treat labels as case-sensitive

; See
; https://stackoverflow.com/questions/33721059/call-c-standard-library-function-from-asm-in-visual-studio
; which explains how to
; call C standard library function from asm in Visual Studio.
;
; More info about this in
; https://docs.microsoft.com/en-us/cpp/c-runtime-library/crt-library-features?view=vs-2019

includelib libcmt.lib
includelib libvcruntime.lib
includelib libucrt.lib
includelib legacy_stdio_definitions.lib

EXTERN strlen:NEAR       ; This procedure is part of the C standard library
EXTERN strncpy:NEAR      ; This procedure is part of the C standard library

.STACK 100h     ; (default is 1-kilobyte stack)

.const          ; Constant data segment
    source      BYTE    "hello", 0

.DATA           ; Begin initialized data segment
    destination BYTE    80 dup ( 0 )
    str_len     DWORD   0

.CODE           ; Begin code segment
_main PROC      ; Beginning of code
    ;--------------------------------------
    ; prepare to call strlen
    ;--------------------------------------
    mov     eax, OFFSET source
    push    eax
    call    strlen      ; the result is in eax
    add     esp, 4      ; C library does not remove args from the stack, we have to do this
                        ; manually
    mov [str_len], eax  ; save string length

	;----------------------------------------------------
    ; create 3 copies of "hello" in the destination.
    ; the result should be: "hellohellohello", 0
    ; make sure to set NULL character at the end
    ;----------------------------------------------------

	;--------------------------------------
    ; prepare to call strncpy
    ;--------------------------------------
    push    eax         ; how many chars to copy
    mov     eax, OFFSET source
    push    eax         ; address of the source string
    mov     eax, OFFSET destination
    push    eax         ; address of the destination string
    call    strncpy
    add     esp, 12     ; C library does not remove args from the stack, we have to do this
                        ; manually

	;--------------------------------------
    ; prepare to call 2nd strncpy
    ;--------------------------------------
	mov		eax, [str_len]			; load string length into eax
    push    eax						; how many chars to copy
    mov     eax, OFFSET source
    push    eax						; address of the source string
    mov     eax, OFFSET destination
	add eax, [str_len]				; adjust destination location to accept 2nd "hello"
    push    eax						; address of the destination string
    call    strncpy
    add     esp, 12					; C library does not remove args from the stack, we have to do this
									; manually

	;--------------------------------------
    ; prepare to call 3rd strncpy
    ;--------------------------------------
	mov		eax, [str_len]			; load string length into eax
    push    eax						; how many chars to copy
    mov     eax, OFFSET source
    push    eax						; address of the source string
    mov     eax, OFFSET destination
	add eax, [str_len]				; adjust destination location to accept 2nd "hello"
	add eax, [str_len]				; adjust destination location to accept 3rd "hello"
    push    eax						; address of the destination string
    call    strncpy
    add     esp, 12					; C library does not remove args from the stack, we have to do this
									; manually
    ;--------------------------------------------------------------
    ; make sure that destination is a null terminated C string
    ;--------------------------------------------------------------
    mov eax, [str_len]  ; load string length into eax
	mov ebx, eax
	add eax, ebx
	add eax, ebx
    mov BYTE PTR destination[ eax ], '0'

    ret
    
_main ENDP

END _main       ; Marks the end of the module and sets the program entry point label



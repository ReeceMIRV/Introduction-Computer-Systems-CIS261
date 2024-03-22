#################################
# print string in reverse
#################################

    .eqv SYSCALL_PRINT_INT       1
    .eqv SYSCALL_PRINT_STRING    4
    .eqv SYSCALL_READ_STRING     8
    .eqv SYSCALL_PRINT_CHAR     11

    .eqv SYSCALL_EXIT_PROG      10

    .eqv INPUT_BUFFER_SIZE      80
    .eqv NEWLINE               0xA
    
    .data
    
user_prompt: 
    .asciiz "Enter string to print in reverse: "
    
buffer:    
    
    .space INPUT_BUFFER_SIZE
    
    .text
#-------------------------------------------------------
# get user input
#-------------------------------------------------------
    li $v0, SYSCALL_PRINT_STRING
    la $a0, user_prompt
    syscall

    li $v0, SYSCALL_READ_STRING
    la $a0, buffer
    li $a1, INPUT_BUFFER_SIZE
    syscall
    
#---------------------------------------------------------------
# compute input length by finding NULL at the end of the input
#---------------------------------------------------------------
    move  $t2, $zero            # $t2 = 0 (buffer index)
inp_len:
    lb    $t0, buffer($t2)      # $t0 = next char from input buffer
    add   $t2, $t2, 1           # ++$t2
    bne   $t0, $zero, inp_len   # if ( $t0 != 0 ) continue

#---------------------------------------------------------------
# print input characters in reverse order
#---------------------------------------------------------------
    sub   $t2, $t2, 1           # --$t2 ($t2 = idx of char before NULL)
next_char:
    sub   $t2, $t2, 1           # --$t2 ($t2 = index of the char to print)
    la    $t0, buffer($t2)      # $t0 = address of the last character
    lb    $a0, ($t0)            # $a0 = last character (load for printing)
    
    #li $v0, SYSCALL_PRINT_INT
    li $v0, SYSCALL_PRINT_CHAR
    syscall

    li $a0, NEWLINE             # print new line
    li $v0, SYSCALL_PRINT_CHAR
    syscall

    bnez  $t2, next_char        # if ( $t2 != 0 ) repeat (more chars to print)
    
    li $a0, NEWLINE             # print new line
    li $v0, SYSCALL_PRINT_CHAR
    syscall

#---------------------------------------------------------------
# exit program
#---------------------------------------------------------------
    li $v0, SYSCALL_EXIT_PROG
    syscall 

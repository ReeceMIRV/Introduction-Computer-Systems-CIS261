# MIPS Programming A2:
# Write MIPS Assembly program that allows the user to enter a string of text. 
# Determine whether the entered string is a palindrome (a word or a phrase that reads the same backwards & forward)
# like how "kayak" and "level" are palindrome, and print the result on the screen.

#################################
# reverse string in place
#################################

.data
    .eqv 	SYSCALL_EXIT_PROG    	10
    .eqv 	SYSCALL_PRINT_INT    	1
    .eqv 	SYSCALL_READ_STRING  	8
    .eqv 	SYSCALL_PRINT_STRING 	4
    .eqv 	SYSCALL_PRINT_CHAR   	11

    .eqv 	MAX_STRING_SIZE      	80
    .eqv 	NEWLINE              	0xA	 # '\n' character

STR_PROMPT: 		.asciiz 	"Enter a string: "
STR_LENGTH: 		.asciiz 	"String length is: "
STR_REVERSED:		.asciiz		"Reversed: "
STR_PALINDROME:		.asciiz		"Result: Your input was a Palindrome "
STR_NOT_PALINDROME:	.asciiz		"Result: Your input was not a Palindrome "
input:      		.space  	MAX_STRING_SIZE

.text
    li  	$v0, SYSCALL_PRINT_STRING
    la  	$a0, STR_PROMPT
    syscall

    li  	$v0, SYSCALL_READ_STRING
    la  	$a0, input
    li  	$a1, MAX_STRING_SIZE
    syscall

    # find the length of input string:
    la  	$a0, input
    jal 	string_length
    
    # length is ready
    # at this point $v0 has the length of input
    move 	$s3, $v0   			# preserve the length of input
    
    li  	$v0, SYSCALL_PRINT_STRING
    la  	$a0, STR_LENGTH			# print the string "String length is: "
    syscall
    
    li   	$v0, SYSCALL_PRINT_INT
    move 	$a0, $s3   			# length of input
    syscall
    
    li 		$a0, NEWLINE             	# print new line
    li 		$v0, SYSCALL_PRINT_CHAR
    syscall

    beqz 	$s3, exit_the_prog 		# empty input causes the prog to exit

                        			# reverse characters in the string:
                        			# abcdef
                       				# |    |
    subi 	$t2, $s3, 1			# |    idx_tail = input_length - 1
    move 	$t1, $zero			# idx_head = 0
    
swap_characters:
    lb   	$t5, input( $t1 ) 		# save head character in $t5
    lb   	$t6, input( $t2 ) 		# save tail character in $t6

    sb   	$t6, input( $t1 ) 		# store tail character as new head character
    sb   	$t5, input( $t2 ) 		# store head character as new tail character
    
    addi 	$t1, $t1, 1       		# increment head index
    addi 	$t2, $t2, -1      		# decrement tail index
    slt  	$t7, $t1, $t2     		# if ( $t1 < $t2 ) $t7 = 1, zero otherwise
    
    bnez 	$t7, swap_characters
    
    # print the string "Reversed: "
    li	$v0, SYSCALL_PRINT_STRING
    la	$a0, STR_REVERSED
    syscall
    
    # print the result (the reversed string)
    li  	$v0, SYSCALL_PRINT_STRING
    la  	$a0, input
    syscall
    
    # print a new empty line
    li 	$v0, SYSCALL_PRINT_CHAR
    li 	$a0, NEWLINE
    syscall
    
    # decide whether to jump to equal to or not equal to
    bne		$t5, $t6, chars_not_equal  	# Branch to "chars_not_equal" if the characters are not equal
    beq		$t5, $t6, chars_equal	  	# Branch to "chars_equal" if the characters are equal
    
chars_not_equal:
    li	$v0, SYSCALL_PRINT_STRING
    la	$a0, STR_NOT_PALINDROME
    syscall
    
    j	exit_the_prog
    
chars_equal:
    li	$v0, SYSCALL_PRINT_STRING
    la	$a0, STR_PALINDROME
    syscall
        
exit_the_prog:
    li 	$v0, SYSCALL_PRINT_CHAR
    li 	$a0, NEWLINE
    syscall
    
    li  $v0, SYSCALL_EXIT_PROG
    syscall


# ------------------------------------------
# Procedures
#-------------------------------------------
# Compute the length of string
# by finding either first newline '\n' or NULL character
#
# Input: $a0 contains the address of the string
# Returns result in $v0
#-------------------------------------------
string_length:
    addiu 	$sp, $sp, -20  			# preserve five 4-byte registers
    sw    	$ra, 0($sp)
    sw    	$t1, 4($sp)
    sw    	$a0, 8($sp)
    sw    	$t2, 12($sp)
    sw    	$t4, 16($sp)

    move  	$t4, $a0       			# $t4 = address of the string
    move  	$v0, $zero     			# $v0 = index of character
    li    	$t1, NEWLINE
    
compare_char_2_newline:
    addu  	$a0, $t4, $v0  			# addr of a char = address of the string + index of character
    lb    	$t2, 0($a0)    			# $t2 = char from input string
    beq   	$t2, $t1, length_is_ready  	# compare char with '\n'
    beqz  	$t2, length_is_ready       	# compare char with zero (NULL character)
    addi  	$v0, $v0, 1    			# increment index
    j     	compare_char_2_newline
    
length_is_ready:
    lw    	$ra, 0($sp)    			# restore five 4-byte registers
    lw    	$t1, 4($sp)
    lw    	$a0, 8($sp)
    lw    	$t2, 12($sp)
    lw    	$t4, 16($sp)
    addiu 	$sp, $sp, 20
    jr    	$ra            			# return back to the caller
# string_length ends
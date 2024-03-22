# This MIPS Assembly Program is the C equivalent of
#	int i = 11;
#	int j = 10;
#	int A[] = { 0x11, 0x22, 0x33 };
#	int B[] = { 0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8 };

#	B[ 8 ] = A[ i - j ];



# #define all macros
.eqv	OFFSET_BY_8	32						# offset an array by 8 integers of 4 bit value
.eqv	PRINT_INTEGER	1
.eqv	EXIT_PROGRAM	10


# initialized data segment (variables)
# these are all stored in RAM (Random Access Memory)
.data
i:	.word		11						# int i = 11;
j:	.word		10						# int j = 10;

A:	.word		0x11, 0x22, 0x33				# A[] = { 0x11, 0x22, 0x33 }
B:	.word		0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8	# B[] = { 0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8 }


# alternative: declaring the arrays without initialization to allocate them later
# A:	.space 12							# int A[3];	# reserve space for 3 integers (each integer is 4 bytes so 3 * 4 = 12 bytes)
# B:	.space 36							# int B[9];	# reserve space for 9 integers (each integer is 4 bytes so 9 * 4 = 36 bytes)



# Next Up Is:	B[ 8 ] = A[ i - j ];

# programs instructions (code) segment
# for the most part we want to load the address (la) from RAM, into a register
# in the CPU (Central Processing Unit) whenever we want to use it
.text
la 	$s3, i								# load address i into register $s3
la 	$s4, j								# load address j into register $s4
la 	$s6, A								# load address A into register $s6
la 	$s7, B								# load address B into register $s7

# the data was loaded into registers $saved temporary which means that the data stored in them will be 
# "preserved across call" or in other words preserved across function calls, and so we don't have to worry about the
# data that these registers contain possibly getting destroyed between function calls

# now that we've loaded the addresses into their registers respectively, we want to load the values in those addresses
# into the cpu, and we can do so by loading them into the same registers, using lw

lw 	$s3, 0($s3)								# load value (integer, word) of address i which is stored in register $s3 (offset by 0 bits) into register $s3
lw 	$s4, 0($s4)								# load value (integer, word) of address j which is stored in register $s4 (offset by 0 bits) into register $s4

sub 	$t0, $s3, $s4								# $temp_0 = i - j; 		# subtract j from i and then store it in register $t0 which is not preserved across function calls				
sll	$t0, $t0, 2								# $temp_0 = $temp_0 * 4 	# shift bits left by 2 which is the equivalent of multiplying the value in temp_0 by 4, and we then store it in $temp_0...
# we "shift left logical" because we need to scale by 4 byte size int since the value/s we'll retrieve from B are 4 byte size integers and so we need to scale our current data over into the appropriate sized bitwise value

add	$t0, $s6, $t0								# $temp_0 = A[i-j]		# add value in register $temp_0 to the address in register $savedTemp_6 and store it in register $temp_0... so $temp_0 = A[$temp_0] where A is the address found in $savedTemp_6
lw	$t1, 0($t0)								# $temp_1 = value of A[i-j]	# load value (integer, word) which is stored in temp_0 (offset by 0 bytes) into register $temp_1
sw	$t1, OFFSET_BY_8($s7)							# store value of $temp1 in $s7 (offset by 4 * 8 = 32 bits) so in other words B[8]

li	$v0, PRINT_INTEGER							# load the immediate value PRINT_INTEGER (which is 1) into register $V0 which is a code for $V0 to prepare to print an integer
move	$a0, $t1								# and move the value in register $temp_1 into register $argument_1 in order to use it for the syscall which will print its value to the console
syscall

li	$v0, EXIT_PROGRAM							# load the immediate value EXIT_PROGRAM (which is 10) into register $V0 which is a code for $V0 to prepare to exit the program when syscall is issues
syscall

# The value 34 was assigned to B[8] after the program finished executing
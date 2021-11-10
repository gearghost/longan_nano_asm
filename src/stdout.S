#stdout

.section .text.stdout

#################################################
#  Desc:                                        #
#    - 	printf																	#
#  Params:                                      #
#    -  a0: string address                      #
#  Returns:                                     #
#    -  N/A                                     #
#################################################

.globl _printf
.type _printf,@function
_printf:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	add s0, sp, 8

	mv t6, a0
	li t5, 0
1:
	lbu t2, (t6)
	mv a0, t2
	jal _put_char
	addi t6, t6, 1
	bne t2, t5, 1b

	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

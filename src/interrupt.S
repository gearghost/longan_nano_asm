# eclic interrupt

.equ ECLIC_BASE, 0xD2000000
.equ ECLIC_CLICINTIE_BASE, ECLIC_BASE+0x1001

.section .text.interrupt

##################################################
# Desc:                                          #
#   - Sets interrupt enabled bit on ECLIC        #
# Params:                                        #
#   - a0: The IRQ No. of the interrupt to set    #
# Returns:                                       #
#   - N/A                                        #
##################################################

.globl _eclic_set_ie
.type _eclic_set_ie,@function
_eclic_set_ie:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8
	
	li a1, ECLIC_CLICINTIE_BASE
	slli a0, a0, 0x2
	add a0, a0, a1
	li a1, 0x1
	sb a1, 0(a0)

	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

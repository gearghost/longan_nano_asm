# system timer module

.equ MTIMER_BASE, 0xD1000000 
.equ MTIMER_MTIME_LO_OFFSET, 0x00
.equ MTIMER_MTIME_HI_OFFSET, 0x04

.equ MTIMER_MTIMECMP_LO_OFFSET, 0x08
.equ MTIMER_MTIMECMP_HI_OFFSET, 0x0C

.equ IRQ_MTIMER, 0x07

.equ MTIMER_FREQ, 0x1E8480


.section .text.timer

#########################################
#  Desc:                                #
#		- Enable mtimer interrupt           #
#  Params:                              #
#   - N/A																#
#  Returns:                             #
#   - N/A																#
#########################################

.globl _enable_mtimer_interrupt
.type _enable_mtimer_interrupt,@function
_enable_mtimer_interrupt:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8
  li a0, IRQ_MTIMER
	jal _eclic_set_ie
	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

##########################################
#  Desc:                                 #
#    - Get the current value of MTIME		 #
#  Params:                               #
#    - N/A                               #
#  Returns:                              #
#    - a0: The value of MTIME_LO         #
#    - a1: The value of MTIME_HI         #
##########################################

.globl _get_mtime
.type _get_mtime,@function
_get_mtime:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8
	li t0, MTIMER_BASE
	lw a0, MTIMER_MTIME_LO_OFFSET(t0)
	lw a1, MTIMER_MTIME_HI_OFFSET(t0)
	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

###########################################
#  Desc:																	#
#    - Set the value for MTIME            #
#  Params:                                #
#    - a0: The value of MTIME_LO          #
#    - a1: The value of MTIME_HI          #
#  Returns:                               #
#    - N/A															  #
###########################################

.globl _set_mtime
.type _set_mtime,@function
_set_mtime:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8
	li t0, MTIMER_BASE
	sw a0, MTIMER_MTIME_LO_OFFSET(t0)
	sw a1, MTIMER_MTIME_HI_OFFSET(t0)
	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

############################################
#  Desc:															     #
#    - Get the current value of MTIMECMP   #
#  Params:																 #
#    - N/A                                 #
#  Returns:                                #
#    - a0: The value of MTIMECMP_LO				 #
#    - a1: The value of MTIMECMP_HI        #
############################################

.globl _get_mtimecmp
.type _get_mtimecmp,@function
_get_mtimecmp:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8
	li t0, MTIMER_BASE
	lw a0, MTIMER_MTIMECMP_LO_OFFSET(t0)
	lw a1, MTIMER_MTIMECMP_HI_OFFSET(t0)
	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

#############################################
#  Desc:                                    #
#    - Set the value for MTIMECMP           #
#  Params:                                  #
#    - a0: the value of MTIMECMP_LO         #
#    - a1: the value of MTIMECMP_HI         #
#  Returns:                                 #
#    - N/A                                  #
#############################################

.globl _set_mtimecmp
.type _set_mtimecmp,@function
_set_mtimecmp:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8
	li t0, MTIMER_BASE
	sw a0, MTIMER_MTIMECMP_LO_OFFSET(t0)
	sw a1, MTIMER_MTIMECMP_HI_OFFSET(t0)
	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

#############################################
#  Desc:                                    #
#    - Delay milliseconds                   #
#  Params:                                  #
#    - a0: Milliseconds to delay            #
#  Returns:                                 #
#    - N/A                                  #
#############################################

.globl _delay_ms
.type _delay_ms,@function
_delay_ms:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8
	li t0, MTIMER_FREQ
	li t1, 1000
	divu t1, t0, t1
	mul t1, t1, a0
	mulhu t2, t1, a0
	
	jal _get_mtime
	mv a2, a1
	add a1, a1, t2
	sltu a2, a1, a2
	add a0, a0, t1
	add a0, a2, a0

	jal _set_mtimecmp
	# TODO This assumes that the SYSTIMER is the only enabled interrupt
	wfi

	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

#############################################
#  Desc:                                    #
#    - Delay microsecond (non-interrupt)    #
#  Params:                                  #
#    - a0: Microseconds to delay            #
#  Returns:                                 #
#    - N/A                                  #
#############################################

.globl _delay_us
.type _delay_us,@function
_delay_us:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8
	li a5, MTIMER_BASE
	lw a4, MTIMER_MTIME_LO_OFFSET(a5) # reference time
	li a3, 27 #CORECLOCK/4.000.000 = 27 (108 Mhz) or 24 for 96 Mhz
	mul a0, a0, a3 #us to clock count
_delay_wait_loop:
	lw a3, MTIMER_MTIME_LO_OFFSET(a5) 
	sub a3, a3, a4 #now - reference time
	bltu a3, a0, _delay_wait_loop
	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

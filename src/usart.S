# usart module

.equ RCU_BASE, 0x40021000
.equ RCU_CFG0, RCU_BASE + 0x04
.equ RCU_CFG1, RCU_BASE + 0x2C
.equ RCU_APB2RST, RCU_BASE + 0x0C 
.equ RCU_AHBEN, RCU_BASE + 0x14
.equ RCU_APB2EN, RCU_BASE + 0x18

.equ RCU_CFG0_PLLSEL, (1 << 16) 
.equ RCU_CFG1_PREDV0SEL, (1 << 16) 
.equ RCU_PREDV0SRC_CKPLL1, (1 << 16)
.equ RCU_CFG1_PREDV0, (0b1111 << 0)
.equ RCU_CFG1_PREDV1, (0b1111 << 4)
.equ RCU_CFG1_PLL1MF, (0b1111 << 8)
.equ RCU_CFG0_PLLMF_4, (1 << 29)
.equ RCU_CFG0_PLLMF_18_21, (0b1111 << 18)
.equ RCU_CFG0_AHBPSC, (0b1111 < 4)
.equ RCU_CFG0_APB1PSC, (0b111 < 8)
.equ RCU_CFG0_APB2PSC, (0b111 < 11)
.equ RCU_CFG0_SCSS, (0b11 << 2)

.equ RCU_APB2EN_PAEN, (1 << 2)
.equ RCU_USART0_EN, (1 << 14)
.equ RCU_USART0_RST, (1 << 14)

.equ GPIO_MD_OUTPUT_50MHz, 0b11
.equ GPIO_CTL_AFIO_PP_OUTPUT, 0b10
.equ GPIO_MD_INPUT, 0b00
.equ GPIO_MODE_IN_FLOATING, 0b01

.equ GPIOA_BASE,0x40010800

.equ GPIOA_CTL0, GPIOA_BASE + 0x00
.equ GPIOA_CTL1, GPIOA_BASE + 0x04
.equ GPIOA_ISTAT, GPIOA_BASE + 0x08
.equ GPIOA_OCTL, GPIOA_BASE + 0x0C

.equ PA9, (1 << 9)
.equ PA10, (1 <<10)

.equ USART0_BASE, 0x40013800
.equ USART0_STAT, USART0_BASE + 0x00
.equ USART0_DATA, USART0_BASE + 0x04
.equ USART0_BAUD, USART0_BASE + 0x08
.equ USART0_CTL0, USART0_BASE + 0x0C
.equ USART0_CTL1, USART0_BASE + 0x10
.equ USART0_CTL2, USART0_BASE + 0x14

.equ IRC8M_VALUE, 8000000
.equ HXTAL_VALUE, 8000000

.equ USART_BAUD_FRADIV, 0xf
.equ USART_BAUD_INTDIV, (0xfff << 4)
.equ USART_CTL0_REN, (1 << 2)
.equ USART_CTL0_TEN, (1 << 3)
.equ USART_CTL0_WL, (1 << 12)
.equ USART_CTL0_UEN, (1 << 13)
.equ USART_CTL0_PM, (1 << 9)
.equ USART_CTL0_PCEN, (1 << 10)
.equ USART_CTL1_STB, (0b11 << 12)
.equ USART_CTL2_RTSEN, (1 << 8)
.equ USART_CTL2_CTSEN, (1 << 9)
.equ USART_STAT_TBE, (1 << 7)


.section .rodata.usart

/* exponent of AHB, APB1 and APB2 clock divider */
.globl _ahb_exp
_ahb_exp:
	.byte  0
	.byte  0
	.byte  0
	.byte  0
	.byte  0
	.byte  0
	.byte  0
	.byte  0
	.byte  1
	.byte  2
	.byte  3
	.byte  4
	.byte  6
	.byte  7
	.byte  8
	.byte  9

.globl _apb1_exp
_apb1_exp:
	.byte  0
	.byte  0
	.byte  0
	.byte  0
	.byte  1
	.byte  2
	.byte  3
	.byte  4

.globl _apb2_exp
_apb2_exp:
	.byte  0
	.byte  0
	.byte  0
	.byte  0
	.byte  1
	.byte  2
	.byte  3
	.byte  4

.section .text.usart

#################################################
#  Desc:                                        #
#    - 	Get RCU clock frequency						      #
#  Params:                                      #
#    - a0: 0 for system clock, 1 for AHB clock  #
#      2 for APB1 clock, 3 for APB2 clock       #
#  Returns:                                     #
#    - a1: the selected clock frequency         #
#################################################

.globl _get_rcu_clk_freq
.type _get_rcu_clk_freq,@function
_get_rcu_clk_freq:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8

  # get system clock selected state
	li t0, RCU_CFG0
	lw t1, (t0)
	andi t1, t1, RCU_CFG0_SCSS 
	srli t1, t1, 2
	li t2, 0
	beq t1, t2, 1f
	li t2, 1
	beq t1, t2, 2f
	li t2, 2
	beq t1, t2, 3f
	li t6, IRC8M_VALUE
	j 13f
 /*defaut select CK_IRC8M as system clock source*/
1:
 /*select CK_IRC8M as system clock source*/
 li t6, IRC8M_VALUE
 j 13f
2:
 /*select CK_HXTAL as system clock source*/
 li t6, HXTAL_VALUE
 j 13f
3:
 /*select CK_PLL as system clock source*/
	lw t1, (t0)
	li t2, RCU_CFG0_PLLSEL
	and t1, t1, t2
	beq t1, t2, 4f
	j 8f
4:
	li t0, RCU_CFG1
	li t5, HXTAL_VALUE
	lw t2, (t0)
	li t3, RCU_CFG1_PREDV0SEL
	and t2, t2, t3
	li t3, RCU_PREDV0SRC_CKPLL1
	beq t2, t3, 5f
	j 7f
5:	
	li t0, RCU_CFG1
	lw t1, (t0)
	li t2, RCU_CFG1_PREDV1
	and t2, t1, t2
	srli t2, t2, 4
	addi t2, t2, 1
	lw t1, (t0)
	li t3, RCU_CFG1_PLL1MF
	and t3, t1, t3
	srli t3, t3, 8
	addi t3, t3, 2
	li t4, 17
	bne t3, t4, 6f
	li t3, 20
6:
	divu t5, t5, t2
	mul t5, t5, t3
7:
	lw t1, (t0)
	li t2, RCU_CFG1_PREDV0
	and t2, t2, t1
	addi t2, t2, 1
	divu t5, t5, t2
	j 9f
8:
  li t2, IRC8M_VALUE
	li t3, 2
	divu t5, t2, t3
	j 9f
9:
	li t0, RCU_CFG0
	lw t1, (t0)
	li t2, RCU_CFG0_PLLMF_18_21
	and t2, t2, t1
	srli t2, t2, 18
	lw t1, (t0)
	li t3, RCU_CFG0_PLLMF_4
	and t3, t3, t1
	srli t3, t3, 29
	beqz t3, 10f
	ori t2, t2, 0x10 
10:
	li t3, 15
	bltu t2, t3, 11f
	addi t2, t2, 1
	j 12f
11:
	add t2, t2, 2
12:
	mul t6, t5, t2
	li t3, 15
	bne t2, t3, 13f
	li t1, 6 
	mul t1, t5, t1
	li t3, 2
	divu t4, t5, t3
	add t6, t1, t4
13:
  li t0, RCU_CFG0
	lw t1, (t0)
	li t2, RCU_CFG0_AHBPSC
	and t2, t2, t1
	srli t2, t2, 4
	la t0, _ahb_exp
	add t0, t0, t2
	lw t1, (t0)
  srl t5, t6, t1
	li t0, 0
	beq a0, t0, 14f
	li t0, 1
	beq a0, t0, 15f
	li t0, 2
	beq a0, t0, 16f
	li t0, 3
	beq a0, t0, 17f
	li a1, -1
	j 18f
14:
	mv a1, t6
	j 18f 
15:
	mv a1, t5
  j 18f
16:
	li t0, RCU_CFG0
	lw t1, (t0)
	li t2, RCU_CFG0_APB1PSC
	and t2, t2, t1
	srli t2, t2, 8
	la t0, _apb1_exp
	add t0, t0, t2
	lw t1, (t0)
	srl t5, t5, t1
	mv a1, t5
	j 18f
17:
	li t0, RCU_CFG0
	lw t1, (t0)
	li t2, RCU_CFG0_APB2PSC
	and t2, t2, t1
	srli t2, t2, 11
	la t0, _apb2_exp
	add t0, t0, t2
	lw t1, (t0)
	srl t5, t5, t1
	mv a1, t5
18:
	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret
	
#################################################
#  Desc:                                        #
#    - Init USART0 module												#
#  Params:                                      #
#    - N/A                                      #
#  Returns:                                     #
#    - N/A                                      #
#################################################

.globl _init_usart0
.type _init_usart0,@function
_init_usart0:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8

  #PA9 for TX, PA10 for RX with USART0
	li t0, RCU_APB2EN
	lw t1, (t0)
	li t2, (RCU_APB2EN_PAEN|RCU_USART0_EN)
	or t1, t1, t2
	sw t1, (t0)

	li t0, GPIOA_CTL1
	lw t1, (t0)
	ori t1, t1, ((GPIO_MD_OUTPUT_50MHz << 4) | (GPIO_CTL_AFIO_PP_OUTPUT << 6) | (GPIO_MD_INPUT << 8) | (GPIO_MODE_IN_FLOATING << 10))
	sw t1, (t0)
  
	#Reset USART0 module
	li t0, RCU_APB2RST
	lw t1, (t0)
	li t2, RCU_USART0_RST
	or t1, t1, t2
	sw t1, (t0)

	li t0, RCU_APB2RST
	lw t1, (t0)
	li t2, RCU_USART0_RST
	not t2,t2
	and t1, t1, t2
	sw t1, (t0)

  #Set baudrate
	jal _set_usart0_baudrate

  #Set word length
	li a0, 0
	jal _set_usart0_word_length


  #Set stop bit
	li a0, 0
	jal _set_usart0_stop_bit


  #Set parity config
	li a0, 0
	jal _set_usart0_parity_config


  #Set rts config
	li a0, 0
	jal _set_usart0_hardware_flow_rts_config


  #Set cts config
	li a0, 0
	jal _set_usart0_hardware_flow_cts_config


  #Set receiver enable
	li a0, 1
	jal _set_usart0_receiver_config


  #Set transmitter enable
	li a0, 1
	jal _set_usart0_transmitter_config


  #Set USART0 module enable
	li a0, 1
	jal _enable_usart0


  ##Set USART0 RBNE Interrupt enable
	#li a0, 1
	#jal _enable_usart0_rbneie

	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

#################################################
#  Desc:                                        #
#    - 	Set usart0 baud rate  						      #
#  Params:                                      #
#    -  N/A                                     #
#  Returns:                                     #
#    -  N/A                                     #
#################################################

.globl _set_usart0_baudrate
.type _set_usart0_baudrate,@function
_set_usart0_baudrate:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8
  # get APB2 clock frequency, usart0 in apb2
	li a0, 3
	jal _get_rcu_clk_freq
	li t0, -1
	bne a1, t0, 1f
	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret
1:
	/* oversampling by 16, configure the value of USART_BAUD */
	li t1, 115200
	li t2, 2
	divu t2, t1, t2
	add t2, t2, a1
	divu t2, t2, t1
	li t3, 0x0000fff0
	and t3, t3, t2
	andi t4, t2, 0x0000000f

	li t0, USART0_BAUD
	li t1, USART_BAUD_INTDIV
	ori t1, t1, USART_BAUD_FRADIV
	or t2, t3, t4
	and t1, t1, t2
	sw t1, (t0)
	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

#################################################
#  Desc:                                        #
#    - 	Set usart0 word length 						      #
#  Params:                                      #
#    -  a0: 0 for 8 bits, 1 for 9 bits          #
#  Returns:                                     #
#    -  N/A                                     # 
#################################################

.globl  _set_usart0_word_length
.type _set_usart0_word_length,@function
_set_usart0_word_length:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8
	
	li t0, USART0_CTL0
	lw t1, (t0)
	li t2, ~USART_CTL0_WL
	and t2, t2, t1
	sw t2, (t0)

	lw t1, (t0)
	slli a0, a0, 12
	or t2, t1, a0
	sw t2, (t0)
	
	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

#################################################
#  Desc:                                        #
#    - 	Set usart0 stop bit 				  		      #
#  Params:                                      #
#    -  a0: 0 for 1 bit, 1 for 0.5 bit          #
#           2 for 2 bits  3 for 1.5 bits        #
#  Returns:                                     #
#    -  N/A                                     #
#################################################

.globl _set_usart0_stop_bit
.type _set_usart0_stop_bit,@function
_set_usart0_stop_bit:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8

	li t0, USART0_CTL1
	lw t1, (t0)
	li t2, ~USART_CTL1_STB
	and t2, t2, t1
	sw t2, (t0)

	lw t1, (t0)
	slli a0, a0, 12
	or t2, t1, a0
	sw t2, (t0)

	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

#################################################
#  Desc:                                        #
#    - 	Set usart0 parity config  				  	  #
#  Params:                                      #
#    -  a0: 0b0x disable parity mode            #
#           0b10 for even parity, 0b11 for odd  #
#  Returns:                                     #
#    -  N/A                                     #
#################################################

.globl _set_usart0_parity_config
.type _set_usart0_parity_config,@function
_set_usart0_parity_config:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8

	li t0, USART0_CTL0
	lw t1, (t0)
	andi t2, t1, (USART_CTL0_PM|USART_CTL0_PCEN)
	sw t2, (t0)

	lw t1, (t0)
	slli a0, a0, 9
	or t2, t1, a0
	sw t2, (t0)

	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

#################################################
#  Desc:                                        #
#    - 	Set usart0 hardware flow rts config     #
#  Params:                                      #
#    -  a0: 1 for enable, 0 for disable         #
#  Returns:                                     #
#    -  N/A                                     #
#################################################

.globl _set_usart0_hardware_flow_rts_config
.type _set_usart0_hardware_flow_rts_config,@function
_set_usart0_hardware_flow_rts_config:
	add sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8

	li t0, USART0_CTL2
	lw t1, (t0)
	andi t2, t1, ~USART_CTL2_RTSEN
	sw t2, (t0)

	lw t1, (t0)
	slli a0, a0, 8
	or t2, t1, a0
	sw t2, (t0)

	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

#################################################
#  Desc:                                        #
#    - 	Set usart0 hardware flow cts config     #
#  Params:                                      #
#    -  a0: 1 for enable, 0 for disable         #
#  Returns:                                     #
#    -  N/A                                     #
#################################################

.globl _set_usart0_hardware_flow_cts_config
.type _set_usart0_hardware_flow_cts_config,@function
_set_usart0_hardware_flow_cts_config:
	add sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8

	li t0, USART0_CTL2
	lw t1, (t0)
	andi t2, t1, ~USART_CTL2_CTSEN
	sw t2, (t0)

	lw t1, (t0)
	slli a0, a0, 9
	or t2, t1, a0
	sw t2, (t0)

	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

#################################################
#  Desc:                                        #
#    - 	Set usart0 receiver config							#
#  Params:                                      #
#    -  a0: 1 for enable, 0 for disable         #
#  Returns:                                     #
#    -  N/A                                     #
#################################################

.globl _set_usart0_receiver_config
.type _set_usart0_receiver_config,@function
_set_usart0_receiver_config:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8

	li t0, USART0_CTL0
	lw t1, (t0)
	andi t2, t1, ~USART_CTL0_REN
	sw t2, (t0)

	lw t1, (t0)
	slli a0, a0, 2
	or t2, t1, a0
	sw t2, (t0)

	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

#################################################
#  Desc:                                        #
#    - 	Set usart0 transmitter config	  				#
#  Params:                                      #
#    -  a0: 1 for enable, 0 for disable         #
#  Returns:                                     #
#    -  N/A                                     #
#################################################

.globl _set_usart0_transmitter_config
.type _set_usart0_transmitter_config,@function
_set_usart0_transmitter_config:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8

	li t0, USART0_CTL0
	lw t1, (t0)
	andi t2, t1, ~USART_CTL0_TEN
	sw t2, (t0)

	lw t1, (t0)
	slli a0, a0, 3
	or t2, t1, a0
	sw t2, (t0)

	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

#################################################
#  Desc:                                        #
#    - 	enable usart0               	  				#
#  Params:                                      #
#    -  a0: 1 for enable, 0 for disable         #
#  Returns:                                     #
#    -  N/A                                     #
#################################################

.globl _enable_usart0
.type _enable_usart0,@function
_enable_usart0:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8

	li t0, USART0_CTL0
	lw t1, (t0)
	slli a0, a0, 13
	or t2, t1, a0
	sw t2, (t0)

	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

#################################################
#  Desc:                                        #
#    - 	enable usart0 RBNE interrupt   	  			#
#  Params:                                      #
#    -  a0: 1 for enable, 0 for disable         #
#  Returns:                                     #
#    -  N/A                                     #
#################################################

.globl _enable_usart0_rbneie
.type _enable_usart0_rbneie,@function
_enable_usart0_rbneie:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8

	li t0, USART0_CTL0
	lw t1, (t0)
	slli a0, a0, 5
	or t2, t1, a0
	sw t2, (t0)

	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

#################################################
#  Desc:                                        #
#    - 	write data to usart0          	  			#
#  Params:                                      #
#    -  a0: 32bits, but only low 8bits sent     #
#  Returns:                                     #
#    -  N/A                                     #
#################################################

.globl _put_char
.type _put_char,@function
_put_char:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8
	
	li t0, USART0_DATA
	andi t1, a0, 0x1FF
	sw t1, (t0)

	li t0, USART0_STAT
1:
	lw t1, (t0)
	andi t1, t1, USART_STAT_TBE
	beqz t1, 1b
	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

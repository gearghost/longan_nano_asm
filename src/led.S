#longan nano on-board led module

.equ RCU_BASE, 0x40021000
.equ RCU_APB2EN, RCU_BASE + 0x18
.equ RCU_APB2EN_PAEN, (1 << 2)
.equ RCU_APB2EN_PCEN, (1 << 4)

.equ GPIOA_BASE, 0x40010800
.equ GPIOA_CTL0, GPIOA_BASE + 0x00
.equ GPIOA_ISTAT,	GPIOA_BASE + 0x08
.equ GPIOA_OCTL, GPIOA_BASE + 0x0C
.equ GPIOA_BOP, GPIOA_BASE + 0x10
.equ GPIOA_BC, GPIOA_BASE + 0x14

.equ GPIOC_BASE, 0x40011000
.equ GPIOC_CTL1, GPIOC_BASE + 0x04
.equ GPIOC_ISTAT,GPIOC_BASE + 0x08
.equ GPIOC_OCTL, GPIOC_BASE + 0x0C
.equ GPIOC_BOP, GPIOC_BASE + 0x10
.equ GPIOC_BC, GPIOC_BASE + 0x14

.equ GPIO_CTL_GPIO_PP, 0b00 << 2
.equ GPIO_MD_OUTPUT_LOW, 0b11
.equ GPIO_PIN1, (1<<1)
.equ GPIO_PIN2, (1<<2)
.equ GPIO_PIN13, (1 << 13)

.section .text.led

##############################################
#  Desc:                                     #
#    - Init on-board LED                     #
#  Params:                                   #
#    - N/A                                   #
#  Returns:                                  #
#    - N/A                                   #
##############################################

.globl _led_init
.type _led_init,@function
_led_init:
	li t0,RCU_APB2EN
	lw t1,(t0)
	ori t1,t1,(RCU_APB2EN_PAEN|RCU_APB2EN_PCEN) #enable PA and PB GPIO
	sw t1,(t0)

	li t0, GPIOA_CTL0
	lw t1, (t0)
	li t2, 0xffffff00
	and t1,t1,t2
	li t2,(((GPIO_MD_OUTPUT_LOW|GPIO_CTL_GPIO_PP) << 4)|((GPIO_MD_OUTPUT_LOW|GPIO_CTL_GPIO_PP) << 8)) #enable PA1 and PA2 Port
	or t1,t1,t2
	sw t1,(t0)

	li t0, GPIOC_CTL1
	lw t1, (t0)
	li t2, 0xff0fffff
	and t1, t1, t2
	li t2, ((GPIO_MD_OUTPUT_LOW | GPIO_CTL_GPIO_PP) << 20) #enable PC13 Port
	or t1, t1, t2
	sw t1, (t0)
	ret
	
###############################################
#  Desc:                                      #
#    - Toggle the red light of LED            #
#  Params:                                    #
#    - N/A                                    #
#  Returns:                                   #
#    - N/A                                    #
###############################################

.globl _led_red_toggle
.type _led_red_toggle,@function
_led_red_toggle:
	li t0,GPIOC_ISTAT	
	li t1,GPIO_PIN13
	lw t2,(t0)
	li t3, 1
	and t2,t2,t1
	srli t2,t2,13
	sub t3,t3,t2
	beqz t3,1f
	li t0,GPIOC_BOP
	li t1,GPIO_PIN13
	sw t1,(t0)
	ret
1:
	li t0,GPIOC_BC
	li t1,GPIO_PIN13
	sw t1,(t0)
	ret

###############################################
#  Desc:                                      #
#    - Toggle the green light of LED          #
#  Params:                                    #
#    - N/A                                    #
#  Returns:                                   #
#    - N/A                                    #
###############################################

.globl _led_green_toggle
.type _led_green_toggle,@function
_led_green_toggle:
	li t0,GPIOA_ISTAT	
	li t1,GPIO_PIN1
	lw t2,(t0)
	li t3, 1
	and t2,t2,t1
	srli t2,t2,1
	sub t3,t3,t2
	beqz t3,1f
	li t0,GPIOA_BOP
	li t1,GPIO_PIN1
	sw t1,(t0)
	ret
1:
	li t0,GPIOA_BC
	li t1,GPIO_PIN1
	sw t1,(t0)
	ret

###############################################
#  Desc:                                      #
#    - Toggle the blue light of LED           #
#  Params:                                    #
#    - N/A                                    #
#  Returns:                                   #
#    - N/A                                    #
###############################################

.globl _led_blue_toggle
.type _led_blue_toggle,@function
_led_blue_toggle:
	li t0,GPIOA_ISTAT	
	li t1,GPIO_PIN2
	lw t2,(t0)
	li t3, 1
	and t2,t2,t1
	srli t2,t2,2
	sub t3,t3,t2
	beqz t3,1f
	li t0,GPIOA_BOP
	li t1,GPIO_PIN2
	sw t1,(t0)
	ret
1:
	li t0,GPIOA_BC
	li t1,GPIO_PIN2
	sw t1,(t0)
	ret

###############################################
#  Desc:                                      #
#    - Turn on the red light of LED           #
#  Params:                                    #
#    - N/A                                    #
#  Returns:                                   #
#    - N/A                                    #
###############################################

.globl _red_light
.type _red_light,@function
_red_light:
	li t0, GPIOA_OCTL	
	lw t1, (t0)
	ori t1, t1, ((0x1 << 1) | (0x1 << 2))
	sw t1, (t0)
	li t0, GPIOC_OCTL
	lw t1, (t0)
	li t2, ~(0x1 << 13)
	and t2, t2, t1
	sw t2, (t0)
	ret

###############################################
#  Desc:                                      #
#    - Turn on the yellow light of LED        #
#  Params:                                    #
#    - N/A                                    #
#  Returns:                                   #
#    - N/A                                    #
###############################################

.globl _yellow_light
.type _yellow_light,@function
_yellow_light:
	li t0, GPIOA_OCTL	
	lw t1, (t0)
	andi t1,t1,~(0x1 << 1)
	sw t1, (t0)
	lw t1, (t0)
	ori t1, t1, (0x1 << 2)
	sw t1, (t0)
	li t0, GPIOC_OCTL
	lw t1, (t0)
	li t2, ~(0x1 << 13)
	and t2, t2, t1
	sw t2, (t0)
	ret
 
###############################################
#  Desc:                                      #
#    - Turn on the green light of LED         #
#  Params:                                    #
#    - N/A                                    #
#  Returns:                                   #
#    - N/A                                    #
###############################################

.globl _green_light
.type _green_light,@function
_green_light:
	li t0, GPIOA_OCTL	
	lw t1, (t0)
	andi t1,t1,~(0x1 << 1)
	sw t1, (t0)
	lw t1, (t0)
	ori t1, t1, (0x1 << 2)
	sw t1, (t0)
	li t0, GPIOC_OCTL
	lw t1, (t0)
	li t2, (0x1 << 13)
	or t2, t2, t1
	sw t2, (t0)
	ret

###############################################
#  Desc:                                      #
#    - Turn on the purple light of LED        #
#  Params:                                    #
#    - N/A                                    #
#  Returns:                                   #
#    - N/A                                    #
###############################################

.globl _purple_light
.type _purple_light,@function
_purple_light:
	li t0, GPIOA_OCTL	
	lw t1, (t0)
	ori t1,t1,(0x1 << 1)
	sw t1, (t0)
	lw t1, (t0)
	andi t1, t1, ~(0x1 << 2)
	sw t1, (t0)
	li t0, GPIOC_OCTL
	lw t1, (t0)
	li t2, ~(0x1 << 13)
	and t2, t2, t1
	sw t2, (t0)
	ret

###############################################
#  Desc:                                      #
#    - Turn on the blue light of LED          #
#  Params:                                    #
#    - N/A                                    #
#  Returns:                                   #
#    - N/A                                    #
###############################################

.globl _blue_light
.type _blue_light,@function
_blue_light:
	li t0, GPIOA_OCTL	
	lw t1, (t0)
	ori t1,t1,(0x1 << 1)
	sw t1, (t0)
	lw t1, (t0)
	andi t1, t1, ~(0x1 << 2)
	sw t1, (t0)
	li t0, GPIOC_OCTL
	lw t1, (t0)
	li t2, (0x1 << 13)
	or t2, t2, t1
	sw t2, (t0)
	ret

###############################################
#  Desc:                                      #
#    - Loop toggling light of LED             #
#  Params:                                    #
#    - N/A                                    #
#  Returns:                                   #
#    - N/A                                    #
###############################################

.globl _led_loop
.type _led_loop,@function
_led_loop:
    jal _led_red_toggle
		li a0, 10000
		jal _delay_us
		jal _led_green_toggle
		li a0, 10000
		jal _delay_us
		jal _led_blue_toggle
		j _led_loop

/* bootstrap */

#include "test.S"

.equ CSR_MSTATUS, 0x300
.equ MSTATUS_MIE, 0x00000008 

.equ CSR_MMISC_CTL,  0x7d0
.equ CSR_MTVT, 0x307

.section .rodata

_red: .asciz "red light on\r\n"

_green: .asciz "green light on\r\n"

_blue: .asciz "blue light on\r\n"

_purple: .asciz "purple light on\r\n"

_yellow: .asciz "yellow light on\r\n"

.section .init
	
    .weak  eclic_msip_handler
    .weak  eclic_mtip_handler
    .weak  eclic_bwei_handler
    .weak  eclic_pmovi_handler
    .weak  WWDGT_IRQHandler
    .weak  LVD_IRQHandler
    .weak  TAMPER_IRQHandler
    .weak  RTC_IRQHandler
    .weak  FMC_IRQHandler
    .weak  RCU_IRQHandler
    .weak  EXTI0_IRQHandler
    .weak  EXTI1_IRQHandler
    .weak  EXTI2_IRQHandler
    .weak  EXTI3_IRQHandler
    .weak  EXTI4_IRQHandler
    .weak  DMA0_Channel0_IRQHandler
    .weak  DMA0_Channel1_IRQHandler
    .weak  DMA0_Channel2_IRQHandler
    .weak  DMA0_Channel3_IRQHandler
    .weak  DMA0_Channel4_IRQHandler
    .weak  DMA0_Channel5_IRQHandler
    .weak  DMA0_Channel6_IRQHandler
    .weak  ADC0_1_IRQHandler
    .weak  CAN0_TX_IRQHandler
    .weak  CAN0_RX0_IRQHandler
    .weak  CAN0_RX1_IRQHandler
    .weak  CAN0_EWMC_IRQHandler
    .weak  EXTI5_9_IRQHandler
    .weak  TIMER0_BRK_IRQHandler
    .weak  TIMER0_UP_IRQHandler
    .weak  TIMER0_TRG_CMT_IRQHandler
    .weak  TIMER0_Channel_IRQHandler
    .weak  TIMER1_IRQHandler
    .weak  TIMER2_IRQHandler
    .weak  TIMER3_IRQHandler
    .weak  I2C0_EV_IRQHandler
    .weak  I2C0_ER_IRQHandler
    .weak  I2C1_EV_IRQHandler
    .weak  I2C1_ER_IRQHandler
    .weak  SPI0_IRQHandler
    .weak  SPI1_IRQHandler
    .weak  USART0_IRQHandler
    .weak  USART1_IRQHandler
    .weak  USART2_IRQHandler
    .weak  EXTI10_15_IRQHandler
    .weak  RTC_Alarm_IRQHandler
    .weak  USBFS_WKUP_IRQHandler
    .weak  EXMC_IRQHandler
    .weak  TIMER4_IRQHandler
    .weak  SPI2_IRQHandler
    .weak  UART3_IRQHandler
    .weak  UART4_IRQHandler
    .weak  TIMER5_IRQHandler
    .weak  TIMER6_IRQHandler
    .weak  DMA1_Channel0_IRQHandler
    .weak  DMA1_Channel1_IRQHandler
    .weak  DMA1_Channel2_IRQHandler
    .weak  DMA1_Channel3_IRQHandler
    .weak  DMA1_Channel4_IRQHandler
    .weak  CAN1_TX_IRQHandler
    .weak  CAN1_RX0_IRQHandler
    .weak  CAN1_RX1_IRQHandler
    .weak  CAN1_EWMC_IRQHandler
    .weak  USBFS_IRQHandler

vector_base:
	j _start
	.align    2
	.word     0
	.word     0
	.word     eclic_msip_handler
	.word     0
	.word     0
	.word  	  0
	.word  	  eclic_mtip_handler
	.word  	  0
	.word  	  0
	.word  	  0
	.word  	  0
	.word  	  0
	.word  	  0
	.word  	  0
	.word 	  0 
	.word  	  0
	.word  	  eclic_bwei_handler
	.word  	  eclic_pmovi_handler
	.word  	  WWDGT_IRQHandler
	.word     LVD_IRQHandler
	.word     TAMPER_IRQHandler
	.word     RTC_IRQHandler 
	.word     FMC_IRQHandler
	.word     RCU_IRQHandler
	.word     EXTI0_IRQHandler
	.word     EXTI1_IRQHandler
	.word     EXTI2_IRQHandler
	.word     EXTI3_IRQHandler
	.word     EXTI4_IRQHandler
	.word     DMA0_Channel0_IRQHandler
	.word     DMA0_Channel1_IRQHandler
	.word     DMA0_Channel2_IRQHandler
	.word     DMA0_Channel3_IRQHandler
	.word     DMA0_Channel4_IRQHandler
	.word     DMA0_Channel5_IRQHandler
	.word     DMA0_Channel6_IRQHandler
	.word     ADC0_1_IRQHandler
	.word     CAN0_TX_IRQHandler
	.word     CAN0_RX0_IRQHandler
	.word     CAN0_RX1_IRQHandler
	.word     CAN0_EWMC_IRQHandler
	.word     EXTI5_9_IRQHandler
	.word     TIMER0_BRK_IRQHandler
	.word     TIMER0_UP_IRQHandler
	.word     TIMER0_TRG_CMT_IRQHandler
	.word     TIMER0_Channel_IRQHandler
	.word     TIMER1_IRQHandler
	.word     TIMER2_IRQHandler
	.word     TIMER3_IRQHandler
	.word     I2C0_EV_IRQHandler
	.word     I2C0_ER_IRQHandler
	.word     I2C1_EV_IRQHandler
	.word     I2C1_ER_IRQHandler
	.word     SPI0_IRQHandler
	.word     SPI1_IRQHandler
	.word     USART0_IRQHandler
	.word     USART1_IRQHandler
	.word     USART2_IRQHandler
	.word     EXTI10_15_IRQHandler
	.word     RTC_Alarm_IRQHandler
	.word     USBFS_WKUP_IRQHandler
	.word     0
	.word     0
	.word     0
	.word     0
	.word     0
	.word     EXMC_IRQHandler
	.word     0
	.word     TIMER4_IRQHandler
	.word     SPI2_IRQHandler
	.word     UART3_IRQHandler
	.word     UART4_IRQHandler
	.word     TIMER5_IRQHandler
	.word     TIMER6_IRQHandler
	.word     DMA1_Channel0_IRQHandler
	.word     DMA1_Channel1_IRQHandler
	.word     DMA1_Channel2_IRQHandler
	.word     DMA1_Channel3_IRQHandler
	.word     DMA1_Channel4_IRQHandler
	.word     0
	.word     0
	.word     CAN1_TX_IRQHandler
	.word     CAN1_RX0_IRQHandler
	.word     CAN1_RX1_IRQHandler
	.word     CAN1_EWMC_IRQHandler
	.word     USBFS_IRQHandler

	.globl _start
	.type _start,@function

_start:

		csrc CSR_MSTATUS, MSTATUS_MIE
		/* Jump to logical address first to ensure correct operation of RAM region  */
    la		a0,	_start
    li		a1,	1
		slli	a1,	a1, 29
    bleu	a1, a0, _start0800
    srli	a1,	a1, 2
    bleu	a1, a0, _start0800
    la		a0,	_start0800
    add		a0, a0, a1
		jr    a0

.section .text

_start0800:

    /* Set the the NMI base to share with mtvec by setting CSR_MMISC_CTL */
    li t0, 0x200
    csrs CSR_MMISC_CTL, t0

		/* Intial the mtvt*/
    la t0, vector_base
    csrw CSR_MTVT, t0
		
.option push
.option norelax
		la gp, __global_pointer$
.option pop
		la sp, _sp

		jal _led_init

		jal _init_usart0

		jal _lcd_init

		#la a0, _logo
		#jal _lcd_load_bmp
		li a0, 50000
		jal _delay_us
		
1:		
		/* red */
		li a0, 0xF800
		jal _lcd_write_bg
		jal _red_light
		la a0, _red
		jal _printf
		li a0, 100000
		jal _delay_us
		
		/* yellow */
		li a0, 0xFFE0
		jal _lcd_write_bg
		jal _yellow_light
		la a0, _yellow
		jal _printf
		li a0, 100000
		jal _delay_us

		/* green */
		li a0, 0x03E0
		jal _lcd_write_bg
		jal _green_light
		la a0, _green
		jal _printf
		li a0, 100000
		jal _delay_us

		/* purple */
		li a0, 0xF81F
		jal _lcd_write_bg
		jal _purple_light
		la a0, _purple
		jal _printf
		li a0, 100000
		jal _delay_us

		/* blue */
		li a0, 0x001F
		jal _lcd_write_bg
		jal _blue_light
		la a0, _blue
		jal _printf
		li a0, 100000
		jal _delay_us
    j 1b

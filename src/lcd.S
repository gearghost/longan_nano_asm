#longan nano on-board lcd driver

.equ LCD_W, 160
.equ LCD_H, 80
.equ LCD_SIZE, LCD_W * LCD_H
.equ CMD_MODE, 0
.equ DATA_MODE, 1
.equ SPI0_BASE, 0x40013000
.equ SPI0_CTL0, SPI0_BASE + 0x00
.equ SPI0_CTL1, SPI0_BASE + 0x04
.equ SPI0_STAT, SPI0_BASE + 0x08
.equ SPI0_DATA, SPI0_BASE + 0x0C

.equ SPI_STAT_TRANS, (1 << 7) #spi0 transmitting bit
.equ SPI_STAT_TBE, (1 << 1) #spi0 transmit buffer empty bit
.equ SPI_CTL1_TXDMAEN, (1 << 1)
.equ SPI_CTL0_BR, (0x7 << 3)
.equ SPI_CTL0_SSM, (0x1 << 9)
.equ SPI_CTL0_SSI, (0x1 << 8)
.equ SPI_CTL0_MSTR, (0x1 << 2)
.equ SPI_CTL0_SPE, (0x1 << 6)
.equ SPI0_CTL0_LSBFIRST, (0x1 << 7)

.equ RCU_BASE, 0x40021000
.equ RCU_APB2RST, RCU_BASE + 0x0C 
.equ RCU_AHBEN, RCU_BASE + 0x14
.equ RCU_APB2EN, RCU_BASE + 0x18

.equ RCU_APB2EN_AFEN, (1 << 0)
.equ RCU_APB2EN_PAEN, (1 << 2)
.equ RCU_APB2EN_PBEN, (1 << 3)
.equ RCU_APB2EN_PCEN, (1 << 4)
.equ RCU_APB2EN_SPI0EN, (1 << 12)
.equ RCU_APB2EN_SPI0RST, (1 << 12)
.equ RCU_AHBEN_DMA0EN, (1 << 0)

.equ DMA0_BASE, 0x40020000
.equ DMA0_CH2CTL, DMA0_BASE + 0x08 + 0x14 * 2
.equ DMA0_CH2CNT, DMA0_BASE + 0x0C + 0x14 * 2
.equ DMA0_CH2PADDR, DMA0_BASE + 0x10 + 0x14 * 2
.equ DMA0_CH2MADDR, DMA0_BASE + 0x14 + 0x14 * 2

.equ GPIOA_BASE,0x40010800
.equ GPIOB_BASE,0x40010C00
.equ GPIOC_BASE,0x40011000

.equ GPIOA_CTL0, GPIOA_BASE + 0x00
.equ GPIOB_CTL0, GPIOB_BASE + 0x00
.equ GPIOC_CTL0, GPIOC_BASE + 0x00
.equ GPIOA_CTL1, GPIOA_BASE + 0x04
.equ GPIOB_CTL1, GPIOB_BASE + 0x04
.equ GPIOC_CTL1, GPIOC_BASE + 0x04
.equ GPIOA_ISTAT, GPIOA_BASE + 0x08
.equ GPIOB_ISTAT, GPIOB_BASE + 0x08
.equ GPIOC_ISTAT, GPIOC_BASE + 0x08
.equ GPIOA_OCTL, GPIOA_BASE + 0x0C
.equ GPIOB_OCTL, GPIOB_BASE + 0x0C
.equ GPIOC_OCTL, GPIOC_BASE + 0x0C

.equ GPIO_MD_OUTPUT_2MHz, 0b10
.equ GPIO_MD_OUTPUT_50MHz, 0b11

.equ GPIO_CTL_AFIO_PP_OUTPUT, 0b10
.equ GPIO_CTL_AFIO_OD_OUPUT, 0b11

.equ DMA_CCR_MEM2MEM, (0x1 << 14)
.equ DMA_CCR_PL, (0x3 << 12)
.equ DMA_CCR_MSIZE, (0x3 << 10)
.equ DMA_CCR_PSIZE, (0x3 << 8)
.equ DMA_CCR_PINC, (0x1 << 6)
.equ DMA_CCR_EN, (0x1 << 0)
.equ DMA_CCR_MINC, (0x1 << 7)
.equ DMA_CCR_CIRC, (0x1 << 5)
.equ DMA_CCR_DIR, (0x1 << 4)

.section .text.lcd

#################################################
#  Desc:                                        #
#    - Set the LCD display mode                 #
#  Params:                                      #
#    - a0: 0 for CMD, 1 for DATA                #
#  Returns:                                     #
#    - N/A                                      #
#################################################

.globl _display_mode
.type _display_mode,@function
_display_mode:
  addi sp , sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8
	li t0, GPIOB_OCTL
	li t1, SPI0_STAT
1:
	lw t2, (t1)
	andi t2, t2, SPI_STAT_TRANS
	bnez t2, 1b
	lw t3, (t0)
	bnez a0, 1f
	andi t3, t3, ~(0x1 << 0)
	sw t3, (t0)
	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret
1:
  ori t3,t3,(0x1 << 0)
	sw t3, (t0)
	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

#################################################
#  Desc:																				#
#    - Write byte to LCD data register          #
#  Params:                                      #
#    - a0:  8 bits (a byte,lsbfirst)            #
#  Returns:																			#
#    - N/A																			#
#################################################

.globl _spi_w8
.type _spi_w8,@function
_spi_w8:
  /* push call stack frame */
  addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8
	li t0, SPI0_STAT	
	li t1, SPI0_DATA
1:
	lw t2, (t0)
	andi t3, t2, SPI_STAT_TBE
	beqz t3, 1b
	sb a0, (t1)
	/* pop call stack frame */
	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

################################################
#  Desc:                                       #
#    - Write two byte to LCD data register     #
#  Params:                                     #
#    - a0:  16 bits (half of word,lsbfirst)    #
#  Returns:                                    #
#    - N/A                                     #
################################################

.globl _spi_w16
.type _spi_w16,@function
_spi_w16:
  addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8
  mv t5, a0
	srli t1, t5, 8
	mv a0, t1
	jal _spi_w8
	andi t1, t5, 0xff
	mv a0, t1
	jal _spi_w8
	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

################################################
#  Desc:                                       #
#    - Write backgroud color to LCD            #
#  Params:                                     #
#    - a0:  16 bits color  (lsbfirst)          #
#  Returns:                                    #
#    - N/A                                     #
################################################

.globl _lcd_write_bg
.type _lcd_write_bg,@function
_lcd_write_bg:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8
	li t0, 25600
	li t1, -2
	la t2, _fb
	andi t3, a0, 0x00FF
	srli t4, a0, 8
1:
	addi t1, t1, 2
	add t5, t2, t1
	sb t3, 0(t5)
	sb t4, 1(t5)
	ble t1, t0, 1b
	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

################################################
#  Desc:                                       #
#    - Write bmp to LCD                        #
#  Params:                                     #
#    - a0:  bmp data address                   #
#  Returns:                                    #
#    - N/A                                     #
################################################

.globl _lcd_load_bmp
.type _lcd_load_bmp,@function
_lcd_load_bmp:
	addi sp, sp, -8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8
	li t0, 25600
	li t1, -1
	la t2, _fb
1:
	addi t1, t1, 1
	add t3, t2, t1
	add t4, a0, t1
	lw t5, (t4)
	sb t5, (t3)
	ble t1, t0, 1b
	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	ret

################################################
#  Desc:                                       #
#    - Init LCD module and turn it on          #
#  Params:                                     #
#    - N/A                                     #
#  Returns:                                    #
#    - N/A                                     #
################################################

.globl _lcd_init
.type _lcd_init,@function
_lcd_init:
  # Reset the SPI0 peripheral.
	addi sp,sp,-8
	sw ra, 4(sp)
	sw s0, 0(sp)
	addi s0, sp, 8
  li t0, RCU_APB2RST
	lw t1, (t0)
	li t2, RCU_APB2EN_SPI0RST
	or t1, t1, t2
  sw t1, (t0)
	lw t1, (t0)
	li t2, ~RCU_APB2EN_SPI0RST
	and t1, t1, t2 
	sw t1, (t0)

  # Clear the DMA channel 2 configuration.
	li t0, DMA0_CH2CTL
	li t1, 0x00000000
	sw t1, (t0)

  # Enable the GPIOA, GPIOB, SPI0, and DMA0 peripherals.
	li t0, RCU_APB2EN
	lw t1, (t0)
	li t2, (RCU_APB2EN_PAEN|RCU_APB2EN_PBEN|RCU_APB2EN_SPI0EN)
	or t2, t2, t1
	sw t2, (t0)

  # Enable DMA0 module
	li t0, RCU_AHBEN
  lw t1, (t0)
	li t2, RCU_AHBEN_DMA0EN
	or t2, t2, t1
	sw t2, (t0)

  # Configure pins A5 and A7 as high-speed alternate-function outputs.
	li t0, GPIOA_CTL0
	lw t1, (t0)
	li t2,~((3 << 20)|(3 << 28)|(3 << 22)|(3 << 30))
	and t2,t2,t1
	sw t2, (t0)
	lw t1, (t0)
	li t2, (GPIO_MD_OUTPUT_50MHz << 20 | GPIO_CTL_AFIO_PP_OUTPUT << 22 | GPIO_MD_OUTPUT_50MHz << 28 | GPIO_CTL_AFIO_PP_OUTPUT << 30)
	or t2 ,t2, t1
	sw t2, (t0)

  # Configure pins B0, B1, and B2 as low-speed push-pull outputs.
	li t0, GPIOB_CTL0
	lw t1, (t0)
	li t2, ~((3 << 0) | (3 << 2)| (3 << 4) | (3 << 6)| (3 << 8)| (3 << 10))
	and t2, t2, t1
	sw t2, (t0)
	lw t1, (t0)
	ori t2, t1, (GPIO_MD_OUTPUT_2MHz << 0 | GPIO_MD_OUTPUT_2MHz << 4| GPIO_MD_OUTPUT_2MHz << 8)
	sw t2, (t0)

  # DMA configuration:
  # - Memory-to-peripheral mode.
  # - Circular mode enabled for continuous transfer.
  # - Increment source ptr, don't increment destination ptr.
  # - 8-bit transfer length.
  # - High-priority. Not that priority matters; it's the only one.
	li t0, DMA0_CH2CTL
	lw t1, (t0)
	li t2,~(DMA_CCR_MEM2MEM | DMA_CCR_PL | DMA_CCR_MSIZE | DMA_CCR_PSIZE | DMA_CCR_PINC | DMA_CCR_EN)
	and t2, t1, t2
	sw t2, (t0)
	lw t1, (t0)
	li t2, (( 0x2 << 12 ) | DMA_CCR_MINC | DMA_CCR_CIRC | DMA_CCR_DIR )
	or t2, t2, t1
	sw t2, (t0)

	#Configure the DMA Memory address
	li t0, DMA0_CH2MADDR
	la t1, _fb
	sw t1, (t0)

	#Configure the DMA Peripheral address
	li t0, DMA0_CH2PADDR
	li t1, SPI0_DATA
	sw t1, (t0)

  #Configure the DMA transmit data size
	li t0, DMA0_CH2CNT
	li t1, (LCD_SIZE * 2) #cause lcd color is 16bit,so must multiply by 2
	sw t1, (t0)

  # SPI1 setup: host mode, no baud rate division, sw cs pin control,
  # TX DMA enabled, 8-bit frames, msb-first, enable the peripheral.
  # Some of those settings are the default state after a reset.
  li t0, SPI0_CTL1
	lw t1, (t0) 
	ori t2, t1, SPI_CTL1_TXDMAEN
	sw t2, (t0)
  
	li t0, SPI0_CTL0
	lw t1, (t0)
	andi t2, t1, ~SPI_CTL0_BR
	sw t2, (t0)
	
	lw t1, (t0)
	ori t2, t1, ( SPI_CTL0_SSM | SPI_CTL0_SSI | SPI_CTL0_MSTR | SPI_CTL0_SPE )
	sw t2, (t0)

  # Set initial SPI pin positions.
  # Pull the 'chip select' pin high to de-select the display.
	li t0,GPIOB_OCTL
	lw t1,(t0)
	ori t1,t1,(0x1 << 2)
	sw t1,(t0)

  # Pull the 'reset' pin low to reset the display.
	lw t1, (t0)
	andi t1, t1, ~(0x1 << 1)
	sw t1, (t0)

  # Wait 100ms and pull the 'reset' pin high.
	li a0, 10000
	jal _delay_us
	lw t1, (t0)
	ori t1, t1, (0x1 << 1)
	sw t1, (t0)

  # Pull the 'chip select' pin low to get the display's attention.
	lw t1, (t0)
	andi t1, t1, ~(0x1 << 2)
	sw t1, (t0)

  # Send initialization commands to the display before starting DMA.
  # Software reset.
	li a0, CMD_MODE
	jal _display_mode
	li a0,0x01
	jal _spi_w8
	li a0,10000
	jal _delay_us
	# Display off.
	li a0,0x28
	jal _spi_w8
	# 'Inverted' color mode, so that 0 is 'off' and 1 is 'on':
	li a0,0x21
	jal _spi_w8
	# Color mode: 16bpp.
	li a0,0x3A
	jal _spi_w8
	li a0,DATA_MODE
	jal _display_mode
	li a0,0x05
	jal _spi_w8
	#memory access control
	li a0,CMD_MODE
	jal _display_mode
	li a0,0x36
	jal _spi_w8
	la a0,DATA_MODE
	jal _display_mode
	li a0,0x20
	jal _spi_w8
	# Exit sleep mode.
	li a0,CMD_MODE
	jal _display_mode
	li a0,0x11
	jal _spi_w8
	li a0,10000
	jal _delay_us
	# Display on.
	li a0,0x29
	jal _spi_w8
	li a0,10000
	jal _delay_us
	# Set drawing window.
	# Column set
	li a0,0x2A
	jal _spi_w8
	li a0,DATA_MODE
	jal _display_mode
	li a0,1
	jal _spi_w16
	li a0,LCD_W
	jal _spi_w16
	# Row set
	li a0,CMD_MODE
	jal _display_mode
	li a0,0x2B
	jal _spi_w8
	li a0,DATA_MODE
	jal _display_mode
	li a0,26
	jal _spi_w16
	li a0,(LCD_H + 25)
	jal _spi_w16
	# Set 'write to RAM' mode.
	li a0,CMD_MODE
	jal _display_mode
	li a0,0x2C
	jal _spi_w8

	# Set 'data' transfer mode to start sending pixel data.
	li a0,DATA_MODE
	jal _display_mode
	

	# Set 'LSBFIRST' mode to make it easier to set color values.
	li t0,SPI0_CTL0
	lw t1,(t0)
	ori t1,t1,SPI0_CTL0_LSBFIRST
	sw t1,(t0)

  # Enable the circular DMA transfer.
	li t0,DMA0_CH2CTL
	lw t1,(t0)
	ori t1,t1,DMA_CCR_EN
	sw t1,(t0)

	lw ra, 4(sp)
	lw s0, 0(sp)
	addi sp, sp, 8
	
	ret

/*
 * Test program to boot an STM32 chip with the absolute
 * minimum required code for teaching about the chips.
 *
 * Copyright William Ransohoff, Vivonomicon, LLC, 2017
 *
 * Open source under the MIT License
 */

.syntax unified
.cpu cortex-m0plus
.fpu softvfp
.thumb

.global vtable
.global default_interrupt_handler
.global reset_handler

/*
 * The vector table.
 */
.type vtable, %object
.section .vector_table,"a",%progbits
vtable:
    .word _estack
    .word reset_handler
    .word NMI_handler
    .word hard_fault_handler
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0
    .word SVC_handler
    .word 0
    .word 0
    .word pending_SV_handler
    .word SysTick_handler
    // 16-31
    .word window_watchdog_IRQ_handler
    .word PVD_IRQ_handler
    .word RTC_IRQ_handler
    .word flash_IRQ_handler
    .word RCC_IRQ_handler
    .word EXTI0_1_IRQ_handler
    .word EXTI2_3_IRQ_handler
    .word EXTI4_15_IRQ_handler
    .word 0
    .word DMA1_chan1_IRQ_handler
    .word DMA1_chan2_3_IRQ_handler
    .word DMA1_chan4_5_6_7_IRQ_handler
    .word ADC1_COMP_IRQ_handler
    .word LPTIM1_break_IRQ_handler
    .word 0
    .word TIM2_IRQ_handler
    // 32-47
    .word 0
    .word 0
    .word 0
    .word 0
    .word TIM21_IRQ_handler
    .word 0
    .word TIM22_IRQ_handler
    .word I2C1_IRQ_handler
    .word 0
    .word SPI1_IRQ_handler
    .word 0
    .word 0
    .word USART2_IRQ_handler
    .word LPUART1_IRQ_handler
    .word 0
    .word 0
    // 48
    // (Location to boot from for RAM startup)
    #define boot_ram_base  0xF108F85F
    .word boot_ram_base

    /*
     * Setup weak aliases for each exception handler to the
     * default one. These can be updated later, or just
     * overridden since they're weak refs.
     * The reset_handler is set up separately.
     */
    .weak NMI_handler
    .thumb_set NMI_handler,default_interrupt_handler
    .weak hard_fault_handler
    .thumb_set hard_fault_handler,default_interrupt_handler
    .weak SVC_handler
    .thumb_set SVC_handler,default_interrupt_handler
    .weak pending_SV_handler
    .thumb_set pending_SV_handler,default_interrupt_handler
    .weak SysTick_handler
    .thumb_set SysTick_handler,default_interrupt_handler
    .weak window_watchdog_IRQ_handler
    .thumb_set window_watchdog_IRQ_handler,default_interrupt_handler
    .weak PVD_IRQ_handler
    .thumb_set PVD_IRQ_handler,default_interrupt_handler
    .weak RTC_IRQ_handler
    .thumb_set RTC_IRQ_handler,default_interrupt_handler
    .weak flash_IRQ_handler
    .thumb_set flash_IRQ_handler,default_interrupt_handler
    .weak RCC_IRQ_handler
    .thumb_set RCC_IRQ_handler,default_interrupt_handler
    .weak EXTI0_1_IRQ_handler
    .thumb_set EXTI0_1_IRQ_handler,default_interrupt_handler
    .weak EXTI2_3_IRQ_handler
    .thumb_set EXTI2_3_IRQ_handler,default_interrupt_handler
    .weak EXTI4_15_IRQ_handler
    .thumb_set EXTI4_15_IRQ_handler,default_interrupt_handler
    .weak DMA1_chan1_IRQ_handler
    .thumb_set DMA1_chan1_IRQ_handler,default_interrupt_handler
    .weak DMA1_chan2_3_IRQ_handler
    .thumb_set DMA1_chan2_3_IRQ_handler,default_interrupt_handler
    .weak DMA1_chan4_5_6_7_IRQ_handler
    .thumb_set DMA1_chan4_5_6_7_IRQ_handler,default_interrupt_handler
    .weak ADC1_COMP_IRQ_handler
    .thumb_set ADC1_COMP_IRQ_handler,default_interrupt_handler
    .weak LPTIM1_break_IRQ_handler
    .thumb_set LPTIM1_break_IRQ_handler,default_interrupt_handler
    .weak TIM2_IRQ_handler
    .thumb_set TIM2_IRQ_handler,default_interrupt_handler
    .weak TIM21_IRQ_handler
    .thumb_set TIM21_IRQ_handler,default_interrupt_handler
    .weak TIM22_IRQ_handler
    .thumb_set TIM22_IRQ_handler,default_interrupt_handler
    .weak I2C1_IRQ_handler
    .thumb_set I2C1_IRQ_handler,default_interrupt_handler
    .weak SPI1_IRQ_handler
    .thumb_set SPI1_IRQ_handler,default_interrupt_handler
    .weak USART2_IRQ_handler
    .thumb_set USART2_IRQ_handler,default_interrupt_handler
    .weak LPUART1_IRQ_handler
    .thumb_set LPUART1_IRQ_handler,default_interrupt_handler
.size vtable, .-vtable

/*
 * A 'Default' interrupt handler. This is where interrupts
 * which are not otherwise configured will go.
 * It is an infinite loop, because...well, we weren't
 * expecting the interrupt, so what can we do?
 */
.section .text.default_interrupt_handler,"ax",%progbits
default_interrupt_handler:
    default_interrupt_loop:
      B default_interrupt_loop
.size default_interrupt_handler, .-default_interrupt_handler

/*
 * The Reset handler. Called on reset.
 */
.type reset_handler, %function
reset_handler:
  // Set the stack pointer to the end of the stack.
  // The '_estack' value is defined in our linker script.
  LDR  r0, =_estack
  MOV  sp, r0

  // Copy data from flash to RAM data init section.
  // R2 will store our progress along the sidata section.
  MOVS r0, #0
  // Load the start/end addresses of the data section,
  // and the start of the data init section.
  LDR  r1, =_sdata
  LDR  r2, =_edata
  LDR  r3, =_sidata
  B    copy_sidata_loop

  copy_sidata:
    // Offset the data init section by our copy progress.
    LDR  r4, [r3, r0]
    // Copy the current word into data, and increment.
    STR  r4, [r1, r0]
    ADDS r0, r0, #4

  copy_sidata_loop:
    // Unless we've copied the whole data section, copy the
    // next word from sidata->data.
    ADDS r4, r0, r1
    CMP  r4, r2
    BCC  copy_sidata

  // Once we are done copying the data section into RAM,
  // move on to filling the BSS section with 0s.
  MOVS r0, #0
  LDR  r1, =_sbss
  LDR  r2, =_ebss
  B    reset_bss_loop

  // Zero out the BSS segment.
  reset_bss:
    // Store a 0 and increment by a word.
    STR  r0, [r1]
    ADDS r1, r1, #4

  reset_bss_loop:
    // We'll use R1 to count progress here; if we aren't
    // done, reset the next word and increment.
    CMP  r1, r2
    BCC  reset_bss

  // Branch to the 'main' method.
  B    main
.size reset_handler, .-reset_handler

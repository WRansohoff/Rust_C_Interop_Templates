#![no_std]
#![no_main]

// Include C bindings.
include!( concat!( env!( "OUT_DIR"), "/bindings.rs" ) );

// Halt when the program panics.
extern crate panic_halt;

// Generic ARM Cortex-M includes.
use cortex_m::peripheral::syst::SystClkSource;
use cortex_m_rt::entry;
// Chip-specific PAC include.
use stm32_pac::stm32l0x1 as stm32;

#[entry]
fn main() -> ! {
  // Prepare SysTick peripheral.
  let cm_p = cortex_m::Peripherals::take().unwrap();
  let mut syst = cm_p.SYST;
  syst.set_clock_source( SystClkSource::Core );
  // Checkout STM32 peripheral singleton.
  let p = stm32::Peripherals::take().unwrap();
  let rcc = p.RCC;
  let gpiob = p.GPIOB;
  // Set ~1s SysTick period; STM32L0 boots to ~2.1MHz internal osc.
  syst.set_reload( 2_097_000 );
  // Set up GPIO pin B3 as push-pull output.
  rcc.iopenr.write( |w| w.iopben().set_bit() );
  gpiob.moder.write( |w| w.mode3().output() );
  gpiob.otyper.write( |w| w.ot3().clear_bit() );

  // Call the C function.
  // Note: Rust assumes that foreign C functions are unsafe.
  let blinks = unsafe { get_number() };

  // Restart the SysTick counter.
  syst.clear_current();
  syst.enable_counter();

  // Blink the LED N times.
  for _i in 0..blinks {
    while !syst.has_wrapped() {};
    gpiob.odr.write( |w| w.od3().set_bit() );
    while !syst.has_wrapped() {};
    gpiob.odr.write( |w| w.od3().clear_bit() );
  }
  loop {}
}

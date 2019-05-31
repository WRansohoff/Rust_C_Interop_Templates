#![no_std]

// Halt when the program panics.
extern crate panic_halt;

// Peripheral Access Crate.
use stm32_pac::stm32l0x1 as stm32;

// Keep track of the peripherals singleton.
// TODO: static mut variable aren't ideal. This is bad practice.
static mut P: Option<stm32::Peripherals> = None;

#[no_mangle]
pub extern "C" fn test_init() {
  unsafe {
    P = Some( stm32::Peripherals::take().unwrap() );
    // Set up GPIO pin B3 as push-pull output.
    let periphs = P.as_mut().unwrap();
    periphs.RCC.iopenr.write( |w| w.iopben().set_bit() );
    periphs.GPIOB.moder.write( |w| w.mode3().output() );
    periphs.GPIOB.otyper.write( |w| w.ot3().clear_bit() );
  }
}

#[no_mangle]
pub extern "C" fn led_on() {
  unsafe { P.as_mut().unwrap().GPIOB.odr.write( |w| w.od3().set_bit() ) }
}

#[no_mangle]
pub extern "C" fn led_off() {
  unsafe { P.as_mut().unwrap().GPIOB.odr.write( |w| w.od3().clear_bit() ) }
}

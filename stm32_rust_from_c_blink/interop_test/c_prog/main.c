#include "main.h"

void __attribute__( ( optimize( "O0" ) ) ) delay( int len ) {
  for ( int i = 0; i < len; ++i ) {
    __asm volatile( "nop" );
  }
}

int main( void ) {
  // Call Rust function to initialize peripherals.
  test_init();

  while ( 1 ) {
    // Call Rust functions to toggle the LED.
    led_on();
    delay( 100000 );
    led_off();
    delay( 200000 );
  }
}

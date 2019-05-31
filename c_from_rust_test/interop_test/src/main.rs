// Include C bindings.
include!( concat!( env!( "OUT_DIR"), "/bindings.rs" ) );

fn main() {
  // Note: Rust assumes that foreign C functions are unsafe.
  unsafe { println!( "Number: {}", get_number() ); }
}

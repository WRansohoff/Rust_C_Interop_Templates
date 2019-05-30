mod bindings;

fn main() {
  // Note: Rust assumes that foreign C functions are unsafe.
  unsafe { println!( "Number: {}", bindings::get_number() ); }
}

extern crate bindgen;

use std::env;
use std::fs::File;
use std::io::Write;
use std::path::PathBuf;

fn main() {
  // Run bindgen to create Rust bindings for the C library.
  let pwd = &PathBuf::from( env::var_os( "CARGO_MANIFEST_DIR" ).unwrap() );
  println!( "cargo:rustc-link-search=native={}/c_prog", pwd.display() );
  println!( "cargo:rustc-link-lib=static=interop_test" );

  let bindings = bindgen::Builder::default()
                   .header( "bindings.h" )
                   .ctypes_prefix( "cty" )
                   .generate()
                   .expect( "Failed to run bindgen" );
  let out_path = PathBuf::from( env::var( "OUT_DIR" ).unwrap() );
  bindings.write_to_file( out_path.join( "bindings.rs" ) )
          .expect( "Failed to write bindings to file." );

  // Make sure the linker script is generated.
  macro_rules! ld_mem { () => ( "ld/stm32l031x6.x" ) };
  File::create( out_path.join( "memory.x" ) )
      .expect( "Failed to open memory sections file" )
      .write_all( include_bytes!( ld_mem!() ) )
      .expect( "Failed to write memory sections file" );
  println!( "cargo:rustc-link-search={}", out_path.display() );
}

extern crate bindgen;

use std::env;
use std::path::PathBuf;

fn main() {
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
}

use std::env;
use std::fs::File;
use std::path::PathBuf;
use std::process::{ Command, Stdio };
// TODO: Platform-independent way to auto-generate bindings.rs file.
use std::os::unix::io::{ FromRawFd, IntoRawFd };

fn main() {
  let pwd = &PathBuf::from( env::var_os( "CARGO_MANIFEST_DIR" ).unwrap() );
  println!( "cargo:rustc-link-search=native={}/c_prog", pwd.display() );
  println!( "cargo:rustc-link-lib=static=interop_test" );

  let bindings_rs = File::create( format!( "{}/src/bindings.rs", pwd.display() ) )
                         .expect( "Couldn't create file" );
  Command::new( "bindgen" ).arg( "--ctypes-prefix=cty" )
                           .arg( format!( "{}/bindings.h", pwd.display() ) )
                           .stdout( unsafe { Stdio::from_raw_fd( bindings_rs.into_raw_fd() ) } )
                           .status().unwrap();
}

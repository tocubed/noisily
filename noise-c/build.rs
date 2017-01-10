extern crate cheddar;

use std::process::Command;
use std::str;

use std::env;

fn main() {
    let source_file = "src/lib.rs";

    let target_dir = "target/".to_string() + &env::var("PROFILE").unwrap();
    let crate_dir = target_dir + "/deps";

    let output = Command::new("rustc")
        .args(&["-Z", "unstable-options", "--pretty=expanded"])
        .args(&["-L", &crate_dir])
        .arg(&source_file)
        .output()
        .expect("Failed to run cargo subprocess");

    if !output.status.success() {
        let error = str::from_utf8(&output.stderr).unwrap();
        panic!("Cargo subprocess failed: {}", error)
    };

    let source = str::from_utf8(&output.stdout).unwrap();

    cheddar::Cheddar::new()
        .expect("Could not read cargo manifest")
        .source_string(source)
        .run_build("include/noise_c.h");
}

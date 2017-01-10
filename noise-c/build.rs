extern crate cheddar;
extern crate regex;

use std::process::Command;
use std::str;

use std::env;

use regex::Regex;

use std::fs::File;
use std::io::Write;

// TODO This could be smaller
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

    let header = cheddar::Cheddar::new()
        .expect("Could not read cargo manifest")
        .source_string(source)
        .compile("")
        .expect("Error while compiling source into header");

    let re = Regex::new(r"#include <std(\w*).h>").unwrap();
    let final_header = re.replace_all(&header, "#include \"portable_std$1.h\"");

    let mut file = File::create("include/noise_c.h").expect("Unable to create header file");
    file.write_all(final_header.as_bytes()).expect("Unable to write to header file");
}

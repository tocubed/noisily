extern crate noise;

use noise::PermutationTable;
use noise::{perlin2, perlin3, perlin4};
use noise::{value2, value3, value4};
use noise::{open_simplex2, open_simplex3, open_simplex4};
use noise::{cell2_range, cell3_range, cell4_range};
use noise::{cell2_range_inv, cell3_range_inv, cell4_range_inv};
use noise::{cell2_value, cell3_value, cell4_value};
use noise::{cell2_manhattan, cell3_manhattan, cell4_manhattan};
use noise::{cell2_manhattan_inv, cell3_manhattan_inv, cell4_manhattan_inv};
use noise::{cell2_manhattan_value, cell3_manhattan_value, cell4_manhattan_value};


#[repr(C)]
pub struct ns_PermutationTable(pub PermutationTable);

#[allow(non_snake_case)]
#[no_mangle]
pub extern "C" fn ns_PermutationTable_create(seed: u32, period: u32) -> *const ns_PermutationTable {
    let perm_table = PermutationTable::new_periodic(seed, period);
    let table = ns_PermutationTable(perm_table);
    Box::into_raw(Box::new(table))
}

#[allow(non_snake_case)]
#[no_mangle]
pub extern "C" fn ns_PermutationTable_destroy(table: *mut ns_PermutationTable) {
    unsafe {
        drop(Box::from_raw(table));
    }
}


macro_rules! noise2cfn {
    ($ext:ident, $int:ident) => {
        #[no_mangle]
        pub extern "C" fn $ext(table: *const ns_PermutationTable, x: f64, y: f64) -> f64 {
            unsafe {
                let ns_PermutationTable(table) = *table;
                $int(&table, &[x, y])
            }
        }
    }
}

macro_rules! noise3cfn {
    ($ext:ident, $int:ident) => {
        #[no_mangle]
        pub extern "C" fn $ext(table: *const ns_PermutationTable, x: f64, y: f64, z: f64) -> f64 {
            unsafe {
                let ns_PermutationTable(table) = *table;
                $int(&table, &[x, y, z])
            }
        }
    }
}

macro_rules! noise4cfn {
    ($ext:ident, $int:ident) => {
        #[no_mangle]
        pub extern "C" fn $ext(table: *const ns_PermutationTable, x: f64, y: f64, z: f64, w: f64) -> f64 {
            unsafe {
                let ns_PermutationTable(table) = *table;
                $int(&table, &[x, y, z, w])
            }
        }
    }
}

noise2cfn!(ns_perlin2, perlin2);
noise3cfn!(ns_perlin3, perlin3);
noise4cfn!(ns_perlin4, perlin4);

noise2cfn!(ns_value2, value2);
noise3cfn!(ns_value3, value3);
noise4cfn!(ns_value4, value4);

noise2cfn!(ns_open_simplex2, open_simplex2);
noise3cfn!(ns_open_simplex3, open_simplex3);
noise4cfn!(ns_open_simplex4, open_simplex4);

noise2cfn!(ns_cell2_range, cell2_range);
noise3cfn!(ns_cell3_range, cell3_range);
noise4cfn!(ns_cell4_range, cell4_range);

noise2cfn!(ns_cell2_range_inv, cell2_range_inv);
noise3cfn!(ns_cell3_range_inv, cell3_range_inv);
noise4cfn!(ns_cell4_range_inv, cell4_range_inv);

noise2cfn!(ns_cell2_value, cell2_value);
noise3cfn!(ns_cell3_value, cell3_value);
noise4cfn!(ns_cell4_value, cell4_value);

noise2cfn!(ns_cell2_manhattan, cell2_manhattan);
noise3cfn!(ns_cell3_manhattan, cell3_manhattan);
noise4cfn!(ns_cell4_manhattan, cell4_manhattan);

noise2cfn!(ns_cell2_manhattan_inv, cell2_manhattan_inv);
noise3cfn!(ns_cell3_manhattan_inv, cell3_manhattan_inv);
noise4cfn!(ns_cell4_manhattan_inv, cell4_manhattan_inv);

noise2cfn!(ns_cell2_manhattan_value, cell2_manhattan_value);
noise3cfn!(ns_cell3_manhattan_value, cell3_manhattan_value);
noise4cfn!(ns_cell4_manhattan_value, cell4_manhattan_value);

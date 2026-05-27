// Copyright (c) 2025-present Cadena Bitcoin
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#[cfg(test)]
mod test_lib;

use dlccryptlib::{get_address, get_xpub};
#[cfg(feature = "with-pyo3")]
use dlccryptlib_py;

use std::ffi::CString;
use std::os::raw::c_char;

// Conditional compilation to exclude PyO3-related code for Android
#[cfg(feature = "with-pyo3")]
use pyo3::prelude::*;
#[cfg(feature = "with-pyo3")]
use pyo3::wrap_pyfunction;

// ##### Facade functions for C-style-interface invocations
// Additional C exports for Flutter wallet operations
#[no_mangle]
pub extern "C" fn get_xpub_c() -> *mut c_char {
    match get_xpub() {
        Ok(xpub) => CString::new(xpub).unwrap().into_raw(),
        Err(e) => error_as_cstr_prefix(e),
    }
}

#[no_mangle]
pub extern "C" fn get_address_c(index: u32) -> *mut c_char {
    match get_address(index) {
        Ok(address) => CString::new(address).unwrap().into_raw(),
        Err(e) => error_as_cstr_prefix(e),
    }
}

#[no_mangle]
pub extern "C" fn free_cstring(s: *mut c_char) {
    unsafe {
        if s.is_null() {
            return;
        }
        let _ = CString::from_raw(s);
    }
}

// Return error with an "ERROR: " prefix, as a C string
fn error_as_cstr_prefix(error: String) -> *mut c_char {
    CString::new(format!("ERROR: {}", error))
        .unwrap()
        .into_raw()
}

#[cfg(feature = "with-pyo3")]
#[pymodule]
fn dlcplazacryptlib(_py: Python, m: &Bound<'_, PyModule>) -> PyResult<()> {
    // m.add_function(wrap_pyfunction!(init, m)?)?;
    // m.add_function(wrap_pyfunction!(reinit_for_testing, m)?)?;
    m.add_function(wrap_pyfunction!(dlccryptlib_py::init_with_entropy, m)?)?;
    m.add_function(wrap_pyfunction!(dlccryptlib_py::get_xpub, m)?)?;
    m.add_function(wrap_pyfunction!(dlccryptlib_py::get_public_key, m)?)?;
    m.add_function(wrap_pyfunction!(dlccryptlib_py::get_address, m)?)?;
    // m.add_function(wrap_pyfunction!(verify_public_key, m)?)?;
    m.add_function(wrap_pyfunction!(dlccryptlib_py::sign_hash_ecdsa, m)?)?;
    m.add_function(wrap_pyfunction!(
        dlccryptlib_py::create_deterministic_nonce,
        m
    )?)?;
    // m.add_function(wrap_pyfunction!(sign_schnorr_with_nonce, m)?)?;
    // m.add_function(wrap_pyfunction!(combine_pubkeys, m)?)?;
    // m.add_function(wrap_pyfunction!(combine_seckeys, m)?)?;
    m.add_function(wrap_pyfunction!(
        dlccryptlib_py::create_cet_adaptor_sigs,
        m
    )?)?;
    // m.add_function(wrap_pyfunction!(verify_cet_adaptor_sigs, m)?)?;
    // m.add_function(wrap_pyfunction!(create_final_cet_sigs, m)?)?;
    Ok(())
}

// Copyright (c) 2025-present Cadena Bitcoin
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

use bitcoin::hex::FromHex;
use bitcoin::key::{Keypair, Secp256k1};
use bitcoin::secp256k1::PublicKey;
use secp256k1_zkp::schnorr::Signature as SchnorrSignature;

pub(crate) fn keypair_from_sec_key_hex(sec_key_hex: &str) -> Result<Keypair, String> {
    let secbin =
        <[u8; 32]>::from_hex(&sec_key_hex).map_err(|e| format!("Error in hex string {}", e))?;
    let secp = Secp256k1::new();
    let keypair = Keypair::from_seckey_slice(&secp, &secbin)
        .map_err(|e| format!("Error in secret key processing {}", e))?;
    Ok(keypair)
}

pub(crate) fn pubkey_from_hex(pub_key_hex: &str) -> Result<PublicKey, String> {
    let pubbin = <[u8; 33]>::from_hex(&pub_key_hex)
        .map_err(|e| format!("Error in hex string {} ({})", e, pub_key_hex))?;
    let pubkey = PublicKey::from_slice(&pubbin)
        .map_err(|e| format!("Error in public key processing {}", e))?;
    Ok(pubkey)
}

pub(crate) fn hash_from_hex(hash_hex: &str) -> Result<[u8; 32], String> {
    let hashbin =
        <[u8; 32]>::from_hex(&hash_hex).map_err(|e| format!("Error in hex string {}", e))?;
    Ok(hashbin)
}

pub(crate) fn schnorr_sig_from_hex(sig_hex: &str) -> Result<SchnorrSignature, String> {
    let sigbin = <[u8; 64]>::from_hex(&sig_hex)
        .map_err(|e| format!("Error in signature string {} ({})", e, sig_hex))?;
    let sig = SchnorrSignature::from_slice(&sigbin)
        .map_err(|e| format!("Error in signature processing {}", e))?;
    Ok(sig)
}

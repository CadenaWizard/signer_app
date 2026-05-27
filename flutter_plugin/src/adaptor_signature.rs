// Copyright (c) 2025-present Cadena Bitcoin
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

use bitcoin::hashes::{sha256, sha256t_hash_newtype, Hash};
use bitcoin::hex::DisplayHex;
use bitcoin::key::{Keypair, Secp256k1};
use bitcoin::secp256k1::ecdsa::Signature;
use bitcoin::secp256k1::{Message, PublicKey, SecretKey, XOnlyPublicKey};
use bitcoin::EcdsaSighashType;
use core::ptr;
use secp256k1_sys::{
    types::{c_int, c_uchar, c_void, size_t},
    CPtr, SchnorrSigExtraParams,
};
use secp256k1_zkp::schnorr::Signature as SchnorrSignature;
use secp256k1_zkp::{EcdsaAdaptorSignature, Scalar, Signing, Verification};

extern "C" fn constant_nonce_fn(
    nonce32: *mut c_uchar,
    _msg32: *const c_uchar,
    _msg_len: size_t,
    _key32: *const c_uchar,
    _xonly_pk32: *const c_uchar,
    _algo16: *const c_uchar,
    _algo_len: size_t,
    data: *mut c_void,
) -> c_int {
    unsafe {
        ptr::copy_nonoverlapping(data as *const c_uchar, nonce32, 32);
    }
    1
}

/// Create a Schnorr signature using the provided nonce
pub(crate) fn schnorrsig_sign_with_nonce<S: Signing>(
    secp: &Secp256k1<S>,
    msg: &Message,
    keypair: &Keypair,
    nonce: &[u8; 32],
) -> SchnorrSignature {
    unsafe {
        let mut sig = [0u8; secp256k1_zkp::constants::SCHNORR_SIGNATURE_SIZE];
        let extra_params =
            SchnorrSigExtraParams::new(Some(constant_nonce_fn), nonce.as_c_ptr() as *const c_void);
        assert_eq!(
            1,
            secp256k1_sys::secp256k1_schnorrsig_sign_custom(
                secp.ctx().as_ref(),
                sig.as_mut_c_ptr(),
                msg.as_c_ptr(),
                32_usize,
                keypair.as_c_ptr(),
                &extra_params,
            )
        );

        SchnorrSignature::from_slice(&sig).unwrap()
    }
}

pub(crate) fn sign_hash_ecdsa_with_key<S: Signing>(
    secp: &Secp256k1<S>,
    hash: &[u8; 32],
    signing_key: &SecretKey,
) -> Result<Vec<u8>, String> {
    let m = Message::from_digest_slice(hash).unwrap();
    let mut sig = secp.sign_ecdsa(&m, &signing_key).serialize_der().to_vec();
    sig.push(EcdsaSighashType::All as u8);
    Ok(sig)
}

const BIP340_MIDSTATE: [u8; 32] = [
    0x9c, 0xec, 0xba, 0x11, 0x23, 0x92, 0x53, 0x81, 0x11, 0x67, 0x91, 0x12, 0xd1, 0x62, 0x7e, 0x0f,
    0x97, 0xc8, 0x75, 0x50, 0x00, 0x3c, 0xc7, 0x65, 0x90, 0xf6, 0x11, 0x64, 0x33, 0xe9, 0xb6, 0x6a,
];

sha256t_hash_newtype! {
    /// BIP340 Hash Tag
    pub struct BIP340HashTag = raw(BIP340_MIDSTATE, 64);

    /// BIP340 Hash
    #[hash_newtype(backward)]
    pub struct BIP340Hash(_);
}

pub(crate) fn create_schnorr_hash(
    msg: &Message,
    nonce: &XOnlyPublicKey,
    pubkey: &XOnlyPublicKey,
) -> [u8; 32] {
    let mut buf = Vec::<u8>::new();
    buf.extend(nonce.serialize());
    buf.extend(pubkey.serialize());
    buf.extend(msg.as_ref().to_vec());
    BIP340Hash::hash(&buf).to_byte_array()
}

pub(crate) fn schnorr_pubkey_to_pubkey(
    schnorr_pubkey: &XOnlyPublicKey,
) -> Result<PublicKey, String> {
    let mut buf = Vec::<u8>::with_capacity(33);
    buf.push(0x02);
    buf.extend(schnorr_pubkey.serialize());
    Ok(PublicKey::from_slice(&buf).map_err(|e| e.to_string())?)
}

/// Sign a message using Schnorr, using a key
pub(crate) fn sign_schnorr_with_nonce_sec<S: Signing>(
    secp: &Secp256k1<S>,
    keypair: &Keypair,
    msg: &str,
    nonce_sec: &[u8; 32],
) -> Result<SchnorrSignature, String> {
    let msg_hash = sha256::Hash::hash(msg.as_bytes()).to_byte_array();
    let msg_msg = Message::from_digest(msg_hash);
    let sig = schnorrsig_sign_with_nonce(&secp, &msg_msg, &keypair, &nonce_sec);
    Ok(sig)
}

/// Compute a signature point for the given public key, nonce and message.
fn schnorrsig_compute_sig_point<S: Verification>(
    secp: &Secp256k1<S>,
    pubkey: &XOnlyPublicKey,
    nonce: &XOnlyPublicKey,
    message: &Message,
) -> Result<PublicKey, String> {
    let hash = create_schnorr_hash(message, nonce, pubkey);
    let pk = schnorr_pubkey_to_pubkey(pubkey)?;
    let scalar = Scalar::from_be_bytes(hash).unwrap();
    let tweaked = pk
        .mul_tweak(&secp, &scalar)
        .map_err(|e| e.to_string())
        .map_err(|e| e.to_string())?;
    let npk = schnorr_pubkey_to_pubkey(nonce)?;
    Ok(npk
        .combine(&tweaked)
        .map_err(|e| e.to_string())
        .map_err(|e| e.to_string())?)
}

/// Decompose a bip340 signature into a nonce and a secret key (as byte array)
fn schnorrsig_decompose(signature: &SchnorrSignature) -> Result<(XOnlyPublicKey, &[u8]), String> {
    let bytes = signature.as_ref();
    Ok((
        XOnlyPublicKey::from_slice(&bytes[0..32]).map_err(|e| e.to_string())?,
        &bytes[32..64],
    ))
}

fn message_hash(msg: &str) -> Result<Message, String> {
    Message::from_digest_slice(sha256::Hash::hash(msg.as_bytes()).as_byte_array())
        .map_err(|e| e.to_string())
}

pub(crate) fn create_digit_adaptor_sig_point<S: Signing + Verification>(
    secp: &Secp256k1<S>,
    oracle_pubkey: &PublicKey,
    digit_index: u8,
    digit_outcome: u8,
    string_template: &str,
    nonce: &PublicKey,
) -> Result<secp256k1_zkp::PublicKey, String> {
    // print("Digit", digit_index, digit_outcome)
    let string_msg = string_template
        .to_string()
        .replace("{digit_index}", &digit_index.to_string())
        .replace("{digit_outcome}", &digit_outcome.to_string());
    // println!(
    //     "Digit outcome: idx {} outcome {} string {} nonce {}",
    //     digit_index,
    //     digit_outcome,
    //     string_msg,
    //     nonce.to_string()
    // );
    let msg_hash = message_hash(&string_msg)?;
    // print(msg_hash)
    let sig_point = schnorrsig_compute_sig_point(
        &secp,
        &oracle_pubkey.x_only_public_key().0,
        &nonce.x_only_public_key().0,
        &msg_hash,
    )?;
    // print("    sig point", sig_point)
    Ok(sig_point)
}

pub(crate) fn combine_pubkeys_wrapper(keys: &[&PublicKey]) -> Result<PublicKey, String> {
    PublicKey::combine_keys(keys).map_err(|err| err.to_string())
}

pub(crate) fn create_cet_adaptor_signatures<S: Signing + Verification>(
    secp: &Secp256k1<S>,
    num_digits: u8,
    num_cets: u64,
    digit_string_template: &str,
    oracle_pubkey: &PublicKey,
    signing_keypair: &Keypair,
    nonces: &Vec<PublicKey>,
    interval_wildcards: &Vec<String>,
    sighashes: &Vec<[u8; 32]>,
) -> Result<Vec<EcdsaAdaptorSignature>, String> {
    if interval_wildcards.len() != num_cets as usize {
        return Err(format!(
            "Invalid number of wildcards {} {}",
            interval_wildcards.len(),
            num_cets
        ));
    }
    if sighashes.len() != num_cets as usize {
        return Err(format!(
            "Invalid number of sighashes {} {}",
            sighashes.len(),
            num_cets
        ));
    }

    // Create adaptor signature points for each digit and outcome (count: digits x 10)
    let mut sig_points: Vec<Vec<secp256k1_zkp::PublicKey>> = Vec::new();
    for d in 0..num_digits {
        let mut sig_points_inner: Vec<secp256k1_zkp::PublicKey> = Vec::new();
        for v in 0..10 {
            let sig_point = create_digit_adaptor_sig_point(
                &secp,
                &oracle_pubkey,
                d,
                v,
                &digit_string_template,
                &nonces[d as usize],
            )?;
            // println!("sig point {}", sig_point.to_string());
            sig_points_inner.push(sig_point);
        }
        sig_points.push(sig_points_inner);
    }

    // Loop through CETs
    debug_assert!(interval_wildcards.len() == num_cets as usize);
    debug_assert!(sighashes.len() == num_cets as usize);
    let mut sigs = Vec::<EcdsaAdaptorSignature>::with_capacity(num_cets as usize);
    for ceti in 0..num_cets {
        let wildcard = &interval_wildcards[ceti as usize].as_bytes();
        let mut keys = Vec::with_capacity(num_digits as usize);
        for d in 0..num_digits {
            let ch = wildcard[d as usize];
            if ch >= 48 && ch <= 57 {
                let digit_val = ch.saturating_sub(48);
                keys.push(&sig_points[d as usize][digit_val as usize]);
            }
        }
        // println!("keys len {} {}", interval_wildcards[ceti as usize], keys.len());

        let aggr_sig_point = combine_pubkeys_wrapper(keys.as_slice())?;
        // println!("aggr_sig_point {}", aggr_sig_point.to_string());

        let cet_tx_sighash = &sighashes[ceti as usize];

        // Creates adaptor signature
        let adaptor_signature = {
            #[cfg(feature = "std")]
            {
                EcdsaAdaptorSignature::encrypt(
                    &secp,
                    &Message::from_digest(*cet_tx_sighash),
                    &signing_keypair.secret_key(),
                    &aggr_sig_point,
                )
            }

            #[cfg(not(feature = "std"))]
            {
                return Err("EcdsaAdaptorSignature::encrypt requires the 'std' feature".to_string());
            }
        };

        sigs.push(adaptor_signature);
    }

    Ok(sigs)
}

pub(crate) fn verify_cet_adaptor_signatures<S: Signing + Verification>(
    secp: &Secp256k1<S>,
    num_digits: u8,
    num_cets: u64,
    digit_string_template: &str,
    oracle_pubkey: &PublicKey,
    signing_pubkey: &PublicKey,
    nonces: &Vec<PublicKey>,
    interval_wildcards: &Vec<String>,
    sighashes: &Vec<[u8; 32]>,
    signatures: &Vec<EcdsaAdaptorSignature>,
) -> Result<(), String> {
    if interval_wildcards.len() != num_cets as usize {
        return Err(format!(
            "Invalid number of wildcards {} {}",
            interval_wildcards.len(),
            num_cets
        ));
    }
    if sighashes.len() != num_cets as usize {
        return Err(format!(
            "Invalid number of sighashes {} {}",
            sighashes.len(),
            num_cets
        ));
    }
    if signatures.len() != num_cets as usize {
        return Err(format!(
            "Invalid number of signatures {} {}",
            signatures.len(),
            num_cets
        ));
    }

    // Create adaptor signature points for each digit and outcome (count: digits x 10)
    let mut sig_points: Vec<Vec<secp256k1_zkp::PublicKey>> = Vec::new();
    for d in 0..num_digits {
        let mut sig_points_inner: Vec<secp256k1_zkp::PublicKey> = Vec::new();
        for v in 0..10 {
            let sig_point = create_digit_adaptor_sig_point(
                &secp,
                &oracle_pubkey,
                d,
                v,
                &digit_string_template,
                &nonces[d as usize],
            )?;
            // println!("sig point {}", sig_point.to_string());
            sig_points_inner.push(sig_point);
        }
        sig_points.push(sig_points_inner);
    }

    // Loop through CETs
    debug_assert!(interval_wildcards.len() == num_cets as usize);
    debug_assert!(sighashes.len() == num_cets as usize);
    debug_assert!(signatures.len() == num_cets as usize);
    for ceti in 0..num_cets {
        let wildcard = &interval_wildcards[ceti as usize].as_bytes();
        let mut keys = Vec::with_capacity(num_digits as usize);
        for d in 0..num_digits {
            let ch = wildcard[d as usize];
            if ch >= 48 && ch <= 57 {
                let digit_val = ch.saturating_sub(48);
                keys.push(&sig_points[d as usize][digit_val as usize]);
            }
        }
        // println!("keys len {} {}", interval_wildcards[ceti as usize], keys.len());

        let aggr_sig_point = combine_pubkeys_wrapper(keys.as_slice())?;
        // println!("aggr_sig_point {}", aggr_sig_point.to_string());

        let cet_tx_sighash = &sighashes[ceti as usize];

        // Verify adaptor signature
        #[cfg(feature = "std")]
        signatures[ceti as usize]
            .verify(
                &secp,
                &Message::from_digest(*cet_tx_sighash),
                &signing_pubkey,
                &aggr_sig_point,
            )
            .map_err(|err| {
                format!(
                    "CET adaptor signature verification failed, cet idx {}, err {:?}",
                    ceti, err
                )
            })?;
    }
    // All is ok
    Ok(())
}

fn aggregate_secret_values(secrets: &Vec<SecretKey>) -> Result<SecretKey, String> {
    if secrets.len() == 0 {
        return Err(format!("At least one key is required!"));
    }
    let secret = secrets[0];
    let result = secrets.iter().skip(1).fold(secret, |accum, s| {
        accum.add_tweak(&Scalar::from(*s)).unwrap()
    });
    Ok(result)
}

pub(crate) fn verify_ecdsa_signature(
    msg: &[u8],
    sig: &[u8],
    pubkey: &PublicKey,
    skip_last_sig_byte: bool,
) -> Result<bool, String> {
    let m = Message::from_digest_slice(&msg).map_err(|e| e.to_string())?;
    let sig_adj = if !skip_last_sig_byte {
        &sig
    } else {
        &sig[0..sig.len() - 1]
    };
    let s = Signature::from_der(&sig_adj).map_err(|e| e.to_string())?;
    let ctx = Secp256k1::new();
    match ctx.verify_ecdsa(&m, &s, &pubkey) {
        Ok(_) => Ok(true),
        Err(e) => Err(format!(
            "Signature verification failed! err {}  msg {}  sig {}  pk {}",
            e,
            &msg.as_hex(),
            &sig.as_hex(),
            &pubkey.to_string(),
        )),
    }
}

/// Create signatures on a CET when outcome signatures are available
pub fn create_final_cet_signatures<S: Signing>(
    secp: &Secp256k1<S>,
    signing_keypair: &Keypair,
    other_pubkey: &PublicKey,
    num_digits: u8,
    oracle_signatures: &Vec<SchnorrSignature>,
    cet_value_wildcard: &str,
    cet_sighash: &[u8; 32],
    other_adaptor_signature: &EcdsaAdaptorSignature,
) -> Result<(Vec<u8>, Vec<u8>), String> {
    let signing_key = &signing_keypair.secret_key();

    // Decompose oracle signatures
    if oracle_signatures.len() != num_digits as usize {
        return Err(format!(
            "Wrong number of oracle signatures {} {}",
            oracle_signatures.len(),
            num_digits
        ));
    }
    debug_assert_eq!(oracle_signatures.len(), num_digits as usize);
    let wildcard = cet_value_wildcard.as_bytes();
    let mut adaptor_secret_vec = Vec::new();
    for d in 0..num_digits {
        let ch = wildcard[d as usize];
        if ch >= 48 && ch <= 57 {
            let (_nonce, secret_value) = schnorrsig_decompose(&oracle_signatures[d as usize])
                .map_err(|e| format!("Error decomposing Schnorr signature {}", e.to_string()))?;
            let adaptor_secret = SecretKey::from_slice(secret_value).map_err(|e| {
                format!(
                    "Error retrieving adaptor secret from signature {}",
                    e.to_string()
                )
            })?;
            adaptor_secret_vec.push(adaptor_secret);
        }
    }
    let adaptor_secret_aggregate = aggregate_secret_values(&adaptor_secret_vec)?;

    // Adaptor signature from the OTHER
    let mut adapted_sig = other_adaptor_signature
        .decrypt(&adaptor_secret_aggregate)
        .map_err(|e| format!("Error in adaptor signature decryption {}", e.to_string()))?
        .serialize_der()
        .to_vec();
    adapted_sig.push(EcdsaSighashType::All as u8);
    // verify signature
    let _res =
        verify_ecdsa_signature(cet_sighash, &adapted_sig, &other_pubkey, true).map_err(|e| {
            format!(
                "Adaptor-derived signature verification failed {}",
                e.to_string()
            )
        })?;

    // Now sign the CET on my own part
    let my_sig = sign_hash_ecdsa_with_key(&secp, cet_sighash, &signing_key)?;
    // verify sig
    let _res = verify_ecdsa_signature(cet_sighash, &my_sig, &signing_keypair.public_key(), true)
        .map_err(|e| format!("Self signature verification failed {}", e.to_string()))?;

    Ok((adapted_sig, my_sig))
}

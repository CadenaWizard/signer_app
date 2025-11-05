use crate::network::{network_from_byte, network_from_string};

use bip39::Mnemonic;
use bitcoin::hashes::{sha256, Hash};
use bitcoin::hex::FromHex;
use bitcoin::Network;
use std::fs;

const ENCRYPT_KEY_HASH_MESSAGE: &str = "Secret Entropy Storage Genesis ";

/// Store a secret seed entropy
pub(crate) struct SecretEntropyStore {
    entropy: Vec<u8>,
    network: Network,
}

impl SecretEntropyStore {
    pub(crate) fn new_from_secret_file(
        path_for_secret_file: &str,
        encryption_password: &str,
    ) -> Result<Self, String> {
        let entropy_encrypted = read_encrypted_payload_from_file(path_for_secret_file)?;
        let (network, entropy_decrypted) =
            decrypt_payload(&entropy_encrypted, encryption_password)?;
        Ok(Self {
            entropy: entropy_decrypted,
            network,
        })
    }

    // #[cfg(test)]
    pub(crate) fn new_with_entropy(entropy: &Vec<u8>, network: &str) -> Result<Self, String> {
        let entropy = entropy.clone();
        let network = network_from_string(network)?;
        Ok(Self { entropy, network })
    }

    pub(crate) fn get_secret_entropy(&self) -> &Vec<u8> {
        &self.entropy
    }

    pub(crate) fn network(&self) -> Network {
        self.network
    }
}

fn checksum_of_entropy(entropy: &Vec<u8>) -> Result<u8, String> {
    let mnemo = Mnemonic::from_entropy(entropy)
        .map_err(|e| format!("Could not process entropy {}", e.to_string()))?;
    let checksum = mnemo.checksum();
    Ok(checksum)
}

pub(crate) fn read_encrypted_payload_from_file(
    path_for_secret_file: &str,
) -> Result<Vec<u8>, String> {
    let contents = fs::read_to_string(path_for_secret_file).map_err(|e| {
        format!(
            "Could not read file '{}', {}",
            path_for_secret_file,
            e.to_string()
        )
    })?;
    if contents.len() < 4 {
        return Err(format!(
            "File content is too short ({} {})",
            contents.len(),
            path_for_secret_file
        ));
    }
    let lines = contents.split("\n").collect::<Vec<_>>();
    let first_line = lines.get(0).expect("File content is too short");
    let words = first_line.split(" ").collect::<Vec<_>>();
    let hex_data = words.get(0).expect("File content is too short");
    let bin_data = parse_payload_hex(hex_data)?;
    Ok(bin_data)
}

fn parse_payload_hex(entropy_hex: &str) -> Result<Vec<u8>, String> {
    let hex_len = entropy_hex.len();
    if hex_len % 2 != 0 {
        return Err(format!("File content length is not even! {}", hex_len));
    }
    let bin_data = match hex_len {
        38 => <[u8; 19]>::from_hex(entropy_hex)
            .map_err(|e| format!("Could not parse contents as hex {}", e.to_string()))?
            .to_vec(),
        70 => <[u8; 35]>::from_hex(entropy_hex)
            .map_err(|e| format!("Could not parse contents as hex {}", e.to_string()))?
            .to_vec(),
        _ => return Err(format!("Invalid hex data length {}", hex_len)),
    };
    Ok(bin_data)
}

pub(crate) fn parse_entropy_hex(entropy_hex: &str) -> Result<Vec<u8>, String> {
    let hex_len = entropy_hex.len();
    if hex_len % 2 != 0 {
        return Err(format!("Hex string length is not even! {}", hex_len));
    }
    let bin_data = match hex_len {
        32 => <[u8; 16]>::from_hex(entropy_hex)
            .map_err(|e| format!("Could not parse entropy as hex {}", e.to_string()))?
            .to_vec(),
        64 => <[u8; 32]>::from_hex(entropy_hex)
            .map_err(|e| format!("Could not parse entropy as hex {}", e.to_string()))?
            .to_vec(),
        _ => return Err(format!("Invalid hex entropy length {}", hex_len)),
    };
    Ok(bin_data)
}

fn decrypt_xor(data: &Vec<u8>, key: &Vec<u8>) -> Result<Vec<u8>, String> {
    let keylen = key.len();
    if keylen == 0 {
        return Err(format!("Invalid decryption key length {}", keylen));
    }
    let mut output = Vec::with_capacity(data.len());
    for i in 0..data.len() {
        output.push(data[i] ^ key[i % keylen]);
    }
    Ok(output)
}

pub(crate) fn decrypt_payload(
    encrypted: &Vec<u8>,
    encryption_password: &str,
) -> Result<(Network, Vec<u8>), String> {
    let message = ENCRYPT_KEY_HASH_MESSAGE.to_string() + encryption_password;
    let encrypt_key = sha256::Hash::hash(message.as_bytes())
        .to_byte_array()
        .to_vec();
    let decrypted = decrypt_xor(encrypted, &encrypt_key)?;

    let network_byte = decrypted[0];
    let entropy_len = decrypted[1];
    let checksum_read = decrypted[2];
    let entropy = decrypted[3..].to_vec();

    // check & set network
    let network = network_from_byte(network_byte).map_err(|e| {
        format!(
            "Invalid network. Check the encryption password and the secret file! ({})",
            e
        )
    })?;

    // check entropy len
    if entropy_len as usize != entropy.len() {
        return Err(format!(
            "Entropy length mismatch, {} vs {}. Check the encryption password and the secret file!",
            entropy_len,
            entropy.len()
        ));
    }

    // check checksum
    let checksum_computed = checksum_of_entropy(&entropy)?;
    if checksum_read != checksum_computed {
        return Err(format!(
            "Checksum mismatch! {} vs {}. Check the encryption password and the secret file!",
            checksum_read, checksum_computed
        ));
    }

    Ok((network, entropy))
}

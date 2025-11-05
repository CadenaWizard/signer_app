use crate::secret_entropy_storage::SecretEntropyStore;

use bip39::Mnemonic;
use bitcoin::bip32::{ChildNumber, DerivationPath, Xpriv, Xpub};
use bitcoin::key::{Keypair, Secp256k1};
use bitcoin::secp256k1::{All, PublicKey};
use bitcoin::{Address, Network};
use std::str::FromStr;

/// Store a HD wallet.
/// Built on top of SecretEntropyStore, but adds HD wallet functionality
pub(crate) struct HDWalletStorage {
    entropy_store: SecretEntropyStore,
    wallet: Option<HDWalletInfo>,
    secp: Secp256k1<All>,
}

pub(crate) struct HDWalletInfo {
    // The level-3 account XPRIV
    xpriv: Xpriv,
    // The level-3 account XPUB
    pub xpub: Xpub,
}

impl HDWalletStorage {
    pub(crate) fn new_from_secret_file(
        path_for_secret_file: &str,
        encryption_password: &str,
    ) -> Result<Self, String> {
        let entropy_store =
            SecretEntropyStore::new_from_secret_file(path_for_secret_file, encryption_password)?;
        let mut instance = Self {
            entropy_store,
            wallet: None,
            secp: Secp256k1::new(),
        };
        // check derivation, cache it
        let wallet = instance.get_hdwallet_from_secret()?;
        instance.wallet = Some(wallet);
        Ok(instance)
    }

    // #[cfg(test)]
    pub(crate) fn new_with_entropy(entropy: &Vec<u8>, network: &str) -> Result<Self, String> {
        let entropy_store = SecretEntropyStore::new_with_entropy(entropy, network)?;
        // check derivation, don't cache secrets, only the xpub
        let mut instance = Self {
            entropy_store,
            wallet: None,
            secp: Secp256k1::new(),
        };
        // check derivation, cache it
        let wallet = instance.get_hdwallet_from_secret()?;
        instance.wallet = Some(wallet);
        Ok(instance)
    }

    /// Return the XPUB
    pub(crate) fn get_xpub(&self) -> Result<Xpub, String> {
        let wallet = self.get_cached_hdwallet_info()?;
        Ok(wallet.xpub)
    }

    pub(crate) fn network(&self) -> Network {
        self.entropy_store.network()
    }

    fn get_hdwallet_from_secret(&self) -> Result<HDWalletInfo, String> {
        let entropy = self.entropy_store.get_secret_entropy();
        let mnemo = Mnemonic::from_entropy(entropy)
            .map_err(|e| format!("Could not process entropy {}", e.to_string()))?;
        let seed = mnemo.to_seed_normalized("");
        let xpriv = Xpriv::new_master(self.network(), &seed).expect("Creating XPriv");
        let derivation = self.default_account_derivation_path();
        let derivation_path_3 =
            DerivationPath::from_str(&derivation).expect("Creating DerivationPath");
        let xpriv_level_3 = xpriv
            .derive_priv(&self.secp, &derivation_path_3)
            .expect("Derive level3 xpriv");
        let xpub_level_3 = Xpub::from_priv(&self.secp, &xpriv_level_3);

        Ok(HDWalletInfo {
            xpriv: xpriv_level_3,
            xpub: xpub_level_3,
        })
    }

    fn get_cached_hdwallet_info(&self) -> Result<&HDWalletInfo, String> {
        if let Some(wallet) = &self.wallet {
            Ok(&wallet)
        } else {
            Err("HDWalletStorage not initialized!".to_string())
        }
    }

    fn default_account_derivation_path(&self) -> String {
        match self.network() {
            Network::Signet => "m/84'/1'/0'".to_string(),
            // Bitcoin mainnet and fallback
            _ => "m/84'/0'/0'".to_string(),
        }
    }

    /// Return a child keypair
    pub(crate) fn get_child_keypair(&self, index: u32) -> Result<Keypair, String> {
        let wallet = self.get_cached_hdwallet_info()?;
        // derive
        let index_4 = ChildNumber::from_normal_idx(0).unwrap();
        let index_5 = ChildNumber::from_normal_idx(index).unwrap();
        let xpriv_5 = wallet
            .xpriv
            .derive_priv(&self.secp, &vec![index_4, index_5])
            .expect("Derivation error");
        let keypair = xpriv_5.to_keypair(&self.secp);
        Ok(keypair)
    }

    /// Return a child public key
    pub(crate) fn get_child_public_key(&self, index: u32) -> Result<PublicKey, String> {
        let keypair = self.get_child_keypair(index)?;
        Ok(keypair.public_key())
    }

    /// Return a child address
    pub(crate) fn get_address(&self, index: u32) -> Result<Address, String> {
        let pubkey = self.get_child_public_key(index)?;
        let ck = bitcoin::CompressedPublicKey(pubkey);
        let address = Address::p2wpkh(&ck, self.network());
        Ok(address)
    }

    pub(crate) fn verify_child_public_key_intern(
        &self,
        index: u32,
        pubkey: &PublicKey,
        print_entity: &str,
    ) -> Result<bool, String> {
        let keypair = self.get_child_keypair(index)?;
        // verify pubkey
        if &keypair.public_key() != pubkey {
            return Err(format!(
                "{} mismatch, index {}, {} vs. {}",
                print_entity,
                index,
                pubkey,
                keypair.public_key()
            ));
        }
        Ok(true)
    }
}

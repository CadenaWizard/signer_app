#!/usr/bin/python
# Command-line tool to set the secret (mnemonic/seed/entropy)
# It asks for the seed phrase (mnemonic), and a file encryption password
#
# A sample valid 12-word seed phrase:   oil oil oil oil oil oil oil oil oil oil oil oil
#

from bitcoinlib import keys, mnemonic
from bitcoinlib.encoding import sha256, double_sha256
import getpass
import sys

DEFAULT_FILE_NAME = "secret.sec"
NETWORK_MAINNET = "bitcoin"
NETWORK_SIGNET = "signet"
DEFAULT_NETWORK = NETWORK_MAINNET
ENCRYPT_KEY_HASH_MESSAGE = "Secret Entropy Storage Genesis "

# Program Mode: 0: check secret file, 1: aks for mnemonic and save it to file
mode = 0
filename = DEFAULT_FILE_NAME
network = DEFAULT_NETWORK


def print_usage():
    print("save_secret.py:  Set or check secret file used by dlcplazacryptlib")
    print()
    print("save_secret.py  [--set] [--file <file>] [--signet]")
    print("  --set:         If specified, mnemominc is prompted for, and secret is saved. Secret file must not exist.")
    print("                 Default is to only check secret file, and print the xpub")
    print("  --file <file>  Secret file to use, default is", DEFAULT_FILE_NAME)
    print("  --signet       If specified, assume Signet network. Default is mainnet (", DEFAULT_NETWORK, ")")

def process_arguments() -> bool:
    global mode
    global network
    global filename
    i = 1
    while i < len(sys.argv):
        a = sys.argv[i]
        if a == "--set":
            mode = 1
        elif a == "--file":
            if i+1 < len(sys.argv):
                filename = sys.argv[i+1]
                i += 1
            else:
                return False
        elif a == "--signet":
            network = NETWORK_SIGNET
        else:
            print("Unknown argument", a)
            return False

        i += 1
    return True

def print_mode():
    print("Mode: ", end='')
    if mode == 0:
        print("Check only", end='')
    else:
        print("Set", end='')
    print("   File:", filename, "   Network: ", network, get_network_byte())

# Return the checksum of an entropy (one byte, 4-to-8 bits)
def checksum_of_entropy(entropy) -> int:
    checksum_bin_str = mnemonic.Mnemonic().checksum(entropy)
    checksum = int(checksum_bin_str, 2)
    return checksum

# Return the entropy and one-byte checksum of a mnemonic
def entropy_from_mnemonic(mnemo: str) -> tuple[bytes, int]:
    entropy = mnemonic.Mnemonic().to_entropy(mnemo, includes_checksum=True)
    checksum = checksum_of_entropy(entropy)
    return [entropy, checksum]

def xpub_from_seed(seed: bytes, network: str) -> str:
    hdkey = keys.HDKey.from_seed(seed, network=network)
    account_xpub = hdkey.public_master().wif()
    return account_xpub

def first_address_from_seed(seed, base_derivation: str, network) -> tuple[str, str]:
    hdkey = keys.HDKey.from_seed(seed, network=network)
    derivation = base_derivation + "/0"
    account_key = hdkey.subkey_for_path(derivation)
    child_secret_key_0 = account_key.child_private(0)
    child_public_key_0 = child_secret_key_0.public()
    address_0 = child_public_key_0.address(script_type='p2wpkh', encoding='bech32')
    return [address_0, child_public_key_0]

def print_info(entropy: bytes, network: str):
    base_derivation = get_derivation()
    mnemo = mnemonic.Mnemonic().to_mnemonic(entropy)
    seed = mnemonic.Mnemonic().to_seed(mnemo)
    xpub = xpub_from_seed(seed, network)
    (address0, pubkey0) = first_address_from_seed(seed, base_derivation, network)
    print("XPUB, first address, and public key (for network", network, ",", base_derivation, "):")
    print(" ", xpub)
    print(" ", address0)
    print(" ", pubkey0)

def encryption_key_from_password(password: str) -> bytes:
    message = ENCRYPT_KEY_HASH_MESSAGE + password
    hash = sha256(bytes(message, 'utf8'))
    return hash

def encrypt_xor(data: bytes, key: bytes) -> bytes:
    keylen = len(key)
    assert(keylen > 0)
    outp = []
    for i in range(len(data)):
        ii = data[i]
        kk = key[i % keylen]
        oo = ii ^ kk
        outp.append(oo)
    return bytes(outp)

def get_derivation():
    if network == NETWORK_MAINNET:
        return "m/84'/0'/0'"
    elif network == NETWORK_SIGNET:
        return "m/84'/1'/0'"
    else:
        return "m/84'/0'/0'"

def get_network_byte() -> int:
    if network == NETWORK_MAINNET:
        return 0
    elif network == NETWORK_SIGNET:
        return 4
    else:
        return 0

# Decode network from byte, return also success
def set_network_from_byte(net_byte: int) -> bool:
    global network
    if net_byte == 0:
        network = NETWORK_MAINNET
        return True
    elif net_byte == 4:
        network = NETWORK_SIGNET
        return True
    else:
        network = NETWORK_MAINNET
    return False

def generate_payload(entropy, entropy_checksum, enc_key):
    to_encrypt = bytearray()

    # add network
    to_encrypt += get_network_byte().to_bytes()
    assert(len(to_encrypt) == 1)

    # add len of entropy
    to_encrypt += len(entropy).to_bytes()
    assert(len(to_encrypt) == 2)

    # add checksum
    to_encrypt += entropy_checksum.to_bytes()
    assert(len(to_encrypt) == 3)

    # add the entropy
    to_encrypt += entropy

    # encrypt it
    encrypted_payload = encrypt_xor(to_encrypt, enc_key)

    return encrypted_payload

def parse_payload(raw_str, enc_key) -> str:
    raw = bytearray.fromhex(raw_str)
    if len(raw) < 17:
        raise Exception("Value too short {}".format(len(raw)))

    decrypted = encrypt_xor(raw, enc_key)

    network_byte = decrypted[0]
    entropy_len = decrypted[1]
    checksum_read = decrypted[2]
    entropy = decrypted[3:]

    # check & set network
    if not set_network_from_byte(network_byte):
        raise Exception("Invalid network byte {}. Check the encryption password and the secret file!".format(network_byte))

    # check entropy len
    if entropy_len != len(entropy):
        raise Exception("Entropy length mismatch, {} vs {}. Check the encryption password and the secret file!".format(entropy_len, len(entropy)))

    # check checksum
    checksum_computed = checksum_of_entropy(entropy)
    if checksum_read != checksum_computed:
        print("Cheksum read", checksum_read, "computed", checksum_computed)
        raise Exception("Checksum mismatch! {} vs {}. Check the encryption password and the secret file!".format(checksum_read, checksum_computed))
    return entropy

# Read password silently
def read_password() -> str:
    password = getpass.getpass("Enter the file encryption password: ")
    password_repeat = getpass.getpass("Re-enter the encryption password: ")
    if password_repeat != password:
        print("Passwords don't match, try again!")
        sys.exit()
    return password

def do_check():
    try:
        file = open(filename, "r")
        content = file.read()
    except:
        print("Could not read file", filename)
        return

    password = read_password()

    # print(content)
    try:
        enc_key = encryption_key_from_password(password)
        entropy = parse_payload(content, enc_key)

        print_info(entropy, network)
        print()
    except Exception as e:
        print("Error parsing content", e)

def do_set():
    try:
        file = open(filename, "r")
        file.close()
        print("File already exists, won't overwrite, aborting", filename)
        return
    except:
        # do nothing
        print()

    # Read mnemonic silently
    mnemo = getpass.getpass("Enter the seed phrase: ")

    # Print out (public) info
    entropy_res = entropy_from_mnemonic(mnemo)
    entropy = entropy_res[0]
    checksum = entropy_res[1]
    print_info(entropy, network)
    print()

    password = read_password()

    enc_key = encryption_key_from_password(password)
    output = generate_payload(entropy, checksum, enc_key)
    output_hex = output.hex()

    # write it to file
    try:
        file = open(filename, "w")
        file.write(output_hex)
        file.close()
    except:
        print("Could not write file", filename)

    print("Secret written to file", filename)



if not process_arguments():
    print_usage()
    sys.exit()
print_mode()

if mode == 0:
    do_check()
elif mode == 1:
    do_set()
else:
    print_usage()


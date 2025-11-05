# DLC Plaza Crypto Library in Rust

A Rust library implementing basic crypto primitives for DLC:

- Load and store seed phrase
- Generate child account keys, addresses
- Sign a hash using a child key
- Generate nonce values
- Perform Schnorr signature of a message using a given nonce, using a child key
- Create CET adaptor signature points (batch)
- Create final CET signature


## TODO

- (secret file: binary instead of hex text)


## Rust-Python interfacing

Done using [`PyO3`](https://github.com/PyO3/pyo3) and `maturin`.

To build and test in Rust:

```
cargo build && cargo test
```

To build the Rust library and install it as a python module:

```
maturin develop
```

(or with venv:)
```
VIRTUAL_ENV='../venv' ../venv/bin/maturin develop
```

To test it from Python:

```
python3 test_lib.py
```

Before normal usage:

```
python3 save_secret.py <secret_file>
```


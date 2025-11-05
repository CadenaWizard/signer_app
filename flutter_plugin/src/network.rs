use bitcoin::Network;

pub(crate) fn network_from_byte(network_byte: u8) -> Result<Network, String> {
    match network_byte {
        0 => Ok(Network::Bitcoin),
        4 => Ok(Network::Signet),
        _ => Err(format!("Invalid network byte {}.", network_byte)),
    }
}

pub(crate) fn network_from_string(network_str: &str) -> Result<Network, String> {
    match network_str {
        "bitcoin" => Ok(Network::Bitcoin),
        "signet" => Ok(Network::Signet),
        _ => Err(format!(
            "Invalid network {}. Use 'bitcoin' for mainnet.",
            network_str
        )),
    }
}

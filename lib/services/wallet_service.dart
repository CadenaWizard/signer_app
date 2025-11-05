import 'dart:convert';
import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;
import 'package:pointycastle/export.dart';
import 'package:crypto/crypto.dart';
import 'package:hex/hex.dart';

String generateMnemonic() {
  return bip39.generateMnemonic();
}

Uint8List mnemonicToSeed(String mnemonic) {
  return bip39.mnemonicToSeed(mnemonic);
}

AsymmetricKeyPair<PublicKey, PrivateKey> generateKeyPair(Uint8List seed) {
  final params = ECKeyGeneratorParameters(ECCurve_secp256k1());
  final secureRandom = FortunaRandom()..seed(KeyParameter(seed.sublist(0, 32)));

  final generator = ECKeyGenerator()..init(ParametersWithRandom(params, secureRandom));

  return generator.generateKeyPair();
}

String getAddressFromPublicKey(ECPublicKey pubKey) {
  final Q = pubKey.Q!.getEncoded(false);
  final sha256Digest = sha256.convert(Q);
  final ripemd160Digest = RIPEMD160Digest().process(Uint8List.fromList(sha256Digest.bytes));

  final prefixed = Uint8List.fromList([0x00] + ripemd160Digest);
  final checksum = sha256.convert(sha256.convert(prefixed).bytes).bytes.sublist(0, 4);

  final binaryAddress = Uint8List.fromList(prefixed + checksum);
  return base58Encode(binaryAddress);
}

String base58Encode(Uint8List input) {
  const base58Alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  var intData = BigInt.parse(HEX.encode(input), radix: 16);
  final base58 = StringBuffer();

  while (intData > BigInt.zero) {
    final quotient = intData ~/ BigInt.from(58);
    final remainder = intData % BigInt.from(58);
    intData = quotient;
    base58.write(base58Alphabet[remainder.toInt()]);
  }

  // Add '1' for each leading 0 byte
  for (int i = 0; i < input.length && input[i] == 0; i++) {
    base58.write('1');
  }

  return base58.toString().split('').reversed.join('');
}

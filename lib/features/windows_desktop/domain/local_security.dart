import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

class PasswordDigest {
  const PasswordDigest(this.hash, this.salt);
  final String hash;
  final String salt;
}

class LocalSecurity {
  LocalSecurity({Random? random}) : _random = random ?? Random.secure();
  final Random _random;
  final Pbkdf2 _algorithm = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 210000,
    bits: 256,
  );

  Future<PasswordDigest> hashPassword(String password, {String? salt}) async {
    if (password.length < 12) {
      throw ArgumentError('Password must contain at least 12 characters.');
    }
    final saltBytes = salt == null
        ? List<int>.generate(32, (_) => _random.nextInt(256))
        : base64Decode(salt);
    final key = await _algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: saltBytes,
    );
    return PasswordDigest(
      base64Encode(await key.extractBytes()),
      base64Encode(saltBytes),
    );
  }

  Future<bool> verify(String password, PasswordDigest digest) async {
    final candidate = await hashPassword(password, salt: digest.salt);
    final left = base64Decode(candidate.hash);
    final right = base64Decode(digest.hash);
    var difference = left.length ^ right.length;
    for (var index = 0; index < min(left.length, right.length); index++) {
      difference |= left[index] ^ right[index];
    }
    return difference == 0;
  }

  String recoveryCode() => _random.nextInt(1000000).toString().padLeft(6, '0');

  String temporaryPassword() {
    const alphabet =
        'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#%';
    return List.generate(
      16,
      (_) => alphabet[_random.nextInt(alphabet.length)],
    ).join();
  }
}

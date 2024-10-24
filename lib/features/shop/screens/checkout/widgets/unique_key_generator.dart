import 'dart:math';

class UniqueKeyGenerator {
  static String generateUniqueKey() {
    final randomNumber = Random().nextInt(9999999);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$timestamp$randomNumber';
  }
}

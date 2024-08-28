class MyFirebaseException implements Exception {
  final String code;

  MyFirebaseException(this.code);

  String get message {
    // Add custom messages based on the Firebase exception code
    // You can customize this according to your specific needs
    return 'Firebase Exception: $code';
  }
}

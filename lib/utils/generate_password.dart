import 'dart:math';

String generatePassword({int length = 12}) {
  const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      'abcdefghijklmnopqrstuvwxyz'
      '0123456789'
      '!@#\$%^&*()-_=+[]{}|;:,.<>?';

  final Random random = Random();
  return List.generate(length, (index) => chars[random.nextInt(chars.length)])
      .join();
}

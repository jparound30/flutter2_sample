import 'dart:ui';

class ColorConverter {
  static Color fromString(String color) {
    assert(color.startsWith('#'));
    assert(color.length == 7);

    return Color.fromARGB(
      255,
      int.parse(color.substring(1, 3), radix: 16),
      int.parse(color.substring(3, 5), radix: 16),
      int.parse(color.substring(5), radix: 16),
    );
  }
}

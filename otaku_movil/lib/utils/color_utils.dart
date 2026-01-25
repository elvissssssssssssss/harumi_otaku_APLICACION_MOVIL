
// lib/utils/color_utils.dart
import 'package:flutter/material.dart';

class ColorUtils {
  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 7) {
      buffer.write(hexString.replaceFirst('#', 'ff'));
    } else if (hexString.length == 6) {
      buffer.write('ff$hexString');
    } else {
      buffer.write(hexString.replaceFirst('#', ''));
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}

// Color harmony functions

import 'package:flutter/material.dart';

class ColorHarmony {
  static List<Color> getComplementary(Color color) {
    return [
      color,
      Color.fromARGB(
          color.alpha, 255 - color.red, 255 - color.green, 255 - color.blue)
    ];
  }

  static List<Color> getAnalogous(Color color) {
    final hue = HSVColor.fromColor(color).hue;
    return [
      HSVColor.fromAHSV(1, (hue + 30) % 360, 1, 1).toColor(),
      color,
      HSVColor.fromAHSV(1, (hue - 30) % 360, 1, 1).toColor(),
    ];
  }

  static List<Color> getTriadic(Color color) {
    final hue = HSVColor.fromColor(color).hue;
    return [
      HSVColor.fromAHSV(1, (hue + 120) % 360, 1, 1).toColor(),
      color,
      HSVColor.fromAHSV(1, (hue - 120) % 360, 1, 1).toColor(),
    ];
  }

  static List<Color> getMonochromatic(Color color) {
    final hsvColor = HSVColor.fromColor(color);
    return [
      hsvColor.withValue(hsvColor.value * 0.8).toColor(),
      color,
      hsvColor.withValue((hsvColor.value + 0.2).clamp(0.0, 1.0)).toColor(),
    ];
  }
}

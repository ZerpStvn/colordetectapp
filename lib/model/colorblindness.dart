// Color blindness simulation functions
import 'package:flutter/cupertino.dart';

Color applyProtanopia(Color color) {
  int r = color.red;
  int g = color.green;
  int b = color.blue;
  return Color.fromARGB(color.alpha, (0.56667 * r + 0.43333 * g).round(), g, b);
}

Color applyDeuteranopia(Color color) {
  int r = color.red;
  int g = color.green;
  int b = color.blue;
  return Color.fromARGB(color.alpha, r, (0.55833 * g + 0.44167 * b).round(), b);
}

Color applyTritanopia(Color color) {
  int r = color.red;
  int g = color.green;
  int b = color.blue;
  return Color.fromARGB(color.alpha, r, g, (0.95 * b).round());
}

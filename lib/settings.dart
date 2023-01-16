import 'package:flutter/material.dart';

enum ByteTheme { none, yellow, amber, sage, light, dark }

class Settings {
  static var theme = ByteTheme.none;

  Color amberColor = const Color.fromARGB(255, 246, 197, 91);
  Color yellowColor = const Color.fromARGB(255, 230, 218, 125);
  Color sageColor = const Color.fromARGB(255, 172, 189, 161);
  Color lightColor = const Color.fromARGB(146, 229, 229, 255);
  Color darkColor = const Color.fromARGB(248, 44, 44, 44);
  Color defaultColor = const Color.fromARGB(146, 229, 229, 255);

  Color getAmberColor() {
    return amberColor;
  }

  Color getYellowColor() {
    return yellowColor;
  }

  Color getDefaultColor() {
    return defaultColor;
  }

  Color getLightColor() {
    return lightColor;
  }

  Color getBackgroundColor() {
    switch (theme) {
      case ByteTheme.amber:
        return amberColor;
      case ByteTheme.yellow:
        return yellowColor;
      case ByteTheme.sage:
        return sageColor;
      case ByteTheme.light:
        return lightColor;
      case ByteTheme.dark:
        return darkColor;
      default:
        return defaultColor;
    }

    //return Color.fromARGB(248, 223, 225, 231);
    //return Color.fromARGB(4, 255, 214, 64);
    //return Color.fromARGB(255, 204, 209, 244);
    //return Color.fromARGB(131, 255, 214, 64);
    //return Color.fromARGB(188, 30, 36, 79);
    //return Color.fromARGB(224, 248, 209, 137);

    //gray/black
    //return Colors.black54;

    //yellow color
    //return Color.fromARGB(255, 245, 225, 145);
    //transparent gray/blue
    //return Color.fromARGB(146, 229, 229, 255);
    //yellow
    //return Color.fromARGB(255, 246, 197, 91);
  }

  Color getHeaderColor() {
    switch (theme) {
      case ByteTheme.light:
        return lightColor;
      default:
        return Color.fromARGB(248, 44, 44, 47);
    }
  }

  Color getForegroundColor() {
    switch (theme) {
      case ByteTheme.amber:
        return Colors.black;
      case ByteTheme.yellow:
        return Colors.black;
      case ByteTheme.sage:
        return Colors.black;
      case ByteTheme.light:
        return Colors.black;
      case ByteTheme.dark:
        return Colors.white70;
      default:
        return Colors.black;
    }
  }

  Color getAvatarColor() {
    switch (theme) {
      case ByteTheme.amber:
        return const Color.fromARGB(255, 2, 51, 124);
      case ByteTheme.yellow:
        return const Color.fromARGB(255, 2, 51, 124);
      default:
        return const Color.fromARGB(255, 2, 51, 124);
    }
  }
}

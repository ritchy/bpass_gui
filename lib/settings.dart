import 'package:flutter/material.dart';

bool lightTheme = true;

class Settings {
  Color getBackgroundColor() {
    if (lightTheme) {
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
      return Color.fromARGB(146, 229, 229, 255);
    } else {
      return Colors.black12;
    }
  }

  Color getForegroundColor() {
    if (lightTheme) {
      return Colors.black;
    } else {
      return Colors.white70;
    }
  }

  Color getAvatarColor() {
    return const Color.fromARGB(255, 2, 51, 124);
  }
}

import 'package:flutter/material.dart';

enum Theme { none, yellow, amber, light, dark }

class Settings {
  var theme = Theme.none;

  void setTheme(Theme newTheme) {
    theme = newTheme;
  }

  Color getBackgroundColor() {
    switch (theme) {
      case Theme.amber:
        return const Color.fromARGB(255, 246, 197, 91);
      case Theme.yellow:
        return Color.fromARGB(255, 230, 218, 125);
      case Theme.light:
        return Color.fromARGB(146, 229, 229, 255);
      case Theme.dark:
        return Color.fromARGB(248, 44, 44, 44);
      default:
        //gray/slate
        //return Color.fromARGB(248, 44, 44, 44);
        return Color.fromARGB(146, 229, 229, 255);
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
    return Color.fromARGB(248, 44, 44, 47);
  }

  Color getForegroundColor() {
    switch (theme) {
      case Theme.amber:
        return Colors.black;
      case Theme.yellow:
        return Colors.black;
      case Theme.light:
        return Colors.black;
      case Theme.dark:
        return Colors.white70;
      default:
        return Colors.black;
    }
  }

  Color getAvatarColor() {
    switch (theme) {
      case Theme.amber:
        return const Color.fromARGB(255, 2, 51, 124);
      case Theme.yellow:
        return const Color.fromARGB(255, 2, 51, 124);
      default:
        return const Color.fromARGB(255, 2, 51, 124);
    }
  }
}

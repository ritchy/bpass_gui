import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:logging/logging.dart';

enum ByteTheme { none, yellow, amber, sage, light, dark }

class Settings {
  static var theme = ByteTheme.none;
  final log = Logger('_Settings');
  late File settingsFile;
  dynamic jsonMap = [];

  Color amberColor = const Color.fromARGB(255, 246, 197, 91);
  Color yellowColor = const Color.fromARGB(255, 230, 218, 125);
  Color sageColor = const Color.fromARGB(255, 172, 189, 161);
  Color lightColor = const Color.fromARGB(146, 229, 229, 255);
  Color darkColor = const Color.fromARGB(248, 44, 44, 44);
  Color defaultColor = const Color.fromARGB(146, 229, 229, 255);

  //default window size Size(width:850, height:640)
  double mainWindowWidth = 850;
  double mainWindowHeight = 640;

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

  Future<void> updateTheme(ByteTheme newTheme) async {
    theme = newTheme;
    saveSettings();
  }

  Future<void> updateMainWindowSizeSetting(
      double windowWidth, double windowHeight) async {
    mainWindowWidth = windowWidth;
    mainWindowHeight = windowHeight;
    saveSettings();
  }

  //none, yellow, amber, sage, light, dark
  void setThemeFromName(String themeName) {
    if (themeName == "none") {
      theme = ByteTheme.none;
    } else if (themeName == "yellow") {
      theme = ByteTheme.yellow;
    } else if (themeName == "amber") {
      theme = ByteTheme.amber;
    } else if (themeName == "sage") {
      theme = ByteTheme.sage;
    } else {
      theme = ByteTheme.none;
    }
  }

  String getCurrentThemeName() {
    switch (theme) {
      case ByteTheme.amber:
        return "amber";
      case ByteTheme.yellow:
        return "yellow";
      case ByteTheme.sage:
        return "sage";
      case ByteTheme.light:
        return "light";
      case ByteTheme.dark:
        return "dark";
      default:
        return "none";
    }
  }

  Future<void> loadSettings(String settingsFilePath) async {
    settingsFile = File(settingsFilePath);
    if (settingsFile.existsSync()) {
      final jsonString = await settingsFile.readAsString();
      jsonMap = jsonDecode(jsonString);
      setThemeFromName(getNamedSetting("color_theme"));
      //print(jsonMap['main_window_height']);
      if (jsonMap['main_window_height'] != null &&
          jsonMap['main_window_width'] != null) {
        mainWindowHeight = jsonMap['main_window_height'];
        mainWindowWidth = jsonMap['main_window_width'];
      }
    } else {
      log.warning("Settings file doesn't exist, creating ....");
      settingsFile.createSync(recursive: true);
      saveSettings();
    }
  }

  Future<void> saveSettings() async {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    var sink = settingsFile.openWrite();
    sink.write(encoder.convert(this));
    // Close the IOSink to free system resources.
    await sink.close();
    log.info("Saving settings ...");
    //print("saving ... ${encoder.convert(this)}");
  }

  String getNamedSetting(String settingName) {
    return jsonMap[settingName];
  }

  Map<String, dynamic> toJson() {
    //print("converting $this");
    DateTime lastUpdated = DateTime.now();
    final Map<String, dynamic> results = <String, dynamic>{};
    results['last_updated'] = lastUpdated.toString();
    results['color_theme'] = getCurrentThemeName();
    results['main_window_height'] = mainWindowHeight;
    results['main_window_width'] = mainWindowWidth;
    return results;
  }
}

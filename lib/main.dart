import 'package:password_manager/controller/account_view_controller.dart';
import 'model/accounts.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:password_manager/service/google_service_notifier.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';

//import 'src/settings/settings_controller.dart';
//import 'src/settings/settings_service.dart';
import 'view/account_page.dart';
import 'dart:io';

const search = 'search';
const int additionalRowCount = 5;

AccountViewController accountViewController = AccountViewController(Accounts());
GoogleServiceNotifier googleServiceNotifier = GoogleServiceNotifier();
final log = Logger('PasswordManager');

void main(List<String> arguments) async {
  initLogger();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<GoogleServiceNotifier>(
          create: (_) => googleServiceNotifier),
      ChangeNotifierProvider<AccountViewController>(
          create: (_) => accountViewController),
    ],
    child: const AccountsPage(),
  ));
  setupWindow();
  loadAccountsFromFile();
  //testWindowFunctions();
}

void initLogger() {
  Logger.root.level = Level.INFO;
  //Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    stdout.writeln('${record.level.name}: ${record.time}: ${record.message}');
  });
}

Future<void> loadAccountsFromFile() async {
  String appDocPath = await getAppDirPath();
  String jsonDocument = "$appDocPath${Platform.pathSeparator}accounts.json";
  //print("loading accounts from file: $jsonDocument");
  File file = File(jsonDocument);
  if (!file.existsSync()) {
    file.createSync();
    var sink = file.openWrite();
    sink.write('[]\n');
    // Close the IOSink to free system resources.
    await sink.close();
  }
  accountViewController.loadFile(file);
}

Future<String> getAppDirPath() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  return appDocDir.path;
}

void getFileDirectories() async {
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;

  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  String jsonDocument = "$appDocPath${Platform.pathSeparator}accounts.json";
  //print("file path: $jsonDocument");

  Directory? downloadDir = await getDownloadsDirectory();
  String? downloadDirPath = downloadDir?.path;

  stdout.writeln("$tempPath, $appDocPath, $downloadDirPath");
  if (await FileSystemEntity.isDirectory(jsonDocument)) {
    stderr.writeln('error: $jsonDocument is a directory');
  }
}

void setupWindow() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    Size size = await DesktopWindow.getWindowSize();
    stdout.writeln(size);
    //await DesktopWindow.setMaxWindowSize(Size(800, 800));
    await DesktopWindow.setMinWindowSize(Size(440, 640));
    await DesktopWindow.setWindowSize(Size(850, 640));
  }
}

Future testWindowFunctions() async {
  Size size = await DesktopWindow.getWindowSize();
  stdout.writeln(size);
  await DesktopWindow.setWindowSize(Size(500, 500));

  await DesktopWindow.setMinWindowSize(Size(400, 400));
  await DesktopWindow.setMaxWindowSize(Size(800, 800));

  await DesktopWindow.resetMaxWindowSize();
  await DesktopWindow.toggleFullScreen();
  bool isFullScreen = await DesktopWindow.getFullScreen();
  if (isFullScreen) {
    stdout.writeln("we're in full screen");
  }
  await DesktopWindow.setFullScreen(true);
  await DesktopWindow.setFullScreen(false);
}

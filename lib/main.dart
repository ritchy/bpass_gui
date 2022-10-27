import 'package:password_manager/model/account_view_controller.dart';
import 'package:password_manager/service/encryption_handler.dart';
import 'model/accounts.dart';
import 'package:desktop_window/desktop_window.dart';
//import 'package:password_manager/service/google_api.dart';
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

//Accounts accounts = Accounts();
AccountViewController accountViewController = AccountViewController(Accounts());
GoogleServiceNotifier googleServiceNotifier = GoogleServiceNotifier();
//GoogleService? googleService;
//GoogleService googleService = GoogleService();
final log = Logger('PasswordManager');

//final columns = accounts.getNumberOfAccountFields();

void main(List<String> arguments) async {
  //String appDirPath = "/Users/ritchy/.bpass";
  //await getAppDirPath();
  //here's how you pass arguments
  //flutter run -d macOS  --dart-entrypoint-args run-as-command-line
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  //final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  // await settingsController.loadSettings();

  //Directory appDocDir = await getApplicationDocumentsDirectory();
  //String appDocPath = appDocDir.path;
  //print("Path is $appDocPath");
  // load our file
  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  //runApp(MyApp(settingsController: settingsController));
  //startGuiApp();

  //runApp(ChangeNotifierProvider(
  //  create: (context) => accounts,
  //  child: const MySearchApp(),
  //));
/***
  runApp(
    ChangeNotifierProvider(
      create: (context) => accounts,
      child: AccountsPage(
          //accounts: accounts,
          ),
    ),
  );

**/
  //await generateExchangePems();

  initLogger();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<GoogleServiceNotifier>(
          create: (_) => googleServiceNotifier),
      ChangeNotifierProvider<AccountViewController>(
          create: (_) => accountViewController),
    ],
    child: AccountsPage(),
  ));
  setupWindow();
  loadAccountsFromFile();
  //startGoogleService();
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
  String jsonDocument = appDocPath + Platform.pathSeparator + "accounts.json";
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
  String jsonDocument = appDocPath + Platform.pathSeparator + "accounts.json";
  //print("file path: $jsonDocument");

  Directory? downloadDir = await getDownloadsDirectory();
  String? downloadDirPath = downloadDir?.path;

  print("$tempPath, $appDocPath, $downloadDirPath");
}

/*****
void startGuiApp(String appDirPath) {
  const columns = 4;
  const rows = 20;

  int simple = 1;
  if (simple == 0) {
    runApp(
      AccountsPage(
          //accounts: accounts,
          ),
    );
  } else {
    runApp(MaterialApp(
      title: 'Password Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Password Manager Demo'),
        ),
        body: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(0),
              child: IconButton(
                  padding: const EdgeInsets.all(0),
                  alignment: Alignment.centerRight,
                  icon: const Icon(Icons.plus_one_rounded),
                  color: Colors.blue,
                  onPressed: addEntry),
            ),
          ],
        ),
      ),
    ));
  }
  Future<Directory> _requestAppDocumentsDirectory() {
    return getApplicationDocumentsDirectory();
  }

  Future<Directory> _requestAppSupportDirectory() {
    return getApplicationSupportDirectory();
  }

  Future<Directory> _requestAppLibraryDirectory() {
    return getLibraryDirectory();
  }

  Future<Directory?> _requestExternalStorageDirectory() {
    return getExternalStorageDirectory();
  }

  Future<List<Directory>?> _requestExternalCacheDirectories() {
    return getExternalCacheDirectories();
  }

  Future<Directory?> _requestDownloadsDirectory() {
    return getDownloadsDirectory();
  }
}
***/

void setupWindow() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    Size size = await DesktopWindow.getWindowSize();
    print(size);
    //await DesktopWindow.setMaxWindowSize(Size(800, 800));
    await DesktopWindow.setWindowSize(Size(750, 550));
  }
}

Future testWindowFunctions() async {
  Size size = await DesktopWindow.getWindowSize();
  print(size);
  await DesktopWindow.setWindowSize(Size(500, 500));

  await DesktopWindow.setMinWindowSize(Size(400, 400));
  await DesktopWindow.setMaxWindowSize(Size(800, 800));

  await DesktopWindow.resetMaxWindowSize();
  await DesktopWindow.toggleFullScreen();
  bool isFullScreen = await DesktopWindow.getFullScreen();
  await DesktopWindow.setFullScreen(true);
  await DesktopWindow.setFullScreen(false);
}

void addEntry() {}

Future<void> _handleError(String path) async {
  if (await FileSystemEntity.isDirectory(path)) {
    stderr.writeln('error: $path is a directory');
  } else {
    exitCode = 2;
  }
}

/***** 
class MySearchApp extends StatelessWidget {
  const MySearchApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // Remove the debug banner
        debugShowCheckedModeBanner: false,
        title: 'Passwords',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: const HomePage());
  }
}
****/

/****** 
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: false,
            centerTitle: false,
            title: const Text('Password Manager'),
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {},
              ),
            ],
            bottom: AppBar(
              title: Container(
                width: double.infinity,
                height: 40,
                color: Colors.deepPurple,
                child: Row(children: [
                  const SizedBox(
                    width: 140.0,
                    height: 35,
                    child: TextField(
                        decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      labelText: 'Filter',
                      contentPadding: const EdgeInsets.all(5.0),
                      //focusColor: Colors.amberAccent,
                    )),
                  ),
                  Text('Deliver', textAlign: TextAlign.center),
                  Text('Craft UIs', textAlign: TextAlign.center),
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {},
                  )
                ]),
              ),
            ),
          ),
          // Other Sliver Widgets
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(
                height: 600,
                child: AccountsPage("/path/to/accounts.json"),
              )
            ]),
          ),
        ],
      ),
    );
  }
}
  ****/

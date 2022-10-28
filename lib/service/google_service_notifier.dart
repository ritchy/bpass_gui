import 'package:password_manager/service/google_api.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:logging/logging.dart';
import 'dart:io';

class GoogleServiceNotifier extends ChangeNotifier {
  GoogleService? googleService;
  bool processingGoogleFile = false;
  bool loggedIntoGoogle = false;
  final log = Logger('GoogleServiceNotifier');

  Future<void> handleGoogleDriveLogin() async {
    log.finest("GoogleServiceNotifier::handleGoogleDriveLogin()");
    processingGoogleFile = true;
    notifyListeners();
    await ensureGoogleServiceRunning();
    final googleService = this.googleService;
    if (googleService != null) {
      //googleService.obtainFakeAuthClient(loginPrompt);
      loggedIntoGoogle =
          await googleService.handleGoogleDriveLogin(GuiPromptHandler());
    }
    processingGoogleFile = false;
    notifyListeners();
  }

  Future<void> handleGoogleDriveLogout() async {
    processingGoogleFile = true;
    notifyListeners();
    final googleService = this.googleService;
    if (googleService != null) {
      googleService.googleLogout();
    }
    loggedIntoGoogle = false;
    processingGoogleFile = false;
    notifyListeners();
  }

  Future<void> handleDenyResponse() async {
    await googleService?.removeOutstandingRequests();
    await googleService?.updateClientAccessRequests();
    handleGoogleDriveLogout();
  }

  Future<void> ensureGoogleServiceRunning() async {
    log.finest("ensureGoogleServiceRunning()");
    if (googleService == null) {
      String appDirPath = await getAppDirPath();
      googleService = GoogleService(appDirPath);
    } else {
      log.info("Google service already started");
    }
  }

  Future<String> getAppDirPath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    return appDocDir.path;
  }
}

class GuiPromptHandler extends PromptHandler {
  @override
  void handlePrompt(String url) async {
    //canLaunchUrl().then((bool result) {});

    final Uri _url = Uri.parse(url);
    if (await canLaunchUrl(_url)) {
      if (!await launchUrl(_url)) {
        throw 'Could not launch $_url';
      }
    } else {
      print('Please go to the following URL and grant access:');
      print('  => $url');
      print('');
    }
    print("Here's the URL to grant access:");
    print('  => $url');
    print('');
  }
}

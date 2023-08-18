import 'package:flutter/material.dart';
import 'package:password_manager/service/google_service_notifier.dart';

class ToolTab extends StatelessWidget implements PreferredSizeWidget {
  ToolTab(this.googleServiceNotifier, {super.key});
  GoogleServiceNotifier googleServiceNotifier;
  final double height = 72;

  @override
  Widget build(BuildContext context) {
    return getWidgetRow();
  }

  Widget getWidgetRow() {
    var displayIcon = const Icon(Icons.list_rounded, size: 55);
    return Container(
        color: Colors.black54,
        child: Row(
          children: <Widget>[
            const Text("Filter"),
            Expanded(
              child: Container(),
            ),
            const Text("Google Drive"),
            const Padding(
                padding: EdgeInsets.all(
                    4)), // This trailing comma makes auto-formatting nicer for build methods.
            IconButton(
              //Icons.list_rounded,
              iconSize: 55,
              alignment: Alignment.topCenter,
              onPressed: () {},
              padding: const EdgeInsets.all(4.0),
              icon: displayIcon,
              color: Colors.white70,
            ),
            const Padding(
                padding: EdgeInsets.all(
                    4)), // This trailing comma makes auto-formatting nicer for build methods.
          ],
        ));
  }

  Future<void> handleGoogleDriveLogout() async {
    await googleServiceNotifier.handleGoogleDriveLogout();
  }

  void cancelGoogleDriveLogin() {}

  Future<void> handleGoogleDriveLogin() async {}

  Widget getGoogleDriveWidget(var googleServiceNotifier) {
    if (googleServiceNotifier.loggedIntoGoogle) {
      //reconcileGoogleAccountFile();
      return SizedBox(
          height: 50,
          child: FloatingActionButton(
            backgroundColor: Colors.white70,
            onPressed: () => handleGoogleDriveLogout(),
            tooltip: 'login',
            child: const Text(
              "Drive",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blue),
            ),
          ));
    } else if (googleServiceNotifier.processingGoogleFile) {
      return SizedBox(
          height: 50,
          child: FloatingActionButton(
            backgroundColor: Colors.white70,
            onPressed: () => cancelGoogleDriveLogin(),
            tooltip: 'login',
            child: const CircularProgressIndicator(
              strokeWidth: 4.0,
            ),
          ));
    } else {
      return SizedBox(
          height: 50,
          child: FloatingActionButton(
            backgroundColor: Colors.white70,
            onPressed: () => handleGoogleDriveLogin(),
            tooltip: 'login',
            child: const Text(
              "Drive",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
          ));
    }
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(height);
  }
}

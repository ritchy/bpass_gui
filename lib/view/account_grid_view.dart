import 'package:flutter/material.dart';
import 'package:password_manager/settings.dart';
//import 'package:googleapis/calendar/v3.dart';
//import 'package:flutter/src/material/colors.dart';
import 'package:password_manager/controller/account_view_controller.dart';
import 'package:password_manager/main.dart';
import 'package:provider/provider.dart';
import '../model/accounts.dart';

class AccountGridView extends StatefulWidget {
  const AccountGridView({super.key});

  @override
  AccountGridViewState createState() => AccountGridViewState();
}

class AccountGridViewState extends State<AccountGridView> {
  @override
  Widget build(BuildContext context) {
    var accountViewController = context.watch<AccountViewController>();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    //print("width: $width / height: $height");
    int axisCount = 3;
    double aspectRatio = 3 / 1;
    if (width > 380 && width < 400) {
      axisCount = 2;
      aspectRatio = 1.8 / 1;
    } else if (width > 870) {
      axisCount = 4;
    } else if (width < 870 && width > 650) {
      axisCount = 3;
    } else if (width < 650 && width > 380) {
      axisCount = 2;
    } else if (width < 380) {
      axisCount = 1;
    }
    if (width < 380) {
      return ListView(
          children: getChildrenCards(accountViewController.displayedAccounts));
    } else {
      return Container(
          color: Color.fromARGB(15, 99, 97, 95),
          child: GridView.count(
            scrollDirection: Axis.vertical,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            padding: const EdgeInsets.all(10),
            crossAxisCount: axisCount,
            childAspectRatio: aspectRatio,
            // Generate 100 widgets that display their index in the List.
            children: getChildrenCards(accountViewController.displayedAccounts),
          ));
    }
  }

  List<Widget> getChildrenCards(var accounts) {
    log.finer("getting new set of child cards to render ...");
    List<Widget> children = [];
    //print(accounts[0]);
    //add create new account card at the top
    for (AccountItem item in accounts) {
      //print("adding ${item.name}");
      if (item.newAccount) {
        children.add(NewAccountWidget(accounts[0], accountViewController));
      } else {
        children.add(CardWidget(item, accountViewController));
      }
    }
    return children;
  }
}

class CardWidget extends StatelessWidget {
  AccountItem item;
  AccountViewController acccountViewController;
  Settings settings = Settings();
  CardWidget(this.item, this.acccountViewController, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
      color: settings.getBackgroundColor(),
      child: InkWell(
        onTap: () {
          log.fine("tapped card");
          accountViewController.selectAccount(item);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              //leading: Icon(Icons.album),
              title: Text(
                  overflow: TextOverflow.ellipsis,
                  item.name,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: settings.getForegroundColor())),
              subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(item.username,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                //fontWeight: FontWeight.bold,
                                color: settings.getForegroundColor()))),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'hint: ${item.hint}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              //fontWeight: FontWeight.bold,
                              color: settings.getForegroundColor()),
                        ))
                  ]),
            )
            /**** ,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: const Text('BUY TICKETS'),
                  onPressed: () {/* ... */},
                ),
                //const SizedBox(width: 2),
                TextButton(
                  child: const Text('LISTEN'),
                  onPressed: () {/* ... */},
                ),
                //const SizedBox(width: 2),
              ],
            ),
            ****/
          ],
        ),
      ),
    ));
  }
}

class NewAccountWidget extends StatelessWidget {
  AccountViewController acccountViewController;
  AccountItem item;
  Settings settings = Settings();
  NewAccountWidget(this.item, this.acccountViewController, {super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
      color: settings.getBackgroundColor(),
      //color: Colors.amber,
      child: InkWell(
        onTap: () {
          log.info("tapped card item: $item");
          accountViewController.selectNewAccount(item);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              //leading: Icon(Icons.album),
              title: Text(
                overflow: TextOverflow.ellipsis,
                "New Account",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: settings.getForegroundColor()),
              ),
              subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text('tap here',
                            style: TextStyle(
                                color: settings.getForegroundColor()))),
                    Align(alignment: Alignment.centerLeft, child: Text(''))
                  ]),
            )
          ],
        ),
      ),
    ));
  }
}

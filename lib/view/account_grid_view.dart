import 'package:flutter/material.dart';
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
    print("width: $width / height: $height");
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
          children: getChildrenCards(accountViewController.accounts.accounts));
    } else {
      return GridView.count(
        scrollDirection: Axis.vertical,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        // Create a grid with 2 columns. If you change the scrollDirection to
        // horizontal, this produces 2 rows.
        crossAxisCount: axisCount,
        childAspectRatio: aspectRatio,
        // Generate 100 widgets that display their index in the List.
        children: getChildrenCards(accountViewController.accounts.accounts),
      );
    }
  }

  List<Widget> getChildrenCards(var accounts) {
    //log.info("Getting child cards...");
    List<Widget> children = [];
    for (AccountItem item in accounts) {
      //print("adding ${item.name}");
      children.add(CardWidget(item, accountViewController));
    }
    return children;
  }
}

class CardWidget extends StatelessWidget {
  AccountItem item;
  AccountViewController acccountViewController;

  CardWidget(this.item, this.acccountViewController, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
      //color: Colors.amber,
      child: InkWell(
        onTap: () {
          log.info("tapped card");
          accountViewController.selectAccount(item);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              //leading: Icon(Icons.album),
              title: Text(overflow: TextOverflow.ellipsis, item.name),
              subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(item.username)),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text('hint: ${item.hint}'))
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

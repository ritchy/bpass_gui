import 'package:flutter/material.dart';
import 'package:password_manager/main.dart';
import 'package:flutter/services.dart';
import '../model/accounts.dart';
import 'package:password_manager/settings.dart';

/// View of account details that includes:
/// Account Name, user, email password and hint
/// Account Number, URL, notes and tags

class AccountListView extends StatelessWidget {
  AccountItem item;
  //AccountViewController accountViewController;
  Settings settings = Settings();

  AccountListView(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    double windowHeight = MediaQuery.of(context).size.height;
    double windowWidth = MediaQuery.of(context).size.width;

    String accountNameFirstChar = item.name.isEmpty ? "" : item.name[0];
    bool vertical = windowWidth < 600;
    double fieldHeight = 30;
    if (vertical) {
      fieldHeight = 60;
    }
    //print("window width: $windowWidth");
    return Expanded(
        //height: windowHeight - 510,
        //width: windowWidth - 10,
        child: Container(
            color: const Color.fromARGB(117, 213, 209, 209),
            //color: Color.fromARGB(255, 138, 142, 169),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
              children: <Widget>[
                Container(
                    //color: Color.fromARGB(151, 255, 214, 64),
                    //cool blue color
                    //color: Color.fromARGB(255, 204, 209, 244),
                    color: settings.getBackgroundColor(),
                    //decoration: BoxDecoration(
                    //    border: Border.all(width: 1, color: Colors.black38)),
                    padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
                    margin: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              padding: const EdgeInsets.fromLTRB(3, 5, 5, 5),
                              child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: settings.getAvatarColor(),
                                  child: Text(accountNameFirstChar,
                                      style: const TextStyle(
                                          fontSize: 52,
                                          fontWeight: FontWeight.bold)))),
                          SizedBox(
                              width: windowWidth,
                              child: Container(
                                  //color: Colors.amber,
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 5, 5),
                                  child: Text(
                                      //overflow: TextOverflow.clip,
                                      //overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      //maxLines: 2,
                                      item.name,
                                      //"Bank of America Jarbo",
                                      style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold)))),
                        ])),
                Container(
                    height: fieldHeight,
                    margin: const EdgeInsets.all(10),
                    //padding: const EdgeInsets.all(4),
                    child: Row(children: [
                      Expanded(
                          child: Container(
                              //color: Colors.amber,
                              padding: const EdgeInsets.fromLTRB(2, 0, 5, 0),
                              child: getNameValue(
                                  "Account Name:", item.name, vertical))),
                      Expanded(
                          child: Container(
                              padding: const EdgeInsets.fromLTRB(2, 0, 5, 0),
                              child: getPasswordSection(item.password, vertical,
                                  context))), //("Password:", item.password, vertical)))
                    ])),
                Container(
                    height: fieldHeight,
                    margin: const EdgeInsets.all(10),
                    //padding: const EdgeInsets.all(4),
                    child: Row(children: [
                      Expanded(
                          child: Container(
                              padding: const EdgeInsets.fromLTRB(2, 0, 5, 0),
                              child: getNameValue(
                                  "User Name:", item.username, vertical))),
                      Expanded(
                          child: Container(
                              padding: const EdgeInsets.fromLTRB(2, 0, 5, 0),
                              child:
                                  getNameValue("Hint:", item.hint, vertical)))
                    ])),
                Container(
                    height: fieldHeight,
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    //padding: const EdgeInsets.all(4),
                    child: Row(children: [
                      Expanded(
                          child: Container(
                              padding: const EdgeInsets.fromLTRB(2, 0, 5, 0),
                              child: getNameValue(
                                  "Email:", item.email, vertical))),
                      Expanded(
                          child: Container(
                              padding: const EdgeInsets.fromLTRB(2, 0, 5, 0),
                              child: getNameValue("Account Number:",
                                  item.accountNumber, vertical)))
                    ])),
                //getBottomSection(windowWidth),
                getBottomSection(vertical),
                Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 40, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                            child: const Text('Delete'),
                            onPressed: () {
                              showAlertDialog(context);
                            }),
                        Expanded(
                          flex: 2,
                          child: Container(
                            color: Colors.amber,
                          ),
                        ),
                        TextButton(
                            child: const Text('Edit'),
                            onPressed: () {
                              accountViewController.editSelectedAccount();
                            }),
                        TextButton(
                          child: const Text('Done'),
                          onPressed: () {
                            accountViewController.clearSelectedAccount();
                          },
                        ),
                        //const SizedBox(width: 2),
                      ],
                    )),
              ],
            )));
  }

  Widget getPasswordSection(
      String passText, bool vertical, BuildContext context) {
    if (vertical) {
      return getVerticalPasswordSection("Password:", passText, context);
    } else {
      return getHorizontalPasswordSection("Password:", passText, context);
    }
  }

  Widget getBottomSection(vertical) {
    List<String> tags = (item.tags.isEmpty) ? [] : item.tags;
    String tagString = tags.join(', ');

    return Container(
        height: 180,
        margin: const EdgeInsets.all(10),
        //padding: const EdgeInsets.all(4),
        child: Row(children: [
          Expanded(
              child: Container(
                  //color: Colors.amber,
                  padding: const EdgeInsets.fromLTRB(2, 0, 5, 0),
                  child: Column(children: [
                    getVerticalNameValue("Web URL:", item.url),
                    getVerticalNameValue("Tags:", tagString),
                  ]))),
          Expanded(
              child: Container(
                  padding: const EdgeInsets.fromLTRB(2, 0, 5, 0),
                  child: Column(children: [
                    Container(
                      alignment: Alignment.topLeft,
                      height: 30,
                      //padding: const EdgeInsets.all(2),
                      margin: const EdgeInsets.all(2),
                      padding: const EdgeInsets.fromLTRB(2, 2, 2, 5),
                      child: Text("Notes:",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 12,
                              //backgroundColor: Colors.amber,
                              fontWeight: FontWeight.bold)),
                    ),
                    Container(
                        height: 120,
                        //width: 100,
                        padding: const EdgeInsets.fromLTRB(4, 2, 2, 0),
                        alignment: Alignment.topLeft,
                        //color: Colors.amber,
                        child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Text(
                              item.notes,
                              overflow: TextOverflow.ellipsis,
                            )))
                  ]))),
        ]));
  }

  Widget getNameValue(String name, String value, bool vertical) {
    if (vertical) {
      return getVerticalNameValue(name, value);
    } else {
      return getHorizontalNameValue(name, value);
    }
  }

  Widget getHorizontalNameValue(String name, String value) {
    return Container(
        padding: const EdgeInsets.all(2),
        margin: const EdgeInsets.all(2),
        //decoration:
        //    BoxDecoration(border: Border.all(width: 2, color: Colors.black38)),
        child: Row(
          children: [
            Expanded(
                child: Container(
              alignment: Alignment.centerLeft,
              child: Text(name,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                      fontSize: 12,
                      //backgroundColor: Colors.amber,
                      fontWeight: FontWeight.bold)),
            )),
            Expanded(
                child: Container(
                    //color: Colors.amber,
                    alignment: Alignment.centerLeft,
                    child: Text(value,
                        textAlign: TextAlign.start,
                        softWrap: true,
                        style: const TextStyle(fontSize: 14))))
          ],
        ));
  }

  Widget getVerticalNameValue(String name, String value) {
    return Container(
        padding: const EdgeInsets.all(2),
        margin: const EdgeInsets.all(2),
        height: 60,
        //decoration:
        //    BoxDecoration(border: Border.all(width: 2, color: Colors.black38)),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(name,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                      fontSize: 12,
                      //backgroundColor: Colors.amber,
                      fontWeight: FontWeight.bold)),
            ),
            Expanded(
                child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(value,
                        textAlign: TextAlign.start,
                        softWrap: true,
                        style: const TextStyle(fontSize: 14))))
          ],
        ));
  }

  Widget getHorizontalPasswordSection(
      String name, String value, BuildContext context) {
    return Container(
        //decoration:
        //    BoxDecoration(border: Border.all(width: 2, color: Colors.black38)),
        child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          margin: const EdgeInsets.all(2),
          alignment: Alignment.centerLeft,
          child: Text(name,
              textAlign: TextAlign.start,
              style: const TextStyle(
                  fontSize: 12,
                  //backgroundColor: Colors.amber,
                  fontWeight: FontWeight.bold)),
        ),
        getPasswordButton(value, context)
      ],
    ));
  }

  Future<void> handleDelete() async {
    accountViewController.accounts.markAccountAsDeleted(item);
    await accountViewController.accounts.updateAccountFiles(null);
    accountViewController.clearSelectedAccount();
  }

  void showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel Delete"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Yes Delete"),
      onPressed: () {
        handleDelete();
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete ${item.name}?"),
      content: Text("Are you sure you want to delete?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget getPasswordButton(String value, BuildContext context) {
    if (value.isEmpty || value.trim().isEmpty) {
      return Expanded(
          child: Container(
        //color: Colors.amber,
        padding: const EdgeInsets.all(2),
        margin: const EdgeInsets.all(2),
        alignment: Alignment.centerLeft,
        child: const Text("<empty>",
            textAlign: TextAlign.start, style: TextStyle(fontSize: 14)),
      ));
    } else {
      return Expanded(
          child: Container(
        //color: Color.fromARGB(35, 255, 214, 64),
        padding: const EdgeInsets.all(0),
        margin: const EdgeInsets.all(0),
        alignment: Alignment.topLeft,
        child: TextButton(
            child: const Text(
              "-->Copy<--",
              textAlign: TextAlign.start,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              showToast(context);
            }),
      ));
    }
  }

  void showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Password Copied'),
        action: SnackBarAction(
            label: 'Dismiss', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  Widget getVerticalPasswordSection(
      String name, String value, BuildContext context) {
    return Container(
        height: 60,
        //decoration:
        //    BoxDecoration(border: Border.all(width: 2, color: Colors.black38)),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              margin: const EdgeInsets.all(2),
              alignment: Alignment.centerLeft,
              child: Text(name,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                      fontSize: 12,
                      //backgroundColor: Colors.amber,
                      fontWeight: FontWeight.bold)),
            ),
            getPasswordButton(value, context)
          ],
        ));
  }
}

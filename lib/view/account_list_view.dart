import 'package:flutter/material.dart';
import 'package:password_manager/main.dart';
import '../model/accounts.dart';

/// View of account details that includes:
/// Account Name, user, email password and hint
/// Account Number, URL, notes and tags

class AccountListView extends StatelessWidget {
  AccountItem item;
  AccountListView(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    double windowHeight = MediaQuery.of(context).size.height;
    double windowWidth = MediaQuery.of(context).size.width;
    List<String> tags = (item.tags.isEmpty) ? [] : item.tags;
    String tagString = tags.join(', ');
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
        child: ListView(
      padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
      children: <Widget>[
        Container(
            padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.all(5),
                      child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue.shade900,
                          child: Text(accountNameFirstChar,
                              style: const TextStyle(
                                  fontSize: 52, fontWeight: FontWeight.bold)))),
                  SizedBox(
                      width: windowWidth - 100,
                      child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 5, 5, 5),
                          child: Text(
                              //overflow: TextOverflow.clip,
                              //overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              //maxLines: 2,
                              item.name,
                              //"Bank of America Jarbo",
                              style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold)))),
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
                      child:
                          getNameValue("Account Name:", item.name, vertical))),
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(2, 0, 5, 0),
                      child:
                          getNameValue("Password:", item.password, vertical)))
            ])),
        Container(
            height: fieldHeight,
            margin: const EdgeInsets.all(10),
            //padding: const EdgeInsets.all(4),
            child: Row(children: [
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(2, 0, 5, 0),
                      child:
                          getNameValue("User Name:", item.username, vertical))),
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(2, 0, 5, 0),
                      child: getNameValue("Hint:", item.hint, vertical)))
            ])),
        Container(
            height: fieldHeight,
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            //padding: const EdgeInsets.all(4),
            child: Row(children: [
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(2, 0, 5, 0),
                      child: getNameValue("Email:", item.email, vertical))),
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(2, 0, 5, 0),
                      child: getNameValue(
                          "Account Number:", item.accountNumber, vertical)))
            ])),
        Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            //color: Colors.amber,
            //padding: const EdgeInsets.all(4),
            height: 60,
            child: getVerticalNameValue("Tags:", tagString)),
        Row(children: [
          Expanded(
              child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  //color: Colors.amber,
                  //padding: const EdgeInsets.all(4),
                  height: 60,
                  child: getVerticalNameValue("Web URL:", item.url))),

          //onSubmit: (value) => print("${item.url} -> $value"))),
          Expanded(
              child: Container(
                  margin: const EdgeInsets.all(10),
                  //padding: const EdgeInsets.all(4),
                  height: 60,
                  child: getVerticalNameValue("Notes:", item.notes)))
        ]),
        Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 40, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
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
    ));
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
}

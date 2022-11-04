import 'package:flutter/material.dart';
import 'package:password_manager/main.dart';
import '../model/accounts.dart';

/// View of account details that includes:
/// Account Name, user, email password and hint
/// Account Number, URL, notes and tags

class AccountCardView extends StatelessWidget {
  AccountItem item;
  AccountCardView(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double windowHeight = MediaQuery.of(context).size.height;
    return SizedBox(
        height: windowHeight - 150,
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            getCard(),
          ],
        ));
  }

  Widget getCard() {
    String accountNameFirstChar = item.name[0];
    return Card(
        elevation: 50,
        margin: const EdgeInsets.all(20.0),
        child: SizedBox(
            //width: 300,
            //height: 500,
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.blue.shade900,
                            child: Text(accountNameFirstChar,
                                style: const TextStyle(
                                    fontSize: 52,
                                    fontWeight: FontWeight.bold))),
                        Text(
                            overflow: TextOverflow.ellipsis,
                            item.name,
                            style: const TextStyle(
                                fontSize: 36, fontWeight: FontWeight.bold)),
                      ])
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: getPrimarySection())),
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: getSecondarySection())),
                ],
              ),
              Row(
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
              ),
            ],
          ),
        )));
  }

  Widget getPrimarySection() {
    return SizedBox(
      height: 150,
      child: Column(children: [
        Expanded(child: getNameValue("User Name:", item.username)),
        Expanded(child: getNameValue("Hint:", item.hint)),
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text("Notes:",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            )),
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
                padding: const EdgeInsets.all(5.0), child: Text(item.notes)))
      ]),
    );
  }

  Widget getSecondarySection() {
    List<String> tags = (item == null || item.tags.isEmpty) ? [] : item.tags;
    String tagString = tags.join(', ');

    return SizedBox(
      height: 150,
      child: Column(children: [
        Expanded(child: getNameValue("Web URL:", item.url)),
        Expanded(child: getNameValue("Account Number:", item.accountNumber)),
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text("Tags:",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            )),
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
                padding: const EdgeInsets.all(5.0), child: Text(tagString)))
      ]),
    );
  }

  Widget getNameValue(String name, String value) {
    return Row(
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            )),
        Align(
            alignment: Alignment.centerLeft,
            child:
                Padding(padding: const EdgeInsets.all(5.0), child: Text(value)))
      ],
    );
  }
}

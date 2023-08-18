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
    double windowHeight = MediaQuery.of(context).size.height;
    return SizedBox(
        height: windowHeight - 170,
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            getCard(context),
          ],
        ));
  }

  Widget getCard(BuildContext context) {
    double windowHeight = MediaQuery.of(context).size.height;
    double windowWidth = MediaQuery.of(context).size.width;
    String accountNameFirstChar = item.name[0];
    return Card(
        elevation: 50,
        margin: const EdgeInsets.all(20.0),
        child: SizedBox(
          //width: 300,
          //height: 500,
          child: Container(
              padding: const EdgeInsets.all(20),
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
                            SizedBox(
                                width: windowWidth - 100,
                                child: Container(
                                    padding: const EdgeInsets.all(5.0),
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
                          ])
                    ],
                  ),
                  getMainStage(context),
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
              )),
        ));
  }

  Widget getMainStage(BuildContext context) {
    double windowHeight = MediaQuery.of(context).size.height;
    double windowWidth = MediaQuery.of(context).size.width;

    if (windowWidth > 630) {
      return Container(
          //decoration: BoxDecoration(
          //    border: Border.all(width: 2, color: Colors.black38)),
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: getPrimarySection())),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: getSecondarySection(context))),
        ],
      ));
    } else {
      return SizedBox(
          width: windowWidth,
          height: 500,
          child: Container(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: getVerticalPrimarySection(context))),
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: getSecondarySection(context))),
                ],
              )));
    }
  }

  Widget getVerticalPrimarySection(BuildContext context) {
    double windowHeight = MediaQuery.of(context).size.height;
    double windowWidth = MediaQuery.of(context).size.width;
    List<String> tags = (item.tags.isEmpty) ? [] : item.tags;
    String tagString = tags.join(', ');

    return SizedBox(
      height: 300,
      width: windowWidth - 100,
      child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
              border: Border.all(width: 0.5, color: Colors.black38)),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                    child: getVerticalNameValue("User Name:", item.username)),
                Expanded(child: getVerticalNameValue("Hint:", item.hint)),
                Expanded(
                    child: getVerticalNameValue(
                        "Account Number:", item.accountNumber)),
                Expanded(child: getNameValue("Tags:", tagString))
              ])),
    );
  }

  Widget getPrimarySection() {
    List<String> tags = (item.tags.isEmpty) ? [] : item.tags;
    String tagString = tags.join(', ');

    return SizedBox(
      height: 300,
      child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
              border: Border.all(width: 0.5, color: Colors.black38)),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(child: getNameValue("User Name:", item.username)),
                Expanded(child: getNameValue("Hint:", item.hint)),
                Expanded(
                    child: getNameValue("Account Number:", item.accountNumber)),
                Expanded(child: getNameValue("Tags:", tagString))
              ])),
    );
  }

  Widget getSecondarySection(BuildContext context) {
    double windowHeight = MediaQuery.of(context).size.height;
    double windowWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 300,
      width: windowWidth - 100,
      child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
              border: Border.all(width: 0.5, color: Colors.black38)),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(child: getVerticalNameValue("Web URL:", item.url)),
                Expanded(
                    flex: 2, child: getVerticalNameValue("Notes:", item.notes)),
              ])),
    );
  }

  Widget getNameValue(String name, String value) {
    return Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(5),
        //decoration:
        //    BoxDecoration(border: Border.all(width: 2, color: Colors.black38)),
        child: Row(
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                child: Text(value))
          ],
        ));
  }

  Widget getVerticalNameValue(String name, String value) {
    return Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(5),
        //decoration:
        //    BoxDecoration(border: Border.all(width: 2, color: Colors.black38)),
        child: Column(
          children: [
            Expanded(
                child: Container(
              alignment: Alignment.centerLeft,
              child: Text(name,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                      fontSize: 14,
                      //backgroundColor: Colors.amber,
                      fontWeight: FontWeight.bold)),
            )),
            Expanded(
                child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(value,
                        textAlign: TextAlign.start,
                        softWrap: true,
                        style: const TextStyle(fontSize: 12))))
          ],
        ));
  }

  Widget getVerticalsNameValue(String name, String value) {
    return Container(
        //padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Text(name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            Expanded(
                child: Text(value)) //, style: const TextStyle(fontSize: 12)))
          ],
        ));
  }
}

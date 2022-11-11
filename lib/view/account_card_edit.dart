import 'package:flutter/material.dart';
import 'package:password_manager/main.dart';
import '../model/accounts.dart';

/// View of account details that includes:
/// Account Name, user, email password and hint
/// Account Number, URL, notes and tags

class AccountEditCardView extends StatelessWidget {
  AccountItem item;
  AccountEditCardView(this.item, {super.key});

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
                                        softWrap: true,
                                        //maxLines: 2,
                                        item.name,
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
                          child: const Text('Save'),
                          onPressed: () {
                            accountViewController.saveChanges();
                          }),
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          accountViewController.cancelEditMode();
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
                  child: getPrimaryEditSection())),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: getSecondaryEditSection(context))),
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
                          child: getSecondaryEditSection(context))),
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
                    child: getTextWidget("User Name", item.username,
                        onSubmit: (value) => item.username = value)),
                //print("${item.username} -> $value"))), //),
                Expanded(
                    child: getTextWidget("Hint", item.hint,
                        onSubmit: (value) => item.hint = value)),
                //print("${item.hint} -> $value"))), //),
                Expanded(
                    child: getTextWidget("Account Number", item.accountNumber,
                        onSubmit: (value) => item.accountNumber = value)),
                //print("${item.accountNumber} -> $value"))), //),
                Expanded(
                    child: getTextWidget("Tags", tagString,
                        onSubmit: (value) => print("${item.tags} -> $value"))),
              ])),
    );
  }

  Widget getSecondaryEditSection(BuildContext context) {
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
                //Expanded(child: getVerticalNameValue("Web URL:", item.url)),
                Expanded(
                    flex: 1,
                    child: getTextWidget("Web URL", item.url,
                        multiLine: true,
                        maxLines: 2,
                        onSubmit: (value) => print("${item.url} -> $value"))),

                Expanded(
                    flex: 2,
                    child: getTextWidget("Notes", item.notes,
                        multiLine: true,
                        maxLines: 6,
                        onSubmit: (value) => print("${item.notes} -> $value"))),
              ])),
    );
  }

  Widget getPrimaryEditSection() {
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
                Expanded(
                    child: getTextWidget("User Name", item.username,
                        onSubmit: (value) =>
                            print("${item.username} -> $value"))), //),
                Expanded(
                    child: getTextWidget("Hint", item.hint,
                        onSubmit: (value) =>
                            print("${item.hint} -> $value"))), //),
                Expanded(
                    child: getTextWidget("Account Number", item.accountNumber,
                        onSubmit: (value) =>
                            print("${item.accountNumber} -> $value"))), //),
                Expanded(
                    child: getTextWidget("Tags", tagString,
                        onSubmit: (value) => print("${item.tags} -> $value"))),
              ])),
    );
  }

  Widget getTextWidget(String label, String value,
      {required ValueChanged<String> onSubmit,
      bool multiLine = false,
      int maxLines = 2}) {
    final controller = TextEditingController(text: value);
    if (multiLine) {
      return TextField(
          controller: controller,
          onSubmitted: onSubmit,
          onChanged: (String value) {
            print(value);
          },
          keyboardType: TextInputType.multiline,
          maxLines: maxLines,
          decoration: InputDecoration(
              border: const OutlineInputBorder(), labelText: label));
    } else {
      return SizedBox(
          height: 70,
          child: TextField(
              controller: controller,
              onSubmitted: onSubmit,
              onEditingComplete: () => {print(value)},
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: label,
              )));
    }
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

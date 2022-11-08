import 'package:flutter/material.dart';
import 'package:password_manager/main.dart';
import '../model/accounts.dart';

class AccountEditCardView extends StatelessWidget {
  AccountItem item;
  AccountEditCardView(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double windowHeight = MediaQuery.of(context).size.height;
    return SizedBox(
        height: windowHeight - 150,
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            Container(
              height: 50,
              color: Colors.amber[600],
              child: const Center(child: Text('Entry A')),
            ),
            Container(
              height: 50,
              color: Colors.amber[500],
              child: const Center(child: Text('Entry B')),
            ),
            Container(
              height: 50,
              color: Colors.amber[100],
              child: const Center(child: Text('Entry C')),
            ),
            getCard(),
            getCard(),
            getCard(),
          ],
        ));
  }

  Widget getCard() {
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
                  SizedBox(width: 200, child: getTextBox("Account Name"))
                ],
              ),
              getRow("firstLabel", "secondLabel"),
              getRow("firstLabel", "secondLabel"),
              getRow("firstLabel", "secondLabel"),
              getRow("firstLabel", "secondLabel"),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
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

  Widget getRow(String firstLabel, String secondLabel) {
    return SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: getVerticalNameValue("blah", "long label")),
            Expanded(
                child: getVerticalNameValue(
                    "label", "lonnnnnggg lable long lonnnnnggg lable long"))
          ],
        ));
  }

  Widget getTextBox(String label) {
    return Container(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
            onSubmitted: (value) {},
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white70,
              contentPadding: EdgeInsets.all(5.0),
              labelText: "label",
            )));
  }

  Widget getVerticalNameValue(String name, String value) {
    return Column(
      children: [
        Expanded(
          child: Text(name,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12)))
      ],
    );
  }
}

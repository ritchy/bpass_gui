import 'package:flutter/material.dart';
import 'package:password_manager/main.dart';
import '../model/accounts.dart';

/// View of account details that includes:
/// Account Name, user, email password and hint
/// Account Number, URL, notes and tags

class AccountListEditView extends StatelessWidget {
  AccountItem item;
  AccountListEditView(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    double windowHeight = MediaQuery.of(context).size.height;
    double windowWidth = MediaQuery.of(context).size.width;
    List<String> tags = (item.tags.isEmpty) ? [] : item.tags;
    String tagString = tags.join(', ');
    String accountNameFirstChar = "";
    if (item.name.isNotEmpty) {
      accountNameFirstChar = item.name[0];
    }

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
                      padding: const EdgeInsets.fromLTRB(3, 5, 5, 5),
                      child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue.shade900,
                          child: Text(accountNameFirstChar,
                              style: const TextStyle(
                                  fontSize: 52, fontWeight: FontWeight.bold)))),
                  SizedBox(
                      width: windowWidth,
                      child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
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
            height: 50,
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(4),
            child: Row(children: [
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(2, 0, 5, 0),
                      child: getTextWidget("Account Name", item.name,
                          onChanged: (value) => item.name = value))),
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(2, 0, 5, 0),
                      child: getTextWidget("Password", item.password,
                          onChanged: (value) => item.password = value)))
            ])),
        Container(
            height: 50,
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(4),
            child: Row(children: [
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(2, 0, 5, 0),
                      child: getTextWidget("User Name", item.username,
                          onChanged: (value) => item.username = value))),
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(2, 0, 5, 0),
                      child: getTextWidget("Hint", item.hint,
                          onChanged: (value) => item.hint = value)))
            ])),
        Container(
            height: 50,
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(4),
            child: Row(children: [
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(2, 0, 5, 0),
                      child: getTextWidget("Email", item.email,
                          onChanged: (value) => item.email = value))),
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(2, 0, 5, 0),
                      child: getTextWidget("Account Number", item.accountNumber,
                          onChanged: (value) => item.accountNumber = value)))
            ])),
        Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(4),
            height: 50,
            child: getTextWidget("Tags", tagString,
                onChanged: (value) => print("${item.tags} -> $value"))),
        Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(4),
            height: 80,
            child: getTextWidget("Web URL", item.url,
                multiLine: true,
                maxLines: 2,
                onChanged: (value) => item.url = value)),

        //onSubmit: (value) => print("${item.url} -> $value"))),
        Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(4),
            height: 120,
            child: getTextWidget("Notes", item.notes,
                multiLine: true,
                maxLines: 6,
                onChanged: (value) => item.notes = value)),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                //accountViewController.cancelEditMode();
                accountViewController.clearSelectedAccount();
              },
            ),
            TextButton(
                child: const Text('Save'),
                onPressed: () {
                  log.info("saving account $item");
                  //accountViewController.editSelectedAccount();
                  //accountViewController.updateCurrentlySelectedAccount();
                  if (item.newAccount) {
                    accountViewController.addAccount(item);
                    accountViewController.updateAccountFiles();
                    accountViewController.clearSelectedAccount();
                  } else if (accountViewController.itemDifferent(item)) {
                    accountViewController.updateAccountItem(item);
                    accountViewController.updateAccountFiles();
                    accountViewController.clearSelectedAccount();
                  } else {
                    log.info("Nothing changed with this account, not saving..");
                  }
                }),
            //const SizedBox(width: 2),
          ],
        ),
      ],
    ));
  }

  Widget getTextWidget(String label, String value,
      {required ValueChanged<String> onChanged,
      bool multiLine = false,
      int maxLines = 2}) {
    final controller = TextEditingController(text: value);
    if (multiLine) {
      return TextField(
          controller: controller,
          //onSubmitted: onSubmit,
          onChanged: onChanged,
          keyboardType: TextInputType.multiline,
          maxLines: maxLines,
          decoration: InputDecoration(
              border: const OutlineInputBorder(), labelText: label));
    } else {
      return SizedBox(
          height: 70,
          child: TextField(
              //maxLength: 100,
              controller: controller,
              //onSubmitted: onSubmit,
              maxLines: 1,
              onChanged: onChanged,
              onEditingComplete: () => {print(value)},
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(5, 0, 3, 5),
                border: const OutlineInputBorder(),
                labelText: label,
                //isDense: true,
              )));
    }
  }
}

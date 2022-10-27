import 'package:flutter/material.dart';
import 'package:password_manager/main.dart';
import 'package:password_manager/service/google_api.dart';
import 'package:password_manager/service/google_service_notifier.dart';
import 'package:password_manager/controller/account_view_controller.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:password_manager/model/accounts.dart';
import 'package:provider/provider.dart';
import 'package:password_manager/view/decorated_table_page.dart';
import 'package:password_manager/view/autocomplete_label.dart';
import 'package:logging/logging.dart';
import 'package:flutter/services.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  AccountsPageState createState() => AccountsPageState();
}

class AccountsPageState extends State<AccountsPage> {
  int? selectedRow;
  int? selectedColumn;
  AccountItem? selectedAccount;
  bool sortAscending = true;
  bool autoSelectColumn = false;
  final log = Logger('_AccountsPageState');
  AccountsPageState();

  Color getContentColor(int i, int j) {
    if (j == selectedRow && i == selectedColumn) {
      return Colors.amber;
    } else if (j == selectedRow) {
      //} || j == selectedColumn) {
      return Colors.amberAccent;
    } else {
      return Colors.transparent;
    }
  }

  void selectNewRow(int i) => setState(() {
        selectedColumn = null;
        autoSelectColumn = false;
        selectedRow = i;
        selectedAccount = accountViewController.getAccountByIndex(i);
      });

  void clearState() => setState(() {
        selectedRow = null;
        selectedColumn = null;
        selectedAccount = null;
        autoSelectColumn = false;
        //outstandingRequests = [];
        //accounts.filterAccounts("");
      });

  void handleColumnClick(int i) => setState(() {
        //log.info("Handlecolumclick");
        Clipboard.setData(const ClipboardData(text: "Your Copy text"));
        selectedRow = null;
        selectedColumn = null;
        selectedAccount = null;
        accountViewController.sortByColumnNumber(i, sortAscending);
        sortAscending = !sortAscending;
      });

  void handleClick(int i, int j) {
    setState(() {
      selectedColumn = i;
      selectedRow = j;
      autoSelectColumn = false;
      selectedAccount = accountViewController.getAccountByIndex(j);
    });
  }

  Future<void> requestAccessToDriveFile() async {
    await accountViewController.requestAccessToDriveFile();
    handleGoogleDriveLogout();
  }

  Future<void> handleGoogleDriveLogin() async {
    //accountViewController.googleService = googleServiceNotifier.googleService;
    await googleServiceNotifier.handleGoogleDriveLogin();
    accountViewController.googleService = googleServiceNotifier.googleService;
    log.fine(
        "should have google service, do we? ${accountViewController.googleService}");
    await accountViewController
        .reconcileGoogleAccountFile(googleServiceNotifier.googleService);
    //await accountViewController
    //    .reconcileAccessRequests(googleServiceNotifier.googleService);
    await accountViewController.refreshAccessRequestList();
    //setState(() {
    //outstandingRequests = requests;
    //});
    //log.info("loggedin? ${googleServiceNotifier.loggedIntoGoogle}");
  }

  void cancelGoogleDriveLogin() {}

  Future<void> handleGoogleDriveLogout() async {
    log.info("Logging out ...");
    setState(() {
      //loggedIntoGoogle = false;
    });
    await googleServiceNotifier.handleGoogleDriveLogout();
    //googleServiceNotifier.googleService?.googleLogout();
    //googleServiceNotifier.loggedIntoGoogle = false;
    //reconcileGoogleAccountFile();
  }

  Widget getRequestAccessDialog() {
    //log.info("getRequestAccessDialog()");
    if (accountViewController.promptToRequestDriveAccess) {
      return SimpleDialog(
        title: const Text('Existing account file in Drive, request access?'),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () {
              log.info("Requesting access ..");
              setState(() {
                accountViewController.promptToRequestDriveAccess = false;
                requestAccessToDriveFile();
              });
            },
            child: const Text('Request Access'),
          ),
          SimpleDialogOption(
            onPressed: () {
              log.info("not requesting access ..");
              setState(() {
                accountViewController.promptToRequestDriveAccess = false;
              });
            },
            child: const Text('Skip Request'),
          ),
        ],
      );
    } else {
      return Visibility(visible: false, child: Container());
    }
  }

  Widget getRequestDialog() {
    //log.info("getRequestDialog() ${accountViewController.outstandingRequests}");
    if (accountViewController.outstandingRequests.isNotEmpty) {
      ClientAccess accessRequest = accountViewController.outstandingRequests[0];
      return SimpleDialog(
        title: Text('Access Requested for ${accessRequest.clientName}'),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () {
              log.info("Granting access ..");
              setState(() {
                accountViewController.outstandingRequests
                    .remove(accountViewController.outstandingRequests.first);
              });
              accountViewController.grantAccessRequest(accessRequest);
            },
            child: const Text('Grant Access'),
          ),
          SimpleDialogOption(
            onPressed: () {
              log.info("Refusing access ..");
              setState(() {
                accountViewController.outstandingRequests
                    .remove(accountViewController.outstandingRequests.first);
              });
              accountViewController.denyAccessRequest(accessRequest);
            },
            child: const Text('Deny Access'),
          ),
        ],
      );
    } else {
      return Visibility(visible: false, child: Container());
    }
  }

  Widget getWidgetRow() {
    return Container(
        color: Colors.black54,
        child: Row(
          children: <Widget>[
            TextButton(
              onPressed: clearState,
              child: _FilterSearch(),
              //onPressed: () => Navigator.pushNamed(context, '/accounts'),
            ),
            const Text(
              "Tags: ",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
            ),
            SizedBox(
              //width: 100.0,
              height: 35,
              child: TagDropdownButton(),
            ),
            Expanded(
              child: Container(),
            ),
            getGoogleDriveWidget(),
            const Padding(
                padding: EdgeInsets.all(
                    4)), // This trailing comma makes auto-formatting nicer for build methods.
            const Icon(
              Icons.account_circle,
              color: Colors.white70,
              size: 60,
            ),
            const Padding(
                padding: EdgeInsets.all(
                    4)), // This trailing comma makes auto-formatting nicer for build methods.
          ],
        ));
  }

  Widget getRowTitleWidget(int rowNumber) {
    String accountName =
        accountViewController.getAccountByIndex(rowNumber).name;
    //String accountName = accounts.getAccountName(i);
    if (rowNumber == 0) {
      accountName = ">New Entry<";
    }

    if (selectedRow == rowNumber) {
      return getRowTitleEditContainer(rowNumber);
    } else {
      return TextButton(
        child: Text(accountName),
        onPressed: () => selectNewRow(rowNumber),
      );
    }
  }

  Widget getGoogleDriveWidget() {
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

  Widget getCellWidget(int i, int j) {
    if (selectedRow != j) {
      return ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(getContentColor(i, j)),
            elevation: MaterialStateProperty.all(0),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40))),
            alignment: Alignment.centerLeft,
            padding: MaterialStateProperty.all(EdgeInsets.zero)),
        onPressed: () => handleClick(i, j),
        child: Text(
          accountViewController.getFieldValue(j, i),
          textAlign: TextAlign.left,
          style: const TextStyle(color: Colors.black),
        ),
      );
    } else {
      return getCellEditContainer(i, j);
    }
  }

  Widget getCellEditContainer(int i, int rowNumber) {
    List<String> currentTags =
        accountViewController.getAccountTagsByIndex(rowNumber);
    final AutocompleteLabelController autocompleteLabelController =
        AutocompleteLabelController<String>(
            source: accountViewController.getTags(), values: currentTags);

    //log.info("Getting editor for column $i");
    if (i == 7) {
      //log.info("creating tag editor .. ");
      return Row(children: [
        Expanded(
            flex: 1,
            child: AutocompleteLabel<String>(
                //keepAutofocus: true,
                onChanged: (values) =>
                    updateTags(values, i, rowNumber), //log.info("$values"),
                autocompleteLabelController: autocompleteLabelController))
      ]);
    } else {
      return getTextEditor(i, rowNumber);
    }
  }

  void updateTags(Iterable<dynamic> tags, int i, int j) {
    log.info("updating tags to $tags for account $selectedAccount");
    final List<String> strs = tags.map((e) => e.toString()).toList();
    selectedAccount?.setTags(strs);
    accountViewController.addTag(strs);
    //clearState();
  }

  Widget getTextEditor(int i, int rowNumber) {
    //log.info(
    ///    "selected row: $selectedRow and building editor for row $j, column $i");
    bool setAutoFocus = (selectedRow == rowNumber && (i == selectedColumn));
    TextEditingController textEditingController = TextEditingController(
        text: accountViewController.getFieldValue(rowNumber, i));
    InputDecoration decoration = const InputDecoration(
        border: OutlineInputBorder(),
        //isDense: true,
        contentPadding: EdgeInsets.all(0.0),
        fillColor: Color.fromARGB(255, 133, 109, 109));
    return TextField(
      autofocus: setAutoFocus,
      controller: textEditingController,
      decoration: decoration,
      textAlign: TextAlign.center,
      //onEditingComplete: () => {log.info("editing complete")},
      onChanged: (String value) {
        int? accountId = selectedAccount?.id;
        if (accountId != null) {
          accountViewController.addChange(accountId, i, value);
        } else {
          log.info("no account selected, can't update changes");
        }
        //accounts.updateField(j, i, value);
        //selectedAccount? = accounts.getAccount(i);
        //log.info(
        //    "changed $value for $selectedRow: $selectedColumn:  $selectedAccount");
      },
      onSubmitted: (String value) {
        if (value != accountViewController.getFieldValue(rowNumber, i)) {
          //log.info(
          //    "current value is ${accounts.getFieldValue(j, i)} .. $j $i submitted $value\n");

          int? accountId = selectedAccount?.id;
          if (accountId != null) {
            accountViewController.updateFieldById(accountId, i, value);
            accountViewController.saveChanges();
            accountViewController
                .updateAccountFiles(googleServiceNotifier.googleService);
          }
        } else {
          log.info("no change");
        }
        clearState();
      },
    );
  }

  Widget getTable() {
    return StickyHeadersTable(
      columnsLength: accountViewController.getNumberOfAccountFields(),
      rowsLength: accountViewController.accounts.getNumberOfDisplayedAccounts(),
      columnsTitleBuilder: (i) => TextButton(
        child: Text(accountViewController.getTitleColumnValue(i)),
        onPressed: () => handleColumnClick(i),
      ),
      rowsTitleBuilder: (i) => getRowTitleWidget(i),
      contentCellBuilder: (i, j) => getCellWidget(i, j),
      cellDimensions: const CellDimensions.fixed(
        contentCellWidth: 170.0,
        contentCellHeight: 30.0,
        stickyLegendWidth: 170.0,
        stickyLegendHeight: 30.0,
      ),
      legendCell: TextButton(
        child: const Text("Account Names"),
        onPressed: () => handleColumnClick(-1),
      ),
    );
  }

  Widget getRowTitleEditContainer(int rowNumber) {
    //log.info("selected column $selectedColumn");
    if (selectedColumn == null) {
      autoSelectColumn = true;
    } else {
      autoSelectColumn = false;
    }
    String currentName =
        accountViewController.getAccountByIndex(rowNumber).name;
    TextEditingController textEditingController =
        TextEditingController(text: currentName);
    InputDecoration decoration = const InputDecoration(
        border: OutlineInputBorder(),
        //isDense: true,
        contentPadding: EdgeInsets.all(0.0));
    if (rowNumber == 0) {
      decoration = const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'New Entry',
          contentPadding: EdgeInsets.all(0.0));
    }

    //log.info("auto select column? $autoSelectColumn");
    return TextField(
      autofocus: autoSelectColumn,
      controller: textEditingController,
      decoration: decoration,
      textAlign: TextAlign.center,
      onChanged: (String value) {
        //log.info("value changed $value");
        int? accountId = selectedAccount?.id;
        if (accountId != null) {
          accountViewController.addChange(accountId, -1, value);
        } else {
          log.info("no account selected, can't update changes");
        }
      },
      onSubmitted: (String value) {
        if (value != currentName) {
          log.info("current value is $currentName, submitted $value\n");
          accountViewController.updateName(rowNumber, value);
          accountViewController
              .updateAccountFiles(googleServiceNotifier.googleService);
        } else {
          log.info("no change");
        }
        clearState();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var accounts = context.watch<AccountViewController>();
    var googleServiceNotifier = context.watch<GoogleServiceNotifier>();
    //var googleService = context.watch<GoogleService>();

    //log.info("build()");

    //TextEditingController nameController = TextEditingController();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/landing': (context) => DecoratedTablePage(
              titleColumn: const ["Col 1", "Col 2"],
              titleRow: const ["Row 1", "Row 2"],
              data: const [],
            ),
      },
      home: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Accounts',
              maxLines: 2,
            ),
            backgroundColor: Colors.black54, //Colors.amber,
          ),
          body: Column(children: <Widget>[
            getRequestAccessDialog(),
            getRequestDialog(),
            getWidgetRow(),
            Expanded(child: getTable())
          ])),
    );
  }

  void testAlert(BuildContext context) {
    var alert = AlertDialog(
      title: Text("Test"),
      content: Text("Done..!"),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to confirm this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                print('Confirmed');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget denyButton = TextButton(
      child: const Text("Deny Access"),
      onPressed: () {},
    );
    Widget allowButton = TextButton(
      child: const Text("Grant Access"),
      onPressed: () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Account Access Request"),
      content: const Text("Access Request, would you like to approve?"),
      actions: [],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class _FilterSearch extends StatelessWidget {
  void updateFilter(String filterText) {
    //log.info("updating filter to $filterText");
    accountViewController.filterAccounts(filterText);
  }

  @override
  Widget build(BuildContext context) {
    //TextEditingController textEditingController =
    //    TextEditingController(text: accountViewController.accounts.filterText);
    return Consumer<AccountViewController>(
        builder: (context, accounts, child) => SizedBox(
            width: 100.0,
            height: 35,
            child: TextField(
                onSubmitted: (value) {
                  updateFilter(value);
                },
                onChanged: (value) => updateFilter(value),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white70,
                  contentPadding: EdgeInsets.all(5.0),
                  labelText: 'Filter',
                ))));
  }
}

class AccountTotal extends StatelessWidget {
  const AccountTotal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountViewController>(
      builder: (context, accounts, child) =>
          Text('${accountViewController.accounts.getNumberOfAccounts()}'),
    );
  }
}

/***
class TagEdit extends StatelessWidget {
  List<String> list = <String>['One', 'Two', 'Three', 'Four'];

  void updateTagFilter(String tagText) {
    //log.info("updating filter to $filterText");
    accounts.filterAccountsByTag(tagText);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Text("Tags"),
        ListView(
          children: <Widget>[Text("Tag1"), Text("Tag2"), Text("Tag3")],
        )
      ],
      //overflow: TextOverflow.clip,
    );
  }
}
***/

class TagDropdownButton extends StatefulWidget {
  TagDropdownButton({super.key});

  @override
  State<TagDropdownButton> createState() => _TagDropdownButtonState();
}

class _TagDropdownButtonState extends State<TagDropdownButton> {
  List<String> tags = accountViewController.getTags();
  String dropdownValue = "No Filter";

  @override
  Widget build(BuildContext context) {
    return Container(
        //padding: EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white70,
        ),
        child: DropdownButton<String>(
          value: dropdownValue,
          icon: const Icon(
            Icons.arrow_downward,
            color: Colors.black54,
          ),
          elevation: 16,
          style: const TextStyle(color: Colors.white),
          //underline: Container(
          //  height: 2,
          //  color: Colors.white70,
          //),
          onChanged: (String? value) {
            // This is called when the user selects an item.
            setState(() {
              dropdownValue = value!;
              accountViewController.filterAccountsByTag(dropdownValue);
            });
          },
          items: tags.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
                value: value,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  //decoration: BoxDecoration(
                  //  color: Colors.white,
                  //),
                  child: Text(
                    value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                ));
          }).toList(),
        ));
  }
}

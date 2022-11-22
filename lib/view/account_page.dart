import 'package:flutter/material.dart';
import 'package:password_manager/main.dart';
import 'package:password_manager/service/google_api.dart';
import 'package:password_manager/service/google_service_notifier.dart';
import 'package:password_manager/controller/account_view_controller.dart';
import 'package:password_manager/view/tool_tab.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:password_manager/model/accounts.dart';
import 'package:provider/provider.dart';
import 'package:password_manager/view/decorated_table_page.dart';
import 'package:password_manager/view/autocomplete_label.dart';
import 'package:logging/logging.dart';
import 'package:flutter/services.dart';

import 'account_grid_view.dart';
import 'account_list_edit.dart';
import 'account_list_view.dart';

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
  bool showGridView = true;

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
    await googleServiceNotifier.handleGoogleDriveLogin();
    accountViewController.googleService = googleServiceNotifier.googleService;
    log.fine(
        "should have google service, do we? ${accountViewController.googleService}");
    await accountViewController
        .reconcileGoogleAccountFile(googleServiceNotifier.googleService);
    await accountViewController.refreshAccessRequestList();
  }

  Future<void> cancelGoogleDriveLogin() async {
    await googleServiceNotifier.handleGoogleDriveLogout();
  }

  Future<void> handleDenyResponse() async {
    await googleServiceNotifier.handleDenyResponse();
  }

  Future<void> handleGoogleDriveLogout() async {
    log.info("Logging out ...");
    await googleServiceNotifier.handleGoogleDriveLogout();
  }

  Widget getRequestAccessDialog() {
    log.finest("getRequestAccessDialog()");
    int x = 1;
    if (accountViewController.promptToShowDeniedAccess) {
      return SimpleDialog(
        title: const Text("""Your Drive request was denied,\ncannot sync."""),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () {
              log.info("access denied ..");
              setState(() {
                accountViewController.promptToShowDeniedAccess = false;
                handleDenyResponse();
              });
            },
            child: const Text('Dismiss'),
          )
        ],
      );
    } else if (accountViewController.promptToShowOutstandingRequest) {
      return SimpleDialog(
        title: const Text(
            """You are still waiting for\ngranted access to Drive"""),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () {
              log.info("access under review..");
              setState(() {
                accountViewController.promptToShowOutstandingRequest = false;
                handleGoogleDriveLogout();
              });
            },
            child: const Text('Dismiss'),
          )
        ],
      );
    } else if (accountViewController.promptToRequestDriveAccess) {
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
                handleGoogleDriveLogout();
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
    if (accountViewController.haveGrantedAccess &&
        accountViewController.outstandingRequests.isNotEmpty) {
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

  Widget getFilterSearch() {
    //log.info("getFilterSearch($accountViewController.showFilterViews)");
    bool showFilterViews = (!accountViewController.showAccountCardView &&
        !accountViewController.showAccountEditCardView);
    return Visibility(
        visible: showFilterViews,
        child: Row(children: [
          Container(
              //color: Colors.amber,
              height: 55,
              child: TextButton(
                onPressed: clearState,
                child: _FilterSearch(),
                //onPressed: () => Navigator.pushNamed(context, '/accounts'),
              )),
          //const Text(
          //  "Tags: ",
          //  style:
          //      TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
          //),
          Container(
            //width: 100.0,
            //color: Colors.amber,
            padding: EdgeInsets.all(2),
            height: 37,
            child: TagDropdownButton(),
          ),
        ]));
  }

  Widget getWidgetRow() {
    //log.finer("getWidgetRow");
    clearState();
    var displayIcon = const Icon(Icons.list_rounded, size: 55);
    if (showGridView) {
      displayIcon = const Icon(
        Icons.apps_rounded,
        size: 50,
      );
      //showFilterViews = true;
    } else {
      //showFilterViews = false;
    }
    //print("getwidgetrow($showFilterViews)");
    return Container(
        color: Colors.black54,
        child: Row(
          children: <Widget>[
            getFilterSearch(),
            Expanded(
              child: Container(),
            ),
            Container(
                //color: Colors.amber,
                alignment: Alignment.centerRight,
                child: getGoogleDriveWidget()),
            IconButton(
              //Icons.list_rounded,
              iconSize: 55,
              alignment: Alignment.center,
              onPressed: () {
                setState(() {
                  showGridView = !showGridView;
                  accountViewController.showAccountCardView = false;
                  accountViewController.showFilterViews = false;
                });
              },
              padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
              icon: displayIcon,
              color: Colors.white70,
            ),
          ],
        ));
  }

  Widget getRowTitleWidget(int rowNumber) {
    String accountName =
        accountViewController.getAccountByIndex(rowNumber).name;
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
          height: 45,
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
          height: 45,
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
          height: 45,
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
      },
      onSubmitted: (String value) {
        if (value != accountViewController.getFieldValue(rowNumber, i)) {
          //log.info(
          //    "current value is ${accounts.getFieldValue(j, i)} .. $j $i submitted $value\n");

          int? accountId = selectedAccount?.id;
          if (accountId != null) {
            accountViewController.updateFieldById(accountId, i, value);
            accountViewController.saveChanges();
            accountViewController.updateAccountFiles();
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
      rowsLength: accountViewController.getNumberOfDisplayedAccounts(),
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

  Widget getMainStageWidget() {
    AccountItem? currentAccount =
        accountViewController.currentlySelectedAccount;
    if ((accountViewController.showAccountEditCardView ||
            accountViewController.showAccountCreateView) &&
        currentAccount != null) {
      //return AccountEditCardView(currentAccount);
      //setState(() {
      //  showFilterViews = false;
      //});
      return AccountListEditView(currentAccount);
    } else if (accountViewController.showAccountCardView &&
        currentAccount != null) {
      //return AccountCardView(currentAccount);
      //setState(() {
      //  showFilterViews = false;
      //});
      return AccountListView(currentAccount);
    } else if (showGridView) {
      //setState(() {
      //  showFilterViews = true;
      //});
      return const Expanded(child: AccountGridView());
    } else {
      return Expanded(child: getTable());
    }
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
          accountViewController.updateAccountFiles();
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

    //log.finest("build()");

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
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          //title: const Text(
          //  'Accounts',
          //  maxLines: 1,
          //),
          toolbarHeight: 20.0,
          //bottom: ToolTab(googleServiceNotifier),
          backgroundColor: Colors.black45, //Colors.amber,
        ),
        body: Column(children: <Widget>[
          getRequestAccessDialog(),
          getRequestDialog(),
          getWidgetRow(),
          getMainStageWidget(),
          //Expanded(child: getTable()),
          //const Expanded(child: AccountGridView()),
        ]),
      ),
    );
  }

  void testAlert(BuildContext context) {
    var alert = const AlertDialog(
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
          title: const Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: Column(
              children: const <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to confirm this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                print('Confirmed');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
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
    AlertDialog alert = const AlertDialog(
      title: Text("Account Access Request"),
      content: Text("Access Request, would you like to approve?"),
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
    log.finer("updating filter to $filterText");
    if (filterText.isEmpty || filterText.trim().isEmpty) {
      accountViewController.clearFilter();
    } else {
      accountViewController.filterAccounts(filterText);
    }
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
                  labelText: 'filter',
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
  const TagDropdownButton({super.key});
  @override
  State<TagDropdownButton> createState() => _TagDropdownButtonState();
}

class _TagDropdownButtonState extends State<TagDropdownButton> {
  List<String> tags = accountViewController.getTags();
  //String dropdownValue = accountViewController.filterDropDownValue;
  //    filterDropDownValue = filterText;

  @override
  Widget build(BuildContext context) {
    //print("_TagDropdownButtonState");
    //print("Tags $tags");
    if (tags.isEmpty) {
      tags = ["none"];
    }

    if (accountViewController.filterDropDownValue.isEmpty) {
      accountViewController.filterDropDownValue = "no tags";
    }

    return Container(
        //padding: EdgeInsets.all(8),
        //height: 35,
        //width: 100,
        decoration: const BoxDecoration(
          color: Colors.white70,
        ),
        child: DropdownButton<String>(
          value: accountViewController.filterDropDownValue,
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
            log.fine("selecting value $value");
            // This is called when the user selects an item.
            setState(() {
              accountViewController.filterDropDownValue = value!;
              accountViewController.filterAccountsByTag(value);
            });
          },
          items: tags.map<DropdownMenuItem<String>>((String value) {
            String toShow = value;
            if (value.isNotEmpty && value.length > 15) {
              toShow = "${value.substring(0, 12)} ...";
            }
            return DropdownMenuItem<String>(
                value: value,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  //decoration: BoxDecoration(
                  //  color: Colors.white,
                  //),
                  child: Text(
                    toShow, //.substring(0, 4),
                    //softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.normal, color: Colors.black54),
                  ),
                ));
          }).toList(),
        ));
  }
}

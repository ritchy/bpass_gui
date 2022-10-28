import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:password_manager/main.dart';
import 'package:password_manager/service/google_api.dart';
import 'package:password_manager/model/accounts.dart';
import 'package:logging/logging.dart';
import 'dart:io';
import 'package:password_manager/console.dart';

class AccountViewController extends ChangeNotifier {
  Accounts accounts;
  GoogleService? googleService;
  List outstandingRequests = [];
  bool haveGrantedAccess = false;
  bool promptToRequestDriveAccess = false;
  bool promptToShowDeniedAccess = false;
  bool promptToShowOutstandingRequest = false;
  final log = Logger('AccountViewController');
  List<String> titleColumns = [
    "UserName",
    "Password",
    "Hint",
    "Email",
    "Account Number",
    "URL",
    "Notes",
    "Tags"
  ];
  List<ChangeItem> changes = [];

  AccountViewController(this.accounts);

  void loadFile(File file) {
    accounts.loadFile(file);
    notifyListeners();
  }

  Future<void> updateAccountFiles(GoogleService? googleService) async {
    await accounts.updateAccountFiles(googleService);
    notifyListeners();
  }

  AccountItem getAccountByIndex(int index) {
    return accounts.getAccount(index);
  }

  List<String> getAccountTagsByIndex(int accountIndex) {
    return accounts.getAccountTags(accountIndex);
  }

  void saveChanges() async {
    accounts.removeEmptyDisplayAccounts();
    accounts.removeEmptyAccounts();
    log.info("saving ${changes.length} changes");
    for (ChangeItem item in changes) {
      log.fine("${item.accountId}, ${item.fieldIndex}, ${item.value}");
      updateFieldById(item.accountId, item.fieldIndex, item.value);
    }
    changes = [];
    accounts.insertBlankDisplayedAccount();
    //notifyListeners();
  }

  Future<void> reconcileGoogleAccountFileOld(
      GoogleService? googleService) async {
    this.googleService = googleService;
    if (googleService == null) {
      log.warning("Trying to sync accounts with Drive file, but not logged in");
    } else {
      File? toReconcile = await googleService.downloadAccountFile();
      if (toReconcile != null) {
        if (googleService.loggedIn) {
          bool somethingChanged = await accounts.reconcileAccountsFromFile(
              toReconcile, googleService);
          if (somethingChanged) {
            notifyListeners();
          }
        } else {
          Console.normal(
              "Trying to sync accounts with Drive file, but we cannot seem to download it");
        }
      }
    }
  }

  Future<void> reconcileGoogleAccountFile(GoogleService? googleService) async {
    //check to see if the accounts file exist
    bool? fileExistsInDrive = await googleService?.accountsFileExistInDrive();
    if (fileExistsInDrive == null) {
      log.warning("There was a problem with the google service");
    } else if (fileExistsInDrive) {
      String? key = googleService?.googleSettings.keyAsBase64;
      if (key != null && key.isNotEmpty) {
        //if we have the key, then we've already been granted access
        haveGrantedAccess = true;
        //we have a file in Drive and an encryption key, good to go
        log.info("Got key, downloading file from Google Drive ... ");
        File? toReconcile = await googleService?.downloadAccountFile();
        //print ("downloaded file ${toReconcile.path}, now reconciling ...");
        if (accounts == null) {
          print("Have not loaded accounts locally, unable to perform sync");
        } else {
          await accounts.reconcileAccountsFromFile(
              toReconcile!, googleService!);
          log.info("Checking for access requests ...");
          await refreshAccessRequestList();
        }
      } else {
        //looks like we need to make a request for access
        //let's make sure we haven't already done that
        ClientAccess? outstandingRequest =
            await googleService?.findExistingRequest();
        //print("outstanding request $outstandingRequest");
        //outstandingRequest ??= null;
        if (outstandingRequest != null) {
          if (outstandingRequest.accessStatus == ClientAccess.REQUESTED) {
            log.info(
                "Existing request for access to existing accounts in Drive, run sync again when request has been granted.");
            promptToShowOutstandingRequest = true;
            //googleServiceNotifier.handleGoogleDriveLogout();
          } else if (outstandingRequest.accessStatus == ClientAccess.DENIED) {
            Console.normal(
                "You sent a request that was denied run sync again if you want to send another request");
            promptToShowDeniedAccess = true;
            //await googleService?.removeOutstandingRequests();
            //await googleService?.updateClientAccessRequests();
          } else if (outstandingRequest.accessStatus == ClientAccess.GRANTED) {
            Console.normal("Request granted .. ");
            final encryptedKey = outstandingRequest.encryptedAccessKey;
            if (encryptedKey != null) {
              //print("decrypting key...");
              await googleService?.decryptAndSaveKey(encryptedKey);
              haveGrantedAccess = true;
            } else {
              log.warning("granted access to Drive, but no key provided??");
            }
          }
        } else {
          //Console.normal("-------> Request Access?");
          log.info(
              "This appears to be first sync and there's an existing file in Google Drive, request access. ");
          promptToRequestDriveAccess = true;
          notifyListeners();
        }
      }
    } else {
      //no file in Drive, so we are the first one to sync, no need to reconcile, but we need to set up encryption
      String? key = googleService?.googleSettings.keyAsBase64;
      if (key != null && key.isNotEmpty) {
        //looks like we already set up encryption key, so just synd
        accounts.updateAccountFiles(googleService);
      } else {
        Console.normal(
            "This appears to be your first sync, generating encryption keys ...");
      }
    }
  }

  Future<void> requestAccessToDriveFile() async {
    final GoogleService? gs = googleService;
    if (gs == null || !gs.loggedIn) {
      log.warning("Trying to request access in Drive file, but not logged in");
    } else {
      await googleService?.generateNewClientAccessRequest();
      await googleService?.updateClientAccessRequests();
    }
    log.info(
        "sent access request, run sync again when request has been granted ...");
  }

  Future<void> grantAccessRequest(ClientAccess accessRequest) async {
    log.finer("controller grantAccessRequest()");
    final GoogleService? gs = googleService;
    if (gs == null || !gs.loggedIn) {
      log.warning("Trying to update access in Drive file, but not logged in");
    } else {
      String? clientId = accessRequest.clientId;
      if (clientId != null) {
        log.info("controller granting access to $clientId ...");
        await gs.grantAccessRequest(clientId);
      } else {
        log.warning(
            "This access request isn't valid, missing required client id, removing");
        await gs.removeAccessRequest(accessRequest);
      }
    }
    notifyListeners();
  }

  Future<void> denyAccessRequest(ClientAccess accessRequest) async {
    final GoogleService? gs = googleService;
    if (gs == null || !gs.loggedIn) {
      log.warning(
          "Trying to sync deny response with Drive file, but not logged in");
    } else {
      accessRequest.accessStatus = ClientAccess.DENIED;
      await gs.updateClientRequest(accessRequest);
    }
    notifyListeners();
  }

  Future<void> updateOutstandingRequest(ClientAccess accessRequest) async {
    if (googleService != null) {
      if (googleService!.loggedIn) {
        Console.normal("Trying to sync with Drive file, but not logged in");
      } else {
        await googleService?.updateClientRequest(accessRequest);
      }
    }
  }

  Future<void> refreshAccessRequestList() async {
    //var outstandingRequests = [];
    ClientAccessRequests? clientAccessRequests =
        await loadOutstandingAccessRequests();
    log.info("reviewing access requests...");
    var requests = clientAccessRequests?.clientAccessRequests;
    if (requests != null) {
      for (ClientAccess ca in requests) {
        if (ca.accessStatus == ClientAccess.REQUESTED) {
          outstandingRequests.add(ca);
        }
      }
    }
    //return outstandingRequests;
    notifyListeners();
  }

  Future<ClientAccessRequests?> loadOutstandingAccessRequests() async {
    final GoogleService? gs = googleService;
    if (gs == null) {
      log.warning("Trying to sync with Drive file, but not logged in");
    } else {
      if (!await gs.clientAccessFileExistInDrive()) {
        log.info("Access file does not exist in drive, creating ...");
        await gs.generateNewClientAccessFile();
      }
      return await gs.loadClientAccessRequests();
    }
    return null;
  }

  Future<void> reconcileAccessRequests(GoogleService? googleService) async {
    if (googleService == null || !googleService.loggedIn) {
      log.warning("Trying to sync with Drive file, but not logged in");
    } else {
      if (!await googleService.clientAccessFileExistInDrive()) {
        Console.normal("Access file does not exist in drive, creating ...");
        googleService.generateNewClientAccessFile();
      } else {
        ClientAccessRequests clientAccessRequests =
            await googleService.loadClientAccessRequests();
        //await googleService.generateNewClientAccessRequest();
        log.info("reviewing access requests...");
        var requests = clientAccessRequests.clientAccessRequests;
        for (ClientAccess ca in requests) {
          if (ca.accessStatus == ClientAccess.REQUESTED) {
            //prompt to accept/deny request
            //print("granting request: ${ca.clientName}");
            //var clientId = ca.clientId;
            //if (clientId != null) {
            //  await googleService.grantAccessRequest(clientId);
            //}
          }
        }
      }
    }
  }

  void sortByColumnNumber(int columnNumber, bool sortAscending) {
    //log.info("sorting by column $columnNumber and ascending $sortAscending...");
    List<AccountItem> displayedAccounts = accounts.displayedAccounts;
    accounts.removeEmptyDisplayAccounts();
    if (columnNumber == -1) {
      displayedAccounts.sort((accountOne, accountTwo) => accountOne.name
          .toLowerCase()
          .compareTo(accountTwo.name.toLowerCase()));
    } else if (columnNumber == 0) {
      displayedAccounts.sort((accountOne, accountTwo) =>
          accountOne.username.compareTo(accountTwo.username));
    } else if (columnNumber == 1) {
      displayedAccounts.sort((accountOne, accountTwo) =>
          accountOne.password.compareTo(accountTwo.password));
    } else if (columnNumber == 2) {
      displayedAccounts.sort((accountOne, accountTwo) =>
          accountOne.hint.compareTo(accountTwo.hint));
    } else if (columnNumber == 3) {
      displayedAccounts.sort((accountOne, accountTwo) =>
          accountOne.email.compareTo(accountTwo.email));
    } else if (columnNumber == 4) {
      displayedAccounts.sort((accountOne, accountTwo) =>
          accountOne.accountNumber.compareTo(accountTwo.accountNumber));
    } else if (columnNumber == 5) {
      displayedAccounts.sort(
          (accountOne, accountTwo) => accountOne.url.compareTo(accountTwo.url));
    } else if (columnNumber == 6) {
      displayedAccounts.sort((accountOne, accountTwo) =>
          accountOne.notes.compareTo(accountTwo.notes));
    }

    if (!sortAscending) {
      displayedAccounts = displayedAccounts.reversed.toList();
    }
    accounts.displayedAccounts = displayedAccounts;
    accounts.insertBlankDisplayedAccount();
    notifyListeners();
  }

  String getFieldValue(int accountIndex, int fieldIndex) {
    List<AccountItem> displayedAccounts = accounts.displayedAccounts;

    if (fieldIndex == -1) {
      return displayedAccounts[accountIndex].name;
    } else if (fieldIndex == 0) {
      return displayedAccounts[accountIndex].username;
    } else if (fieldIndex == 1) {
      return displayedAccounts[accountIndex].password;
    } else if (fieldIndex == 2) {
      return displayedAccounts[accountIndex].hint;
    } else if (fieldIndex == 3) {
      return displayedAccounts[accountIndex].email;
    } else if (fieldIndex == 4) {
      return displayedAccounts[accountIndex].accountNumber;
    } else if (fieldIndex == 5) {
      return displayedAccounts[accountIndex].url;
    } else if (fieldIndex == 6) {
      return displayedAccounts[accountIndex].notes;
    } else if (fieldIndex == 7) {
      String tagValue = "";
      for (String t in displayedAccounts[accountIndex].tags) {
        tagValue = tagValue + " " + t;
      }
      return tagValue;
    } else {
      return "";
    }
  }

  bool updateFieldById(int accountId, int fieldNumber, String newValue) {
    bool updated = false;
    for (AccountItem account in accounts.accounts) {
      if (account.id == accountId) {
        //log.info("updating account with id $accountId ...");
        updated = updateField(account, fieldNumber, newValue);
        break;
      }
    }
    return updated;
  }

  bool updateField(AccountItem account, int fieldNumber, String newValue) {
    bool updated = true;
    switch (fieldNumber) {
      case -1:
        {
          //new account name
          //log.info("updating account name to $newValue");
          account.name = newValue;
        }
        break;
      case 0:
        {
          //new username
          //log.info("updating username to $newValue");
          account.username = newValue;
        }
        break;

      case 1:
        //new password
        //log.info("updating password to $newValue");
        account.password = newValue;
        break;

      case 2:
        //new hint
        //log.info("updating hint to $newValue");
        account.hint = newValue;
        break;

      case 3:
        //new email
        //log.info("updating email to $newValue");
        account.email = newValue;
        break;

      case 4:
        //new account number
        //log.info("updating account number to $newValue");
        account.accountNumber = newValue;
        break;

      case 5:
        //new url
        //log.info("updating url to $newValue");
        account.url = newValue;
        break;

      case 6:
        //new notes
        //log.info("updating notes to $newValue");
        account.notes = newValue;
        break;

      case 7:
        //new notes
        //log.info("updating notes to $newValue");
        account.tags = [];
        break;

      default:
        {
          //statements;
          updated = false;
        }
        break;
    }
    if (updated) {
      account.lastUpdated = DateTime.now();
    }
    notifyListeners();
    return updated;
  }

  void updateName(int index, String name) {
    AccountItem account = accounts.displayedAccounts[index];
    updateFieldById(account.id, -1, name);
  }

  void clearFilter() {
    accounts.clearFilter();
    notifyListeners();
  }

  void filterAccounts(String searchTerm) {
    accounts.filterAccounts(searchTerm);
    notifyListeners();
  }

  void filterAccountsByTag(String tagSearch) {
    accounts.filterAccountsByTag(tagSearch);
    notifyListeners();
  }

  void addAccount(AccountItem item) {
    accounts.addAccount(item);
    notifyListeners();
  }

  void addTag(List<String> newTags) {
    accounts.addTag(newTags);
    notifyListeners();
  }

  List<String> getTitleColumns() {
    return titleColumns;
  }

  String getTitleColumnValue(int index) {
    return titleColumns[index];
  }

  int getNumberOfAccountFields() {
    return titleColumns.length;
  }

  List<String> getTags() {
    return accounts.getTags();
  }

  void addChangeItem(ChangeItem change) {
    List<ChangeItem> toRemove = [];
    for (ChangeItem item in changes) {
      if (item.fieldIndex == change.fieldIndex &&
          item.accountId == change.accountId) {
        toRemove.add(item);
      }
    }
    for (ChangeItem item in toRemove) {
      changes.remove(item);
    }
    changes.add(change);
  }

  void addChange(int accountId, int fieldIndex, String value) {
    //log.info("adding change to account $accountId ...");
    addChangeItem(
        ChangeItem(accountId: accountId, fieldIndex: fieldIndex, value: value));
  }
}

class ChangeItem {
  ChangeItem(
      {required this.accountId, required this.fieldIndex, required this.value});
  int accountId;
  int fieldIndex;
  String value;
}

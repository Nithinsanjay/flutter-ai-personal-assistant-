import 'package:flutter/foundation.dart';
import '../services/gmail/gmail_service.dart';

class ConnectivityViewModel extends ChangeNotifier {
  int currentTabIndex = 0;
  bool isGmailConnected = false;
  String gmailEmail = '';
  bool isM365Connected = false;
  bool outlookTasksEnabled = false;
  bool meetingPrepEnabled = false;
  final String userName = "Pandi";

  void setTabIndex(int index) {
    currentTabIndex = index;
    notifyListeners();
  }

  Future<String> initiateGmailOAuthFlow() async {
    return await GmailService.instance.startOAuthFlow();
  }

  Future<void> connectGmail(String email) async {
    isGmailConnected = true;
    gmailEmail = email;
    notifyListeners();
  }

  Future<void> disconnectGmail() async {
    isGmailConnected = false;
    gmailEmail = '';
    await GmailService.instance.clearCredentials();
    notifyListeners();
  }

  void setGmailConnected(bool value) {
    isGmailConnected = value;
    notifyListeners();
  }

  void setGmailAccountEmail(String email) {
    gmailEmail = email;
    notifyListeners();
  }

  void setM365Connected(bool value) {
    isM365Connected = value;
    if (!value) {
      outlookTasksEnabled = false;
      meetingPrepEnabled = false;
    }
    notifyListeners();
  }

  void setOutlookTasksEnabled(bool value) {
    if (isM365Connected) {
      outlookTasksEnabled = value;
      notifyListeners();
    }
  }

  void setMeetingPrepEnabled(bool value) {
    if (isM365Connected) {
      meetingPrepEnabled = value;
      notifyListeners();
    }
  }
}

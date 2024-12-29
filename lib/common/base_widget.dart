import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showCustomSnackBar(String? message, BuildContext context, {bool isError = true, bool isToaster = false}) {
  Fluttertoast.showToast(
      msg: message!,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,

      timeInSecForIosWeb: 1,
      backgroundColor: isError ? const Color(0xFFFF0014) : const Color(0xFF1E7C15),
      textColor: Colors.white,
      fontSize: 16.0
  );
}

Future<bool> checkNetworkConnection() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    // Connected to a mobile network or wifi
    return true;
  } else {
    // Not connected to any network
    return false;
  }
}

GlobalKey<NavigatorState> dialogKey = GlobalKey<NavigatorState>();

void showLoadingDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    },
    useRootNavigator: true,  // Ensure the dialog is shown in the root navigator
    barrierColor: Colors.black.withOpacity(0.5),  // Optional: Add a dimming effect
  );
}

void hideLoadingDialog(BuildContext context) {
  if (Navigator.of(context, rootNavigator: true).canPop()) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
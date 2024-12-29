import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  static void show(BuildContext context, {Key? key}) {
    showDialog<void>(
      context: context,
      useRootNavigator: false,
      barrierColor: Colors.black26,
      barrierDismissible: false,
      builder: (_) => LoadingDialog(key: key),
    ).then((_) => FocusScope.of(context).requestFocus(FocusNode()));
  }

  static void hide(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1));
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              backgroundColor: Color(0xffcde8a4),
              color: Color(0xffa0cb57),
            ),
            SizedBox(height: 16),
            // Add some space between the indicator and text
            /*Text(
              Strings.pleaseWaitMessage,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none),
            ),*/
          ],
        ),
      ),
    );
  }
}

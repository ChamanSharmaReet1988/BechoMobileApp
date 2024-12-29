import 'package:flutter/material.dart';

class DismissKeyboardWidget extends StatelessWidget {
  final Widget child;

  const DismissKeyboardWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: child,
    );
  }
}

import 'package:flutter/material.dart';

//for keyboard hide.
/// Purpose : Custom Class for hiding keyboard when click anywhere on screen

class KeyboardHideView extends StatelessWidget {
  final Widget child;

  KeyboardHideView({required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: this.child,
    );
  }
}

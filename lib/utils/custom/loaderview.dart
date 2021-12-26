import 'package:flutter/material.dart';
import 'package:flutter_practical_aveosoft/utils/app_color.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

/// Purpose: Custom Class to show loader till api response comes.
class LoaderView extends StatelessWidget {
  final Widget child;
  final bool showLoader;

  const LoaderView({Key? key, required this.child, required this.showLoader}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: child,
      inAsyncCall: showLoader,
      color: AppColor.appWhite,
      progressIndicator: const CircularProgressIndicator(),
    );
  }
}

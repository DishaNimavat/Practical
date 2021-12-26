import 'package:flutter/material.dart';

import 'app_color.dart';

//App theme.
class AppTheme {
  static Color lightBG = Color(0xffe01522);

  static Map<int, Color> myColor = {
    50: Color.fromRGBO(224, 21, 34, .1),
    100: Color.fromRGBO(224, 21, 34, .2),
    200: Color.fromRGBO(224, 21, 34, .3),
    300: Color.fromRGBO(224, 21, 34, .4),
    400: Color.fromRGBO(224, 21, 34, .5),
    500: Color.fromRGBO(224, 21, 34, .6),
    600: Color.fromRGBO(224, 21, 34, .7),
    700: Color.fromRGBO(224, 21, 34, .8),
    800: Color.fromRGBO(224, 21, 34, .9),
    900: Color.fromRGBO(224, 21, 34, 1),
  };

  static MaterialColor colorCustom = MaterialColor(0xFFe01522, myColor);

  static ThemeData lightTheme = ThemeData(
    backgroundColor: lightBG,
    primaryColor: colorCustom,
    canvasColor: Colors.transparent,
    scaffoldBackgroundColor: AppColor.appWhite,
    appBarTheme: AppBarTheme(
      color: AppColor.appColor,
      elevation: 0,
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: colorCustom)
        .copyWith(secondary: colorCustom),
    textSelectionTheme: TextSelectionThemeData(cursorColor: colorCustom),
  );
}

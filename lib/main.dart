import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_practical_aveosoft/splash.dart';
import 'package:flutter_practical_aveosoft/utils/app_theme.dart';
import 'package:flutter_practical_aveosoft/utils/service_locator.dart';
const debug = false;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: debug);

  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aveosoft Practical',
      theme: AppTheme.lightTheme.copyWith(
        appBarTheme: Theme.of(context).appBarTheme.copyWith(
          brightness: Brightness.light,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home:  SplashScreen(),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:adawifi/screens/sign-in/index.dart';
import 'package:adawifi/detail.dart';
import 'package:adawifi/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Adawifi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/sign-in',
      routes: {
        '/sign-in' : (context) => SignIn(),

        '/': (context) => MyHomePage(
              title: 'Flutter Adawifi',
            ),
        '/detail': (context) => Detail()
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'root_page.dart';
import 'auth.dart';

void main() {
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    home: new MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Firebase Auth',
        theme: new ThemeData(
            primarySwatch: Colors.blue,
            buttonColor: Colors.blue[900],
            inputDecorationTheme:
                InputDecorationTheme(border: OutlineInputBorder())),
        // home:
        routes: <String, WidgetBuilder>{
          '/': (BuildContext context) => new RootPage(auth: new Auth()),
        });
  }
}

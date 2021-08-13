import 'package:flutter/material.dart';
import 'screens/homePage.dart';

class MyApp extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData( brightness: Brightness.dark),
        home: HomePage(),
      );
  }
}

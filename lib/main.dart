import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mood/Model/AppModel.dart';
import 'package:mood/View/HomePage.dart';
import 'package:scoped_model/scoped_model.dart';

void main() {
  runApp(MyApp(model: AppModel()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final AppModel model;

  const MyApp({Key key, @required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppModel>(
      model: model,
      child: MaterialApp(
        title: 'Mood',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: Colors.white,
          primarySwatch: Colors.pink,
          accentColor: Colors.pinkAccent,
          backgroundColor: Color.fromRGBO(245, 245, 245, 1),
          chipTheme: ChipThemeData(
            backgroundColor: Color.fromRGBO(245, 245, 245, 1),
            disabledColor: Colors.black12,
            selectedColor: Colors.grey,
            secondarySelectedColor: Colors.black45,
            padding: EdgeInsets.all(4),
            labelStyle: TextStyle(color: Colors.black87),
            secondaryLabelStyle: TextStyle(color: Colors.black87),
            brightness: Brightness.dark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Colors.transparent,
                  width: 0,
                  style: BorderStyle.solid
                )
            )
          ),
          appBarTheme: AppBarTheme(
            color: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.black45,
            ),
          ),
          iconTheme: IconThemeData(
            color: Colors.black45,
          ),
          // This makes the visual density adapt to the platform that you run
          // the app on. For desktop platforms, the controls will be smaller and
          // closer together (more dense) than on mobile platforms.
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(),
      ),
    );
  }
}
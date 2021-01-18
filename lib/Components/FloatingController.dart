import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mood/Components/MinimizedController.dart';
import 'package:mood/Components/AdvancedController.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:mood/Model/AppModel.dart';

class FloatingController extends StatefulWidget {
  FloatingController({Key key}) : super(key: key);

  @override
  _FloatingControllerState createState() => _FloatingControllerState();
}

class _FloatingControllerState extends State<FloatingController> {

  double _height = 60;

  @override
  Widget build(BuildContext context) {
    return Container(child: ScopedModelDescendant<AppModel>(
        builder: (context, child, model) {
          return Container(
            alignment: Alignment.bottomCenter,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 100),
                  height: model.trackInfo == null ? 0 : _height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 8,
                          color: Colors.black26
                      )
                    ],
                    border: Border(top: BorderSide(
                        color: Colors.transparent,
                        style: BorderStyle.solid,
                        width: 1
                    )),
                  ),
                  child: _height <= 250 ? MinimizedController() :
                  AdvancedController(),
                ),
                if (model.trackInfo != null)
                  GestureDetector(
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: Text(""),
                    ),
                    onVerticalDragUpdate: (details) {
                      double pos = details.globalPosition.dy;
                      double dy = MediaQuery.of(context).size.height;
                      if ((dy - pos) > 60) setState(() {
                        _height = dy - pos;
                      });
                      else setState(() {
                        _height = 60;
                      });
                    },
                    onVerticalDragEnd: (details) {
                      if (_height > 250) setState(() {
                        _height = MediaQuery.of(context).size.height;
                      });
                      else setState(() {
                        _height = 60;
                      });
                    },
                  ),
              ],
            ),
          );
        }
    ));
  }
}
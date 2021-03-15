import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';

class WaitingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: mainBoxDecoration,
        child: new Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            alignment: Alignment.center,
            child: circularProgressIndicator,
          ),
        ));
  }
}

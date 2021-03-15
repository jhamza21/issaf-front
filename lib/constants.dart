import 'package:issaf/language/appLocalizations.dart';
import 'package:flutter/material.dart';

//TEXT INPUT DECORATION
inputTextDecoration(
    Icon prefixIcon, String hintText, GestureDetector suffixIcon) {
  return InputDecoration(
    hintText: hintText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    fillColor: Colors.white,
    filled: true,
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.orange[900], width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(40))),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.orange[300], width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(40))),
    disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.orange[300], width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(40))),
    errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red[800], width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(40))),
    focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red[400], width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(40))),
  );
}

//RETURN TRANSLATED VALUE
String getTranslate(BuildContext context, String key) {
  return AppLocalizations.of(context).getTranslatedValue(key);
}

//APPLICATION BACKGROUND COLOR GRADIENT
BoxDecoration mainBoxDecoration = BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xfffbb448), Color(0xffe46b10)]));

//CIRCULAR PROGRESS INDICATOR
SizedBox circularProgressIndicator = SizedBox(
  height: 20.0,
  width: 20.0,
  child: CircularProgressIndicator(
    valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
  ),
);

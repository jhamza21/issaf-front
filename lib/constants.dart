import 'package:issaf/language/appLocalizations.dart';
import 'package:flutter/material.dart';

const URL_BACKEND = "http://10.0.2.2:8000/api/";
//TEXT INPUT DECORATION
inputTextDecorationRounded(
    Icon prefixIcon, String hintText, GestureDetector suffixIcon) {
  return InputDecoration(
    contentPadding: const EdgeInsets.all(10.0),
    hintText: hintText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    fillColor: Colors.white,
    filled: true,
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.yellow[600], width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(40))),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.orange[300], width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(40))),
    disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.orange[300], width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(40))),
    errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(40))),
    focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(40))),
  );
}

//TEXT INPUT DECORATION
inputTextDecorationRectangle(Icon prefixIcon, String hintText, String errorText,
    GestureDetector suffixIcon) {
  return InputDecoration(
    contentPadding: const EdgeInsets.all(10),
    hintText: hintText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    errorText: errorText,
    fillColor: Colors.white,
    filled: true,
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.yellow[600], width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.orange[300], width: 1.5),
    ),
    disabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.orange[300], width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 1.5),
    ),
  );
}

Widget customDialog(
    String title, String description, String image, Widget content) {
  return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 0,
    backgroundColor: Colors.transparent,
    child: Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
              left: 20, top: image != null ? 50 : 20, right: 20, bottom: 20),
          margin: EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                description,
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              content,
            ],
          ),
        ), // bottom part
        image != null
            ? Positioned(
                left: 20,
                right: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 45,
                  child: CircleAvatar(
                    backgroundColor: Colors.orange,
                    radius: 40.0,
                    backgroundImage: NetworkImage(URL_BACKEND + image),
                  ),
                ),
              )
            : SizedBox.shrink() // top part
      ],
    ),
  );
}

//RETURN TRANSLATED VALUE
String getTranslate(BuildContext context, String key) {
  return AppLocalizations.of(context).getTranslatedValue(key);
}

//APPLICATION BACKGROUND COLOR GRADIENT FOR CLIENT
BoxDecoration mainBoxDecoration = BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xfffbb448), Color(0xffe46b10)]));

//CIRCULAR PROGRESS INDICATOR
SizedBox circularProgressIndicator = SizedBox(
  height: 15.0,
  width: 15.0,
  child: CircularProgressIndicator(
    valueColor: new AlwaysStoppedAnimation<Color>(Colors.orange),
  ),
);

final kLabelStyle = TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.bold,
  fontFamily: 'OpenSans',
);

final regions = [
  "ARIANA",
  "BEJA",
  "BEN_AROUS",
  "BIZERTE",
  "GABES",
  "GAFSA",
  "JENDOUBA",
  "KAIROUAN",
  "KASSERINE",
  "KEBILI",
  "LE_KEF",
  "MAHDIA",
  "LA_MANOUBA",
  "MEDNINE",
  "MONASTIR",
  "NABEUL",
  "SFAX",
  "SIDI_BOUZID",
  "SILIANA",
  "SOUSSE",
  "TATAOUINE",
  "TOZEUR",
  "TUNIS",
  "ZAGHOUAN"
];
final providers = [
  "HEALTH",
  "BEAUTY",
  "MARKET",
  "BANKING",
  "GOUVERNMENT",
  "AUTOMOBILE",
  "TELECOMMUNICATION",
  "OTHER"
];

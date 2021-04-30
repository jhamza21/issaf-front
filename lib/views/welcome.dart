import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/language/appLanguage.dart';
import 'package:issaf/language/language.dart';
import 'package:issaf/views/shared/authentification.dart';
import 'package:provider/provider.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  int _currentIndex = 0;

  Widget showStartButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 40.0),
      child: ButtonTheme(
        minWidth: 250,
        // ignore: deprecated_member_use
        child: RaisedButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Colors.orange[300],
          child: Text(getTranslate(context, "BEGIN"),
              style: new TextStyle(fontSize: 20.0, color: Colors.black)),
          onPressed: () {
            setState(() {
              _currentIndex = 1;
            });
          },
        ),
      ),
    );
  }

  Widget showWelcomeText() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 10.0),
      child: Container(
        height: 25,
        decoration:
            new BoxDecoration(color: Colors.grey.shade200.withOpacity(0.8)),
        child: Center(
          child: Text(
            getTranslate(context, "WELCOME_MSG"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget showLogo() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/images/logo2.png'),
      ),
    );
  }

  Widget showLanguageChange() {
    var appLanguage = Provider.of<AppLanguage>(context);
    return Align(
      alignment: appLanguage.appLocale == Locale("fr")
          ? Alignment.topRight
          : Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 30, 5, 0),
        child: DropdownButton(
          onChanged: (Language lang) {
            appLanguage.changeLanguage(lang.languageCode);
          },
          icon: Icon(
            Icons.language,
            color: Colors.black,
          ),
          underline: SizedBox(),
          items: Language.languageList()
              .map<DropdownMenuItem<Language>>((lang) => DropdownMenuItem(
                    value: lang,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[Text(lang.flag), Text(lang.name)],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget welcome() {
    return Material(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/welcome.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              showLanguageChange(),
              Spacer(),
              showLogo(),
              showWelcomeText(),
              showStartButton(),
            ],
          ),
        ),
      ),
    );
  }

  void changePage(int x) {
    setState(() {
      _currentIndex = x;
    });
  }

  Widget build(BuildContext context) {
    final List<Widget> _children = [
      welcome(),
      LoginSignUp(changePage),
    ];

    return _children[_currentIndex];
  }
}

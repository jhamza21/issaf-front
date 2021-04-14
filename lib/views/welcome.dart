import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/language/appLanguage.dart';
import 'package:issaf/language/language.dart';
import 'package:issaf/views/clients/authentification.dart';
import 'package:issaf/views/providers/authentification.dart';
import 'package:provider/provider.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  int _currentIndex = 0;

  Widget showProvidersButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
      child: ButtonTheme(
        minWidth: 250,
        child: RaisedButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Colors.orange[300],
          child: Text(getTranslate(context, "FOURNISSEUR"),
              style: new TextStyle(fontSize: 20.0, color: Colors.black)),
          onPressed: () {
            changePage(2);
          },
        ),
      ),
    );
  }

  void changePage(int x) {
    setState(() {
      _currentIndex = x;
    });
  }

  Widget showClientsButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 20.0),
      child: ButtonTheme(
        minWidth: 250,
        child: RaisedButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Colors.orange[300],
          child: Text(getTranslate(context, "CLIENT"),
              style: new TextStyle(fontSize: 20.0, color: Colors.black)),
          onPressed: () {
            changePage(1);
          },
        ),
      ),
    );
  }

  Widget showWelcomeText() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 10.0),
      child: Text(
        getTranslate(context, "WELCOME_MSG"),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
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
        child: Image.asset('assets/images/logo.png'),
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
        padding: const EdgeInsets.fromLTRB(5, 15, 5, 0),
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
              showProvidersButton(),
              showClientsButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    final List<Widget> _children = [
      welcome(),
      LoginSignUp(changePage),
      LoginSignUpF(changePage)
    ];

    return _children[_currentIndex];
  }
}

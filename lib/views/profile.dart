import 'package:commons/commons.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:issaf/language/appLanguage.dart';
import 'package:issaf/language/language.dart';
import 'package:issaf/models/user.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/redux/store.dart';
import 'package:issaf/redux/users/actions.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isLoading;
  String name, mobile, password;

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  bool checkFormChanged(User user) {
    if ((mobile != null && mobile != user.mobile) ||
        (name != null && name != user.name) ||
        password != null) return true;
    return false;
  }

  Widget showMobileInput(previousMobile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: new IntlPhoneField(
        initialCountryCode: "TN",
        initialValue: previousMobile,
        keyboardType: TextInputType.number,
        decoration: inputTextDecorationMobile(getTranslate(context, 'MOBILE')),
        validator: (value) =>
            value.length < 8 ? getTranslate(context, 'INVALID_MOBILE') : null,
        onChanged: (value) => setState(() {
          mobile = value.completeNumber;
        }),
      ),
    );
  }

  Widget showNameInput(previousName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: new TextFormField(
        initialValue: previousName,
        keyboardType: TextInputType.text,
        decoration: inputTextDecorationProfile(
            Icon(Icons.person), getTranslate(context, 'FIRST_NAME')),
        validator: (value) =>
            value.isEmpty ? getTranslate(context, 'INVALID_FIRST_NAME') : null,
        onChanged: (value) => setState(() {
          name = value.trim();
        }),
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        obscureText: true,
        decoration: inputTextDecorationProfile(
            Icon(Icons.lock_outline), getTranslate(context, 'NEW_PASSWORD')),
        validator: (value) => value.isEmpty || value.length < 8
            ? getTranslate(context, 'IVALID_PASSWORD')
            : null,
        onChanged: (value) => setState(() {
          password = value.trim();
        }),
      ),
    );
  }

  Widget showTitle(text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget showLanguageChange() {
    var appLanguage = Provider.of<AppLanguage>(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.flag),
              SizedBox(
                width: 7.0,
              ),
              Text(
                getTranslate(context, "LANGUAGE"),
                style: TextStyle(fontSize: 15.0),
              ),
            ],
          ),
          DropdownButton(
            onChanged: (Language lang) {
              appLanguage.changeLanguage(lang.languageCode);
            },
            hint: appLanguage.appLocale.toString() == "fr"
                ? Text("Français")
                : Text("العربية"),
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
        ],
      ),
    );
  }

  Widget showUrlToView(text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
        child: Text(text),
      ),
    );
  }

  Widget showLogout() {
    return TextButton.icon(
        onPressed: () {
          //disconnect
          Redux.store.dispatch(logoutUserAction);
        },
        icon: Icon(Icons.exit_to_app),
        label: Text(getTranslate(context, "LOGOUT")));
  }

  Widget showSaveButton(User user) {
    return checkFormChanged(user)
        ? TextButton.icon(
            onPressed: () {
              singleInputDialog(
                context,
                title: getTranslate(context, "CONFIRMATION"),
                label: getTranslate(context, "PASSWORD"),
                validator: (value) => value.isEmpty || value.length < 8
                    ? getTranslate(context, 'IVALID_PASSWORD')
                    : null,
                neutralText: getTranslate(context, "CANCEL"),
                positiveText: getTranslate(context, "LOGIN"),
                positiveAction: (value) async {
                  //call api
                },
              );
            },
            icon: Icon(Icons.save),
            label: Text(getTranslate(context, "SAVE_CHANGES")))
        : SizedBox.shrink();
  }

  Widget showDivider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15.0, 0, 0.0),
      child: Divider(
        color: Colors.black54,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: mainBoxDecoration,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(getTranslate(context, 'PROFILE')),
          centerTitle: true,
        ),
        body: Form(
          child: SingleChildScrollView(
            child: StoreConnector<AppState, AppState>(
                converter: (store) => store.state,
                builder: (context, state) {
                  return Column(
                    children: <Widget>[
                      showTitle(getTranslate(context, "PERSONAL_INFORMATIONS")),
                      showNameInput(state.userState.user.name),
                      showMobileInput(state.userState.user.mobile),
                      showPasswordInput(),
                      showSaveButton(state.userState.user),
                      showDivider(),
                      showTitle(getTranslate(context, "USER_PREFERENCES")),
                      showLanguageChange(),
                      showDivider(),
                      showTitle(getTranslate(context, "ABOUT")),
                      showUrlToView(
                          getTranslate(context, "GENERAL_CONDITIONS")),
                      showUrlToView(getTranslate(context, "PRIVACY_POLICY")),
                      showUrlToView(getTranslate(context, "CONTACT_US")),
                      showDivider(),
                      showLogout()
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:commons/commons.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:issaf/language/appLanguage.dart';
import 'package:issaf/language/language.dart';
import 'package:issaf/models/user.dart';
import 'package:issaf/redux/users/state.dart';
import 'package:issaf/services/userService.dart';
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
  bool _isLoading = false, _showPasswordInput = false;
  String name, mobile, country, password, email, username, sexe, globalError;
  final _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  bool checkFormChanged(User user) {
    if ((mobile != null && mobile != user.mobile) ||
        (name != null && name != user.name) ||
        (username != null && username != user.username) ||
        (email != null && email != user.email) ||
        (sexe != null && sexe != user.sexe) ||
        password != null) return true;
    return false;
  }

  Widget showMobileInput(previousMobile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
      child: new IntlPhoneField(
        autoValidate: false,
        searchText: getTranslate(context, "SEARCH_BY_COUNTRY"),
        initialCountryCode: previousMobile.split('/')[0],
        initialValue: previousMobile.split('/')[2],
        keyboardType: TextInputType.phone,
        decoration: inputTextDecorationRectangle(
            Icon(
              Icons.mobile_friendly,
              color: Colors.transparent,
            ),
            getTranslate(context, 'MOBILE') + "*",
            null,
            null),
        validator: (value) =>
            value.isEmpty || value.length < 8 || value.length > 12
                ? getTranslate(context, "INVALID_MOBILE_LENGTH")
                : null,
        onChanged: (value) => setState(() {
          mobile = value.countryISOCode +
              "/" +
              value.countryCode +
              "/" +
              value.number;
        }),
      ),
    );
  }

  Widget showNameInput(previousName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
      child: new TextFormField(
        initialValue: previousName,
        keyboardType: TextInputType.text,
        decoration: inputTextDecorationRectangle(
            Icon(Icons.supervised_user_circle),
            getTranslate(context, 'NAME') + "*",
            null,
            null),
        validator: (value) =>
            value.isEmpty || value.length < 6 || value.length > 255
                ? getTranslate(context, 'INVALID_NAME_LENGTH')
                : null,
        onChanged: (value) => setState(() {
          name = value.trim();
        }),
      ),
    );
  }

  void _handleRadioButton(String value) {
    setState(() {
      sexe = value;
    });
  }

  Widget showSexeInput(String _sexe) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Radio(
              activeColor: Colors.black,
              value: "HOMME",
              groupValue: sexe != null ? sexe : _sexe,
              onChanged: _handleRadioButton),
          new Text(
            'Homme',
            style: new TextStyle(fontSize: 16.0),
          ),
          new Radio(
              activeColor: Colors.black,
              value: "FEMME",
              groupValue: sexe != null ? sexe : _sexe,
              onChanged: _handleRadioButton),
          new Text(
            'Femme',
            style: new TextStyle(
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget showUsernameInput(previousUsername) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
      child: new TextFormField(
        initialValue: previousUsername,
        keyboardType: TextInputType.text,
        decoration: inputTextDecorationRectangle(Icon(Icons.person),
            getTranslate(context, 'USERNAME') + "*", null, null),
        validator: (value) =>
            value.isEmpty || value.length < 6 || value.length > 255
                ? getTranslate(context, 'INVALID_USERNAME_LENGTH')
                : null,
        onChanged: (value) => setState(() {
          username = value.trim();
        }),
      ),
    );
  }

  Widget showEmailInput(previousEmail) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
      child: new TextFormField(
        initialValue: previousEmail,
        keyboardType: TextInputType.emailAddress,
        decoration: inputTextDecorationRectangle(Icon(Icons.email_rounded),
            getTranslate(context, 'EMAIL') + "*", null, null),
        validator: (value) => value.isEmpty || !Validator.isValidEmail(value)
            ? getTranslate(context, 'INVALID_EMAIL')
            : null,
        onChanged: (value) => setState(() {
          email = value.trim();
        }),
      ),
    );
  }

  Widget showPasswordInput() {
    return _showPasswordInput
        ? Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
            child: TextFormField(
              obscureText: true,
              decoration: inputTextDecorationRectangle(Icon(Icons.lock_outline),
                  getTranslate(context, 'NEW_PASSWORD') + "*", null, null),
              validator: (value) => value.isEmpty || value.length < 8
                  ? getTranslate(context, 'INVALID_PASSWORD_LENGTH')
                  : null,
              onChanged: (value) => setState(() {
                password = value.trim();
              }),
            ),
          )
        : SizedBox.shrink();
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
      padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 0.0),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 0.0),
      child: Row(
        children: [
          Text(text),
        ],
      ),
    );
  }

  Widget showLogout() {
    return TextButton.icon(
        onPressed: () async {
          //disconnect
          var prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', null);
          Redux.store.dispatch(
            SetUserStateAction(
              UserState(
                isLoggedIn: false,
                user: null,
              ),
            ),
          );
        },
        icon: Icon(Icons.exit_to_app),
        label: Text(getTranslate(context, "LOGOUT")));
  }

  // Check if form is valid
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) return true;
    return false;
  }

  Widget showSaveButton(User user) {
    return checkFormChanged(user)
        ? TextButton.icon(
            onPressed: () {
              if (!_isLoading && validateAndSave())
                singleInputDialog(
                  context,
                  title: getTranslate(context, "CONFIRMATION"),
                  label: getTranslate(context, "PASSWORD"),
                  keyboardType: TextInputType.text,
                  validator: (value) => value.isEmpty || value.length < 8
                      ? getTranslate(context, 'INVALID_PASSWORD_LENGTH')
                      : null,
                  neutralText: getTranslate(context, "CANCEL"),
                  positiveText: getTranslate(context, "LOGIN"),
                  positiveAction: (value) async {
                    try {
                      setState(() {
                        globalError = null;
                        _isLoading = true;
                      });
                      var prefs = await SharedPreferences.getInstance();
                      var res = await UserService().updateUser(
                          prefs.getString('token'),
                          username,
                          password,
                          name,
                          sexe,
                          "CLIENT",
                          email,
                          mobile,
                          value);
                      if (res.statusCode == 401) {
                        setState(() {
                          _isLoading = false;
                          globalError =
                              getTranslate(context, "INVALID_PASSWORD");
                        });
                      } else if (res.statusCode == 200) {
                        final snackBar = SnackBar(
                          content: Text(
                              getTranslate(context, "SUCCESS_USER_UPDATE")),
                        );
                        final jsonData = json.decode(res.body);
                        Redux.store.dispatch(SetUserStateAction(
                          UserState(
                            isLoggedIn: true,
                            user: User.fromJson(jsonData),
                          ),
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        setState(() {
                          _isLoading = false;
                        });
                      } else if (res.statusCode == 400) {
                        final jsonData =
                            json.decode(res.body) as Map<String, dynamic>;
                        setState(() {
                          _isLoading = false;
                          globalError = getTranslate(
                              context, jsonData.values.first[0].toUpperCase());
                        });
                      } else
                        setState(() {
                          _isLoading = false;
                          globalError = getTranslate(context, "ERROR_SERVER");
                        });
                    } catch (e) {
                      setState(() {
                        _isLoading = false;
                        globalError = getTranslate(context, "ERROR_SERVER");
                      });
                    }
                  },
                );
            },
            icon: _isLoading ? circularProgressIndicator : Icon(Icons.save),
            label: Text(getTranslate(context, "SAVE_CHANGES")))
        : SizedBox.shrink();
  }

  Widget showDivider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12.0, 0, 0.0),
      child: Divider(
        color: Colors.black54,
      ),
    );
  }

  Widget showError() {
    return globalError != null
        ? Padding(
            padding: const EdgeInsets.fromLTRB(0, 12.0, 0, 0.0),
            child: Text(
              globalError,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          )
        : SizedBox.shrink();
  }

  Widget showChangePassword() {
    return !_showPasswordInput
        ? Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Row(
              children: [
                TextButton(
                  child: Text(getTranslate(context, "CHANGE_PASSWORD")),
                  onPressed: () {
                    setState(() {
                      _showPasswordInput = true;
                    });
                  },
                )
              ],
            ),
          )
        : SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(getTranslate(context, 'PROFILE')),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: StoreConnector<AppState, AppState>(
              converter: (store) => store.state,
              builder: (context, state) {
                return Column(
                  children: <Widget>[
                    showTitle(getTranslate(context, "PERSONAL_INFORMATIONS")),
                    showUsernameInput(state.userState.user.username),
                    showNameInput(state.userState.user.name),
                    showEmailInput(state.userState.user.email),
                    showMobileInput(state.userState.user.mobile),
                    showSexeInput(state.userState.user.sexe),
                    showPasswordInput(),
                    showError(),
                    showChangePassword(),
                    showSaveButton(state.userState.user),
                    showDivider(),
                    showTitle(getTranslate(context, "USER_PREFERENCES")),
                    showLanguageChange(),
                    showDivider(),
                    showTitle(getTranslate(context, "ABOUT")),
                    showUrlToView(getTranslate(context, "GENERAL_CONDITIONS")),
                    showUrlToView(getTranslate(context, "PRIVACY_POLICY")),
                    showUrlToView(getTranslate(context, "CONTACT_US")),
                    showDivider(),
                    showLogout()
                  ],
                );
              }),
        ),
      ),
    );
  }
}

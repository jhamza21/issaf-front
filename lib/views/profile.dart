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
  String name, mobile, country, password, email, username, sexe, error;
  Map errors, formData;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    errors = new Map<String, String>();
    formData = new Map<String, String>();
  }

  bool checkFormChanged(User user) {
    if ((mobile != null && mobile != user.mobile) ||
        (country != null && country != user.country) ||
        (name != null && name != user.name) ||
        (username != null && username != user.username) ||
        (email != null && email != user.email) ||
        password != null) return true;
    return false;
  }

  bool validateForm(User user) {
    formData = new Map<String, String>();
    Map<String, String> _errors = new Map<String, String>();
    bool valid = true;
    //VALIDATE USERNAME
    if (username != null && username != user.username) {
      if (username.length < 6 || username.length > 255) {
        _errors["username"] = getTranslate(context, "INVALID_USERNAME_LENGTH");
        valid = false;
      } else
        formData["username"] = username;
    }
    //VALIDATE EMAIL
    if (email != null && email != user.email) {
      if (!Validator.isValidEmail(email)) {
        _errors["email"] = getTranslate(context, "INVALID_EMAIL");
        valid = false;
      } else
        formData["email"] = email;
    }
    //VALIDATE MOBILE
    if (mobile != null && mobile != user.mobile) {
      if (mobile.length < 8 || mobile.length > 14) {
        _errors["mobile"] = getTranslate(context, "INVALID_MOBILE_LENGTH");
        valid = false;
      } else {
        formData["mobile"] = mobile;
        formData["country"] = country;
      }
    }
    //VALIDATE country
    if (country != null && country != user.country) {
      formData["country"] = country;
    }
    //VALIDATE NAME
    if (name != null && name != user.name) {
      if (name.length < 8 || name.length > 80) {
        _errors["name"] = getTranslate(context, "INVALID_NAME_LENGTH");
        valid = false;
      } else
        formData["name"] = name;
    }
    //VALIDATE PASSWORD
    if (password != null && password != user.password) {
      if (password.length < 8) {
        _errors["password"] = getTranslate(context, "INVALID_PASSWORD_LENGTH");
        valid = false;
      } else
        formData["password"] = password;
    }
    setState(() {
      errors = _errors;
    });
    return valid;
  }

  Widget showMobileInput(previousMobile, countryCode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
      child: new IntlPhoneField(
        initialCountryCode: countryCode != '' ? countryCode : "TN",
        initialValue: previousMobile,
        keyboardType: TextInputType.phone,
        decoration: inputTextDecorationRectangle(
            Icon(
              Icons.mobile_friendly,
              color: Colors.transparent,
            ),
            getTranslate(context, 'MOBILE'),
            errors['mobile'],
            null),
        onChanged: (value) => setState(() {
          country = value.countryISOCode;
          mobile = value.number;
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
            getTranslate(context, 'NAME'),
            errors['name'],
            null),
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
              value: "homme",
              groupValue: sexe != null ? sexe : _sexe,
              onChanged: _handleRadioButton),
          new Text(
            'Homme',
            style: new TextStyle(fontSize: 16.0),
          ),
          new Radio(
              activeColor: Colors.black,
              value: "femme",
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
            getTranslate(context, 'USERNAME'), errors['username'], null),
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
            getTranslate(context, 'EMAIL'), errors['email'], null),
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
              decoration: inputTextDecorationRectangle(
                  Icon(Icons.lock_outline),
                  getTranslate(context, 'NEW_PASSWORD'),
                  errors['password'],
                  null),
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
              if (!_isLoading && validateForm(user))
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
                        error = null;
                        _isLoading = true;
                      });
                      var prefs = await SharedPreferences.getInstance();
                      formData["oldPassword"] = value;
                      var res = await UserService()
                          .updateUser(formData, prefs.getString('token'));
                      if (res.statusCode == 401) {
                        setState(() {
                          _isLoading = false;
                          error = getTranslate(context, "INVALID_PASSWORD");
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
                            isLoading: false,
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
                          error = getTranslate(
                              context, jsonData.values.first[0].toUpperCase());
                        });
                      } else
                        setState(() {
                          _isLoading = false;
                          error = getTranslate(context, "ERROR_SERVER");
                        });
                    } catch (e) {
                      setState(() {
                        _isLoading = false;
                        error = getTranslate(context, "ERROR_SERVER");
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
    return error != null
        ? Padding(
            padding: const EdgeInsets.fromLTRB(0, 12.0, 0, 0.0),
            child: Text(
              error,
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
                      showUsernameInput(state.userState.user.username),
                      showNameInput(state.userState.user.name),
                      showEmailInput(state.userState.user.email),
                      showMobileInput(state.userState.user.mobile,
                          state.userState.user.country),
                      showSexeInput(state.userState.user.sexe),
                      showPasswordInput(),
                      showError(),
                      showSaveButton(state.userState.user),
                      showChangePassword(),
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

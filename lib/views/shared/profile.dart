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
import 'package:issaf/constants.dart';
import 'package:issaf/redux/store.dart';
import 'package:issaf/redux/users/actions.dart';

class Profile extends StatefulWidget {
  final UserState userState;
  Profile(this.userState);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _isLoading = false, _showPasswordInput = false;
  String _name, _mobile, _password, _email, _username, _region, _error;
  final _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initializeUserData();
  }

  void initializeUserData() {
    _username = widget.userState.user.username;
    _email = widget.userState.user.email;
    _mobile = widget.userState.user.mobile;
    _region = widget.userState.user.region;
    _name = widget.userState.user.name;
  }

  bool checkFormChanged(User user) {
    if (_name != user.name ||
        _username != user.username ||
        _email != user.email ||
        _mobile != user.mobile ||
        _region != user.region ||
        _password != null) return true;
    return false;
  }

  Widget showMobileInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
      child: new IntlPhoneField(
        autoValidate: false,
        searchText: getTranslate(context, "SEARCH_BY_COUNTRY"),
        initialCountryCode: _mobile.split('/')[0],
        initialValue: _mobile.split('/')[2],
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
          _mobile = value.countryISOCode +
              "/" +
              value.countryCode +
              "/" +
              value.number;
        }),
      ),
    );
  }

  Widget showNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
      child: new TextFormField(
        initialValue: _name,
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
          _name = value.trim();
        }),
      ),
    );
  }

  // void _handleRadioButton(String value) {
  //   setState(() {
  //     _sexe = value;
  //   });
  // }

  // Widget showSexeInput(String sexe) {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: <Widget>[
  //         Row(
  //           children: [
  //             new Radio(
  //                 activeColor: Colors.black,
  //                 value: "HOMME",
  //                 groupValue: _sexe != null ? _sexe : sexe,
  //                 onChanged: _handleRadioButton),
  //             new Text(
  //               getTranslate(context, "MEN"),
  //               style: new TextStyle(fontSize: 16.0),
  //             ),
  //           ],
  //         ),
  //         Row(
  //           children: [
  //             new Radio(
  //                 activeColor: Colors.black,
  //                 value: "FEMME",
  //                 groupValue: _sexe != null ? _sexe : sexe,
  //                 onChanged: _handleRadioButton),
  //             new Text(
  //               getTranslate(context, "WOMAN"),
  //               style: new TextStyle(
  //                 fontSize: 16.0,
  //               ),
  //             ),
  //           ],
  //         )
  //       ],
  //     ),
  //   );
  // }

  Widget showUsernameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
      child: new TextFormField(
        initialValue: _username,
        keyboardType: TextInputType.text,
        decoration: inputTextDecorationRectangle(Icon(Icons.person),
            getTranslate(context, 'USERNAME') + "*", null, null),
        validator: (value) =>
            value.isEmpty || value.length < 6 || value.length > 255
                ? getTranslate(context, 'INVALID_USERNAME_LENGTH')
                : null,
        onChanged: (value) => setState(() {
          _username = value.trim();
        }),
      ),
    );
  }

  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
      child: new TextFormField(
        initialValue: _email,
        keyboardType: TextInputType.emailAddress,
        decoration: inputTextDecorationRectangle(Icon(Icons.email_rounded),
            getTranslate(context, 'EMAIL') + "*", null, null),
        validator: (value) => value.isEmpty || !Validator.isValidEmail(value)
            ? getTranslate(context, 'INVALID_EMAIL')
            : null,
        onChanged: (value) => setState(() {
          _email = value.trim();
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
                _password = value.trim();
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

  Widget showProfileChange(String _role) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.login_outlined),
              SizedBox(
                width: 7.0,
              ),
              Text(
                "Se connecter en tant que ",
                style: TextStyle(fontSize: 15.0),
              ),
            ],
          ),
          DropdownButton(
            onChanged: (String role) {
              Redux.store.dispatch(SetUserStateAction(UserState(role: role)));
            },
            hint: Text(_role),
            underline: SizedBox(),
            items: ["CLIENT", "ADMIN", "PERSONNEL"]
                .map<DropdownMenuItem<String>>((role) => DropdownMenuItem(
                      value: role,
                      child: Text(role),
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

  Widget showSaveButton() {
    return checkFormChanged(widget.userState.user)
        ? TextButton.icon(
            onPressed: () async {
              if (!_isLoading && validateAndSave())
                try {
                  setState(() {
                    _error = null;
                    _isLoading = true;
                  });
                  var prefs = await SharedPreferences.getInstance();
                  var res = await UserService().updateUser(
                      prefs.getString('token'),
                      _username == widget.userState.user.username
                          ? null
                          : _username,
                      _password,
                      _name,
                      _email == widget.userState.user.email ? null : _email,
                      _mobile,
                      _region);
                  if (res.statusCode == 200) {
                    final snackBar = SnackBar(
                      content:
                          Text(getTranslate(context, "SUCCESS_USER_UPDATE")),
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
                  } else {
                    final jsonData = json.decode(res.body);
                    setState(() {
                      _isLoading = false;
                      _error = getTranslate(
                          context, jsonData["error"].toUpperCase());
                    });
                  }
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                    _error = getTranslate(context, "ERROR_SERVER");
                  });
                }
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
    return _error != null
        ? Padding(
            padding: const EdgeInsets.fromLTRB(0, 12.0, 0, 0.0),
            child: Text(
              _error,
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

  Widget showRegionInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: DropdownButtonFormField(
        decoration: inputTextDecorationRectangle(Icon(Icons.location_on),
            getTranslate(context, 'REGION') + "*", null, null),
        validator: (value) => value == null
            ? getTranslate(context, "REQUIRED_USER_REGION")
            : null,
        isExpanded: true,
        dropdownColor: Colors.orange[50],
        value: _region,
        onChanged: (value) {
          setState(() {
            _region = value;
          });
        },
        icon: Icon(
          Icons.arrow_drop_down,
        ),
        items: regions
            .map<DropdownMenuItem<String>>((region) => DropdownMenuItem(
                  value: region,
                  child: Text(getTranslate(context, region)),
                ))
            .toList(),
      ),
    );
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
          child: Column(
            children: <Widget>[
              showTitle(getTranslate(context, "PERSONAL_INFORMATIONS")),
              showUsernameInput(),
              showNameInput(),
              showEmailInput(),
              showMobileInput(),
              showRegionInput(),
              //  showSexeInput(state.userState.user.sexe),
              showPasswordInput(),
              showError(),
              showChangePassword(),
              showSaveButton(),
              showDivider(),
              showTitle(getTranslate(context, "USER_PREFERENCES")),
              showProfileChange(widget.userState.role),
              showLanguageChange(),
              showDivider(),
              showTitle(getTranslate(context, "ABOUT")),
              showUrlToView(getTranslate(context, "GENERAL_CONDITIONS")),
              showUrlToView(getTranslate(context, "PRIVACY_POLICY")),
              showUrlToView(getTranslate(context, "CONTACT_US")),
              showDivider(),
              showLogout()
            ],
          ),
        ),
      ),
    );
  }
}

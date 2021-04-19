import 'dart:convert';

import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/errorHandler.dart';
import 'package:issaf/language/appLanguage.dart';
import 'package:issaf/language/language.dart';
import 'package:issaf/models/user.dart';
import 'package:issaf/redux/store.dart';
import 'package:issaf/redux/users/actions.dart';
import 'package:issaf/redux/users/state.dart';
import 'package:issaf/services/userService.dart';
import 'package:provider/provider.dart';

class LoginSignUp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginSignUpState();
  final void Function(int) callback;
  final bool isProvider;
  LoginSignUp(this.callback, this.isProvider);
}

class _LoginSignUpState extends State<LoginSignUp> {
  final _formKey = new GlobalKey<FormState>();
  String _username,
      _password,
      _name,
      _email,
      _sexe = "HOMME",
      _mobile,
      _role = "ADMIN_SERVICE",
      _error;
  bool _isLoginForm = true, _isLoading = false, _showPassword = false;

  // Check if form is valid
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void validateAndSubmit() async {
    if (validateAndSave()) {
      if (_isLoginForm) {
        //LOGIN
        try {
          setState(() {
            _isLoading = true;
          });
          var prefs = await SharedPreferences.getInstance();
          final response = await UserService().signIn(_username, _password);
          final jsonData = json.decode(response.body);
          if (response.statusCode == 200) {
            await prefs.setString('token', jsonData["data"]["api_token"]);
            Redux.store.dispatch(
              SetUserStateAction(
                UserState(
                  isLoggedIn: true,
                  user: User.fromJson(jsonData["data"]),
                ),
              ),
            );
          } else {
            var error = jsonData["errors"] as Map<String, dynamic>;
            setState(() {
              _isLoading = false;
              _error = errorHandler(error.values.first[0], context);
            });
          }
        } catch (error) {
          setState(() {
            _isLoading = false;
            _error = errorHandler("ERROR_SERVER", context);
          });
        }
      } else {
        //SIGN UP CLIENT
        try {
          setState(() {
            _isLoading = true;
          });
          var prefs = await SharedPreferences.getInstance();
          final response = await UserService().signUp(
              _username,
              _password,
              _name,
              _email,
              _mobile,
              _sexe,
              widget.isProvider ? _role : "CLIENT");
          final jsonData = json.decode(response.body);
          if (response.statusCode == 201) {
            await prefs.setString('token', jsonData["data"]["api_token"]);
            Redux.store.dispatch(
              SetUserStateAction(
                UserState(
                  isLoggedIn: true,
                  user: User.fromJson(jsonData["data"]),
                ),
              ),
            );
          } else {
            print(jsonData["error"]);
            var error = jsonData["errors"] as Map<String, dynamic>;
            setState(() {
              _isLoading = false;
              _error = errorHandler(error.values.first[0], context);
            });
          }
        } catch (error) {
          print(error);
          setState(() {
            _isLoading = false;
            _error = errorHandler("ERROR_SERVER", context);
          });
        }
      }
    }
  }

  void resetForm() {
    _formKey.currentState.reset();
  }

  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  Widget _showForm() {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  showLogo(),
                  !_isLoginForm && widget.isProvider
                      ? showRoleInput()
                      : SizedBox(),
                  !_isLoginForm ? showNameInput() : SizedBox(),
                  showUserNameInput(),
                  showPasswordInput(),
                  !_isLoginForm ? showPasswordConfirmationInput() : SizedBox(),
                  !_isLoginForm ? showEmailInput() : SizedBox(),
                  !_isLoginForm ? showMobileInput() : SizedBox(),
                  !_isLoginForm ? showSexeInput() : SizedBox(),
                  showErrorMessage(),
                  !_isLoginForm
                      ? showNotice(getTranslate(context, "REQUIRED_FIELD"))
                      : SizedBox(),
                  showPrimaryButton(),
                  showSecondaryButton(),
                ],
              ),
            ),
          );
        });
  }

  Widget showLogo() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 30.0),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/images/logo.png'),
      ),
    );
  }

  void _handleRadioButton(String value) {
    setState(() {
      _sexe = value;
    });
  }

  Widget showSexeInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Row(
            children: [
              new Radio(
                  activeColor: Colors.black,
                  value: "HOMME",
                  groupValue: _sexe,
                  onChanged: _handleRadioButton),
              new Text(
                getTranslate(context, "MEN"),
                style: new TextStyle(fontSize: 16.0),
              ),
            ],
          ),
          Row(
            children: [
              new Radio(
                  activeColor: Colors.black,
                  value: "FEMME",
                  groupValue: _sexe,
                  onChanged: _handleRadioButton),
              new Text(
                getTranslate(context, "WOMAN"),
                style: new TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget showUserNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        decoration: inputTextDecorationRounded(
            Icon(Icons.person), getTranslate(context, 'USERNAME') + "*", null),
        validator: (value) =>
            value.isEmpty || value.length < 6 || value.length > 255
                ? getTranslate(context, 'INVALID_USERNAME_LENGTH')
                : null,
        onSaved: (value) => _username = value.trim(),
      ),
    );
  }

  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: inputTextDecorationRounded(
            Icon(Icons.email), getTranslate(context, 'EMAIL') + "*", null),
        validator: (value) => value.isEmpty || !Validator.isValidEmail(value)
            ? getTranslate(context, 'INVALID_EMAIL')
            : null,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget showMobileInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: new IntlPhoneField(
        autoValidate: false,
        initialCountryCode: "TN",
        searchText: getTranslate(context, "SEARCH_BY_COUNTRY"),
        keyboardType: TextInputType.phone,
        decoration: inputTextDecorationRounded(
            null, getTranslate(context, 'MOBILE') + "*", null),
        validator: (value) =>
            value.isEmpty || value.length < 8 || value.length > 12
                ? getTranslate(context, "INVALID_MOBILE_LENGTH")
                : null,
        onSaved: (value) => {
          _mobile = value.countryISOCode +
              "/" +
              value.countryCode +
              "/" +
              value.number
        },
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        obscureText: !_showPassword,
        decoration: inputTextDecorationRounded(
          Icon(Icons.lock_outline),
          getTranslate(context, 'PASSWORD') + "*",
          GestureDetector(
              child: Icon(
                  !_showPassword ? Icons.visibility_off : Icons.visibility),
              onTap: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              }),
        ),
        validator: (value) => value.isEmpty || value.length < 8
            ? getTranslate(context, 'INVALID_PASSWORD_LENGTH')
            : null,
        onChanged: (value) => _password = value.trim(),
      ),
    );
  }

  Widget showNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
      child: new TextFormField(
        keyboardType: TextInputType.text,
        decoration: inputTextDecorationRounded(
            Icon(Icons.supervised_user_circle),
            getTranslate(context, 'NAME') + "*",
            null),
        validator: (value) =>
            value.isEmpty || value.length < 6 || value.length > 255
                ? getTranslate(context, 'INVALID_NAME_LENGTH')
                : null,
        onSaved: (value) => _name = value.trim(),
      ),
    );
  }

  Widget showPasswordConfirmationInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        obscureText: !_showPassword,
        decoration: inputTextDecorationRounded(
          Icon(Icons.lock_outline),
          getTranslate(context, 'PASSWORD_CONFIRMATION') + "*",
          GestureDetector(
              child: Icon(
                  !_showPassword ? Icons.visibility_off : Icons.visibility),
              onTap: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              }),
        ),
        validator: (value) => value != _password
            ? getTranslate(context, 'INVALID_PASSWORD_CONFIRMATION')
            : null,
      ),
    );
  }

  Widget showPrimaryButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
      child: ButtonTheme(
        minWidth: 250,
        // ignore: deprecated_member_use
        child: RaisedButton.icon(
          elevation: 5.0,
          icon: _isLoading ? circularProgressIndicator : SizedBox(),
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Colors.deepOrange[900],
          label: Text(
              _isLoginForm
                  ? getTranslate(context, 'LOGIN').toUpperCase()
                  : getTranslate(context, 'SIGN_UP').toUpperCase(),
              style: new TextStyle(fontSize: 20.0, color: Colors.orange[100])),
          onPressed: () {
            validateAndSubmit();
          },
        ),
      ),
    );
  }

  Widget showSecondaryButton() {
    // ignore: deprecated_member_use
    return new FlatButton(
        child: new Text(
            _isLoginForm
                ? getTranslate(context, 'CREATE_AN_ACCOUNT')
                : getTranslate(context, 'HAVE_ACCOUNT'),
            style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
        onPressed: toggleFormMode);
  }

  Widget showErrorMessage() {
    if (_error != null)
      return Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
        child: Text(
          _error,
          style: TextStyle(
              fontSize: 15.0, color: Colors.red, fontWeight: FontWeight.w400),
        ),
      );
    else
      return SizedBox.shrink();
  }

  Widget showNotice(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
                fontSize: 12.0,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget showLanguageChange() {
    var appLanguage = Provider.of<AppLanguage>(context);
    return DropdownButton(
      onChanged: (Language lang) {
        appLanguage.changeLanguage(lang.languageCode);
      },
      icon: Icon(
        Icons.language,
        color: Colors.black45,
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
    );
  }

  Widget showRoleInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 0.0),
      child: Row(
        children: [
          Text(
            getTranslate(context, "REGISTER_AS") + " : ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          DropdownButton(
            dropdownColor: Colors.orange[50],
            hint: Text(getTranslate(context, _role)),
            onChanged: (String value) {
              setState(() {
                _role = value;
              });
            },
            icon: Icon(
              Icons.arrow_downward,
            ),
            underline: SizedBox(),
            items: ["ADMIN_SERVICE", "ADMIN_SAFF"]
                .map<DropdownMenuItem<String>>((role) => DropdownMenuItem(
                      value: role,
                      child: Text(getTranslate(context, role)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration:
          !widget.isProvider ? mainBoxDecoration : mainBoxDecorationProvider,
      child: new Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
              onPressed: () {
                widget.callback(0);
              },
              icon: Icon(Icons.arrow_back)),
          actions: [
            showLanguageChange(),
          ],
        ),
        backgroundColor: Colors.transparent,
        body: _showForm(),
      ),
    );
  }
}

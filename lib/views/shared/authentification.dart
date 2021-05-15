import 'dart:convert';

import 'package:commons/commons.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  LoginSignUp(this.callback);
}

class _LoginSignUpState extends State<LoginSignUp> {
  final _formKey = new GlobalKey<FormState>();
  String _username, _password, _name, _email, _mobile, _region, _error;
  bool _isLoginForm = true, _isLoading = false, _buildPassword = false;

  // Check if form is valid
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  //sign in user
  void signIn() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var prefs = await SharedPreferences.getInstance();
      final response = await UserService().signIn(_username, _password);
      final jsonData = json.decode(response.body);
      if (response.statusCode == 200) {
        await prefs.setString('token', jsonData["data"]["api_token"]);
        try {
          String _messagingToken = await FirebaseMessaging.instance.getToken();
          await UserService().updateUser(prefs.getString('token'), null, null,
              null, null, null, null, _messagingToken);
        } catch (e) {
          print(e);
        }
        Redux.store.dispatch(
          SetUserStateAction(
            UserState(
                isLoggedIn: true,
                user: User.fromJson(jsonData["data"]),
                role: prefs.getString("role") != null
                    ? prefs.getString("role")
                    : "CLIENT"),
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
  }

//sign up user
  void signUp() async {
    try {
      setState(() {
        _isLoading = true;
      });
      String _messagingToken = await FirebaseMessaging.instance.getToken();
      var prefs = await SharedPreferences.getInstance();
      final response = await UserService().signUp(_username, _password, _name,
          _email, _mobile, _region, _messagingToken);
      final jsonData = json.decode(response.body);
      if (response.statusCode == 201) {
        await prefs.setString('token', jsonData["data"]["api_token"]);
        Redux.store.dispatch(
          SetUserStateAction(
            UserState(
                isLoggedIn: true,
                user: User.fromJson(jsonData["data"]),
                role: "CLIENT"),
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
  }

  // login or signup if form is valid
  void validateAndSubmit() async {
    if (validateAndSave()) {
      if (_isLoginForm)
        signIn();
      else
        signUp();
    }
  }

//reset all form fields
  void resetForm() {
    _formKey.currentState.reset();
  }

//toggle between signIn and signUp form
  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

//build sign in with google button
  Widget buildSocialBtn() {
    return Column(
      children: <Widget>[
        SizedBox(height: 20.0),
        Text(
          getTranslate(context, "OR"),
          style: TextStyle(
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 20.0),
        Text(
          getTranslate(context, "SIGN_IN_WITH"),
          style: TextStyle(
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 20.0),
        GestureDetector(
          onTap: () => signInWithGoogle(),
          child: Container(
            height: 60.0,
            width: 60.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 6.0,
                ),
              ],
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/google.jpg',
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  void signInWithGoogle() async {
    try {
      final _googleSignIn = GoogleSignIn();
      final user = await _googleSignIn.signIn();
      var res = await UserService().getUserByEmail(user.email);
      if (res.statusCode == 404) {
        toggleFormMode();
        setState(() {
          _name = user.displayName;
          _email = user.email;
        });
        return;
      }
      assert(res.statusCode == 200);
      try {
        var prefs = await SharedPreferences.getInstance();
        String _messagingToken = await FirebaseMessaging.instance.getToken();
        await UserService().updateUser(prefs.getString('token'), null, null,
            null, null, null, null, _messagingToken);
      } catch (e) {
        print(e);
      }
      var prefs = await SharedPreferences.getInstance();
      final jsonData = json.decode(res.body);
      await prefs.setString('token', jsonData["api_token"]);
      Redux.store.dispatch(
        SetUserStateAction(
          UserState(
              isLoggedIn: true,
              user: User.fromJson(jsonData),
              role: prefs.getString("role") != null
                  ? prefs.getString("role")
                  : "CLIENT"),
        ),
      );
    } catch (e) {
      final snackBar = SnackBar(
        content: Text(getTranslate(context, "ERROR_SERVER")),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Widget buildSwitchFormBtn() {
    return GestureDetector(
      onTap: () => toggleFormMode(),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: _isLoginForm
                  ? getTranslate(context, "DONT_HAVE_ACCOUNT")
                  : getTranslate(context, "HAVE_ACCOUNT"),
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: _isLoginForm
                  ? getTranslate(context, "SIGN_UP")
                  : getTranslate(context, "LOGIN"),
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  buildLogo(),
                  !_isLoginForm ? buildNameInput() : SizedBox(),
                  buildUserNameInput(),
                  buildPasswordInput(),
                  !_isLoginForm ? buildPasswordConfirmationInput() : SizedBox(),
                  !_isLoginForm ? buildEmailInput() : SizedBox(),
                  !_isLoginForm ? buildMobileInput() : SizedBox(),
                  !_isLoginForm ? buildRegionInput() : SizedBox(),
                  buildErrorMessage(),
                  !_isLoginForm
                      ? buildNotice(getTranslate(context, "REQUIRED_FIELD"))
                      : SizedBox(),
                  buildSignInBtn(),
                  _isLoginForm ? buildSocialBtn() : SizedBox.shrink(),
                  SizedBox(height: 20.0),
                  buildSwitchFormBtn(),
                ],
              ),
            ),
          );
        });
  }

  Widget buildLogo() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 30.0),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/images/logo.png'),
      ),
    );
  }

  // void _handleRadioButton(String value) {
  //   setState(() {
  //     _sexe = value;
  //   });
  // }

  // Widget buildSexeInput() {
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
  //                 groupValue: _sexe,
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
  //                 groupValue: _sexe,
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

  Widget buildUserNameInput() {
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

  Widget buildEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        initialValue: _email,
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

  Widget buildMobileInput() {
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

  Widget buildPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        obscureText: !_buildPassword,
        decoration: inputTextDecorationRounded(
          Icon(Icons.lock_outline),
          getTranslate(context, 'PASSWORD') + "*",
          GestureDetector(
              child: Icon(
                  !_buildPassword ? Icons.visibility_off : Icons.visibility),
              onTap: () {
                setState(() {
                  _buildPassword = !_buildPassword;
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

  Widget buildNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: new TextFormField(
        initialValue: _name,
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

  Widget buildPasswordConfirmationInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        obscureText: !_buildPassword,
        decoration: inputTextDecorationRounded(
          Icon(Icons.lock_outline),
          getTranslate(context, 'PASSWORD_CONFIRMATION') + "*",
          GestureDetector(
              child: Icon(
                  !_buildPassword ? Icons.visibility_off : Icons.visibility),
              onTap: () {
                setState(() {
                  _buildPassword = !_buildPassword;
                });
              }),
        ),
        validator: (value) => value != _password
            ? getTranslate(context, 'INVALID_PASSWORD_CONFIRMATION')
            : null,
      ),
    );
  }

  Widget buildSignInBtn() {
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
          onPressed: _isLoading ? null : () => validateAndSubmit(),
        ),
      ),
    );
  }

  Widget buildErrorMessage() {
    if (_error != null)
      return Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
        child: Text(
          _error,
          style: TextStyle(
              fontSize: 14.0,
              color: Colors.red[600],
              fontWeight: FontWeight.w400),
        ),
      );
    else
      return SizedBox.shrink();
  }

  Widget buildNotice(String text) {
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

  Widget buildLanguageChange() {
    var appLanguage = Provider.of<AppLanguage>(context);
    return DropdownButton(
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
    );
  }

  Widget buildRegionInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: DropdownButtonFormField(
        decoration: inputTextDecorationRounded(Icon(Icons.location_on),
            getTranslate(context, 'REGION') + "*", null),
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
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: mainBoxDecoration,
      child: new Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
              onPressed: () {
                widget.callback(0);
              },
              icon: Icon(Icons.navigate_before)),
          actions: [
            buildLanguageChange(),
          ],
        ),
        backgroundColor: Colors.transparent,
        body: _buildForm(),
      ),
    );
  }
}

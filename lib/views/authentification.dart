import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/language/appLanguage.dart';
import 'package:issaf/language/language.dart';
import 'package:issaf/redux/store.dart';
import 'package:issaf/redux/users/actions.dart';
import 'package:provider/provider.dart';

class LoginSignUp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginSignUpState();
}

class _LoginSignUpState extends State<LoginSignUp> {
  final formKey = new GlobalKey<FormState>();
  String userName;
  String password;
  bool showPassword;
  bool isLoginForm;

  @override
  void initState() {
    super.initState();
    isLoginForm = true;
    showPassword = false;
  }

  // Check if form is valid
  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void validateAndSubmit() async {
    if (validateAndSave()) {
      if (isLoginForm) {
        //LOGIN
        Redux.store.dispatch(
            signInUserAction(Redux.store, userName, password, context));
      } else {
        // //SIGN UP
        Redux.store.dispatch(
            signUpUserAction(Redux.store, userName, password, context));
      }
    }
  }

  void resetForm() {
    formKey.currentState.reset();
  }

  void toggleFormMode() {
    resetForm();
    setState(() {
      isLoginForm = !isLoginForm;
    });
  }

  Widget _showForm() {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            showLogo(),
            showUserNameInput(),
            showPasswordInput(),
            !isLoginForm ? showPasswordConfirmationInput() : SizedBox(),
            showErrorMessage(),
            showPrimaryButton(),
            showSecondaryButton(),
          ],
        ),
      ),
    );
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

  Widget showUserNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: inputTextDecoration(
            Icon(Icons.person), getTranslate(context, 'USERNAME'), null),
        validator: (value) =>
            value.isEmpty ? getTranslate(context, 'INVALID_USERNAME') : null,
        onSaved: (value) => userName = value.trim(),
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        obscureText: !showPassword,
        decoration: inputTextDecoration(
          Icon(Icons.lock_outline),
          getTranslate(context, 'PASSWORD'),
          GestureDetector(
              child:
                  Icon(!showPassword ? Icons.visibility_off : Icons.visibility),
              onTap: () {
                setState(() {
                  showPassword = !showPassword;
                });
              }),
        ),
        validator: (value) => value.isEmpty || value.length < 8
            ? getTranslate(context, 'IVALID_PASSWORD')
            : null,
        onChanged: (value) => password = value.trim(),
      ),
    );
  }

  Widget showPasswordConfirmationInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        obscureText: !showPassword,
        decoration: inputTextDecoration(
          Icon(Icons.lock_outline),
          getTranslate(context, 'PASSWORD_CONFIRMATION'),
          GestureDetector(
              child:
                  Icon(!showPassword ? Icons.visibility_off : Icons.visibility),
              onTap: () {
                setState(() {
                  showPassword = !showPassword;
                });
              }),
        ),
        validator: (value) => value != password
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
        child: StoreConnector<AppState, bool>(
            converter: (store) => store.state.userState.isLoading,
            builder: (context, isLoading) {
              return RaisedButton.icon(
                elevation: 5.0,
                icon: isLoading ? circularProgressIndicator : SizedBox(),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Colors.deepOrange[900],
                label: Text(
                    isLoginForm
                        ? getTranslate(context, 'LOGIN').toUpperCase()
                        : getTranslate(context, 'SIGN_UP').toUpperCase(),
                    style: new TextStyle(
                        fontSize: 20.0, color: Colors.orange[100])),
                onPressed: () {
                  validateAndSubmit();
                },
              );
            }),
      ),
    );
  }

  Widget showSecondaryButton() {
    return new FlatButton(
        child: new Text(
            isLoginForm
                ? getTranslate(context, 'CREATE_AN_ACCOUNT')
                : getTranslate(context, 'HAVE_ACCOUNT'),
            style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
        onPressed: toggleFormMode);
  }

  Widget showErrorMessage() {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          if (state.userState.isError)
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                state.userState.errorText,
                style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.red,
                    fontWeight: FontWeight.w400),
              ),
            );
          else
            return SizedBox.shrink();
        });
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: mainBoxDecoration,
      child: new Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
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

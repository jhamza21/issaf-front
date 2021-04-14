import 'dart:io';
import 'dart:ui';

import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/language/appLanguage.dart';
import 'package:issaf/language/language.dart';
import 'package:issaf/redux/store.dart';
import 'package:issaf/redux/users/actions.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class LoginSignUpF extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginSignUpFState();
  final void Function(int) callback;
  LoginSignUpF(this.callback);
}

class _LoginSignUpFState extends State<LoginSignUpF> {
  final _formKey = new GlobalKey<FormState>();
  PageController pageController = PageController();
  String _username,
      _name,
      _password,
      _title,
      _description,
      _mobileF,
      _mobileU,
      _emailF,
      _emailU,
      _sexe = "HOMME",
      _role = "ADMIN_SERVICE",
      _siteWeb;
  bool _showPassword, _isLoginForm;
  File _image;

  @override
  void initState() {
    super.initState();
    _isLoginForm = true;
    _showPassword = false;
  }

  // Check if form is valid
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) return true;
    return false;
  }

  // Perform login or signup
  void validateAndSubmit() async {
    if (validateAndSave()) {
      if (_isLoginForm) {
        //LOGIN
        Redux.store.dispatch(
            signInUserAction(Redux.store, _username, _password, context));
      } else {
        // //SIGN UP
        if (_role == "ADMIN_SAFF")
          Redux.store.dispatch(signUpUserAction(
              Redux.store,
              _username,
              _password,
              _name,
              _emailU,
              _mobileU,
              _sexe,
              "ADMIN_SAFF",
              context));
        else
          Redux.store.dispatch(signUpProviderAction(
              Redux.store,
              _username,
              _password,
              _name,
              _emailU,
              _mobileU,
              _sexe,
              "ADMIN_SERVICE",
              _title,
              _description,
              _mobileF,
              _emailF,
              "address ...",
              _siteWeb,
              _image,
              context));
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
                  !_isLoginForm ? showRoleInput() : SizedBox(),
                  !_isLoginForm
                      ? _showSectionTitle(getTranslate(context, "USER_INFO"))
                      : SizedBox(),
                  showUserNameInput(),
                  !_isLoginForm ? showNameInput() : SizedBox(),
                  !_isLoginForm ? showEmailInput(true) : SizedBox(),
                  !_isLoginForm ? showMobileInput(true) : SizedBox(),
                  showPasswordInput(),
                  !_isLoginForm ? showPasswordConfirmationInput() : SizedBox(),
                  !_isLoginForm ? showSexeInput() : SizedBox(),
                  !_isLoginForm && _role == "ADMIN_SERVICE"
                      ? _showSectionTitle(getTranslate(context, "SERVICE_INFO"))
                      : SizedBox(),
                  !_isLoginForm && _role == "ADMIN_SERVICE"
                      ? showImageInput()
                      : SizedBox(),
                  !_isLoginForm && _role == "ADMIN_SERVICE"
                      ? showTitleInput()
                      : SizedBox(),
                  !_isLoginForm && _role == "ADMIN_SERVICE"
                      ? showDescriptionInput()
                      : SizedBox(),
                  !_isLoginForm && _role == "ADMIN_SERVICE"
                      ? showEmailInput(false)
                      : SizedBox(),
                  !_isLoginForm && _role == "ADMIN_SERVICE"
                      ? showMobileInput(false)
                      : SizedBox(),
                  !_isLoginForm && _role == "ADMIN_SERVICE"
                      ? showSiteWebInput()
                      : SizedBox(),
                  showErrorMessage(state.userState),
                  !_isLoginForm
                      ? showNotice(getTranslate(context, "REQUIRED_FIELD"))
                      : SizedBox(),
                  showPrimaryButton(state.userState),
                  showSecondaryButton(),
                ],
              ),
            ),
          );
        });
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

  Widget _showSectionTitle(String title) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
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
        keyboardType: TextInputType.text,
        decoration: inputTextDecorationRectangle(
            _isLoginForm ? Icon(Icons.person) : null,
            getTranslate(context, 'USERNAME') + "*",
            null,
            null),
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

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        obscureText: !_showPassword,
        decoration: inputTextDecorationRectangle(
          _isLoginForm ? Icon(Icons.lock_outline) : null,
          getTranslate(context, 'PASSWORD') + "*",
          null,
          GestureDetector(
              child: Icon(
                  !_showPassword ? Icons.visibility_off : Icons.visibility),
              onTap: () => setState(() {
                    _showPassword = !_showPassword;
                  })),
        ),
        validator: (value) => value.isEmpty || value.length < 8
            ? getTranslate(context, 'INVALID_PASSWORD_LENGTH')
            : null,
        onChanged: (value) => _password = value.trim(),
      ),
    );
  }

  Widget showPasswordConfirmationInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        obscureText: !_showPassword,
        decoration: inputTextDecorationRectangle(
          null,
          getTranslate(context, 'PASSWORD_CONFIRMATION') + "*",
          null,
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

  Widget showPrimaryButton(userState) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
      child: ButtonTheme(
        minWidth: 250,
        child: RaisedButton.icon(
          elevation: 5.0,
          icon: userState.isLoading ? circularProgressIndicator : SizedBox(),
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
    return new FlatButton(
        child: new Text(
            _isLoginForm
                ? getTranslate(context, 'CREATE_AN_ACCOUNT')
                : getTranslate(context, 'HAVE_ACCOUNT'),
            style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
        onPressed: toggleFormMode);
  }

  Widget showErrorMessage(userState) {
    if (userState.isError)
      return Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
        child: Text(
          userState.errorText,
          style: TextStyle(
              fontSize: 15.0, color: Colors.red, fontWeight: FontWeight.w400),
        ),
      );
    else
      return SizedBox.shrink();
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

  Widget showTitleInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        decoration: inputTextDecorationRectangle(
            null, getTranslate(context, 'TITLE') + "*", null, null),
        validator: (value) =>
            value.isEmpty || value.length < 2 || value.length > 255
                ? getTranslate(context, 'INVALID_TITLE_LENGTH')
                : null,
        onChanged: (value) => setState(() {
          _title = value.trim();
        }),
      ),
    );
  }

  Widget showMobileInput(bool _isUserField) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: IntlPhoneField(
        autoValidate: false,
        initialCountryCode: "TN",
        searchText: getTranslate(context, "SEARCH_BY_COUNTRY"),
        keyboardType: TextInputType.phone,
        decoration: inputTextDecorationRectangle(
            null, getTranslate(context, 'MOBILE') + "*", null, null),
        validator: (value) =>
            value.isEmpty || value.length < 8 || value.length > 12
                ? getTranslate(context, "INVALID_MOBILE_LENGTH")
                : null,
        onChanged: (value) => setState(() {
          if (_isUserField)
            _mobileU = value.countryISOCode +
                "/" +
                value.countryCode +
                "/" +
                value.number;
          else
            _mobileF = value.countryISOCode +
                "/" +
                value.countryCode +
                "/" +
                value.number;
        }),
      ),
    );
  }

  Widget showEmailInput(bool _isUserField) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: inputTextDecorationRectangle(
            null, getTranslate(context, 'EMAIL') + "*", null, null),
        validator: (value) => value.isEmpty || !Validator.isValidEmail(value)
            ? getTranslate(context, 'INVALID_EMAIL')
            : null,
        onChanged: (value) => setState(() {
          if (_isUserField)
            _emailU = value.trim();
          else
            _emailF = value.trim();
        }),
      ),
    );
  }

  Widget showNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: inputTextDecorationRectangle(
            null, getTranslate(context, 'NAME') + "*", null, null),
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

  void _handleRadioButton(String value) {
    setState(() {
      _sexe = value;
    });
  }

  Widget showSexeInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Radio(
              activeColor: Colors.black,
              value: "HOMME",
              groupValue: _sexe,
              onChanged: _handleRadioButton),
          new Text(
            'Homme',
            style: new TextStyle(fontSize: 16.0),
          ),
          new Radio(
              activeColor: Colors.black,
              value: "FEMME",
              groupValue: _sexe,
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

  Widget showSiteWebInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: inputTextDecorationRectangle(
            null, getTranslate(context, 'SITE_WEB') + "*", null, null),
        validator: (value) => value.isEmpty || Uri.parse(value).isAbsolute
            ? getTranslate(context, 'INVALID_SITE_WEB')
            : null,
        onChanged: (value) => setState(() {
          _siteWeb = value.trim();
        }),
      ),
    );
  }

  Widget showDescriptionInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        maxLines: 4,
        keyboardType: TextInputType.text,
        decoration: inputTextDecorationRectangle(
            null, getTranslate(context, 'DESCRIPTION') + "*", null, null),
        validator: (value) =>
            value.isEmpty || value.length < 8 || value.length > 255
                ? getTranslate(context, 'INVALID_DESCRIPTION_LENGTH')
                : null,
        onChanged: (value) => setState(() {
          _description = value.trim();
        }),
      ),
    );
  }

  Future getImageFromGallery() async {
    var img = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      if (img != null) _image = File(img.path);
    });
  }

  Widget showImageInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            child: _image == null
                ? Text(getTranslate(context, 'INSERT_IMAGE') + "*")
                : SizedBox.shrink(),
            backgroundColor: Colors.orange[200],
            radius: 80,
            backgroundImage: _image != null ? FileImage(_image) : null,
          ),
          IconButton(
            icon: Icon(Icons.camera_alt, color: Colors.grey[600]),
            onPressed: () {
              getImageFromGallery();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
      backgroundColor: Colors.white,
      body: _showForm(),
    );
  }
}

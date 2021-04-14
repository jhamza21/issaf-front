import 'dart:convert';
import 'dart:io';

import 'package:commons/commons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:issaf/language/appLanguage.dart';
import 'package:issaf/language/language.dart';
import 'package:issaf/models/provider.dart';
import 'package:issaf/models/user.dart';
import 'package:issaf/redux/users/state.dart';
import 'package:issaf/services/provideService.dart';
import 'package:issaf/services/userService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/redux/store.dart';
import 'package:issaf/redux/users/actions.dart';
import 'package:provider/provider.dart' as Prov;

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _isLoadingUser = false,
      _isLoadingProvider = false,
      _showPasswordInput = false;
  Provider _provider;
  String _name,
      _mobileU,
      _password,
      _emailU,
      _username,
      _sexe,
      _userError,
      _title,
      _description,
      _emailF,
      _mobileF,
      _siteWeb,
      _providerError;
  File _image;
  final _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _isLoadingUser = false;
    _fetchProvider();
  }

  void _fetchProvider() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      final response =
          await ProviderService().fetchProvider(prefs.getString('token'));
      assert(response.statusCode == 200);
      final jsonData = json.decode(response.body);
      setState(() {
        _provider = Provider.fromJson(jsonData);
        _isLoadingProvider = false;
      });
    } catch (error) {
      setState(() {
        _isLoadingProvider = false;
      });
    }
  }

  bool checkUserChanged(User user) {
    if ((_mobileU != null && _mobileU != user.mobile) ||
        (_name != null && _name != user.name) ||
        (_username != null && _username != user.username) ||
        (_emailU != null && _emailU != user.email) ||
        (_sexe != null && _sexe != user.sexe) ||
        _password != null) return true;
    return false;
  }

  bool checkProviderChanged(Provider provider) {
    if ((_mobileF != null && _mobileF != provider.mobile) ||
        (_title != null && _title != provider.title) ||
        (_description != null && _description != provider.description) ||
        (_emailF != null && _emailF != provider.email) ||
        (_image != null) ||
        (_siteWeb != null && _siteWeb != provider.url)) return true;
    return false;
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

  Widget showSexeInput(String sexe) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Radio(
              activeColor: Colors.black,
              value: "HOMME",
              groupValue: _sexe != null ? _sexe : sexe,
              onChanged: _handleRadioButton),
          new Text(
            'Homme',
            style: new TextStyle(fontSize: 16.0),
          ),
          new Radio(
              activeColor: Colors.black,
              value: "FEMME",
              groupValue: _sexe != null ? _sexe : sexe,
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
          _username = value.trim();
        }),
      ),
    );
  }

  Widget showMobileInput(bool _isUserField, String previousMobile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: IntlPhoneField(
        autoValidate: false,
        initialCountryCode: previousMobile.split('/')[0],
        initialValue: previousMobile.split('/')[2],
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

  Widget showEmailInput(bool _isUserField, String previousEmail) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        initialValue: previousEmail,
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
    var appLanguage = Prov.Provider.of<AppLanguage>(context);
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

  // Check if form is valid
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) return true;
    return false;
  }

  Widget showSaveUser(User user) {
    return checkUserChanged(user)
        ? TextButton.icon(
            onPressed: () {
              if (!_isLoadingUser && validateAndSave())
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
                        _userError = null;
                        _isLoadingUser = true;
                      });
                      var prefs = await SharedPreferences.getInstance();
                      var res = await UserService().updateUser(
                          prefs.getString('token'),
                          _username,
                          _password,
                          _name,
                          _sexe,
                          "CLIENT",
                          _emailU,
                          _mobileU,
                          value);
                      if (res.statusCode == 401) {
                        setState(() {
                          _isLoadingUser = false;
                          _userError =
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
                            isLoading: false,
                            user: User.fromJson(jsonData),
                          ),
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        setState(() {
                          _isLoadingUser = false;
                        });
                      } else if (res.statusCode == 400) {
                        final jsonData =
                            json.decode(res.body) as Map<String, dynamic>;
                        setState(() {
                          _isLoadingUser = false;
                          _userError = getTranslate(
                              context, jsonData.values.first[0].toUpperCase());
                        });
                      } else
                        setState(() {
                          _isLoadingUser = false;
                          _userError = getTranslate(context, "ERROR_SERVER");
                        });
                    } catch (e) {
                      setState(() {
                        _isLoadingUser = false;
                        _userError = getTranslate(context, "ERROR_SERVER");
                      });
                    }
                  },
                );
            },
            icon: _isLoadingUser ? circularProgressIndicator : Icon(Icons.save),
            label: Text(getTranslate(context, "SAVE_CHANGES")))
        : SizedBox.shrink();
  }

  Widget showSaveProvider(Provider provider) {
    return checkProviderChanged(provider)
        ? TextButton.icon(
            onPressed: () {
              if (!_isLoadingProvider && validateAndSave())
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
                        _providerError = null;
                        _isLoadingProvider = true;
                      });
                      var prefs = await SharedPreferences.getInstance();
                      var res = await ProviderService().updateProvider(
                          prefs.getString('token'),
                          provider.id,
                          _title,
                          _description,
                          ".........",
                          _emailF,
                          _mobileF,
                          _siteWeb,
                          _image,
                          value);
                      if (res.statusCode == 401) {
                        setState(() {
                          _isLoadingProvider = false;
                          _providerError =
                              getTranslate(context, "INVALID_PASSWORD");
                        });
                      } else if (res.statusCode == 200) {
                        _title = null;
                        _description = null;
                        _image = null;
                        _emailF = null;
                        _mobileF = null;
                        _siteWeb = null;
                        _fetchProvider();
                        final snackBar = SnackBar(
                          content: Text(
                              getTranslate(context, "SUCCESS_USER_UPDATE")),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        setState(() {
                          _isLoadingProvider = false;
                        });
                      } else
                        setState(() {
                          _isLoadingProvider = false;
                          _providerError =
                              getTranslate(context, "ERROR_SERVER");
                        });
                    } catch (e) {
                      setState(() {
                        _isLoadingProvider = false;
                        _providerError = getTranslate(context, "ERROR_SERVER");
                      });
                    }
                  },
                );
            },
            icon: _isLoadingUser ? circularProgressIndicator : Icon(Icons.save),
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

  Widget showError(bool _isUserField) {
    if (_isUserField)
      return _userError != null
          ? Padding(
              padding: const EdgeInsets.fromLTRB(0, 12.0, 0, 0.0),
              child: Text(
                _userError,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            )
          : SizedBox.shrink();
    else
      return _providerError != null
          ? Padding(
              padding: const EdgeInsets.fromLTRB(0, 12.0, 0, 0.0),
              child: Text(
                _providerError,
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

  Widget showDescriptionInput(String previousDescription) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        initialValue: previousDescription,
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

  Widget showImageInput(String previousImage) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
              backgroundColor: Colors.orange[200],
              radius: 80,
              backgroundImage: _image != null
                  ? FileImage(_image)
                  : NetworkImage(
                      "http://10.0.2.2:8000/api/providerImg/" + previousImage)),
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

  Widget showSiteWebInput(String previousSite) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        initialValue: previousSite,
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

  Widget showTitleInput(String previousTitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        initialValue: previousTitle,
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
                      showEmailInput(true, state.userState.user.email),
                      showMobileInput(true, state.userState.user.mobile),
                      showSexeInput(state.userState.user.sexe),
                      showPasswordInput(),
                      showError(true),
                      showChangePassword(),
                      showSaveUser(state.userState.user),
                      showDivider(),
                      showTitle("Service informations"),
                      if (_provider != null) showImageInput(_provider.image),
                      if (_provider != null) showTitleInput(_provider.title),
                      if (_provider != null)
                        showDescriptionInput(_provider.description),
                      if (_provider != null)
                        showEmailInput(false, _provider.email),
                      if (_provider != null)
                        showMobileInput(false, _provider.mobile),
                      if (_provider != null) showSiteWebInput(_provider.url),
                      if (_provider != null) showError(false),
                      if (_provider == null)
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: circularProgressIndicator,
                        ),
                      if (_provider != null) showSaveProvider(_provider),
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

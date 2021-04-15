import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';

import 'package:commons/commons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:issaf/models/provider.dart' as ModelProvider;
import 'package:issaf/services/provideService.dart';
import 'package:flutter/services.dart';
import 'package:issaf/constants.dart';

class AddUpdateProvider extends StatefulWidget {
  final ModelProvider.Provider provider;
  final void Function(ModelProvider.Provider) callback;
  AddUpdateProvider(this.provider, this.callback);
  @override
  _AddUpdateProviderState createState() => _AddUpdateProviderState();
}

class _AddUpdateProviderState extends State<AddUpdateProvider> {
  bool _isLoading = false;
  String _title, _description, _email, _mobile, _siteWeb, _error;
  File _image;
  final _formKey = new GlobalKey<FormState>();

  bool checkProviderChanged(ModelProvider.Provider provider) {
    if (provider == null) return true;
    if ((_mobile != null && _mobile != provider.mobile) ||
        (_title != null && _title != provider.title) ||
        (_description != null && _description != provider.description) ||
        (_email != null && _email != provider.email) ||
        (_image != null) ||
        (_siteWeb != null && _siteWeb != provider.url)) return true;
    return false;
  }

  Widget showMobileInput(String previousMobile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: IntlPhoneField(
        autoValidate: false,
        initialCountryCode:
            previousMobile != null ? previousMobile.split('/')[0] : "TN",
        initialValue:
            previousMobile != null ? previousMobile.split('/')[2] : null,
        searchText: getTranslate(context, "SEARCH_BY_COUNTRY"),
        keyboardType: TextInputType.phone,
        decoration: inputTextDecorationRectangle(
            null, getTranslate(context, 'MOBILE') + "*", null, null),
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

  Widget showEmailInput(String previousEmail) {
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
          _email = value.trim();
        }),
      ),
    );
  }

  bool validateImage() {
    if (_image != null ||
        (widget.provider != null && widget.provider.image != null)) return true;

    return false;
  }

  // Check if form is valid
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate() && validateImage()) return true;
    return false;
  }

  Widget showSaveProvider(ModelProvider.Provider provider) {
    return checkProviderChanged(provider)
        ? TextButton.icon(
            onPressed: () async {
              if (!_isLoading && validateAndSave())
                try {
                  setState(() {
                    _error = null;
                    _isLoading = true;
                  });
                  var prefs = await SharedPreferences.getInstance();
                  var res = widget.provider == null
                      ? await ProviderService().addProvider(
                          prefs.getString('token'),
                          _title,
                          _description,
                          "........",
                          _email,
                          _mobile,
                          _siteWeb,
                          _image)
                      : await ProviderService().updateProvider(
                          prefs.getString('token'),
                          provider.id,
                          _title,
                          _description,
                          ".........",
                          _email,
                          _mobile,
                          _siteWeb,
                          _image);

                  if (res.statusCode == 200) {
                    ModelProvider.Provider _resProvider =
                        ModelProvider.Provider.fromJson(
                            json.decode(await res.stream.bytesToString()));
                    widget.callback(_resProvider);
                    setState(() {
                      _isLoading = false;
                    });
                    final snackBar = SnackBar(
                      content: Text(getTranslate(context, "SUCCESS_UPDATE")),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    //TODO:HANDLE ERROR
                    final jsonData =
                        json.decode(await res.stream.bytesToString())
                            as Map<String, dynamic>;
                    setState(() {
                      _isLoading = false;
                      _error = getTranslate(
                          context, jsonData.values.first[0].toUpperCase());
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
              child: previousImage == null && _image == null
                  ? Text(getTranslate(context, "INSERT_IMAGE") + "*")
                  : SizedBox.shrink(),
              backgroundColor: Colors.orange[200],
              radius: 80,
              backgroundImage: _image != null
                  ? FileImage(_image)
                  : previousImage != null
                      ? NetworkImage("http://10.0.2.2:8000/api/providerImg/" +
                          previousImage)
                      : null),
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
          title: Text(getTranslate(context, 'SERVICE_INFORMATIONS')),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                showImageInput(
                    widget.provider != null ? widget.provider.image : null),
                showTitleInput(
                    widget.provider != null ? widget.provider.title : null),
                showDescriptionInput(widget.provider != null
                    ? widget.provider.description
                    : null),
                showEmailInput(
                    widget.provider != null ? widget.provider.email : null),
                showMobileInput(
                    widget.provider != null ? widget.provider.mobile : null),
                showSiteWebInput(
                    widget.provider != null ? widget.provider.url : null),
                showError(),
                showSaveProvider(widget.provider),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

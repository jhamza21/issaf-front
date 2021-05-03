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
  String _type,
      _title,
      _description,
      _email,
      _mobile,
      _siteWeb,
      _region,
      _error;
  File _selectedImage;
  final _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initializeProviderData();
  }

  void initializeProviderData() async {
    if (widget.provider != null) {
      _type = widget.provider.type;
      _title = widget.provider.title;
      _description = widget.provider.description;
      _mobile = widget.provider.mobile;
      _email = widget.provider.email;
      _siteWeb = widget.provider.url;
      _region = widget.provider.region;
    }
  }

  bool checkProviderChanged(ModelProvider.Provider provider) {
    if (provider == null) return true;
    if (_mobile != provider.mobile ||
        _type != provider.type ||
        _title != provider.title ||
        _description != provider.description ||
        _email != provider.email ||
        _region != provider.region ||
        _siteWeb != null && _siteWeb != provider.url ||
        _selectedImage != null) return true;
    return false;
  }

  Widget showMobileInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: IntlPhoneField(
        autoValidate: false,
        initialCountryCode: _mobile != null ? _mobile.split('/')[0] : "TN",
        initialValue: _mobile != null ? _mobile.split('/')[2] : null,
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

  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        initialValue: _email,
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

  Widget showRegionInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 15.0),
      child: DropdownButtonFormField(
        decoration: inputTextDecorationRectangle(
            null, getTranslate(context, 'REGION') + "*", null, null),
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

  bool validateImage() {
    if (widget.provider == null && _selectedImage == null) return false;

    return true;
  }

  // Check if form is valid
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) return true;
    return false;
  }

  Widget showSaveProvider() {
    return checkProviderChanged(widget.provider)
        ? TextButton.icon(
            onPressed: _isLoading
                ? null
                : () async {
                    if (!_isLoading && validateAndSave())
                      try {
                        setState(() {
                          _error = null;
                          _isLoading = true;
                        });
                        var prefs = await SharedPreferences.getInstance();
                        var res = await ProviderService().addUpdateProvider(
                            prefs.getString('token'),
                            widget.provider != null ? widget.provider.id : null,
                            _type,
                            _title,
                            _description,
                            _email,
                            _mobile,
                            _siteWeb,
                            _region,
                            _selectedImage);
                        if (res.statusCode == 201 || res.statusCode == 200) {
                          ModelProvider.Provider _resProvider =
                              ModelProvider.Provider.fromJson(json
                                  .decode(await res.stream.bytesToString()));
                          _selectedImage = null;
                          widget.callback(_resProvider);
                          setState(() {
                            _isLoading = false;
                          });
                          final snackBar = SnackBar(
                            content: Text(getTranslate(
                                context,
                                res.statusCode == 200
                                    ? "SUCCESS_UPDATE"
                                    : "SUCCESS_ADD")),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else {
                          final jsonData =
                              json.decode(await res.stream.bytesToString());
                          setState(() {
                            _isLoading = false;
                            _error = getTranslate(context, jsonData["error"]);
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

  Widget showDescriptionInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        initialValue: _description,
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
      if (img != null) _selectedImage = File(img.path);
    });
  }

  Widget showImageInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
              child: _selectedImage != null ||
                      (widget.provider != null && widget.provider.image != null)
                  ? SizedBox.shrink()
                  : Text(getTranslate(context, "INSERT_IMAGE")),
              backgroundColor: Colors.orange[200],
              radius: 80,
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage)
                  : widget.provider != null && widget.provider.image != null
                      ? NetworkImage(
                          URL_BACKEND + "providerImg/" + widget.provider.image)
                      : null),
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.grey[600]),
                onPressed: () {
                  getImageFromGallery();
                },
              ),
              IconButton(
                icon: Icon(Icons.restore,
                    color: _selectedImage != null
                        ? Colors.grey[600]
                        : Colors.grey[400]),
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget showSiteWebInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        initialValue: _siteWeb,
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

  Widget showTitleInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        initialValue: _title,
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

  Widget showTypeInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: DropdownButtonFormField(
        decoration: inputTextDecorationRectangle(
            null, getTranslate(context, 'TYPE') + "*", null, null),
        validator: (value) => value == null
            ? getTranslate(context, "REQUIRED_PROVIDER_TYPE")
            : null,
        isExpanded: true,
        dropdownColor: Colors.orange[50],
        value: _type,
        onChanged: (value) {
          setState(() {
            _type = value;
          });
        },
        icon: Icon(
          Icons.arrow_downward,
        ),
        items: providers
            .map<DropdownMenuItem<String>>((type) => DropdownMenuItem(
                  value: type,
                  child: Text(getTranslate(context, type)),
                ))
            .toList(),
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
          title: Text(widget.provider == null
              ? getTranslate(context, 'ADD_PROVIDER')
              : widget.provider.title),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                showImageInput(),
                showTypeInput(),
                showTitleInput(),
                showDescriptionInput(),
                showEmailInput(),
                showMobileInput(),
                showSiteWebInput(),
                showRegionInput(),
                showError(),
                showSaveProvider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

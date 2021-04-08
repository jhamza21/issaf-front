import 'package:issaf/constants.dart';

String errorHandler(String code, dynamic context) {
  List<String> errors = [
    "INVALID_EMAIL",
    "INVALID_PASSWORD",
    "EMAIL_ALREADY_IN_USE",
    "USERNAME_ALREADY_IN_USE",
    "INVALID_CREDENTIALS"
  ];
  if (errors.contains(code.toUpperCase()))
    return getTranslate(context, code.toUpperCase());
  else
    return getTranslate(context, "ERROR_SERVER");
}

import 'package:issaf/models/user.dart';
import 'package:meta/meta.dart';

@immutable
class UserState {
  final bool isError;
  final bool isLoading;
  final bool isLoggedIn;
  final bool isCheckingLogin;
  final String errorText;
  final User user;

  UserState({
    this.isError,
    this.isLoading,
    this.isLoggedIn,
    this.isCheckingLogin,
    this.errorText,
    this.user,
  });

  factory UserState.initial() => UserState(
        isLoading: false,
        isError: false,
        isLoggedIn: false,
        isCheckingLogin: false,
        errorText: null,
        user: null,
      );

  UserState copyWith({
    @required bool isError,
    @required bool isLoading,
    @required bool isLoggedIn,
    @required bool isCheckingLogin,
    @required String errorText,
    @required User user,
  }) {
    return UserState(
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isCheckingLogin: isCheckingLogin ?? this.isCheckingLogin,
      errorText: errorText ?? this.errorText,
      user: user ?? this.user,
    );
  }
}

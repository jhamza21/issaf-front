import 'package:issaf/redux/users/actions.dart';
import 'package:issaf/redux/users/state.dart';

userReducer(UserState prevState, SetUserStateAction action) {
  final payload = action.userState;
  return prevState.copyWith(
    isError: payload.isError,
    isLoading: payload.isLoading,
    isLoggedIn: payload.isLoggedIn,
    isCheckingLogin: payload.isCheckingLogin,
    errorText: payload.errorText,
    user: payload.user,
  );
}

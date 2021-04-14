import 'package:issaf/redux/users/actions.dart';
import 'package:issaf/redux/users/state.dart';

userReducer(UserState prevState, SetUserStateAction action) {
  final payload = action.userState;
  return prevState.copyWith(
    isLoggedIn: payload.isLoggedIn,
    user: payload.user,
  );
}

import 'package:issaf/models/user.dart';
import 'package:meta/meta.dart';

@immutable
class UserState {
  final bool isLoggedIn;
  final User user;
  final String role;

  UserState({this.isLoggedIn, this.user, this.role});

  factory UserState.initial() =>
      UserState(isLoggedIn: false, user: null, role: null);

  UserState copyWith({
    @required bool isLoggedIn,
    @required User user,
    @required String role,
  }) {
    return UserState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
      role: role ?? this.role,
    );
  }
}

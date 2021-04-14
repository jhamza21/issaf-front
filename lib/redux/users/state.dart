import 'package:issaf/models/user.dart';
import 'package:meta/meta.dart';

@immutable
class UserState {
  final bool isLoggedIn;
  final User user;

  UserState({
    this.isLoggedIn,
    this.user,
  });

  factory UserState.initial() => UserState(
        isLoggedIn: false,
        user: null,
      );

  UserState copyWith({
    @required bool isLoggedIn,
    @required User user,
  }) {
    return UserState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
    );
  }
}

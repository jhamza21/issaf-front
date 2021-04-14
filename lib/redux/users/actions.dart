import 'package:issaf/redux/users/state.dart';
import 'package:meta/meta.dart';

@immutable
class SetUserStateAction {
  final UserState userState;
  SetUserStateAction(this.userState);
}

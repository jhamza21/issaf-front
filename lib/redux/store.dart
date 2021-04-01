import 'package:issaf/redux/users/actions.dart';
import 'package:issaf/redux/users/reducer.dart';
import 'package:issaf/redux/users/state.dart';
import 'package:meta/meta.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

AppState appReducer(AppState state, dynamic action) {
  if (action is SetUserStateAction) {
    final nextUserState = userReducer(state.userState, action);
    return state.copyWith(userState: nextUserState);
  }
  return state;
}

@immutable
class AppState {
  final UserState userState;

  AppState({
    @required this.userState,
  });

  AppState copyWith({
    UserState userState,
  }) {
    return AppState(
      userState: userState ?? this.userState,
    );
  }
}

class Redux {
  static Store<AppState> _store;

  static Store<AppState> get store {
    if (_store == null) {
      throw Exception("store is not initialized");
    } else {
      return _store;
    }
  }

  static Future<void> init() async {
    final userStateInitial = UserState.initial();

    _store = Store<AppState>(
      appReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(userState: userStateInitial),
    );
  }
}

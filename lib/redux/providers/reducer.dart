import 'package:issaf/redux/providers/actions.dart';
import 'package:issaf/redux/providers/state.dart';

providerReducer(ProviderState prevState, SetProviderStateAction action) {
  final payload = action.providerState;
  return prevState.copyWith(
    isError: payload.isError,
    isLoading: payload.isLoading,
    errorText: payload.errorText,
    providers: payload.providers,
  );
}

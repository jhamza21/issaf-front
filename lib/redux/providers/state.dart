import 'package:issaf/models/provider.dart';
import 'package:meta/meta.dart';

@immutable
class ProviderState {
  final bool isError;
  final bool isLoading;
  final String errorText;
  final List<Provider> providers;

  ProviderState({
    this.isError,
    this.isLoading,
    this.errorText,
    this.providers,
  });

  factory ProviderState.initial() => ProviderState(
        isLoading: false,
        isError: false,
        errorText: null,
        providers: [],
      );

  ProviderState copyWith({
    @required bool isError,
    @required bool isLoading,
    @required String errorText,
    @required List<Provider> providers,
  }) {
    return ProviderState(
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      errorText: errorText ?? this.errorText,
      providers: providers ?? this.providers,
    );
  }
}

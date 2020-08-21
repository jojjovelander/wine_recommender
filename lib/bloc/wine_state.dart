part of 'wine_bloc.dart';

@freezed
abstract class WineState with _$WineState {
  const factory WineState.initial() = WineInitial;
  const factory WineState.loading() = WineLoading;
  const factory WineState.loaded(Cluster wineName) = WineLoaded;
  const factory WineState.error(String message) = WineError;
}
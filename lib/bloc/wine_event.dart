part of 'wine_bloc.dart';

@freezed
abstract class WineEvent  with _$WineEvent {
  const factory WineEvent.getWine(String wineName) = GetWine;
}
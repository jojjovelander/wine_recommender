import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:wine_recommender/data/wine_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:k_means_cluster/k_means_cluster.dart';
import 'package:meta/meta.dart';

part 'wine_event.dart';
part 'wine_state.dart';
part 'wine_bloc.freezed.dart';

class WineBloc extends Bloc<WineEvent, WineState> {

  WineBloc() : super(WineInitial());

  @override
  Stream<WineState> mapEventToState(
    WineEvent event,
  ) async* {
    if (event is GetWine) {
        yield WineLoading();
        final cluster = await WineRepository().performClustering(event.wineName);
        yield WineLoaded(cluster);
    }
  }
}

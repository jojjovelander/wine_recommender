
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:wine_recommender/app_widget.dart';
import 'package:wine_recommender/data/wine_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Fimber.plantTree(DebugTree());
  WineRepository();
  runApp(AppWidget());
}

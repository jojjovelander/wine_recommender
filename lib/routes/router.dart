import 'package:auto_route/auto_route_annotations.dart';
import 'package:wine_recommender/pages/results_page.dart';

import '../pages/wine_search_page.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    AutoRoute(page: WineSearchPage, initial: true),
    AutoRoute(page: ResultsPage)
  ],
)
class $Router {}

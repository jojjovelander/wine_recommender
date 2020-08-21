import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wine_recommender/bloc/wine_bloc.dart';
import 'package:wine_recommender/data/model/wine.dart';
import 'package:wine_recommender/data/wine_repository.dart';
import 'package:wine_recommender/routes/router.gr.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../bloc/wine_bloc.dart';

class WineSearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: BlocProvider(
        create: (context) => WineBloc(),
        child: WineSearchPageWidget(),
      ),
    );
  }
}

class WineSearchPageWidget extends StatefulWidget {
  @override
  _WineSearchPageWidget createState() => _WineSearchPageWidget();
}

class _WineSearchPageWidget extends State<WineSearchPageWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wine Search"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        child: BlocConsumer<WineBloc, WineState>(
          listener: (context, state) {
            if (state is WineError) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            } else if (state is WineLoaded) {
              ExtendedNavigator.of(context).push(Routes.resultsPage,
                  arguments: ResultsPageArguments(results: state.wineName));
            }
          },
          builder: (context, state) {
            if (state is WineInitial) {
              return buildInitialInput();
            } else if (state is WineLoading) {
              return buildLoading();
            } else {
              // (state is WineError)
              return buildInitialInput();
            }
          },
        ),
      ),
    );
  }

  Widget buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  List<SearchResult> _buildSearchList(String pattern) {
    if (pattern.isEmpty) {
      return WineRepository()
          .wineList
          .map((result) => new SearchResult(result.name, result.uuid))
          .toList();
    } else {
      List<Wine> _searchList = List();
      for (int i = 0; i < WineRepository().wineList.length; i++) {
        Wine result = WineRepository().wineList.elementAt(i);
        if ((result.name).toLowerCase().contains(pattern.toLowerCase())) {
          _searchList.add(result);
        }
      }
      return _searchList
          .map((result) => new SearchResult(result.name, result.uuid))
          .toList();
    }
  }

  Widget buildInitialInput() {
    return Column(
      children: <Widget>[
        Text("What kind of wine do you like?"),
        TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
            autofocus: true,
            /*style: DefaultTextStyle.of(context)
                .style
                .copyWith(fontStyle: FontStyle.italic),*/
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          suggestionsCallback: (pattern) => _buildSearchList(pattern),
          itemBuilder: (context, suggestion) {
            return ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text(suggestion.name),
              /*subtitle: Text('\$${suggestion['price']}'),*/
            );
          },
          onSuggestionSelected: (suggestion) => context.bloc<WineBloc>()..add(WineEvent.getWine(suggestion.name)),
        ),
      ],
    );
  }
}

class SearchResult {
  final String name;
  final String uuid;

  SearchResult(this.name, this.uuid);
}

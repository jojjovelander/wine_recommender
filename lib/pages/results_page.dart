import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:wine_recommender/data/model/wine.dart';
import 'package:wine_recommender/data/wine_repository.dart';
import 'package:k_means_cluster/k_means_cluster.dart';

class ResultsPage extends StatelessWidget {
  final Cluster results;

  const ResultsPage({@required this.results});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wine Finder"),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: ListView.separated(
            separatorBuilder: (context, index) => Divider(
              color: Colors.black,
            ),
            itemCount: this.results.instances.length,
            itemBuilder: (context, index) {
              Wine wine = WineRepository()
                  .wineList
                  .where((element) =>
                      element.name == this.results.instances[index].id)
                  .first;
              return ListTile(
                title: Container(
                  alignment: Alignment.center,
                  child: Text('${this.results.instances[index].id}'),
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('${wine.country}'),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('${wine.grapeVariety}'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wine_recommender/data/model/wine.dart';
import 'package:injectable/injectable.dart';
import 'package:k_means_cluster/k_means_cluster.dart';

parseEncodedWineData(String encodedWineData) {
  return jsonDecode(encodedWineData);
}

parseCsvData(String rawCsvData) {
  return CsvToListConverter().convert(rawCsvData);
}

calculateIndices(csvData) async {
  var count = 0;
  csvData.forEach((row) {
    if (count == 0) {
      count++;
      return;
    }
  });
}

transformKMeansObject(wines) {
  var encodedData = <List<int>>[];
  var j = 0;
  for (var i = 0; i < wines[j].length; i++) {
    var newWine = <int>[];
    while (j < wines.length) {
      newWine.add(wines[j][i]);
      j++;
    }
    j = 0;
    encodedData.add(newWine);
  }
  return encodedData;
}

class IsolateResult {
  final Map<String, Set<String>> sets;
  final List<Wine> wineList;

  IsolateResult(this.sets, this.wineList);
}

generateKMeanClusters(instances) {
  // Randomly create the initial clusters.
  var clusters = initialClusters(10, instances, seed: 0);

  // Run the KMeans.
  var info =
      kmeans(maxIterations: 10, clusters: clusters, instances: instances);
  Fimber.i('$info');
  return clusters;
}

convertCsvData(csvData) {
  var count = 0;
  Set<String> country = Set();
  Set<String> county = {};
  Set<String> province = {};
  Set<String> variety = {};
  var wineList = <Wine>[];

  csvData.forEach((row) {
    if (count == 0) {
      count++;
      return;
    }

    country.add(row[1]);
    county.add(row[2]);
    /*designation
          .add(row[3].runtimeType == String ? row[3] : row[3].toString());*/
    province.add(row[6].runtimeType == String ? row[6] : row[6].toString());
    variety.add(row[8].runtimeType == String ? row[8] : row[8].toString());

    var wine = Wine.fromCsv(row);
    wineList.add(
      wine.copyWith(
        countryIndex: WineRepository.getIndexForSet(country, wine.country),
        countyIndex: WineRepository.getIndexForSet(country, wine.county),
        provinceIndex: WineRepository.getIndexForSet(province, wine.province),
        grapeVarietyIndex:
            WineRepository.getIndexForSet(variety, wine.grapeVariety),
      ),
    );

    count++;
  });
  var result = Map<String, Set<String>>();
  result['country'] = country;
  result['county'] = county;
  result['province'] = province;
  result['variety'] = variety;
  return IsolateResult(result, wineList);
}

@prod
@singleton
class WineRepository {
  List<Wine> wineList = [];
  var csvData;
  List<List<dynamic>> cleanWineList;
  Set<String> country = {};
  Set<String> county = {};
  Set<String> designation = {};
  Set<String> province = {};
  Set<String> variety = {};
  List<String> names = <String>[];
  List<int> points = <int>[];
  List<double> prices = <double>[];
  var encodedData;

  static final WineRepository _singleton = WineRepository._internal();

  factory WineRepository() {
    return _singleton;
  }

  WineRepository._internal() {
    init();
  }

  fetchEncodedWineData() async {
    final rawData = await loadAsset('assets/encodedWineData.json');
    return compute(parseEncodedWineData, rawData);
  }

  fetchCsvData() async {
    final String rawData = await loadAsset('assets/wines.csv');
    return compute(parseCsvData, rawData);
  }

  extractData() async {
    return compute(convertCsvData, csvData);
  }

  doKMeans(List<Instance> instances) async {
    return compute(generateKMeanClusters, instances);
  }

  init() async {
    Fimber.i('Initialising Wine Repository...');
    csvData = await fetchCsvData();
    encodedData = await fetchEncodedWineData();
    IsolateResult results = await extractData();
    country = results.sets['country'];
    county = results.sets['county'];
    province = results.sets['province'];
    variety = results.sets['variety'];
    wineList = results.wineList;
    populateData();
    Fimber.i('....initialised.');
  }

  buildEncodedObject() => [encodedData['varieties']].expand((x) => x).toList();

  void populateData() {
    wineList.forEach((wine) {
      names.add(wine.name);
      points.add(wine.points);
      prices.add(wine.price);
    });
  }

  buildKMeansObject(wines) async {
    return compute(transformKMeansObject, wines);
  }

  Future<Cluster> performClustering(String wineName) async {
    var wines = buildEncodedObject();
    distanceMeasure = DistanceType.squaredEuclidian;

    var count = 0;
    List<List<int>> something = await buildKMeansObject(wines);
    List<Instance> instances = something.map((List<int> line) {
      return Instance(line, id: '${wineList[count++].name}');
    }).toList();
    List<Cluster> clusters = await doKMeans(instances);
    return Future.value(clusters.where((cluster) {
      return cluster.instances
              .where((element) => element.id == wineName,)
              .length > 0;
    }).first);
  }

  Future<String> loadAsset(String path) async =>
      await rootBundle.loadString(path);

  static int getIndexForSet(set, toFind) {
    var count = 0;
    set.forEach((currentValue) {
      if (currentValue == toFind) {
        return;
      }
      count++;
    });
    return count;
  }
}

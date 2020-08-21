import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'wine.freezed.dart';

@freezed
abstract class Wine implements _$Wine {

  Wine._();

  factory Wine({
    @required String uuid,
    @required String name,
    @required int vintage,
    @required String county,
    @required String country,
    @required int points,
    @required String grapeVariety,
    @required double price,
    @required String province,
    @required String winery,
    @required String designation,
    int countryIndex,
    int countyIndex,
    int designationIndex,
    int provinceIndex,
    int grapeVarietyIndex,
  }) = _Wine;

  factory Wine.fromCsv(
      List<dynamic> csvRow, {
        @nullable int countryIndex,
        @nullable int countyIndex,
        @nullable int designationIndex,
        @nullable int provinceIndex,
        @nullable int grapeVarietyIndex,
      }) {

    var fullVintage = csvRow[0].toString();
    var year = int.parse(fullVintage.substring(fullVintage.length - 4, fullVintage.length));
    var  strPrice = csvRow[5].toString();
    if (strPrice.contains(',')) {
      strPrice = strPrice.replaceAll(',' , '');
    }
    var  price = strPrice.isNotEmpty ? double.parse(strPrice.substring(1, strPrice.length)) : 0.0;

    return Wine(
      uuid: Uuid().v4(),
      vintage: year,
      country: csvRow[1],
      county: csvRow[2],
      designation: csvRow[3].toString(),
      points: int.parse(csvRow[4].toString()),
      price: price,
      province: csvRow[6],
      name: csvRow[7],
      grapeVariety: csvRow[8],
      winery: csvRow[9].toString(),
      countryIndex: countryIndex ?? 0,
      countyIndex: countyIndex ?? 0,
      designationIndex: designationIndex ?? 0,
      provinceIndex: provinceIndex ?? 0,
      grapeVarietyIndex: grapeVarietyIndex ?? 0,
    );
  }
}
import 'package:flutter/material.dart';

/* Example

    "sector" : "Basic Materials",
    "changesPercentage" : "0.0849%"
*/

class SectorsModel {
  final String sector;
  final String changesPercentage;

  SectorsModel({
    @required this.sector,
    @required this.changesPercentage,
  });

  bool selected = false;
  factory SectorsModel.fromJson(Map<String, dynamic> json) => SectorsModel(
        sector: json['sector'],
        changesPercentage: json['changesPercentage'],
      );
}

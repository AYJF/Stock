import 'package:flutter/material.dart';

/* Example

    "ticker" : "LMPX",
    "changes" : 4.25,
    "price" : "17.66",
    "changesPercentage" : "(+31.69%)",
    "companyName" : "Lmp Automotive Holdings Inc"
*/

class MostGainersModel {
  final String tickers;
  final String companyName;
  final double changes;
  final String price;
  final String changesPercentage;

  MostGainersModel({
    @required this.tickers,
    @required this.companyName,
    @required this.changes,
    @required this.price,
    @required this.changesPercentage,
  });

  bool selected = false;
  factory MostGainersModel.fromJson(Map<String, dynamic> json) =>
      MostGainersModel(
        tickers: json['ticker'],
        companyName: json['companyName'],
        changes: json['changes'],
        price: json['price'],
        changesPercentage: json['changesPercentage'],
      );
}

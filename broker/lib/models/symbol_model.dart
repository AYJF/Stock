import 'package:flutter/material.dart';

class SymbolModel {
  final String symbol;
  final String name;

  final String sector;

  SymbolModel({
    @required this.symbol,
    @required this.name,
    @required this.sector,
  });

  factory SymbolModel.fromJson(Map<String, dynamic> json) => SymbolModel(
        symbol: json['symbol'],
        name: json['name'],
        sector: json['sector'],
      );
}

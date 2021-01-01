import 'package:flutter/material.dart';

class GroupDailyModel {
  final String tickers;
  final int vol;
  final double weightedVol; //The volume weighted average price.
  final double open;
  final double close;
  final double high;
  final double low;
  final int timestamp;
  final double change;

  GroupDailyModel({
    @required this.tickers,
    @required this.vol,
    @required this.weightedVol,
    @required this.open,
    @required this.close,
    @required this.high,
    @required this.low,
    @required this.timestamp,
    @required this.change,
  });

  GroupDailyModel empty() {
    return GroupDailyModel(
      tickers: '',
      vol: null,
      weightedVol: null,
      open: null,
      close: null,
      high: null,
      low: null,
      timestamp: null,
      change: null,
    );
  }

  bool selected = false;
  factory GroupDailyModel.fromJson(Map<String, dynamic> json) =>
      GroupDailyModel(
        tickers: json['T'],
        vol: json['v'],
        weightedVol: json['vw'],
        open: json['o'],
        close: json['c'],
        high: json['h'],
        low: json['l'],
        timestamp: json['t'],
        change: ((json['c'] - json['o']) / json['o']) * 100,
      );
}

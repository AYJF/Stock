import 'package:flutter/material.dart';

class HomeHandler with ChangeNotifier {
  Map<String, List<String>> _map = {};

  Map<String, List<String>> get map => _map;

  void setMap(Map<String, List<String>> map) {
    _map = map;
    notifyListeners();
  }
}

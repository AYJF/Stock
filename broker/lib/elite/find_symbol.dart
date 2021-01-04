import 'package:broker/models/symbol_model.dart';
import 'package:flutter/material.dart';

class SymbolHandler with ChangeNotifier {
  SymbolHandler({List<SymbolModel> symbol}) {
    _clients = symbol;
    _updateClients = symbol;
  }

  List<SymbolModel> _clients;
  List<SymbolModel> _updateClients;
  List<SymbolModel> get clientsList => _updateClients;

  void setClients(List value) {
    _clients = value;
    notifyListeners();
  }

  void findClients(String value) {
    if (value.isNotEmpty) {
      _updateClients = _clients
          .where((element) =>
              element.name.toLowerCase().contains(value.toLowerCase()) ||
              element.symbol.toLowerCase().contains(value.toLowerCase()))
          .toList();
    } else
      _updateClients = _clients;

    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

import 'package:broker/models/most_gainers.dart';
import 'package:flutter/material.dart';

class ClientsListHnadler with ChangeNotifier {
  ClientsListHnadler(List<MostGainersModel> clients) {
    _clients = clients;
    _updateClients = clients;
  }

  List<MostGainersModel> _clients;
  List<MostGainersModel> _updateClients;
  List<MostGainersModel> get clientsList => _updateClients;

  void setClients(List value) {
    _clients = value;
    notifyListeners();
  }

  void findClients(String value) {
    if (value.isNotEmpty) {
      final name = value.toLowerCase().split(' ');
      if (name.length > 1)
        _updateClients = _clients
            .where((element) => element.tickers.toLowerCase().contains(name[0]))
            .toList();
      else
        _updateClients = _clients
            .where((element) => element.tickers.toLowerCase().contains(name[0]))
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

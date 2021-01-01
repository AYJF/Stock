import 'package:broker/models/sector_model.dart';
import 'package:flutter/material.dart';

class SectorHnadler with ChangeNotifier {
  SectorHnadler(List<SectorsModel> clients) {
    _clients = clients;
    _updateClients = clients;
  }

  List<SectorsModel> _clients;
  List<SectorsModel> _updateClients;
  List<SectorsModel> get clientsList => _updateClients;

  void setClients(List value) {
    _clients = value;
    notifyListeners();
  }

  void findClients(String value) {
    if (value.isNotEmpty) {
      final name = value.toLowerCase().split(' ');
      if (name.length > 1)
        _updateClients = _clients
            .where((element) => element.sector.toLowerCase().contains(name[0]))
            .toList();
      else
        _updateClients = _clients
            .where((element) => element.sector.toLowerCase().contains(name[0]))
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

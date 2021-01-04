import 'dart:convert' as convert; // for the utf8.encode method
import 'dart:async';

import 'package:http/http.dart' as http;

enum INDEX {
  NASDAQ,
  NASDAQ_100,
  SP_500,
}

class FMPApi {
  final String _apiBaseUrl = "https://financialmodelingprep.com/api/";
  final String _version = 'v3';
  final String _apiKey = "3bbeb9c6b7d31f4b2d659cd42459ee58";

  Future<List<dynamic>> getMostGainers() async {
    try {
      final response =
          await http.get(_apiBaseUrl + _version + '/gainers?apikey=$_apiKey');

      if (response.statusCode == 200) {
        return convert.jsonDecode(response.body);
      } else
        return [];
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<dynamic>> getMostLossers() async {
    try {
      final response =
          await http.get(_apiBaseUrl + _version + '/losers?apikey=$_apiKey');

      if (response.statusCode == 200) {
        return convert.jsonDecode(response.body);
      } else
        return [];
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<dynamic>> getMostActive() async {
    try {
      final response =
          await http.get(_apiBaseUrl + _version + '/actives?apikey=$_apiKey');

      if (response.statusCode == 200) {
        return convert.jsonDecode(response.body);
      } else
        return [];
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<dynamic>> getSectorsPerformance() async {
    try {
      final response = await http
          .get(_apiBaseUrl + _version + '/sectors-performance?apikey=$_apiKey');

      if (response.statusCode == 200) {
        return convert.jsonDecode(response.body);
      } else
        return [];
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<dynamic>> getStockMarkerIndex() async {
    try {
      final response = await http.get(_apiBaseUrl +
          _version +
          '/quote/%5EGSPC,%5ENDX,%5EIXIC?apikey=$_apiKey');

      if (response.statusCode == 200) {
        return convert.jsonDecode(response.body);
      } else
        return [];
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<dynamic>> getTecnicalIndicators(
    String symbol, {
    String time = 'daily',
    int period = 10,
  }) async {
    try {
      final response = await http.get(_apiBaseUrl +
          _version +
          '/technical_indicator/$time/$symbol?period=$period&type=ema&apikey=$_apiKey');

      if (response.statusCode == 200) {
        return convert.jsonDecode(response.body);
      } else
        return [];
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<dynamic>> getStockList() async {
    try {
      final response = await http
          .get(_apiBaseUrl + _version + '/stock/list?apikey=$_apiKey');

      if (response.statusCode == 200) {
        return convert.jsonDecode(response.body);
      } else
        return [];
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<dynamic>> getNasdaq() async {
    try {
      final response = await http
          .get(_apiBaseUrl + _version + '/nasdaq_constituent?apikey=$_apiKey');

      if (response.statusCode == 200) {
        return convert.jsonDecode(response.body);
      } else
        return [];
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<dynamic>> getQuote(String symbol) async {
    try {
      final response = await http
          .get(_apiBaseUrl + _version + '/quote/$symbol?apikey=$_apiKey');

      if (response.statusCode == 200) {
        return convert.jsonDecode(response.body);
      } else
        return [];
    } catch (e) {
      print(e.toString());
      return [];
    }
  }
}

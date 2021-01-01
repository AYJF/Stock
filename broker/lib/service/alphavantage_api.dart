import 'dart:convert' as convert; // for the utf8.encode method
import 'dart:async';

import 'package:http/http.dart' as http;

class AlphaVantageApi {
  AlphaVantageApi();

  final String _apiBaseUrl = "https://www.alphavantage.co/query?function=";
  final String _apiKey = "96M60S5G98OSRKG5";

  Future<Map<String, List<String>>> getListData(String status) async {
    Map<String, List<String>> _map = {};
    try {
      final response = await http
          .get(_apiBaseUrl + 'LISTING_STATUS&state=$status&apikey=$_apiKey');

      if (response.statusCode == 200) {
        List<String> symbol = [];
        List<String> name = [];
        List<String> exchange = [];
        List<String> res = response.body.split('\n');
        res.removeLast();

        res.where((element) => element.split(',')[3] == 'Stock').forEach((e) {
          symbol.add(e.split(',')[0]);
          name.add(e.split(',')[1]);
          exchange.add(e.split(',')[2]);
        });

        _map['symbol'] = symbol;
        _map['name'] = name;
        _map['exchange'] = exchange;

        return _map;
      } else {
        print('Request failed with status: ${response.statusCode}.');
        return {};
      }
    } catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future<Map<String, dynamic>> getCompanyOverView(String symbol) async {
    try {
      final response = await http
          .get(_apiBaseUrl + 'OVERVIEW&symbol=$symbol&apikey=$_apiKey');

      if (response.statusCode == 200)
        return convert.jsonDecode(response.body);
      else
        return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>> getIntraday(
    String symbol, {
    String timeInterval = '5min',
    String outputsize = 'compact',
  }) async {
    try {
      final response = await http.get(_apiBaseUrl +
          'TIME_SERIES_INTRADAY&symbol=$symbol&interval=$timeInterval&outputsize=$outputsize&apikey=$_apiKey');

      if (response.statusCode == 200)
        return convert.jsonDecode(response.body);
      else
        return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>> getDailyAdjusted(
    String symbol, {
    String outputsize = 'compact',
  }) async {
    try {
      final response = await http.get(_apiBaseUrl +
          'TIME_SERIES_DAILY_ADJUSTED&symbol=$symbol&outputsize=$outputsize&apikey=$_apiKey');

      if (response.statusCode == 200)
        return convert.jsonDecode(response.body);
      else
        return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>> getSMA(
    String symbol, {
    int timePeriod = 5,
    String interval = 'daily',
    String seriesType = 'close',
  }) async {
    try {
      final response = await http.get(_apiBaseUrl +
          'SMA&symbol=$symbol&interval=$interval&time_period=$timePeriod&series_type=$seriesType&apikey=$_apiKey');

      if (response.statusCode == 200)
        return convert.jsonDecode(response.body);
      else
        return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<Map<String, dynamic>> quoteEndpoint(String symbol) async {
    try {
      final response = await http
          .get(_apiBaseUrl + 'GLOBAL_QUOTE&symbol=$symbol&apikey=$_apiKey');

      if (response.statusCode == 200)
        return convert.jsonDecode(response.body);
      else
        return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}

//https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=IBM&apikey=demo

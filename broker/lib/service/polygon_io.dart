import 'dart:convert' as convert; // for the utf8.encode method
import 'dart:async';

import 'package:http/http.dart' as http;

class PolygonIo {
  final String _apiBaseUrl = "https://api.polygon.io/";
  final String _versionV1 = 'v1';
  final String _versionV2 = 'v2';
  final String _apiKey = "8Du3IljgrHMH37UuMGNGcQp6YKaZQ_O1";

  Future<Map<String, dynamic>> getListData({
    String market = 'stocks',
    String locale = 'us',
    int perpage = 50,
    int page = 1,
  }) async {
    try {
      final response = await http.get(_apiBaseUrl +
          _versionV2 +
          '/reference/tickers?sort=ticker&market=$market&perpage=$perpage&page=$page&active=true&apikey=$_apiKey');

      if (response.statusCode == 200)
        return convert.jsonDecode(response.body);
      else
        return null;
    } catch (e) {
      print(e.toString());
      return {};
    }
  }

  Future<Map<String, dynamic>> getTicketDetails(String symbol) async {
    try {
      final response = await http.get(_apiBaseUrl +
          _versionV1 +
          '/meta/symbols/$symbol/company?apiKey=$_apiKey');

      if (response.statusCode == 200)
        return convert.jsonDecode(response.body);
      else if (response.statusCode == 404)
        return {};
      else
        return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<List<dynamic>> getTicketNews(
    String symbol, {
    int perpage = 50,
    int page = 1,
  }) async {
    try {
      final response = await http.get(_apiBaseUrl +
          _versionV1 +
          '/meta/symbols/$symbol/news?perpage=$perpage&page=$page&apiKey=$_apiKey');

      if (response.statusCode == 200)
        return convert.jsonDecode(response.body);
      else if (response.statusCode == 404)
        return [];
      else
        return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

// Get aggregate bars for a stock over a given date range in custom time window sizes.
// For example, if timespan = ‘minute’ and multiplier = ‘5’ then 5-minute bars will be returned.
  Future<Map<String, dynamic>> getAggregates(
    String symbol, {
    int multiplier = 1,
    String timespan = 'day',
    String from = '2020-01-01',
    String to = '2020-12-29',
  }) async {
    try {
      final response = await http.get(_apiBaseUrl +
          _versionV2 +
          '/aggs/ticker/$symbol/range/$multiplier/$timespan/$from/$to?unadjusted=true&sort=desc&limit=120&apiKey=$_apiKey');

      if (response.statusCode == 200) {
        return convert.jsonDecode(response.body);
      } else if (response.statusCode == 404)
        return {};
      else
        return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //Get the daily open, high, low, and close (OHLC) for the entire stocks/equities markets.
  Future<Map<String, dynamic>> getGroupedDaily({
    String date = '2020-12-30',
    String locale = 'global',
  }) async {
    try {
      final response = await http.get(_apiBaseUrl +
          _versionV2 +
          '/aggs/grouped/locale/$locale/market/stocks/$date?unadjusted=true&apiKey=$_apiKey');

      if (response.statusCode == 200) {
        return convert.jsonDecode(response.body);
      } else if (response.statusCode == 404)
        return {};
      else
        return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}

//https://api.polygon.io/v2/aggs/grouped/locale/us/market/stocks/2020-12-30?unadjusted=true&apiKey=8Du3IljgrHMH37UuMGNGcQp6YKaZQ_O1

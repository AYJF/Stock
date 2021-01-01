//  EXAMPLE RESULT QUERY
// "01. symbol": "IBM",
//   "02. open": "125.3500",
//   "03. high": "125.4800",
//   "04. low": "123.2400",
//   "05. price": "123.8000",
//   "06. volume": "3487007",
//   "07. latest trading day": "2020-12-29",
//   "08. previous close": "124.8200",
//   "09. change": "-1.0200",
//   "10. change percent": "-0.8172%"

class InfoCard {
  String symbol;
  double open;
  double high;
  double low;
  double price;
  double vol;
  String latestTradingDay;
  double prevClose;
  double change;
  String changePercent;

  InfoCard.fromCustom({
    this.symbol,
    this.open,
    this.prevClose,
    this.change,
    this.changePercent,
    this.latestTradingDay,
    this.high,
    this.low,
    this.vol,
    this.price,
  });

  InfoCard.fromJson(Map<String, dynamic> json) {
    symbol = json['01. symbol'];
    open = double.tryParse(json['02. open']);
    high = double.tryParse(json['03. high']);
    low = double.tryParse(json['04. low']);
    price = double.tryParse(json['05. price']);
    vol = double.tryParse(json['06. volume']);
    latestTradingDay = json['07. latest trading day'];
    prevClose = double.tryParse(json['08. previous close']);
    change = double.tryParse(json['09. change']);
    changePercent = json['10. change percent'];
  }
}

import 'package:broker/service/alphavantage_api.dart';
import 'package:broker/service/fmp_api.dart';
import 'package:broker/tools/custom_card.dart';
import 'package:broker/tools/utils.dart';
import 'package:broker/widgets/k_chart/flutter_k_chart.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Item {
  const Item(this.name, this.icon);
  final String name;
  final Icon icon;
}

List<Item> time = <Item>[
  const Item(
      'daily',
      Icon(
        Icons.date_range,
        color: Colors.pink,
      )),
  const Item(
      '1min',
      Icon(
        Icons.plus_one,
        color: Colors.pink,
      )),
  const Item(
      '5min',
      Icon(
        Icons.lock_clock,
        color: Colors.pink,
      )),
  const Item(
      '1hour',
      Icon(
        Icons.hourglass_empty,
        color: Colors.pink,
      )),
];

class Chart extends StatefulWidget {
  Chart({Key key, this.title, this.symbol}) : super(key: key);

  final String title;
  final String symbol;

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  int _index = 0;
  Item selectedTime = time[0];
  List<KLineEntity> datas = [];
  InfoCard infoCard;
  bool showLoading = true;
  MainState _mainState = MainState.MA;
  bool _volHidden = false;
  SecondaryState _secondaryState = SecondaryState.MACD;
  bool isLine = true;
  bool isChinese = false;
  List<DepthEntity> _bids, _asks;

  @override
  void initState() {
    super.initState();
    getData();
    getInfoCard();
    // rootBundle.loadString('assets/json/depth.json').then((result) {
    //   final parseJson = json.decode(result);
    //   Map tick = parseJson['tick'];
    //   var bids = tick['bids']
    //       .map((item) => DepthEntity(item[0], item[1]))
    //       .toList()
    //       .cast<DepthEntity>();
    //   var asks = tick['asks']
    //       .map((item) => DepthEntity(item[0], item[1]))
    //       .toList()
    //       .cast<DepthEntity>();
    //   initDepth(bids, asks);
    // });
  }

  void initDepth(List<DepthEntity> bids, List<DepthEntity> asks) {
    if (bids == null || asks == null || bids.isEmpty || asks.isEmpty) return;
    _bids = List();
    _asks = List();
    double amount = 0.0;
    bids?.sort((left, right) => left.price.compareTo(right.price));
    //累加买入委托量
    bids.reversed.forEach((item) {
      amount += item.vol;
      item.vol = amount;
      _bids.insert(0, item);
    });

    amount = 0.0;
    asks?.sort((left, right) => left.price.compareTo(right.price));
    //累加卖出委托量
    asks?.forEach((item) {
      amount += item.vol;
      item.vol = amount;
      _asks.add(item);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff17212F),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title + '  ${widget.symbol}',
          style: GoogleFonts.staatliches(
            textStyle: Theme.of(context).textTheme.headline4,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.star,
              color: Colors.yellow,
            ),
            onPressed: () {},
          )
        ],
      ),
      extendBody: true,
      bottomNavigationBar: FloatingNavbar(
        onTap: (int val) {
          //returns tab id which is user tapped
          switch (val) {
            case 0:
              isLine = !isLine;
              break;
            case 1:
              if (_mainState == MainState.MA) {
                _mainState = MainState.BOLL;
              } else if (_mainState == MainState.BOLL) {
                _mainState = MainState.NONE;
              } else {
                _mainState = MainState.MA;
              }

              break;
            case 2:
              _secondaryState = SecondaryState.MACD;
              //             button("MACD", onPressed: () => ),
              // button("KDJ", onPressed: () => _secondaryState = SecondaryState.KDJ),
              // button("RSI", onPressed: () => _secondaryState = SecondaryState.RSI),
              // button("WR", onPressed: () => _secondaryState = SecondaryState.WR),
              break;
            case 3:
              _volHidden = !_volHidden;
              break;
            default:
              break;
          }

          setState(() => _index = val);
        },
        currentIndex: _index,
        items: [
          FloatingNavbarItem(icon: Icons.swipe, title: 'L/C'),
          FloatingNavbarItem(icon: Icons.line_style, title: 'SMA/BOLL'),
          FloatingNavbarItem(icon: Icons.stacked_line_chart, title: 'MACD'),
          FloatingNavbarItem(icon: Icons.bar_chart, title: 'Vol'),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 175,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Card(
                elevation: 3.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 7,
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 1),
                            child: Row(
                              children: [
                                Text(
                                  infoCard?.price?.toString() ?? '',
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w600,
                                    textStyle:
                                        Theme.of(context).textTheme.headline4,
                                    fontSize: 38,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        infoCard?.change?.toString() ?? '',
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.w600,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .headline4,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        infoCard?.changePercent ?? '',
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.w600,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .headline4,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(1, 8.0, 1.0, 1.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      // border: Border.all(
                                      //     color: Colors.indigoAccent, width: 1.0),
                                      color: Colors.yellow[900],
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: InkWell(
                                      //This keeps the splash effect within the circle

                                      //Something large to ensure a circle
                                      onTap: () => print("click"),
                                      child: Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Icon(
                                          Icons.access_alarms_sharp,
                                          size: 20.0,
                                          color: Colors.yellowAccent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      // border: Border.all(
                                      //     color: Colors.indigoAccent, width: 1.0),
                                      color: Colors.indigo[900],
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: InkWell(
                                      //This keeps the splash effect within the circle

                                      //Something large to ensure a circle
                                      onTap: () => print("click"),
                                      child: Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Icon(
                                          Icons.bar_chart,
                                          size: 20.0,
                                          color: Colors.indigoAccent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      color: Colors.green[900],
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: InkWell(
                                      onTap: () => print("click"),
                                      child: Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Icon(
                                          Icons.money_off,
                                          size: 20.0,
                                          color: Colors.greenAccent,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                      child: Text(
                        (infoCard?.latestTradingDay == null)
                            ? ''
                            : "Latest trading day: " +
                                infoCard.latestTradingDay,
                        style: GoogleFonts.nunito(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          textStyle: Theme.of(context).textTheme.headline4,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  "OPEN/PREV CLOSE",
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w400,
                                    textStyle:
                                        Theme.of(context).textTheme.headline4,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  (infoCard.open == null ||
                                          infoCard.prevClose == null)
                                      ? ''
                                      : "${infoCard.open.toString()} / ${infoCard.prevClose.toString()}",
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w400,
                                    textStyle:
                                        Theme.of(context).textTheme.headline4,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  "DAY'S RANGE",
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w400,
                                    textStyle:
                                        Theme.of(context).textTheme.headline4,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  (infoCard.low == null ||
                                          infoCard.high == null)
                                      ? ''
                                      : "${infoCard.low.toString()} - ${infoCard.high.toString()}",
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w400,
                                    textStyle:
                                        Theme.of(context).textTheme.headline4,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  "VOLUME",
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w400,
                                    textStyle:
                                        Theme.of(context).textTheme.headline4,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  (infoCard.vol == null)
                                      ? ''
                                      : "${infoCard.vol}",
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w400,
                                    textStyle:
                                        Theme.of(context).textTheme.headline4,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 50,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Card(
                elevation: 3.0,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: DropdownButton<Item>(
                        underline: Container(
                            // height: 2,
                            // color: Colors.deepPurpleAccent,
                            ),
                        hint: Text("Select item"),
                        value: selectedTime,
                        onChanged: (Item value) {
                          setState(() {
                            selectedTime = value;
                            getData();
                          });
                        },
                        items: time.map((Item user) {
                          return DropdownMenuItem<Item>(
                            value: user,
                            child: Row(
                              children: <Widget>[
                                user.icon,
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  user.name,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Stack(children: <Widget>[
            Container(
              height: 700,
              width: double.infinity,
              child: KChartWidget(
                datas,
                isLine: isLine,
                mainState: _mainState,
                volHidden: _volHidden,
                // onLoadMore: (bool a) {
                //   print("onLoadMore: $a");
                // },
                // isOnDrag: (isDrag) {
                //   print("Drag: $isDrag");
                // },
                secondaryState: _secondaryState,
                fixedLength: 2,
                timeFormat: TimeFormat.YEAR_MONTH_DAY,
                isChinese: isChinese,
              ),
            ),
            if (showLoading)
              Container(
                  width: double.infinity,
                  height: 700,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator()),
          ]),
          //  buildButtons(),
        ],
      ),
    );
  }

  Widget buildButtons() {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      children: <Widget>[
        button("Tiempo compartido", onPressed: () => isLine = true),
        button("linea k", onPressed: () => isLine = false),
        button("MA", onPressed: () => _mainState = MainState.MA),
        button("BOLL", onPressed: () => _mainState = MainState.BOLL),
        button("Ocultar", onPressed: () => _mainState = MainState.NONE),
        button("MACD", onPressed: () => _secondaryState = SecondaryState.MACD),
        button("KDJ", onPressed: () => _secondaryState = SecondaryState.KDJ),
        button("RSI", onPressed: () => _secondaryState = SecondaryState.RSI),
        button("WR", onPressed: () => _secondaryState = SecondaryState.WR),
        button("Ocultar vista lateral",
            onPressed: () => _secondaryState = SecondaryState.NONE),
        button(_volHidden ? "Mostrar volumen" : "Ocultar volumen",
            onPressed: () => _volHidden = !_volHidden),
        button("Cambiar entre chino e ingles",
            onPressed: () => isChinese = !isChinese),
      ],
    );
  }

  Widget button(String text, {VoidCallback onPressed}) {
    return FlatButton(
        onPressed: () {
          if (onPressed != null) {
            onPressed();
            setState(() {});
          }
        },
        child: Text("$text"),
        color: Colors.blue);
  }

  void getInfoCard() {
    AlphaVantageApi().quoteEndpoint(widget.symbol).then((value) {
      infoCard = InfoCard.fromJson(value['Global Quote']);
      setState(() {});
    }).catchError((e) {
      print(e.toString());
    });
  }

  void getData() {
    datas.clear();
    FMPApi()
        .getTecnicalIndicators(widget.symbol, time: selectedTime.name)
        .then((value) {
      value.forEach((e) {
        datas.add(KLineEntity.fromCustom(
          time: convertDateFromString(e['date']).millisecondsSinceEpoch,
          open: e['open'],
          high: e['high'],
          low: e['low'],
          close: e['close'],
          vol: e['volume'],
          amount: e['ema'],
          // change:
          //     (double.tryParse(value['5. adjusted close']) - old) / old * 100,
          // ratio: double.tryParse(value['8. split coefficient']),
        ));
      });
      datas = datas.reversed.toList().cast<KLineEntity>();

      DataUtil.calculate(datas);

      showLoading = false;
      setState(() {});
    }).catchError((_) {
      print("error");
      showLoading = false;
      setState(() {});
    });

    // AlphaVantageApi()
    //     .getDailyAdjusted(widget.symbol, outputsize: 'full')
    //     .then((value) {
    //   value['Time Series (Daily)'].forEach((key, value) {
    //     datas.add(KLineEntity.fromCustom(
    //       time: convertDateFromString(key).millisecondsSinceEpoch,
    //       open: double.tryParse(value['1. open']),
    //       high: double.tryParse(value['2. high']),
    //       low: double.tryParse(value['3. low']),
    //       close: double.tryParse(value['4. close']),
    //       vol: double.tryParse(value['6. volume']),
    //       amount: double.tryParse(value['7. dividend amount']),
    //       // change:
    //       //     (double.tryParse(value['5. adjusted close']) - old) / old * 100,
    //       // ratio: double.tryParse(value['8. split coefficient']),
    //     ));
    //   });
    //   datas = datas.reversed.toList().cast<KLineEntity>();

    //   MyDataUtil.calculate(datas);

    //   showLoading = false;
    //   setState(() {});
    // }).catchError((_) {
    //   //showLoading = false;
    //   setState(() {});
    //   print('error');
    // });

    // PolygonIo().getAggregates(widget.symbol).then((value) {
    //   datas = value['results']
    //       .map((item) => KLineEntity.fromCustom(
    //             time: item['t'],
    //             open: item['o'],
    //             high: item['h'],
    //             low: item['l'],
    //             close: item['c'],
    //             vol: item['v'],
    //             amount: item['vw'],
    //             change: item['vw'],
    //             ratio: item['vw'],
    //           ))
    //       .toList()
    //       .reversed
    //       .toList()
    //       .cast<KLineEntity>();

    //   DataUtil.calculate(datas);
    //   showLoading = false;
    //   setState(() {});
    // }).catchError((_) {
    //   showLoading = false;
    //   setState(() {});
    //   print('error');
    // });
  }
}

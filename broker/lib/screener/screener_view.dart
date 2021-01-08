import 'dart:async';

import 'package:broker/models/symbol_model.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class ScreenerView extends StatelessWidget {
  ScreenerView({Key key, this.listSymbol}) : super(key: key);
  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();

  final List<SymbolModel> listSymbol;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Card(
          elevation: 3.0,
          margin: const EdgeInsets.all(8.0),
          child: RoundedLoadingButton(
            child: Text('Compute data!', style: TextStyle(color: Colors.white)),
            controller: _btnController,
            onPressed: _doSomething,
          ),
        ),
      ),
    );
  }

  void _doSomething() async {
    print(listSymbol.length);
    // for (var i = 0; i < listSymbol.length - 99; i++) {
    //   print(listSymbol[i].name);
    //   final res = await AlphaVantageApi().getDIMinus(listSymbol[i].symbol);
    //   final res2 = await AlphaVantageApi().getDIPlus(listSymbol[i].symbol);
    //   print(res);
    //   print("----------------------------------");
    //   print(res2);
    // }

    // await AlphaVantageApi().getDIMinus(listSymbol.first.symbol);

    _btnController.success();
    Timer(Duration(seconds: 3), () {
      _btnController.reset();
    });
  }
}

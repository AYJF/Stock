import 'package:broker/service/fmp_api.dart';

import 'package:flutter/material.dart';
import 'package:json_table/json_table.dart';

class Details extends StatelessWidget {
  const Details({Key key, this.symbol}) : super(key: key);
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
      ),
      body: FutureBuilder<List<dynamic>>(
          future: FMPApi().getQuote(symbol),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              else {
                if (snapshot.data.isNotEmpty) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                        child: Center(
                            child: Card(
                                margin: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    JsonTable(
                                      snapshot.data,
                                      // showColumnToggle: true,
                                    ),
                                  ],
                                )))),
                  );
                } else
                  return Container(
                    child: Center(
                      child: Text("Empty data"),
                    ),
                  );
              }
            }
          }),
    );
  }
}

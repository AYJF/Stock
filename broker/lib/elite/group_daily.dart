import 'package:broker/elite/ttt.dart';
import 'package:broker/models/most_gainers.dart';
import 'package:broker/service/fmp_api.dart';

import 'package:broker/tools/gain_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Groupdaily extends StatelessWidget {
  const Groupdaily({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<MostGainersModel> _groupModel = [];
    final TextEditingController myController = TextEditingController();
    return Scaffold(
        appBar: AppBar(
          title: Text("Stock List"),
        ),
        body: FutureBuilder<List<dynamic>>(
            future: FMPApi().getMostGainers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                if (snapshot.hasError)
                  return Center(child: Text('Error: ${snapshot.error}'));
                else {
                  snapshot.data.forEach((element) {
                    _groupModel.add(MostGainersModel.fromJson(element));
                  });
                  return ChangeNotifierProvider(
                    create: (_) => ClientsListHnadler(_groupModel),
                    child: Consumer<ClientsListHnadler>(
                      builder: (_, value, __) {
                        return SingleChildScrollView(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
                                              controller: myController,
                                              decoration: InputDecoration(
                                                border: new OutlineInputBorder(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          25.0),
                                                  borderSide: new BorderSide(),
                                                ),
                                                // focusColor:
                                                //     Theme.of(context).primaryColor,
                                                labelText: "Find Client",
                                                // filled: true,
                                                // fillColor: Colors.white70,
                                                prefixIcon: Icon(
                                                  Icons.search,
                                                  color: Colors.white,
                                                ),
                                                // errorText: value.name.error,
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.red,
                                                      width: 1.0),
                                                ),
                                              ),
                                              onChanged: value.findClients,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Container(),
                                        )
                                      ],
                                    ),
                                    GainTable(value.clientsList),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                }
              }
            }));
  }
}

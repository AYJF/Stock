import 'package:broker/elite/find_symbol.dart';
import 'package:broker/elite/group_daily.dart';
import 'package:broker/elite/less_gain.dart';
import 'package:broker/elite/most_active.dart';
import 'package:broker/elite/sector_performance.dart';
import 'package:broker/info/info_view.dart';
import 'package:broker/models/symbol_model.dart';
import 'package:broker/screener/screener_view.dart';
import 'package:broker/service/fmp_api.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  HomeView({Key key}) : super(key: key);

  final TextEditingController myController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    List<SymbolModel> _symbolModel = [];
    return Scaffold(
      appBar: AppBar(
        title: Text("Stock List"),
        actions: [
          IconButton(
            tooltip: "Most Gainer",
            icon: Icon(
              Icons.arrow_circle_up,
              color: Colors.green,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Groupdaily()),
              );
            },
          ),
          IconButton(
            tooltip: "Most Loser",
            icon: Icon(
              Icons.arrow_circle_down,
              color: Colors.red,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MostLosser()),
              );
            },
          ),
          IconButton(
            tooltip: "Most Active",
            icon: Icon(
              Icons.group_add_outlined,
              color: Colors.deepPurple,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MostActive()),
              );
            },
          ),
          IconButton(
            tooltip: "Sector Performance",
            icon: Icon(
              Icons.settings_backup_restore,
              color: Colors.blue,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SectorPerformance()),
              );
            },
          ),
          IconButton(
            tooltip: "Idex",
            icon: Icon(
              Icons.image_aspect_ratio,
              color: Colors.deepOrange,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ScreenerView(
                          listSymbol: _symbolModel,
                        )),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: FMPApi().getNasdaq(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            else {
              snapshot.data.forEach((element) {
                _symbolModel.add(SymbolModel.fromJson(element));
              });

              return ChangeNotifierProvider(
                create: (_) => SymbolHandler(symbol: _symbolModel),
                child: Consumer<SymbolHandler>(
                  builder: (_, value, __) {
                    return SingleChildScrollView(
                      child: Container(
                        child: Center(
                          child: Column(
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
                                                new BorderRadius.circular(25.0),
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
                                                color: Colors.red, width: 1.0),
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
                              Container(
                                height: MediaQuery.of(context).size.height,
                                child: Scrollbar(
                                  child: ListView.builder(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: value.clientsList.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Card(
                                          elevation: 3.0,
                                          margin: const EdgeInsets.all(5.0),
                                          child: ListTile(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        InfoView(
                                                            name: value
                                                                .clientsList[
                                                                    index]
                                                                .name,
                                                            symbol:
                                                                value
                                                                    .clientsList[
                                                                        index]
                                                                    .symbol)),
                                              );
                                            },
                                            title: Text(
                                                value.clientsList[index].name),
                                            subtitle: Text(value
                                                .clientsList[index].symbol),
                                            trailing: Text(value
                                                .clientsList[index].sector),
                                          ),
                                        );
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          }
        },
      ),
    );
  }
}

import 'package:broker/elite/group_daily.dart';
import 'package:broker/elite/less_gain.dart';
import 'package:broker/elite/most_active.dart';
import 'package:broker/elite/sector_performance.dart';
import 'package:broker/info/info_view.dart';
import 'package:broker/service/fmp_api.dart';
import 'package:broker/service/polygon_io.dart';
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            onPressed: () async {
              // await FMPApi().getStockMarkerIndex();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: FMPApi().getStockList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            else {
              return Container(
                child: Center(
                  child: Scrollbar(
                    child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            elevation: 3.0,
                            margin: const EdgeInsets.all(5.0),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => InfoView(
                                          name: snapshot.data[index]['name'],
                                          symbol: snapshot.data[index]
                                              ['symbol'])),
                                );
                              },
                              title: Text(snapshot.data[index]['name']),
                              subtitle: Text(snapshot.data[index]['exchange']),
                              trailing: Text(
                                  snapshot.data[index]['price'].toString() ??
                                      ''),
                            ),
                          );
                        }),
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}

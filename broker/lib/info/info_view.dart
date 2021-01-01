import 'package:broker/news/news.dart';
import 'package:broker/service/polygon_io.dart';
import 'package:broker/widgets/chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class InfoView extends StatelessWidget {
  const InfoView({Key key, this.name, this.symbol}) : super(key: key);

  final String symbol;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Info'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.new_releases),
            label: 'Business',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stacked_line_chart),
            label: 'Trade',
          ),
        ],
        // currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (value) {
          switch (value) {
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => News(
                          symbol: symbol,
                        )),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chart(
                          title: name,
                          symbol: symbol,
                        )),
              );
              break;
            default:
          }
        },
      ),
      body: FutureProvider<Map<String, dynamic>>(
        create: (_) => PolygonIo().getTicketDetails(symbol),
        lazy: false,
        child: Consumer<Map<String, dynamic>>(
          builder: (_, value, __) {
            if (value == null) {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (value.isEmpty) {
              return Container(
                child: Center(
                  child: Text("404 Not Found"),
                ),
              );
            }

            return Container(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 3.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Image.network(
                                      value['logo'] ??
                                          'assets/images/nasdaq.png',
                                      fit: BoxFit.fitWidth,
                                    ),
                                    const VerticalDivider(
                                      color: Colors.white,
                                      width: 10,
                                      thickness: 5,
                                      indent: 20,
                                      endIndent: 0,
                                    ),
                                    Text(
                                      value['name'],
                                      style: GoogleFonts.staatliches(
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .headline4,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                color: Colors.white,
                                height: 10,
                                thickness: 2,
                                indent: 20,
                                endIndent: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  value['description'],
                                  textAlign: TextAlign.justify,
                                  style: GoogleFonts.openSansCondensed(
                                    textStyle:
                                        Theme.of(context).textTheme.headline5,
                                    fontSize: 18,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 3.0,
                          child: Column(
                            children: [
                              ...value.keys.map((e) {
                                if (e != 'name' &&
                                    e != 'logo' &&
                                    e != 'description' &&
                                    e != 'tags' &&
                                    e != 'similar')
                                  return Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          '$e:',
                                          style: GoogleFonts.openSansCondensed(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .headline5,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          value[e].toString() ?? '',
                                          style: GoogleFonts.openSansCondensed(
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .headline5,
                                            fontSize: 18,
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                else
                                  return Container();
                              }),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

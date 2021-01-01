import 'package:broker/info/info_view.dart';
import 'package:broker/service/polygon_io.dart';
import 'package:broker/tools/utils.dart';
import 'package:broker/widgets/chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class News extends StatelessWidget {
  const News({Key key, this.symbol}) : super(key: key);

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News'),
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
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InfoView(
                          symbol: symbol,
                        )),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chart(
                          symbol: symbol,
                        )),
              );
              break;
            default:
          }
        },
      ),
      body: FutureProvider<List<dynamic>>(
        create: (_) => PolygonIo().getTicketNews(symbol),
        lazy: false,
        child: Consumer<List<dynamic>>(
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

            // value.forEach((element) {
            //   print(element['url']);
            //   print(element['title']);
            // });

            return Container(
              child: Center(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        await launchURL(value[index]['url']);
                      },
                      child: Card(
                        elevation: 3.0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                value[index]['title'],
                                textAlign: TextAlign.justify,
                                style: GoogleFonts.staatliches(
                                  textStyle:
                                      Theme.of(context).textTheme.headline5,
                                  fontSize: 18,
                                ),
                              ),
                              const Divider(
                                color: Colors.white,
                                height: 10,
                                thickness: 2,
                                indent: 20,
                                endIndent: 20,
                              ),
                              Text(
                                value[index]['summary'],
                                textAlign: TextAlign.justify,
                                style: GoogleFonts.openSansCondensed(
                                  textStyle:
                                      Theme.of(context).textTheme.headline5,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                value[index]['source'],
                                textAlign: TextAlign.justify,
                                style: GoogleFonts.openSansCondensed(
                                  textStyle:
                                      Theme.of(context).textTheme.headline5,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                value[index]['timestamp'],
                                textAlign: TextAlign.justify,
                                style: GoogleFonts.openSansCondensed(
                                  textStyle:
                                      Theme.of(context).textTheme.headline5,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

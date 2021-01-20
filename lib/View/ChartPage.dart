import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mood/View/FavoritesPage.dart';
import 'package:web_scraper/web_scraper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChartPage extends StatefulWidget {
  ChartPage({Key key}) : super(key: key);

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {

  List<Map<String, dynamic>> _musicsChart = List();

  Future<List> _getMusicsChart() async {
    final webScraper = WebScraper("https://www.spotifycharts.com");
    if (await webScraper.loadWebPage("/regional")) {
      List<Map<String, dynamic>> musics = webScraper.getElement("td.chart-table-track > strong", []);
      List<Map<String, dynamic>> artists = webScraper.getElement("td.chart-table-track > span", []);
      List<Map<String, dynamic>> images = webScraper.getElement("td.chart-table-image > a > img", ["src"]);

      List<Map<String, dynamic>> data = List();

      for (int i = 0; i < musics.length; i++) {
        data.add({
          "title": musics[i]["title"],
          "artist": artists[i]["title"].substring(3, artists[i]["title"].length),
          "image": images[i]["attributes"]["src"]
        });
      }

      return data;
    }
  }
  
  Widget _widgetMusicChart() {
    return Container(
      child: FutureBuilder(
        initialData: null,
        future: _getMusicsChart(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          _musicsChart = snapshot.data;
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              /*return Column(
                children: _musicsChart.sublist(0, 4).map((music) => ListTile(
                  title: Text(music["title"]),
                  l
                )).toList()
              );*/
              return ListView.separated(
                shrinkWrap: true,
                itemCount: 4,
                itemBuilder: (context, i) {
                  return ListTile(
                    leading: Image.network(
                      _musicsChart[i]["image"],
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(_musicsChart[i]["title"], overflow: TextOverflow.ellipsis,),
                    subtitle: Text(_musicsChart[i]["artist"], overflow: TextOverflow.ellipsis,),
                    trailing: Text((i+1).toString(), style: TextStyle(
                      color: Colors.grey
                    ),),
                  );
                },
                separatorBuilder: (context, i) {
                  return Divider(
                    height: 1,
                    color: Colors.black,
                    endIndent: 30,
                    indent: 30,
                  );
                },
              );
            } else {
              return Center(
                child: Text("Sorry! will can't resolve data"),
              );
            }
          } else return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_build();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10,),
            ListTile(
              onTap: () => {},
              title: Text("Top musics", style: TextStyle(
                  fontSize: 25,
                  color: Theme.of(context).primaryColor
              ),),
              trailing: Icon(Icons.navigate_next, color: Theme.of(context).primaryColor,),
            ),
            _widgetMusicChart(),
            SizedBox(height: 10,),
            ListTile(
              onTap: () => {},
              title: Text("Recently listened", style: TextStyle(
                  fontSize: 25,
                  color: Theme.of(context).primaryColor
              ),),
              trailing: Icon(Icons.navigate_next, color: Theme.of(context).primaryColor,),
            ),
            SizedBox(height: 10,),
            ListTile(
              onTap: () => {},
              title: Text("Playlists", style: TextStyle(
                  fontSize: 25,
                  color: Theme.of(context).primaryColor
              ),),
              trailing: Icon(Icons.navigate_next, color: Theme.of(context).primaryColor,),
            ),
            Column(
              children: [
                ListTile(
                  onTap: () => Navigator.push(context, CupertinoPageRoute(
                      builder: (BuildContext context) {
                        return FavoritesPage();
                      }
                  )),
                  title: Text("Favorites"),
                  trailing: Icon(Icons.favorite),
                ),
                ListTile(
                  onTap: () => {},
                  title: Text("Offline"),
                  trailing: Icon(Icons.download_done_outlined),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
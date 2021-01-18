import 'package:flutter/material.dart';
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
              return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(
                children: _musicsChart.sublist(0, 4).map((music) => Container(
                  width: 130,
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Image.network(music["image"],
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(music["title"], overflow: TextOverflow.ellipsis, style: TextStyle(
                          fontSize: 18,
                        color: Colors.grey
                      ),),
                      Text(music["artist"], overflow: TextOverflow.ellipsis, style: TextStyle(
                        color: Colors.grey
                      ),)
                    ],
                  ),
                )).toList()
              ));
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
      body: Column(
        children: [
          SizedBox(height: 10,),
          ListTile(
            onTap: () => {},
            title: Text("Top musics", style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).primaryColor
            ),),
            trailing: Icon(Icons.navigate_next, color: Theme.of(context).primaryColor,),
          ),
          _widgetMusicChart(),
          SizedBox(height: 10,),
          ListTile(
            onTap: () => {},
            title: Text("Recently listen", style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).primaryColor
            ),),
            trailing: Icon(Icons.navigate_next, color: Theme.of(context).primaryColor,),
          ),
          SizedBox(height: 10,),
          ListTile(
            onTap: () => {},
            title: Text("Playlists", style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).primaryColor
            ),),
            trailing: Icon(Icons.navigate_next, color: Theme.of(context).primaryColor,),
          ),
          Column(
            children: [
              ListTile(
                onTap: () => {},
                title: Text("Favorites"),
                trailing: Icon(Icons.favorite),
              ),
              ListTile(
                onTap: () => {},
                title: Text("Recently added"),
                trailing: Icon(Icons.access_time),
              )
            ],
          )
        ],
      ),
    );
  }
}
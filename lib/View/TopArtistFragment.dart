
import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_scraper/web_scraper.dart';

class TopArtistFragment extends StatefulWidget {
  @override
  _TopArtistFragmentState createState() => _TopArtistFragmentState();
}

class _TopArtistFragmentState extends State<TopArtistFragment> {

  String _apiKey = "9edcee8c91128fea1e6ef3233beb1de8";
  List _data = null;

  Future<List> _topArtist() async {
    //dynamic request = await http.get("https://ws.audioscrobbler.com/2.0/?method=chart.gettopartists&api_key=${_apiKey}&format=json");
    final webScraper = WebScraper("https://www.last.fm");
    if (await webScraper.loadWebPage("/charts")) {
      List<Map<String, dynamic>> artist_name = webScraper.getElement("div.charts-col:last-child td.globalchart-name > a.link-block-target", []);
      print(artist_name);
    }
    /*if (request.statusCode == 200) {
      request = jsonDecode(request.body)["artists"]["artist"];
      return request;
    }*/
  }

  @override
  Widget build(BuildContext context) {
    _topArtist();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
        child: /*FutureBuilder(
          initialData: null,
          future: _topArtist(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                _data = snapshot.data;
                print(_data);
                return Row(
                  children: [
                    ...snapshot.data.sublist(0, 5).map((artist) => InkWell(
                      child: Container(
                        child: Column(
                          children: [
                            Image.network(artist["image"][2]["#text"],
                              fit: BoxFit.cover,
                              height: 60,
                              width: 60,
                            )
                          ],
                        ),
                      ),
                    ))
                        .toList()
                  ],
                );
              } else return Text("No data found");
            } else return CircularProgressIndicator();
          },
        ),*/Text("salut")
      );
  }
}
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mood/Components/AdvancedListItem.dart';
import 'package:mood/Components/ArtistsList.dart';
import 'package:mood/Components/CheckChipGroup.dart';
import 'package:mood/Model/AppModel.dart';
import 'package:mood/Style/Style.dart';
import 'package:mood/Components/CondensedCard.dart';
import 'package:http/http.dart' as http;
import 'package:mood/View/AlbumPage.dart';
import 'dart:convert';

import 'package:scoped_model/scoped_model.dart';

class SearchResultsPage extends StatefulWidget {
  String query;
  SearchResultsPage(this.query, {Key key}) : super(key: key);

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {

  List _songs = new List();
  List _artists = new List();
  List _albums = new List();
  String _lastSearch = "";

  int REQUEST_STATUS = 0;

  _search() async {
    try {
      final songsData = await http.get(
          "https://api.deezer.com/search/track/?q=${widget
              .query}&limit=5&output=json"
      );
      final artistsData = await http.get(
          "https://api.deezer.com/search/artist/?q=${widget
              .query}&limit=5&output=json"
      );
      final albumsData = await http.get(
          "https://api.deezer.com/search/album/?q=${widget
              .query}&limit=5&output=json"
      );

      if (songsData.statusCode == 200)
        _songs = jsonDecode(songsData.body)["data"];

      if (artistsData.statusCode == 200)
        _artists = jsonDecode(artistsData.body)["data"];

      if (albumsData.statusCode == 200)
        _albums = jsonDecode(albumsData.body)["data"];

      setState(() { REQUEST_STATUS = 1; });
    } on SocketException catch(e) {
      setState(() {
        REQUEST_STATUS = 2;
      });
    } catch(e) {print(e);}
  }

  Widget _showComponents () {
    return _songs.isNotEmpty || _artists.isNotEmpty || _albums.isNotEmpty ?
        SingleChildScrollView(scrollDirection: Axis.vertical, child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
              child: Column(
                children: [
                  SizedBox(height: 20,),
                  CheckChipGroup(
                    children: [
                      Chip(label: Text("All")),
                      Chip(label: Text("Artist")),
                      Chip(label: Text("Songs")),
                      Chip(label: Text("Album")),
                      Chip(label: Text("Playlist"))
                    ]
                  ),
                  SizedBox(height: 10),
                  Text("Results of ${widget.query}", style: Style.h1,),
                  SizedBox(height: 20,),
                  Column(
                    children: [
                      if (_artists.isNotEmpty)
                        CondensedCard(
                          title: "Artists",
                          child: ArtistsList(artists: _artists,),
                        ),
                      SizedBox(height: 10,),
                      if (_songs.isNotEmpty)
                        CondensedCard(
                          title: "Songs",
                          child: ScopedModelDescendant<AppModel>(
                            builder: (context, child, model) {
                              return Column(
                                  children: _songs.sublist(0, _songs.length > 4 ? 4 : _songs.length)
                                      .map((song) => ListTileTheme(
                                    selectedColor: Theme.of(context).accentColor,
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
                                        child: Image.network(
                                          song["album"]["cover_medium"],
                                          height: 60,
                                          width: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      title: Text(
                                        song["title"],
                                        style: TextStyle(fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      selected: model.trackInfo != null ? model.trackInfo["id"] == song["id"] : false,
                                      subtitle: Text(song["artist"]["name"]),
                                      onTap: () => model.play(
                                          track: song,
                                          album: {
                                            "title": song["album"]["title"],
                                            "cover": song["album"]["cover_medium"],
                                          }),
                                      trailing: FittedBox(
                                        fit: BoxFit.fill,
                                        child: Row(
                                          children: <Widget>[
                                            IconButton(
                                              onPressed: () => {},
                                              icon: Icon(Icons.favorite_border),
                                            ),
                                            IconButton(
                                              onPressed: () => {},
                                              icon: Icon(Icons.more_vert),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )).toList()
                              );
                            },
                          ),
                        ),
                      SizedBox(height: 10,),
                      if (_albums.isNotEmpty)
                        CondensedCard(
                          title: "Albums",
                          child: Column(
                              children: _albums.sublist(0, _albums.length > 4 ? 4 : _albums.length)
                                  .map((album) =>  ListTile(
                                onTap: () => Navigator.push(context, CupertinoPageRoute(
                                    builder: (BuildContext context) {
                                      return AlbumPage(album["id"],
                                        album: [album["title"], album["cover_medium"]],
                                        artist: album["artist"]["name"],
                                      );
                                    }
                                )),
                                    title: Text(
                                      album["title"],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(album["artist"]["name"]),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: Image.network(
                                        album["cover_medium"],
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                              )).toList()
                          ),
                        ),
                      SizedBox(height: 80,),
                    ],
                  )
                ],
              ),
            )
        ))
        :
        Center(
          child: CircularProgressIndicator(),
        );
  }

  _noInternet () {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("No internet connection.", style: Style.paragraph,),
          SizedBox(height: 10,),
          FlatButton(
            onPressed: () {
              setState(() {
                REQUEST_STATUS = 0;
                _search();
              });
            },
            child: Text("Retry", style: Style.paragraph,),
            color: Colors.black12,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)
            ),
          ),
        ],
      ),
    );
  }

  Widget _init () {
    if (_lastSearch != widget.query)
      setState(() {
        _lastSearch = widget.query;
        REQUEST_STATUS = 0;
        _search();
      });

    switch(REQUEST_STATUS) {
      case 0: return Center(child: CircularProgressIndicator(),);
      break;
      case 1: return _showComponents();
      break;
      case 2: return _noInternet();
      break;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _search();
  }

  @override
  Widget build(BuildContext context) {
    return _init();
  }
}
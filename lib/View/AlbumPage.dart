import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mood/Components/FloatingController.dart';
import 'package:mood/Scripts/FavoriteDB.dart';
import 'package:mood/Scripts/FavoriteModel.dart';
import 'dart:convert';

import 'package:scoped_model/scoped_model.dart';

import 'package:mood/Model/AppModel.dart';

class AlbumPage extends StatefulWidget {
  int id;
  List album;
  String artist;
  String name;

  AlbumPage(this.id, {Key key, this.album, this.artist, this.name}) : super(key: key);

  @override
  _AlbumPageState createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {

  Map _favorites;
  
  Future<List> _getAlbumTracklist() async {
    final request = await http.get("https://api.deezer.com/album/${widget.id}/tracks");

    if (request.statusCode == 200) {
      FavoriteDB favoriteDB = FavoriteDB();
      await favoriteDB.init();
      _favorites = await favoriteDB.favorites();
      return jsonDecode(request.body)["data"];
    }
  }

  _onTrackTapped(track) async {
    ScopedModel.of<AppModel>(context).play(
        track: track,
        album: {
          "title": widget.album[0],
          "cover": widget.album[1]
        }
    );
  }

  _addToFavorite(track) async {
    FavoriteDB favoriteDB = FavoriteDB();
    await favoriteDB.init();
    favoriteDB.insertFavorite(Favorite(
      key: track["id"],
      album: widget.album[0],
      title: track["title"],
      artist: track["artist"]["name"],
      cover: widget.album[1]
    )).then((value) {
      setState(() {
        /*_favorites.addAll({track["id"]: {
          "key": track["id"],
          "album": widget.album[0],
          "title": track["title"],
          "artist": track["artist"]["name"],
          "cover": widget.album[1]
        }});*/
      });
    });
  }

  _removeToFavorite(track) async {
    FavoriteDB favoriteDB = FavoriteDB();
    await favoriteDB.init();
    favoriteDB.deleteFavorite(track["id"]).then((value) {
      setState(() {});
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingController(),
      appBar: AppBar(
        title: Text("${widget.artist} - ${widget.album[0]}", style: TextStyle(
          color: Colors.black,
          fontSize: 16
        )),
        actions: [
          MaterialButton(
            minWidth: 55,
            height: 55,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)
            ),
            color: Theme.of(context).primaryColor,
            child: Icon(Icons.play_arrow_outlined, color: Colors.white,),
            onPressed: () => {},
          ),
          IconButton(
              icon: Icon(Icons.favorite_border),
              onPressed: () => {}
          ),
          IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => {}
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 60),
        child: FutureBuilder(
          initialData: null,
          future: _getAlbumTracklist(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                return ScopedModelDescendant<AppModel>(
                  builder: (context, child, model) {
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTileTheme(
                          selectedColor: Theme.of(context).accentColor,
                          child: ListTile(
                            selected: model.trackInfo != null ? model.trackInfo["id"] == snapshot.data[index]["id"] : false,
                            onTap: () => _onTrackTapped(snapshot.data[index]),
                            title: Text(snapshot.data[index]["title"], overflow: TextOverflow.ellipsis,),
                            trailing: FittedBox(
                              fit: BoxFit.fill,
                              child: Row(
                                children: <Widget>[
                                  _favorites.keys.contains(snapshot.data[index]["id"]) ?
                                  IconButton(
                                    onPressed: () => _removeToFavorite(snapshot.data[index]),
                                    icon: Icon(Icons.favorite, color: Theme.of(context).accentColor,),
                                  ) :
                                  IconButton(
                                    onPressed: () => _addToFavorite(snapshot.data[index]),
                                    icon: Icon(Icons.favorite_border),
                                  ),
                                  IconButton(
                                    onPressed: () => {
                                      showModalBottomSheet<void>(
                                          context: context,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(top: Radius.circular(10),)
                                          ),
                                          isScrollControlled: true,
                                          builder: (BuildContext context) {
                                            return Wrap(
                                                children: [
                                                  ListTile(
                                                    title: Text("Add to favorites"),
                                                  ),
                                                  ListTile(
                                                    title: Text("Add to a playlist"),
                                                  ),
                                                  ListTile(
                                                    title: Text("Report"),
                                                  ),
                                                ]
                                            );
                                          }
                                      )
                                    },
                                    icon: Icon(Icons.more_vert),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                );
              } else {
                return Center(child: Text("No data found"));
              }
            } else {
              return Center(child: CircularProgressIndicator(),);
            }
          },
        ),
      )
    );
  }
}
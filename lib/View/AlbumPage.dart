import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mood/Components/FloatingController.dart';
import 'package:mood/Helpers/FavoriteDB.dart';
import 'package:mood/Helpers/FavoriteModel.dart';
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

  ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  
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
        _favorites.addAll({track["id"]: {
          "key": track["id"],
          "album": widget.album[0],
          "title": track["title"],
          "artist": track["artist"]["name"],
          "cover": widget.album[1]
        }});
      });
    });
  }

  _removeToFavorite(track) async {
    FavoriteDB favoriteDB = FavoriteDB();
    await favoriteDB.init();
    favoriteDB.deleteFavorite(track["id"]).then((value) {
      setState(() {
        _favorites.remove(track["id"]);
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  _onStartScroll(ScrollMetrics metrics) {
    setState(() {
    });
  }
  _onUpdateScroll(ScrollMetrics metrics) {
    setState(() {
      _scrollOffset = _scrollController.offset.clamp(0.0, 100.0).toDouble();
    });
  }
  _onEndScroll(ScrollMetrics metrics) {
    setState(() {
      if (_scrollOffset < 50) {
        Future.delayed(Duration(milliseconds: 1), () {
          _scrollController.animateTo(0, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
        });
      } else if (_scrollOffset > 50 && _scrollOffset < 100) {
        Future.delayed(Duration(milliseconds: 1), () {
          _scrollController.animateTo(100, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingController(),
      backgroundColor: Color.fromRGBO(245, 245, 245, 1),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(250 - (_scrollOffset + (50 * (_scrollOffset / 100)))),
        child: Container(
          height: 250 - (_scrollOffset + (50 * (_scrollOffset / 100))),
          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Stack(
            children: [
              Positioned(
                top: 0 + (_scrollOffset/(100/17)),
                child: Container(
                  child: IconButton(
                    onPressed: () => { Navigator.pop(context) },
                    icon: Icon(Icons.arrow_back),
                  ),
                ),
              ),
              Positioned(
                top: 50 - (_scrollOffset/(100/20)),
                left: 20 + ((_scrollOffset/(100/20))),
                child: Container(
                  child: Text(
                    "${widget.artist} - ${widget.album[0]}",
                    style: TextStyle(
                      fontSize: 25 - (_scrollOffset/15),
                      color: Colors.black54
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: _scrollOffset < 50 ? 2 : 1,
                    textAlign: TextAlign.center,
                  ),
                  width: MediaQuery.of(context).size.width - (40 + (_scrollOffset/(100/140))),
                ),
              ),
              Positioned(
                top: 160 - (_scrollOffset/(100/145)),
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        icon: Icon(Icons.shuffle),
                        color: Colors.black54,
                        onPressed: () => {}
                    ),
                    MaterialButton(
                      minWidth: 55,
                      height: 55,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)
                      ),
                      color: Theme.of(context).accentColor,
                      child: Icon(Icons.play_arrow_outlined, color: Colors.white,),
                      onPressed: () => {},
                    ),
                    IconButton(
                        icon: Icon(Icons.more_vert),
                        color: Colors.black54,
                        onPressed: () => {}
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
        ),
        child: FutureBuilder(
          initialData: null,
          future: _getAlbumTracklist(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                return ScopedModelDescendant<AppModel>(
                  builder: (context, child, model) {
                    return NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        if (scrollNotification is ScrollStartNotification) {
                          _onStartScroll(scrollNotification.metrics);
                        } else if (scrollNotification is ScrollUpdateNotification) {
                          _onUpdateScroll(scrollNotification.metrics);
                        } else if (scrollNotification is ScrollEndNotification) {
                          _onEndScroll(scrollNotification.metrics);
                        }
                        return true;
                      },
                      child: ListView.builder(
                        controller: _scrollController,
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
                      ),
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
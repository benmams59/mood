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
  int _length = null;
  
  Future<List> _getAlbumTracklist() async {
    final request = await http.get("https://api.deezer.com/album/${widget.id}/tracks");

    if (request.statusCode == 200) {
      FavoriteDB favoriteDB = FavoriteDB();
      await favoriteDB.init();
      _favorites = await favoriteDB.favorites();
      setState(() {_length = jsonDecode(request.body)["data"].length;});
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

  Widget _TrackItem(data, model) {
    return ListTileTheme(
      selectedColor: Theme.of(context).accentColor,
      child: ListTile(
        selected: model.trackInfo != null ? model.trackInfo["id"] == data["id"] : false,
        onTap: () => _onTrackTapped(data),
        title: Text(data["title"], overflow: TextOverflow.ellipsis,),
        trailing: FittedBox(
          fit: BoxFit.fill,
          child: Row(
            children: <Widget>[
              _favorites.keys.contains(data["id"]) ?
              IconButton(
                onPressed: () => _removeToFavorite(data),
                icon: Icon(Icons.favorite, color: Theme.of(context).accentColor,),
              ) :
              IconButton(
                onPressed: () => _addToFavorite(data),
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
                                onTap: () {
                                  if (_favorites.keys.contains(data["id"]))
                                    _removeToFavorite(data);
                                  else _addToFavorite(data);
                                  Navigator.pop(context);
                                },
                                title: Text("${_favorites.keys.contains(data["id"]) ? "Remove" : "Add"} to favorites"),
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
            fit: StackFit.loose,
            children: [
              SingleChildScrollView(
                child: Opacity(
                  opacity: 1 - (_scrollOffset/100),
                  child: Container(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    decoration: BoxDecoration(),
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 50),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            widget.album[1],
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 20,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 180,
                              child: Text(
                                widget.artist,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            SizedBox(height: 5),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 180,
                              child: Text(
                                widget.album[0],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            SizedBox(height: 5),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 180,
                              child: Text(
                                "${_length == null ? "-" : _length.toString()} titles",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => { Navigator.pop(context) },
                      icon: Icon(Icons.arrow_back),
                    ),
                    Opacity(
                      opacity: 0 + (_scrollOffset/100),
                      child: Container(
                        child: Text(
                          "${widget.artist} - ${widget.album[0]}",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black54
                          ),
                        ),
                        width: MediaQuery.of(context).size.width - 200,
                      ),
                    ),
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
      body: FutureBuilder(
        initialData: null,
        future: _getAlbumTracklist(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              return ScopedModelDescendant<AppModel>(
                  builder: (context, child, model) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        //borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        border: Border(top: BorderSide(color: Colors.black12, width: 1, style: BorderStyle.solid))
                      ),
                      child: NotificationListener<ScrollNotification>(
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
                            if (snapshot.data.length-1 == index) {
                              return Column(
                                children: [
                                  _TrackItem(snapshot.data[index], model),
                                  SizedBox(height: 100,)
                                ],
                              );
                            } else
                              return _TrackItem(snapshot.data[index], model);
                          },
                        ),
                      ),
                    );
                  }
              );
            } else {
              return Center(child: Text("No data found"));
            }
          } else {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(
                  color: Colors.black12,
                  style: BorderStyle.solid,
                  width: 1
                ))
              ),
              child: Center(child: CircularProgressIndicator(),
            ),);
          }
        },
      )
    );
  }
}
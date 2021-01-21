import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mood/Helpers/FavoriteDB.dart';

class FavoritesPage extends StatefulWidget {
  FavoritesPage({Key key}) : super(key: key);

  @override
  FavoritesPageState createState() => FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage> {

  Map _favorites;
  ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  Future<Map> _getFavorites() async {
    FavoriteDB favoriteDB = FavoriteDB();
    await favoriteDB.init();
    _favorites = await favoriteDB.favorites();
    return _favorites;
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
    /*_scrollController.addListener(() {
      setState(() {

      });
    });*/

    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 245, 245, 1),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(200.0 - _scrollOffset - (_scrollOffset/(100/20))),
        child: Container(
          child: Stack(
            children: [
              Opacity(
                opacity: 1 - (_scrollOffset/100),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                      "Favorites",
                      style: TextStyle(
                          fontSize: 40,
                          color: Colors.black54
                      )
                  ),
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.arrow_back_rounded),
                        color: Colors.black54,
                        onPressed: () => { Navigator.pop(context) }
                    ),
                    Opacity(
                      opacity: (_scrollOffset/100),
                      child: Text("Favorites", style: TextStyle(
                          color: Colors.black54,
                          fontSize: 20
                      ),),
                    ),
                    Spacer(flex: 1,),
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
        future: _getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              return Container(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(
                      color: Colors.black12,
                      style: BorderStyle.solid,
                      width: 1
                    ))
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
                    child: ReorderableListView(
                      scrollController: _scrollController,
                      onReorder: (index, pos) => {},
                      children: _favorites.values.toList().reversed.map((favorite) => ListTile(
                        key: Key(favorite["id"].toString()),
                        title: Text(favorite["title"]),
                        subtitle: Text(favorite["artist"]),
                        trailing: IconButton(
                            icon: Icon(Icons.more_vert)
                        ),
                      )).toList(),
                    ),
                  )
              );
            } else {
              return Center(
                child: Text("You have no favorite"),
              );
            }
          } else return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";

import 'AlbumPage.dart';

class DiscographiePage extends StatefulWidget {
  Map data;
  dynamic artist;
  DiscographiePage(this.data, {Key key, this.artist}) : super(key: key);

  @override
  _DiscographiePageState createState() => _DiscographiePageState();
}

class _DiscographiePageState extends State<DiscographiePage> {
  @override
  Widget build(BuildContext context) {
    print(widget.data);
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.artist} - Disco",
          style: TextStyle(
            color: Colors.black54
          ),
        ),
      ),
      body: ListView(
        children: widget.data.keys.map((album) => ListTile(
          onTap: () => {
            Navigator.push(context, CupertinoPageRoute(
                builder: (BuildContext context) {
                  return AlbumPage(widget.data[album][0],
                    album: widget.data[album][1],
                    artist: widget.artist,
                    name: album,
                  );
                }
            ))
          },
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              widget.data[album][1][1],
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            album,
            overflow: TextOverflow.ellipsis,
          ),
        )).toList(),
      ),
    );
  }
}
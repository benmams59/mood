import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mood/Style/Style.dart';
import 'package:mood/View/ArtistPage.dart';

class ArtistsList extends StatelessWidget {
  List artists;
  ArtistsList({Key key, this.artists}) : super(key: key);

  _showModalOf(BuildContext context, dynamic artist) {
    Navigator.push(context, CupertinoPageRoute(
      builder: (BuildContext context) {
        return ArtistPage(artist: artist);
      }
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: artists
                .sublist(0, artists.length > 4 ? 4 : artists.length)
                .map((artist) => Container(padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10), child: InkWell(
                      onTap: () => _showModalOf(context, artist),
                      borderRadius: BorderRadius.circular(10),
                      child: Column(
                        children: [
                          Container(
                            child: Hero(
                                tag: "artist${artist["id"]}",
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                      artist["picture_medium"].toString(),
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover
                                  ),
                                )
                            )
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            artist["name"].toString().length > 11
                                ? "${artist["name"].toString().substring(0, 11)}..."
                                : artist["name"].toString(),
                            style: Style.paragraph,
                          )
                        ],
                      ),
                    )))
                .toList()));
  }
}

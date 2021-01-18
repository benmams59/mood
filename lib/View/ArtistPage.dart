import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:mood/Components/FloatingController.dart';
import 'dart:convert';

import 'package:mood/Style/Style.dart';
import 'package:mood/View/AlbumPage.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:mood/Model/MoodModel.dart';

class ArtistPage extends StatefulWidget {
  dynamic artist;
  ArtistPage({Key key, this.artist}) : super(key: key);

  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {

  Map<dynamic, dynamic> _data = Map();
  
  _build() async {
    dynamic request = await http.get(widget.artist["tracklist"]);

    if (request.statusCode == 200) {
      request = jsonDecode(request.body)["data"];
      print(widget.artist["tracklist"]);
      for (int i = 0; i < request.length; i++) {
        if (!_data.keys.contains(request[i]["album"]["title"])) {
          _data[request[i]["album"]["title"]] =
          [request[i]["album"]["id"], [request[i]["album"]["title"], request[i]["album"]["cover_medium"]]];
        }
      }
    }
    //print(_data);

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _build();
  }

  void _showModal(BuildContext context) {
    showBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return FloatingController();
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingController(),
      appBar: AppBar(
        title: Opacity(
          opacity: 0,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  widget.artist["picture_medium"],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 10,),
              Text(
                widget.artist["name"],
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18
                ),
              )
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20,),
            Center(
              child: Column(
                children: [
                  Hero(
                    tag: "artist${widget.artist["id"]}",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        widget.artist["picture_medium"],
                        height: 180,
                        width: 180,
                        fit: BoxFit.cover,
                      ),
                    )
                  ),
                  SizedBox(height: 10,),
                  Text(
                    "${widget.artist["name"]}",
                    style: TextStyle(
                        fontSize: 24
                    ),
                  ),
                  Text(
                    "${widget.artist["nb_fan"]} followers",
                    style: TextStyle(
                        fontSize: 12,
                      color: Colors.grey
                    ),
                  ),
                ],
              )
            ),
            SizedBox(height: 40,),
            Container(
              height: 60,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Container(height: 25,),
                      Container(
                        height: 35,
                        color: Colors.white,
                      )
                    ],
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 20,),
                        MaterialButton(
                          minWidth: 55,
                          height: 55,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)
                          ),
                          color: Colors.white,
                          child: Icon(Icons.shuffle, color: Theme.of(context).accentColor,),
                          onPressed: () => {},
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.favorite_border),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.ios_share),
                        ),
                        Spacer(flex: 1,),
                        IconButton(
                          icon: Icon(Icons.more_vert),
                        ),
                        SizedBox(width: 20,),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10,),
                  ListTile(
                    onTap: () => {},
                    title: Text(
                      "Discographie",
                      style: TextStyle(
                          fontSize: 22
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: _data.isNotEmpty ? Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 5,
                      runSpacing: 5,
                      children: _data.keys.toList().sublist(0, _data.length > 5 ? 5 : _data.length).map((element) =>  InkWell(
                        onTap: () => {
                          Navigator.push(context, CupertinoPageRoute(
                              builder: (BuildContext context) {
                                return AlbumPage(_data[element][0],
                                  album: _data[element][1],
                                  artist: widget.artist["name"],
                                  name: element,
                                );
                              }
                          ))
                        },
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8)
                          ),
                          width: 120,
                          height: 120,
                          child: Stack(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: _data[element][1][1] is String ? Image.network(
                                  _data[element][1][1],
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ) : Container(),
                              ),
                              Container(
                                width: 120,
                                height: 120,
                                alignment: Alignment.bottomLeft,
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(0, 0, 0, 0.2),
                                    borderRadius: BorderRadius.circular(4)
                                ),
                                child: Text(
                                  element,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                        ),
                      )).toList(),
                    ) : Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  SizedBox(height: 80,)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
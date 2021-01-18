import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Favorite {
  final int id;
  final int key;
  final String title;
  final String artist;
  final String album;
  final String cover;

  Favorite({this.id, this.key, this.title, this.artist, this.album, this.cover});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "key": key,
      "title": title,
      "artist": artist,
      "album": album,
      "cover": cover
    };
  }
}
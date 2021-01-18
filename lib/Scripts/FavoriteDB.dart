import "dart:async";

import 'package:mood/Scripts/FavoriteModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FavoriteDB {
  Future<Database> _db;

  Future<void> init() async {
    _db = openDatabase(
        join(await getDatabasesPath(), "m_data.db"),
        onCreate: (db, version) {
          return db.execute(
            "CREATE TABLE favorite(id INTEGER PRIMARY KEY, key INTEGER, title TEXT, artist TEXT, album TEXT, cover TEXT)"
          );
        },
        version: 1
    );
  }

  Future<void> insertFavorite(Favorite favorite) async {
    final Database db = await _db;

    await db.insert('favorite', favorite.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map> favorites() async {
    final Database db = await _db;

    final List<Map<String, dynamic>> maps = await db.query('favorite');
    Map newMaps = Map();
    for (int i = 0; i < maps.length; i++) {
      newMaps.addAll({maps[i]["key"]: maps[i]});
    }
    print(newMaps);
    return newMaps;

    /*return List.generate(maps.length, (i) {
      return Favorite (
        id: maps[i]["id"],
        key: maps[i]["key"],
        title: maps[i]["title"],
        artist: maps[i]["artist"],
        album: maps[i]["album"],
        cover: maps[i]["cover"]
      ).toMap();
    })*/;
  }

  Future<void> updateFavorite(Favorite favorite) async {
    final db = await _db;

    await db.update(
      "favorite",
      favorite.toMap(),
      where: "id = ?",
      whereArgs: [favorite.id]
    );
  }

  Future<void> deleteFavorite(int key) async {
    // Get a reference to the database.
    final db = await _db;

    // Remove the Dog from the Database.
    await db.delete(
      'favorite',
      // Use a `where` clause to delete a specific dog.
      where: "key = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [key],
    );
  }

}
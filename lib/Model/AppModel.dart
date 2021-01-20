import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:mood/Helpers/FavoriteDB.dart';
import 'package:mood/Helpers/FavoriteModel.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

enum StateOf {
  None,
  Charging,
  Playing,
  Paused,
}

class AppModel extends Model {

  AssetsAudioPlayer get _audioPlayer => AssetsAudioPlayer.withId("audioPlayer");
  YoutubeExplode _yt = YoutubeExplode();

  int _trackId;
  dynamic _trackInfo;
  bool _initialized = false;
  StateOf state = StateOf.None;
  FavoriteDB favoriteDB = FavoriteDB();
  List<Favorite> favorites = List();


  initFavoriteDB() async {
    await favoriteDB.init();
  }

  // Getters
  int get trackId => _trackId;
  dynamic get trackInfo => _trackInfo;
  AssetsAudioPlayer get player => _audioPlayer;

  void setTrackInfo(dynamic information) {
    _trackId = information["id"];
    _trackInfo = information;
    notifyListeners();
  }

  Future<String> resolveFromYoutube(String query) async {
    String url;
    await _yt.search.getVideos(query).elementAt(0).then((value) =>
        _yt.videos.streamsClient.getManifest(value.id).then((value) =>
            url = value.audio.first.url.toString()
        )
    );
    return url;
  }

  Future<void> setPlay({track, Map<String, dynamic> album}) {
    String query = "${track["artist"]["name"]} - ${track["title"]}";
    Map<String, dynamic> information = {
      "id": track["id"],
      "title": track["title"],
      "artist": track["artist"]["name"],
      "album": album == null ? track["album"]["title"] : album["title"],
      "cover": album == null ? track["album"]["cover_medium"] : album["cover"],
      "duration": Duration(seconds: 0)
    };
    try {
      state = StateOf.Charging;
      setTrackInfo(information);
      resolveFromYoutube(query).then((value) => _audioPlayer.open(
        Audio.network(
            value,
          metas: Metas(
            album: information["album"],
            artist: information["artist"],
            title: information["title"],
            image: MetasImage.network(information["cover"])
          )
        ),
        autoStart: true,
        showNotification: true,
      ).then((value) {
        _audioPlayer.playlistAudioFinished.listen((playable) {
          notifyListeners();
        });
        state = StateOf.Playing;
        information["duration"] = _audioPlayer.current.value.audio.duration;
        notifyListeners();
      }));
    } catch(e) {
      print(e);
      state = StateOf.None;
      notifyListeners();
    }
  }

  void play({track, Map<String, dynamic>album}) {
    setPlay(track: track, album: album);
    /*if (_trackInfo != null && _trackInfo["id"] == track["id"]) {
      _audioPlayer.playOrPause().then((value) { notifyListeners(); });
    } else if(track != null) {
      setPlay(track: track, album: album);
    } else _audioPlayer.playOrPause().then((value) { notifyListeners(); });*/
  }

  void audioPlayerOrPause() {
    state = _audioPlayer.playerState.value == PlayerState.play ? StateOf.Playing : StateOf.Paused;
    _audioPlayer.playOrPause().then((value) { notifyListeners(); });
  }

  void audioSeek(Duration d) {
    _audioPlayer.seek(d);
    notifyListeners();
  }
}
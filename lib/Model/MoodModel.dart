/*import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MoodModel extends Model {
  int _playerID;
  bool _playerInitialized = false;
  FlutterSoundPlayer _player;
  YoutubeExplode _yt = YoutubeExplode();
  List _album;
  Uri _source;
  dynamic _songInfos;
  Duration _duration = Duration.zero;

  AssetsAudioPlayer get _audioPlayer => AssetsAudioPlayer.withId("music");

  MoodModel() {
    _player = FlutterSoundPlayer();
  }

  int get playerID => _playerID;
  bool get initialized => _playerInitialized;
  FlutterSoundPlayer get player => _player;
  dynamic get songInfos => _songInfos;
  List get album => _album;
  AssetsAudioPlayer get audioPlayer => _audioPlayer;
  Duration get duration => _duration;

  void setFingerPrints(int id, dynamic songInfos, List album) {
    _playerID = id;
    _songInfos = songInfos;
    _album = album;
    _duration = _audioPlayer.current.value.audio.duration;
  }

  void startPlay(element, album) async {
    String query = "${element["artist"]["name"]} - ${element["title"]}";
    try {
        await _yt.search.getVideos(query).elementAt(0).then((value) {
          _yt.videos.streamsClient.getManifest(value.id).then((value) {
            _audioPlayer.open(
              Audio.network(
                  value.audio.first.url.toString(),
                  metas: Metas(
                    title: element["title"],
                    artist: element["artist"]["name"],
                    album: album[0],
                    image: MetasImage.network(album[1])
                  )
              ),
              autoStart: true,
              showNotification: true,
            ).then((value) {
              setFingerPrints(
                  element["id"],
                  element,
                  album
              );
              notifyListeners();
            });
          });
        });
    } catch (e) {
      print(e);
    }
  }

  void play(element, album) async {
   /* if(_player.isPlaying) {
      if (_playerID == element["id"]) {
        await _player.pausePlayer().then((value) { notifyListeners(); });
      } else {
        await _player.stopPlayer().then((value) {
          startPlay(element, album);
        });
      }
    } else if (_player.isPaused) {
      if (_playerID == element["id"]) {
        await _player.resumePlayer().then((value) { notifyListeners(); });
      } else {
        await _player.stopPlayer().then((value) {
          startPlay(element, _album);
        });
      }
    } else startPlay(element, album);*/
    if (_playerID == element["id"]) {
      await _audioPlayer.playOrPause().then((value) { notifyListeners(); });
    } else {
      startPlay(element, album);
    }
  }

  void playOrPause() async {
    await _audioPlayer.playOrPause().then((value) {
      notifyListeners();
    });
  }

  void resume() async {
    await _player.resumePlayer().then((value) { notifyListeners(); });
  }

  void pause() async {
    await _player.pausePlayer().then((value) { notifyListeners(); });
  }

  void replay() async {
    await _player.pausePlayer().then((value) { notifyListeners(); });
  }

  void update() {
    notifyListeners();
  }
}*/
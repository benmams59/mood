import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:mood/Model/AppModel.dart';
import 'package:mood/Style/Style.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

class AdvancedController extends StatefulWidget {
  AdvancedController({Key key}) : super(key: key);

  @override
  _AdvancedControllerState createState() => _AdvancedControllerState();
}

class _AdvancedControllerState extends State<AdvancedController> {

  bool _play;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  formatDuration (Duration d) {
    String tdigits(int n) => n.toString().padLeft(2, "0");
    return "${tdigits(d.inMinutes.remainder(60))}:"
        "${tdigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          height: MediaQuery.of(context).size.height,
          child: ScopedModelDescendant<AppModel>(
            builder: (context, child, model) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40,),
                  Container(
                    height: 4,
                    width: 30,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(20)
                    ),
                  ),
                  Spacer(flex: 1,),
                  Container(
                    height: 300,
                    width: 300,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 32,
                              color: Colors.black45
                          )
                        ]
                    ),
                    child: model.trackInfo != null ? Image.network(
                      model.trackInfo["cover"],
                      width: 300,
                      height: 300,
                      fit: BoxFit.cover,
                    ) : Container(),
                  ),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      IconButton(icon: Icon(Icons.ios_share)),
                      Spacer(flex: 1,),
                      IconButton(icon: Icon(Icons.favorite_border)),
                      Spacer(flex: 1),
                      IconButton(icon: Icon(Icons.more_vert)),
                    ],
                  ),
                  SizedBox(height: 20,),
                  if (model.trackInfo != null)
                    Column(
                      children: [
                        Text(model.trackInfo["title"],
                          style: TextStyle(
                              fontSize: 18
                          ), overflow: TextOverflow.ellipsis,),
                        SizedBox(height: 10,),
                        Text(
                            "${model.trackInfo["artist"]} - "
                                "${model.trackInfo["album"]}",
                            style: Style.paragraph,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    )
                  else Text("-"),
                  SizedBox(height: 20),
                  model.player.builderCurrentPosition(
                      builder: (context, duration) {
                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderThemeData(
                                  thumbColor: Theme.of(context).accentColor,
                                  activeTrackColor: Theme.of(context).accentColor,
                                  inactiveTrackColor: Colors.black12,
                                  trackHeight: 2,
                                  thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: 8
                                  )
                              ),
                              child: Slider(
                                  value: duration.inSeconds.toDouble(),
                                  min: 0,
                                  max: model.trackInfo["duration"].inSeconds.toDouble(),
                                  onChanged: (d) => {model.audioSeek(Duration(seconds: d.toInt()))}),
                            ),
                            Row(
                              children: [
                                SizedBox(width: 20),
                                Text(
                                    formatDuration(duration)
                                ),
                                Spacer(flex: 1,),
                                Text(
                                    formatDuration(model.trackInfo["duration"])
                                ),
                                SizedBox(width: 20),
                              ],
                            )
                          ],
                        );
                      }
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                            model.player.loopMode.value == LoopMode.none ?
                            Icons.repeat : Icons.repeat_one
                        ),
                        onPressed: () {
                          if (model.player.loopMode.value == LoopMode.single)
                            model.player.setLoopMode(LoopMode.none);
                          else model.player.setLoopMode(LoopMode.single);
                          //widget.model.update();
                        },
                      ),
                      Spacer(flex: 1),
                      IconButton(icon: Icon(Icons.skip_previous)),
                      Spacer(flex: 1),
                      IconButton(onPressed: () => model.audioPlayerOrPause(),
                          icon: model.player.isPlaying.value ?
                          Icon(Icons.pause, size: 36, color: Colors.black)
                              : Icon(Icons.play_arrow, size: 36, color: Colors.black,)),
                      Spacer(flex: 1),
                      IconButton(icon: Icon(Icons.skip_next)),
                      Spacer(flex: 1),
                      IconButton(icon: Icon(Icons.shuffle)),
                    ],
                  ),
                  SizedBox(height: 40,)
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
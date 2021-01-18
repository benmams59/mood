import 'package:flutter/material.dart';
import 'package:mood/Style/Style.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:mood/Model/AppModel.dart';

class MinimizedController extends StatefulWidget {
  MinimizedController({Key key}) : super(key: key);

  @override
  _MinimizedControllerState createState() => _MinimizedControllerState();
}

class _MinimizedControllerState extends State<MinimizedController> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(
      builder: (context, child, model) {
        return Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            child: model.trackInfo != null ? ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(
                model.trackInfo["title"],
                style: Style.paragraph,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                "${model.trackInfo["artist"]} - ${model.trackInfo["album"]}",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14
                ),
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  model.trackInfo["cover"],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              trailing: model.state == StateOf.Charging ?
              SizedBox(
                child: CircularProgressIndicator(strokeWidth: 3,),
                width: 20,
                height: 20,
              )
                  :
              IconButton(
                  onPressed: () {
                    if (model.trackInfo != null) {
                      model.play();
                    }
                  },
                  icon: model.player.isPlaying.value ?
                  Icon(Icons.pause, size: 30, color: Colors.black)
                      : Icon(Icons.play_arrow, size: 30, color: Colors.black,)
              ),
            ) : Container()
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:mood/Style/Style.dart';

class CondensedCard extends StatefulWidget {
  String title;
  Widget child;

  CondensedCard({Key key, this.title, this.child}) : super(key: key);

  @override
  _CondensedCardState createState() => _CondensedCardState();
}

class _CondensedCardState extends State<CondensedCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Text(widget.title, style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700
            ),)
          ),
          Container(
            child: widget.child,
          ),
          InkWell(
            onTap: () => {},
            child: Container(
              padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("See more", style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 16
                    )),
                    Icon(Icons.arrow_forward_ios_outlined, color: Theme.of(context).accentColor)
                  ],
                )
            ),
          )
        ],
      ),
    );
  }
}
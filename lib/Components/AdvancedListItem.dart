import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mood/Style/Style.dart';

class AdvancedListItem extends StatelessWidget {
  String image;
  IconButton iconButton;
  String title;

  AdvancedListItem({Key key, this.title,this.image, this.iconButton}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (image != null && image.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(image, height: 70, width: 70, fit: BoxFit.cover),
                  ),
              SizedBox(width: 10,),
              Text(title, style: Style.paragraph, overflow: TextOverflow.ellipsis,),
            ]
          ),
          if (iconButton != null)
            iconButton
        ],
      ),
    );
  }
}
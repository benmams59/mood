import 'package:flutter/material.dart';

class CheckChipGroup extends StatefulWidget {
  List<Chip> children;
  CheckChipGroup({Key key, this.children}) : super(key: key);

  @override
  _CheckChipGroupState createState() => _CheckChipGroupState();
}

class _CheckChipGroupState extends State<CheckChipGroup> {

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < widget.children.length; i++) {
      Chip chip = Chip(
        key: widget.children[i].key,
        label: widget.children[i].label,
        elevation: 2,
        backgroundColor: i == _selected ? Colors.black : Colors.white,
        labelStyle: TextStyle(color: i == _selected ? Colors.white : Colors.black),
        onDeleted: i == _selected ? null : () => {
          setState(() => {_selected = i})
        },
        deleteIcon: Icon(Icons.check),
        deleteIconColor: i == _selected ? Colors.white : Colors.black,
      );
      widget.children[i] = chip;
    }

    return Wrap(
      alignment: WrapAlignment.spaceAround,
      spacing: 5,
      children: widget.children,
    );
  }
}
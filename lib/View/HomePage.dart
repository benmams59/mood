import 'package:flutter/material.dart';
import 'package:mood/Components/FloatingController.dart';
import 'package:mood/Model/AppModel.dart';
import 'package:mood/Model/MoodModel.dart';
import 'package:mood/View/ChartPage.dart';
import 'package:mood/View/SearchResultsPage.dart';
import 'package:mood/View/TopArtistFragment.dart';
import 'package:scoped_model/scoped_model.dart';
import 'AlbumPage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();

  bool _isSearchSubmitted = false;

  _submitSearch(String value) {
    if (value.trim().isNotEmpty) {
      setState(() {
        _isSearchSubmitted = true;
      });
    } else {
      setState(() {
        _searchController.text = "";
      });
    }
  }

  _searchTextChanged(String value) {
    if (value.isEmpty)
      setState(() {
        _isSearchSubmitted = false;
      });
  }

  _emptySearchText() {
    setState(() {
      _searchController.text = "";
      _isSearchSubmitted = false;
    });
  }

  @override
  void initState() {
    ScopedModel.of<AppModel>(context).initFavoriteDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingController(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(245, 245, 245, 1),
          brightness: Brightness.light,
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => {},
              ),
              Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Flexible(
                            child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "What are you looking for !",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          cursorColor: Colors.black,
                          style: TextStyle(color: Colors.black),
                          onSubmitted: (value) => _submitSearch(value),
                          onChanged: (value) => _searchTextChanged(value),
                        )),
                        if (_isSearchSubmitted)
                          IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => _emptySearchText()
                          )
                      ],
                    ),
                  )
              ),
              SizedBox(
                width: 30,
              ),
            ],
          ),
        ),
        body: _isSearchSubmitted || _searchController.value.text.isNotEmpty
            ? SearchResultsPage(_searchController.value.text)
            : ChartPage()//ChartPage()
    );
  }
}

import 'package:flutter/material.dart';
import 'package:freevideo/ui/item.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'api/api_client.dart';

class Randompage extends StatefulWidget {
  @override
  _RandompageState createState() => _RandompageState();
}

class _RandompageState extends State<Randompage> {
  int crossAxisCount = 2;
  double crossAxisSpacing = 5.0;
  double mainAxisSpacing = 5.0;
  List item = List();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  Future fetchData() async {
    ApiClient client = new ApiClient();
    Map data = await client.getRandom();
    setState(() {
      item = data['movies'];
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("试试手气"),
        actions: <Widget>[
          IconButton(
            icon:Icon(Icons.autorenew),
            onPressed: () {
              fetchData();
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(5.0),
        child: CustomScrollView(
        slivers: <Widget>[
          SliverWaterfallFlow(
            gridDelegate: SliverWaterfallFlowDelegate(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
            ),
            delegate: SliverChildBuilderDelegate((c, index) {
              return buildWaterfallFlowItem(c, item[index], index);
            }, childCount: item.length),
          )
        ],
      ),
      )
      
      
    );
  }
}

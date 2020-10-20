import 'package:flutter/material.dart';
import 'package:freevideo/ui/item.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'api/api_client.dart';

class Hotspage extends StatefulWidget {
  @override
  _HotspageState createState() => _HotspageState();
}

class _HotspageState extends State<Hotspage> {
  List<Color> colors = List<Color>();
  int crossAxisCount = 2;
  double crossAxisSpacing = 5.0;
  double mainAxisSpacing = 5.0;
  String dropdownValue = '全部';
  Map lists = Map();
  List item = List();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  Future fetchData() async {
    ApiClient client = new ApiClient();
    Map data = await client.getHotsBydate();
    setState(() {
      item = data['allhotmovies'];
      lists = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("热门视频"),
        ),
        body: Container(
          padding: EdgeInsets.only(left: 5.0, right: 5.0),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                  child: Container(
                child: DropdownButton<String>(
                    value: dropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    dropdownColor: Colors.white,
                    isExpanded: false,
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                        String filter = 'allhotmovies';
                        if (newValue == '全部') {
                          filter = 'allhotmovies';
                        } else if (newValue == '一周排行') {
                          filter = 'weekhotmovies';
                        } else if (newValue == '月度排行') {
                          filter = 'monthhotmovies';
                        } else {
                          filter = 'yearhotmovies';
                        }
                        item = lists[filter];
                      });
                    },
                    items: <String>['全部', '一周排行', '月度排行', '年度排行']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList()),
              )),
              SliverGrid.count(
                childAspectRatio: 1.2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 0,
                  crossAxisCount: 2,
                  children: item.map<Widget>((theitem) {
                    return gridItem(context, theitem);
                  }).toList()),
              // SliverWaterfallFlow(
              //   gridDelegate: SliverWaterfallFlowDelegate(
              //     crossAxisCount: crossAxisCount,
              //     crossAxisSpacing: crossAxisSpacing,
              //     mainAxisSpacing: mainAxisSpacing,
              //   ),
              //   delegate: SliverChildBuilderDelegate((c, index) {
              //     return buildWaterfallFlowItem(c, item[index], index);
              //   }, childCount: item.length),
              // )
            ],
          ),
        ));
  }
}

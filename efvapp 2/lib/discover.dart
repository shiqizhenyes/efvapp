import 'package:flutter/material.dart';
import 'package:freevideo/api/api_client.dart';
import 'package:freevideo/category.dart';
import 'package:freevideo/tag.dart';
import 'package:freevideo/ui/item.dart';
import 'package:freevideo/utils/helper.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Discover extends StatefulWidget {
  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  List categories = List();
  List tags = List();
  List taggroups = List();
  Box userBox;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userBox = Hive.box('user');
    fetchData();
  }

  Future fetchData() async {
    ApiClient client = new ApiClient();
    Map data = await client.getDiscover();
    setState(() {
      categories = data['categories'];
      tags = data['tags'];
      taggroups = data['taggroups'];
    });
  }

  Widget discover(List categories, List tags, List taggroups) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              title('大分类'),
              _buildCategory(context, categories),
              _buildTags(context, tags, taggroups),
            ]),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("探索更多"),
        ),
        body: ValueListenableBuilder(
            valueListenable: userBox.listenable(),
            builder: (context, Box box, _) {
              return discover(categories, tags, taggroups);
            }));
  }

  Widget _buildTags(BuildContext context, List tags, List taggroups) {
    List<Widget> lists = [Container()];
    var follows = userBox.get('userfollow');
    taggroups.forEach((group) {
      lists.add(title(group['title']));
      List filtertags = tags.where((f) {
        if (f['groupid'] == null) {
          return false;
        }
        return f['groupid']['title'] == group['title'];
      }).toList();
      lists.add(Container(
        child: Wrap(
            runSpacing: 10.0,
            spacing: 10.0,
            children: filtertags.map<Widget>((tag) {
              String thetag = tag['tag'];
              String counts = tag['counts'].toString();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => TagPage(tag: thetag)));
                    },
                    child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                            border: Border(
                                right: BorderSide(
                                    color: Helper.hexToColor("#ea5a5a"),
                                    width: 1.0),
                                top: BorderSide(
                                    color: Helper.hexToColor("#ea5a5a"),
                                    width: 1.0),
                                bottom: BorderSide(
                                    color: Helper.hexToColor("#ea5a5a"),
                                    width: 1.0),
                                left: BorderSide(
                                    color: Helper.hexToColor("#ea5a5a"),
                                    width: 1.0))),
                        child: Text("$thetag · $counts",
                            style: TextStyle(
                                color: Helper.hexToColor("#ea5a5a")))),
                  ),
                  // OutlineButton(
                  //   onPressed: () {
                  //     Navigator.of(context).push(MaterialPageRoute(
                  //         builder: (_) => TagPage(tag: thetag)));
                  //   },
                  //   textColor: Helper.hexToColor("#ea5a5a"),
                  //   child: Text("$thetag · $counts"),
                  //   borderSide: BorderSide(color: Helper.hexToColor("#ea5a5a")),
                  // ),
                  InkWell(
                    onTap: () async {
                      print('关注');
                      if (userBox.get('user') == null) {
                        return showMessage('请登录之再使用关注功能！');
                      }
                      if (follows == null) {
                        userBox.put('userfollow', [thetag]);
                      } else {
                        if (follows.indexOf(thetag) > -1) {
                          follows.remove(thetag);
                        } else {
                          follows.add(thetag);
                        }
                        userBox.put('userfollow', follows);
                      }
                      ApiClient client = new ApiClient();
                      Map data = await client.toggleFollow(userBox.get('token'), thetag);
                      showMessage(data['message']);
                    },
                    child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                            border: Border(
                                left: BorderSide.none,
                                top: BorderSide(
                                    color: Helper.hexToColor("#ea5a5a"),
                                    width: 1.0),
                                bottom: BorderSide(
                                    color: Helper.hexToColor("#ea5a5a"),
                                    width: 1.0),
                                right: BorderSide(
                                    color: Helper.hexToColor("#ea5a5a"),
                                    width: 1.0))),
                        child: Text(
                          userBox.get('userfollow') == null || userBox.get('userfollow').indexOf(thetag) == -1
                              ? '关注'
                              : '已关注',
                          style: TextStyle(
                            color: Helper.hexToColor("#ea5a5a"),
                          ),
                        )),
                  )
                ],
              );
            }).toList()),
        padding: EdgeInsets.all(5.0),
      ));
    });
    List filtertags = tags.where((f) {
      return (f['groupid'] == null);
    }).toList();
    lists.add(title('其他'));
    lists.add(Container(
      child: Wrap(
          runSpacing: 10.0,
          spacing: 10.0,
          children: filtertags.map<Widget>((tag) {
            String thetag = tag['tag'];
            String counts = tag['counts'].toString();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => TagPage(tag: thetag)));
                  },
                  child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(
                                  color: Helper.hexToColor("#ea5a5a"),
                                  width: 1.0),
                              top: BorderSide(
                                  color: Helper.hexToColor("#ea5a5a"),
                                  width: 1.0),
                              bottom: BorderSide(
                                  color: Helper.hexToColor("#ea5a5a"),
                                  width: 1.0),
                              left: BorderSide(
                                  color: Helper.hexToColor("#ea5a5a"),
                                  width: 1.0))),
                      child: Text("$thetag · $counts",
                          style:
                              TextStyle(color: Helper.hexToColor("#ea5a5a")))),
                ),
                // OutlineButton(
                //   onPressed: () {
                //     Navigator.of(context).push(MaterialPageRoute(
                //         builder: (_) => TagPage(tag: thetag)));
                //   },
                //   textColor: Helper.hexToColor("#ea5a5a"),
                //   child: Text("$thetag · $counts"),
                //   borderSide: BorderSide(color: Helper.hexToColor("#ea5a5a")),
                // ),
                InkWell(
                  onTap: () async {
                    print('关注');
                    if (userBox.get('user') == null) {
                      return showMessage('请登录之再使用关注功能！');
                    }
                    if (follows == null) {
                      userBox.put('userfollow', [thetag]);
                    } else {
                      if (follows.indexOf(thetag) > -1) {
                        follows.remove(thetag);
                      } else {
                        follows.add(thetag);
                      }
                      userBox.put('userfollow', follows);
                    }
                    ApiClient client = new ApiClient();
                    Map data = await client.toggleFollow(userBox.get('token'), thetag);
                    showMessage(data['message']);
                  },
                  child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide.none,
                              top: BorderSide(
                                  color: Helper.hexToColor("#ea5a5a"),
                                  width: 1.0),
                              bottom: BorderSide(
                                  color: Helper.hexToColor("#ea5a5a"),
                                  width: 1.0),
                              right: BorderSide(
                                  color: Helper.hexToColor("#ea5a5a"),
                                  width: 1.0))),
                      child: Text(
                        userBox.get('userfollow') == null || userBox.get('userfollow').indexOf(thetag) == -1
                              ? '关注'
                              : '已关注',
                        style: TextStyle(
                          color: Helper.hexToColor("#ea5a5a"),
                        ),
                      )),
                )
              ],
            );
          }).toList()),
      padding: EdgeInsets.all(5.0),
    ));
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lists,
    ));
  }
}

Widget _buildCategory(BuildContext context, List categories) {
  return Container(
    child: Wrap(
        runSpacing: 5.0,
        spacing: 10.0,
        children: categories.map<Widget>((category) {
          return OutlineButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CategoryPage(category: category['title'])));
            },
            textColor: Helper.hexToColor("#1e87f0"),
            child: Text(category['title']),
            borderSide: BorderSide(color: Helper.hexToColor("#1e87f0")),
          );
        }).toList()),
    padding: EdgeInsets.all(5.0),
  );
}

Widget title(String title) {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.symmetric(vertical: 0.0),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
      ),
    ),
  );
}

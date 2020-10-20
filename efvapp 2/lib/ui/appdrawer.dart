import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freevideo/api/api_client.dart';
import 'package:freevideo/articles.dart';
import 'package:freevideo/buyvip.dart';
import 'package:freevideo/category.dart';
import 'package:freevideo/collection.dart';
import 'package:freevideo/discover.dart';
import 'package:freevideo/download.dart';
import 'package:freevideo/hots.dart';
import 'package:freevideo/images.dart';
import 'package:freevideo/login.dart';
import 'package:freevideo/random.dart';
import 'package:freevideo/tag.dart';
import 'package:freevideo/user.dart';
import 'package:freevideo/buyscore.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppDrawer extends StatefulWidget {
  final Map navbar;
  AppDrawer({this.navbar});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Box userBox;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userBox = Hive.box('user');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ValueListenableBuilder(
        valueListenable: userBox.listenable(),
        builder: (context, Box box, _) {
          return ListView(
            children: navbarList(widget.navbar, context, userBox),
          );
        },
      ),
    );
  }
}

Future checkIn(token) async {
  ApiClient client = ApiClient();
  Map data = await client.checkIn(token);
  Fluttertoast.showToast(
      msg: data['message'],
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER);
}

List<Widget> navbarList(Map item, BuildContext context, Box userBox) {
  List<Widget> lists = [
    DrawerHeader(
      child: Center(
        child: Container(),
      ),
      decoration: new BoxDecoration(
          image: new DecorationImage(
              image: AssetImage('assets/background.jpg'), fit: BoxFit.cover)),
    ),
  ];
  Widget userinfo() {
    Widget info;
    Map user = userBox.get('user');
    if (user != null) {
      String id = user['_id'];
      info = ExpansionTile(
        trailing: Icon(
          Icons.expand_more,
          color: Colors.white,
        ),
        title: Row(
          children: <Widget>[
            Icon(Icons.supervised_user_circle, color: Colors.white),
            Padding(
                child: Text(
                  user['username'],
                  style: TextStyle(color: Colors.white),
                ),
                padding: EdgeInsets.only(left: 8.0))
          ],
        ),
        children: <Widget>[
          ListTile(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => UserPage(id: id)));
              },
              title: Row(
                children: <Widget>[
                  Padding(
                      child: Text(
                        '个人页面',
                        style: TextStyle(color: Colors.white),
                      ),
                      padding: EdgeInsets.only(left: 8.0))
                ],
              )),
          ListTile(
              onTap: () {
                checkIn(userBox.get('token'));
              },
              title: Row(
                children: <Widget>[
                  Padding(
                      child: Text(
                        '每日签到',
                        style: TextStyle(color: Colors.white),
                      ),
                      padding: EdgeInsets.only(left: 8.0))
                ],
              )),
          ListTile(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => BuyvipScreen()));
              },
              title: Row(
                children: <Widget>[
                  Padding(
                      child: Text(
                        '购买VIP',
                        style: TextStyle(color: Colors.white),
                      ),
                      padding: EdgeInsets.only(left: 8.0))
                ],
              )),
          ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return BuyscoreScreen();
                }));
              },
              title: Row(
                children: <Widget>[
                  Padding(
                      child: Text(
                        '购买积分',
                        style: TextStyle(color: Colors.white),
                      ),
                      padding: EdgeInsets.only(left: 8.0))
                ],
              )),
          ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return CollectionPage();
                }));
              },
              title: Row(
                children: <Widget>[
                  Padding(
                      child: Text(
                        '我的收藏',
                        style: TextStyle(color: Colors.white),
                      ),
                      padding: EdgeInsets.only(left: 8.0))
                ],
              )),
          ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                  return DownloadPage();
                }));
              },
              title: Row(
                children: <Widget>[
                  Padding(
                      child: Text(
                        '下载记录',
                        style: TextStyle(color: Colors.white),
                      ),
                      padding: EdgeInsets.only(left: 8.0))
                ],
              )),
          ListTile(
              onTap: () {
                userBox.deleteAll(['user', 'token', 'userfollow']);
              },
              title: Row(
                children: <Widget>[
                  Padding(
                      child: Text(
                        '注销',
                        style: TextStyle(color: Colors.white),
                      ),
                      padding: EdgeInsets.only(left: 8.0))
                ],
              ))
        ],
      );
    } else {
      info = ListTile(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => LoginScreen()));
          },
          title: Row(
            children: <Widget>[
              Icon(Icons.supervised_user_circle, color: Colors.white),
              Padding(
                  child: Text(
                    '用户登录',
                    style: TextStyle(color: Colors.white),
                  ),
                  padding: EdgeInsets.only(left: 8.0))
            ],
          ));
    }
    return info;
  }

  lists.add(userinfo());
  lists.add(Divider());
  lists.addAll([
    ListTile(
      title: Row(children: <Widget>[
        Icon(Icons.favorite, color: Colors.white),
        Padding(
            child: Text(
              '热门排行',
              style: TextStyle(color: Colors.white),
            ),
            padding: EdgeInsets.only(left: 8.0))
      ]),
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => Hotspage()));
      },
    ),
    ListTile(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => Randompage()));
        },
        title: Row(children: <Widget>[
          Icon(Icons.explore, color: Colors.white),
          Padding(
              child: Text(
                '试试手气',
                style: TextStyle(color: Colors.white),
              ),
              padding: EdgeInsets.only(left: 8.0))
        ])),
    ListTile(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => Discover()));
        },
        title: Row(children: <Widget>[
          Icon(Icons.find_replace, color: Colors.white),
          Padding(
              child: Text(
                '探索更多',
                style: TextStyle(color: Colors.white),
              ),
              padding: EdgeInsets.only(left: 8.0))
        ])),
    ListTile(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => ArticlesPage()));
        },
        title: Row(children: <Widget>[
          Icon(Icons.description, color: Colors.white),
          Padding(
              child: Text(
                '资讯文章',
                style: TextStyle(color: Colors.white),
              ),
              padding: EdgeInsets.only(left: 8.0))
        ])),
    ListTile(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => ImagesPage()));
        },
        title: Row(children: <Widget>[
          Icon(Icons.image, color: Colors.white),
          Padding(
              child: Text(
                '图集漫画',
                style: TextStyle(color: Colors.white),
              ),
              padding: EdgeInsets.only(left: 8.0))
        ])),
    ExpansionTile(
      trailing: Icon(
        Icons.expand_more,
        color: Colors.white,
      ),
      title: Row(
        children: <Widget>[
          Icon(Icons.class_, color: Colors.white),
          Padding(
              child: Text(
                '分类',
                style: TextStyle(color: Colors.white),
              ),
              padding: EdgeInsets.only(left: 8.0))
        ],
      ),
      children: item['categories'].map<Widget>((category) {
        return ListTile(
            title: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    category['title'],
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CategoryPage(category: category['title'])));
            });
      }).toList(),
    ),
    ExpansionTile(
      trailing: Icon(
        Icons.expand_more,
        color: Colors.white,
      ),
      title: Row(
        children: <Widget>[
          Icon(Icons.loyalty, color: Colors.white),
          Padding(
              child: Text(
                '热门标签',
                style: TextStyle(color: Colors.white),
              ),
              padding: EdgeInsets.only(left: 8.0))
        ],
      ),
      children: item['globaltags'].map<Widget>((tag) {
        String title = tag['tag'];
        String counts = tag['counts'].toString();
        return ListTile(
            title: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    "$title ($counts)",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => TagPage(tag: title)));
            });
      }).toList(),
    )
  ]);
  lists.add(Divider());
  // if (item['categories'] != null && item['categories'].length > 0) {
  //   lists.addAll(item['categories'].map<Widget>((category) {
  //     return ListTile(
  //         title: Row(
  //           children: <Widget>[
  //             Icon(Icons.class_, color: Colors.white),
  //             Padding(
  //               padding: EdgeInsets.only(left: 8.0),
  //               child: Text(
  //                 category['title'],
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //             )
  //           ],
  //         ),
  //         onTap: () {
  //           Navigator.of(context).push(MaterialPageRoute(
  //               builder: (_) => CategoryPage(category: category['title'])));
  //         });
  //   }).toList());
  //   lists.add(Divider());
  // }
  // if (item['globaltags'] != null && item['globaltags'].length > 0) {
  //   lists.addAll(item['globaltags'].map<Widget>((tag) {
  //     String title = tag['tag'];
  //     String counts = tag['counts'].toString();
  //     return ListTile(
  //         title: Row(
  //           children: <Widget>[
  //             Icon(Icons.loyalty, color: Colors.white),
  //             Padding(
  //               padding: EdgeInsets.only(left: 8.0),
  //               child: Text(
  //                 "$title ($counts)",
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //             )
  //           ],
  //         ),
  //         onTap: () {
  //           Navigator.of(context)
  //               .push(MaterialPageRoute(builder: (_) => TagPage(tag: title)));
  //         });
  //   }).toList());
  // }
  return lists;
}

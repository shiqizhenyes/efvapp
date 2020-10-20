import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freevideo/api/api_client.dart';
import 'package:freevideo/buyscore.dart';
import 'package:freevideo/buyvip.dart';
import 'package:freevideo/collection.dart';
import 'package:freevideo/login.dart';
import 'package:hive/hive.dart';

class UserPage extends StatefulWidget {
  final String id;
  final editIndex;
  UserPage({this.id, this.editIndex});
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Box userBox;
  Map user;
  TextEditingController _cardController = new TextEditingController();
  final key = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    userBox = Hive.box('user');
    getUser(widget.id);
  }

  Future getUser(String id) async {
    ApiClient client = ApiClient();
    Map data = await client.getUser(id);
    setState(() {
      user = data['user'];
    });
  }

  Future checkIn(token) async {
    ApiClient client = ApiClient();
    Map data = await client.checkIn(token);
    Fluttertoast.showToast(
        msg: data['message'],
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER);
  }

  Future usecard() async {
    ApiClient client = ApiClient();
    String card = _cardController.text;
    if (card.isEmpty || card.length != 20) {
      return showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
              title: new Text("提示"),
              content: new Text('卡号不正确'),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new FlatButton(
                  child: new Text("关闭"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
    Map data = await client.postUseCard(userBox.get('token'), card);
    Navigator.of(context).pop();
    Fluttertoast.showToast(
        msg: data['message'],
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG);
  }

  @override
  Widget build(BuildContext context) {
    String theid = user == null ? '1' : user['_id'];
    String username = user == null ? '1' : user['username'];
    Map portal = userBox.get('portal');
    return user == null
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            key: key,
            body: CustomScrollView(slivers: [
              SliverAppBar(
                actions: <Widget>[],
                centerTitle: true,
                floating: true,
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Container(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(username),
                        SizedBox(
                          height: 1.0,
                        ),
                        Text('积分数：' + user['score'].toString(),
                            style: TextStyle(
                                fontSize: 14.0, color: Colors.white54)),
                        SizedBox(
                          height: 1.0,
                        ),
                        _group(user)
                      ],
                    )),
                    background: Image(
                        image: AssetImage('assets/background.jpg'),
                        fit: BoxFit.cover)),
              ),
              SliverList(
                delegate: SliverChildListDelegate(<Widget>[
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: <Widget>[
                        ListTile(
                            onTap: () {
                              checkIn(userBox.get('token'));
                            },
                            leading: Icon(Icons.settings_system_daydream),
                            title: Text("每日签到"),
                            trailing: Icon(Icons.arrow_right)),
                        ListTile(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => BuyvipScreen()));
                          },
                          leading: Icon(Icons.beenhere),
                          title: Text("购买VIP"),
                          trailing: Icon(Icons.arrow_right),
                        ),
                        ListTile(
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) {
                              return BuyscoreScreen();
                            }));
                          },
                          leading: Icon(Icons.score),
                          title: Text("购买积分"),
                          trailing: Icon(Icons.arrow_right),
                        ),
                        ListTile(
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) {
                              return CollectionPage();
                            }));
                          },
                          leading: Icon(Icons.collections),
                          title: Text("我的收藏"),
                          trailing: Icon(Icons.arrow_right),
                        ),
                        new ListTile(
                          leading: Icon(Icons.share),
                          title: Text("推广赚积分"),
                          trailing: Icon(Icons.arrow_right),
                          onTap: () {
                            // key.currentState.showSnackBar(new SnackBar(
                            //                         duration: Duration(seconds: 5),
                            //                     content: new Text("复制至剪贴板成功")));
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return SimpleDialog(
                                    contentPadding: EdgeInsets.all(20.0),
                                    children: <Widget>[
                                      Center(
                                        child: Text(
                                            '长按下方链接自动复制，粘贴发送给好友，用户访问即推广成功，积分增加' +
                                                portal['invitationreward']
                                                    .toString(),
                                            style: TextStyle(fontSize: 16.0)),
                                      ),
                                      SizedBox(height: 16.0),
                                      GestureDetector(
                                        child: new Text(
                                            ApiClient.host +
                                                '/invite?id=$theid',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.blue)),
                                        onLongPress: () {
                                          Clipboard.setData(new ClipboardData(
                                            text: ApiClient.host +
                                                '/invite?id=$theid',
                                          ));
                                          Navigator.of(context).pop();
                                          key.currentState
                                              .showSnackBar(new SnackBar(
                                            duration: Duration(seconds: 5),
                                            content: new Text("复制至剪贴板成功"),
                                          ));
                                        },
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                    ],
                                  );
                                });
                          },
                        ),
                        new ListTile(
                          leading: Icon(Icons.add),
                          title: Text("使用卡卷"),
                          trailing: Icon(Icons.arrow_right),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return SimpleDialog(
                                    contentPadding: EdgeInsets.all(20.0),
                                    title: Text('使用卡卷'),
                                    children: <Widget>[
                                      TextFormField(
                                        controller: _cardController,
                                        autofocus: false,
                                        decoration: InputDecoration(
                                          hintText: '卡卷',
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      FlatButton(
                                        color: Colors.blue,
                                        onPressed: usecard,
                                        textColor: Colors.white,
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('提交使用'),
                                      ),
                                    ],
                                  );
                                });
                          },
                        ),
                        new ListTile(
                          leading: Icon(Icons.account_circle),
                          title: Text("注销"),
                          trailing: Icon(Icons.arrow_right),
                          onTap: () {
                            userBox.deleteAll(['user', 'token', 'userfollow']);
                            // Navigator.of(context).pop();
                            widget.editIndex(0);
                          },
                        ),
                      ]))
                ]),
              )
            ]));
  }
}

Widget _group(Map user) {
  var now = new DateTime.now();
  if (user['vipgroup'] != null) {
    var duedate = DateTime.parse(user['vipgroup']['duedate']);
    if (now.isBefore(duedate)) {
      return Text('VIP用户组：' + user['vipgroup']['groupid']['title'],
          style: TextStyle(fontSize: 14.0, color: Colors.white54));
    }
  }
  return Text('用户组：' + user['group']['title'],
      style: TextStyle(fontSize: 14.0, color: Colors.white54));
}

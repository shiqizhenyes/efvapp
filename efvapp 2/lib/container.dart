import 'package:flutter/material.dart';
import 'package:freevideo/discover.dart';
import 'package:freevideo/home_page1.dart';
import 'package:freevideo/hots.dart';
import 'package:freevideo/login.dart';
import 'package:freevideo/user.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

///这个页面是作为整个APP的最外层的容器，以Tab为基础控制每个item的显示与隐藏
class ContainerPage extends StatefulWidget {
  static String tag = 'container-page';
  ContainerPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ContainerPageState();
  }
}

class _ContainerPageState extends State<ContainerPage> {
  List<Widget> pages;

  List<BottomNavigationBarItem> itemList;
  Box userBox;

  @override
  void initState() {
    super.initState();
    userBox = Hive.box('user');
    if (pages == null) {
      pages = [
        HomePage1(editIndex: (index) => _editSelectIndex(index)),
        Discover(),
        Hotspage(),
      ];
    }
  }

  int _selectIndex = 0;
  _editSelectIndex(int index) {
    setState(() {
      _selectIndex = index;
    });
  }

//Stack（层叠布局）+Offstage组合,解决状态被重置的问题
  Widget _getPagesWidget(int index) {
    return Offstage(
      offstage: _selectIndex != index,
      child: TickerMode(
        enabled: _selectIndex == index,
        child: pages[index],
      ),
    );
  }

  @override
  void didUpdateWidget(ContainerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
//    Scaffold({
//    Key key,
//    this.appBar,
//    this.body,
//    this.floatingActionButton,
//    this.floatingActionButtonLocation,
//    this.floatingActionButtonAnimator,
//    this.persistentFooterButtons,
//    this.drawer,
//    this.endDrawer,
//    this.bottomNavigationBar,
//    this.bottomSheet,
//    this.backgroundColor,
//    this.resizeToAvoidBottomPadding = true,
//    this.primary = true,
//    })
    return Scaffold(
      body: ValueListenableBuilder(
          valueListenable: userBox.listenable(),
          builder: (context, Box<dynamic> box, _) {
            return new Stack(
              children: [
                _getPagesWidget(0),
                _getPagesWidget(1),
                _getPagesWidget(2),
                Offstage(
                  offstage: _selectIndex != 3,
                  child: TickerMode(
                    enabled: _selectIndex == 3,
                    child: userBox.get('user') != null
                        ? UserPage(
                            id: userBox.get('user')['_id'],
                            editIndex: (index) => _editSelectIndex(index))
                        : Container(),
                  ),
                ),
              ],
            );
          }),
//        List<BottomNavigationBarItem>
//        @required this.icon,
//    this.title,
//    Widget activeIcon,
//    this.backgroundColor,
      backgroundColor: Color.fromARGB(255, 248, 248, 248),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black87,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('首页'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.find_replace),
            title: Text('发现'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            title: Text('排行榜'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('我的'),
          ),
        ],
        currentIndex: _selectIndex,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.blue,
        selectedFontSize: 14.0,
        onTap: (index) {
          if (index == 3) {
            Map user = userBox.get('user');
            if (user == null) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => LoginScreen()));
              setState(() {
                _selectIndex = 0;
              });
            } else {
              setState(() {
                _selectIndex = index;
              });
            }
          } else {
            setState(() {
              _selectIndex = index;
            });
          }
        },
      ),
    );
  }
}

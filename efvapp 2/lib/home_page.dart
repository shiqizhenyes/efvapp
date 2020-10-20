import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freevideo/discover.dart';
import 'package:freevideo/login.dart';
import 'package:freevideo/ui/appdrawer.dart';
import 'package:freevideo/ui/item.dart';
import 'package:freevideo/ui/repository.dart';
import 'package:freevideo/ui/search_delegate.dart';
import 'package:hive/hive.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'api/api_client.dart';
import 'utils/screen_util.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int page = 0;
  int size = 18;
  List lists = new List();
  Map navbar = new Map();
  bool more = true;
  String selectcategory = '全部';
  List categories = new List();
  Repository listSourceRepository = Repository(pagetag: 'index');
  Repository followlistSourceRepository;
  Box userBox;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchNavbar();
    userBox = Hive.box('user');
    if (userBox.get('userfollow') != null) {
      followlistSourceRepository = Repository(
          pagetag: 'userfollow');    
    }
    checkAuth();
    // fetchData(page, selectcategory);
    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels ==
    //       _scrollController.position.maxScrollExtent) {
    //     if (more) {
    //       page += 1;
    //       fetchData(page, selectcategory);
    //     }
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
    listSourceRepository.dispose();
  }

  Future checkAuth() async {
    ApiClient client = ApiClient();
    dynamic token = userBox.get('token');
    if (token != null) {
      Map data = await client.checkAuth(token);
      if (!data['auth']) {
        userBox.deleteAll(['user', 'token']);
      }
    }
  }

  Future fetchNavbar() async {
    ApiClient client = new ApiClient();
    Map data = await client.getNav();
    userBox.put('portal', data['portal']);
    setState(() {
      navbar = data;
    });
  }
  // Future<void> fetchData(int page, String category) async {
  //   ApiClient client = new ApiClient();
  //   Map data = await client.getIndex(page, size);
  //   setState(() {
  //     if (page == 1) {
  //       lists = data['movies'];
  //     } else {
  //       lists.addAll(data['movies']);
  //     }
  //     categories = data['categories'];
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // if (lists.length == 0) {
    //   return Scaffold(
    //       body: Center(
    //     child: CupertinoActivityIndicator(),
    //   ));
    // }
    Future _handleRefresh() async {
      return await followlistSourceRepository.refresh(true);
    }

    return DefaultTabController(
        length: 2,
        child: Scaffold(
            drawer: AppDrawer(navbar: navbar),
            appBar: AppBar(
              title: TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: '最新'),
                  Tab(text: '关注'),
                ],
              ),
              centerTitle: true,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(context: context, delegate: SearchScreen());
                  },
                )
              ],
            ),
            body: ValueListenableBuilder(
                valueListenable: userBox.listenable(),
                builder: (context, Box<dynamic> box, _) {
                  return TabBarView(children: [
                    LayoutBuilder(
                      builder: (c, data) {
                        final crossAxisCount = max(
                            data.maxWidth ~/
                                (ScreenUtil.instance.screenWidthDp / 2.0),
                            2);
                        return LoadingMoreList(
                          ListConfig<dynamic>(
                            waterfallFlowDelegate: WaterfallFlowDelegate(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                            ),
                            itemBuilder: buildWaterfallFlowItem,
                            sourceList: listSourceRepository,
                            padding: EdgeInsets.all(5.0),
                            lastChildLayoutType: LastChildLayoutType.foot,
                          ),
                        );
                      },
                    ),
                    userBox.get('user') == null
                        ? Container(
                            child: Center(
                              child: Row(children: [
                                Text('请登录之后再使用关注功能。'),
                                InkWell(
                                  child: Text('点击前往登录',
                                      style: TextStyle(color: Colors.blue)),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) => LoginScreen()));
                                  },
                                )
                              ], mainAxisAlignment: MainAxisAlignment.center),
                            ),
                          )
                        : (userBox.get('userfollow') == null ||
                                userBox.get('userfollow').length == 0)
                            ? Container(
                                child: Center(
                                  child: Row(
                                      children: [
                                        Text('您还未关注任何标签。'),
                                        InkWell(
                                          child: Text('点击前往关注',
                                              style: TextStyle(
                                                  color: Colors.blue)),
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        Discover()));
                                          },
                                        )
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.center),
                                ),
                              )
                            : LayoutBuilder(
                                builder: (c, data) {
                                  final crossAxisCount = max(
                                      data.maxWidth ~/
                                          (ScreenUtil.instance.screenWidthDp /
                                              2.0),
                                      2);
                                  return LiquidPullToRefresh(
                                      showChildOpacityTransition: false,
                                      springAnimationDurationInMilliseconds:
                                          300,
                                      backgroundColor: Colors.black54,
                                      color: Colors.grey[200],
                                      onRefresh:
                                          _handleRefresh, // refresh callback
                                      child: LoadingMoreList(
                                        ListConfig<dynamic>(
                                          waterfallFlowDelegate:
                                              WaterfallFlowDelegate(
                                            crossAxisCount: crossAxisCount,
                                            crossAxisSpacing: 5,
                                            mainAxisSpacing: 5,
                                          ),
                                          itemBuilder: buildWaterfallFlowItem,
                                          sourceList:
                                              followlistSourceRepository,
                                          padding: EdgeInsets.all(5.0),
                                          lastChildLayoutType:
                                              LastChildLayoutType.foot,
                                        ),
                                      ));
                                },
                              ),
                  ]);
                })));
  }
}
//   return Stack(
//     children: <Widget>[
//       Scaffold(
//         body: NestedScrollView(
//           controller: _scrollController,
//           headerSliverBuilder: (context, isInnerBoxScroll) => [
//             RoundedFloatingAppBar(
//               actions: <Widget>[
//                 IconButton(
//                   icon: Icon(Icons.filter_list),
//                   onPressed: () {
//                     _showModal();
//                   },
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.search),
//                   onPressed: () {
//                     showSearch(context: context, delegate: SearchScreen());
//                   },
//                 )
//               ],
//               floating: true,
//               snap: true,
//               iconTheme: IconThemeData(color: Colors.black),
//               textTheme: TextTheme(title: TextStyle(color: Colors.black)),
//               title: Row(
//                 children: <Widget>[
//                   Icon(
//                     Icons.video_library,
//                     color: Colors.red,
//                   ),
//                   Padding(
//                     padding: EdgeInsets.symmetric(vertical: 10.0),
//                     child: Text(ApiClient.title,
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 18)),
//                   )
//                 ],
//               ),
//               backgroundColor: Colors.white,
//             ),
//           ],
//           body: Container(
//             child: ListView.builder(
//               itemBuilder: (context, index) => VideoItem(lists[index]),
//               itemCount: lists.length,
//             ),
//           ),
//         ),
//       )
//     ],
//   );
// }

// void _showModal() {
//   showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Container(
//           color: Color(0xFF737373),
//           child: Container(
//             child: _buildBottomNavifationMenu(),
//             decoration: BoxDecoration(
//                 color: Theme.of(context).canvasColor,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(10),
//                   topRight: Radius.circular(10),
//                 )),
//           ),
//         );
//       });
// }

// Column _buildBottomNavifationMenu() {
//   return Column(
//     mainAxisSize: MainAxisSize.min,
//     children: getListTileWidgets(categories),
//   );
// }

// List<Widget> getListTileWidgets(List categories) {
//   List<Widget> list = new List<Widget>();
//   list.add(ListTile(
//     title: Text('全部'),
//     onTap: () {
//       Navigator.pop(context);
//       setState(() {
//         selectcategory = '全部';
//         page = 1;
//       });
//       fetchData(page, selectcategory);
//     },
//     selected: selectcategory == '全部',
//   ));
//   for (var i = 0; i < categories.length; i++) {
//     Map category = categories[i];
//     list.add(ListTile(
//       title: Text(category['title']),
//       onTap: () {
//         _selectCategory(category);
//       },
//       selected: selectcategory == category['_id'],
//     ));
//   }
//   return list;
// }

// void _selectCategory(Map category) {
//   Navigator.pop(context);
//   setState(() {
//     page = 1;
//     selectcategory = category['_id'];
//   });
//   fetchData(page, selectcategory);
// }

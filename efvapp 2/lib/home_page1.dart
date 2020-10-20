import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:freevideo/articles.dart';
import 'package:freevideo/discover.dart';
import 'package:freevideo/hots.dart';
import 'package:freevideo/images.dart';
import 'package:freevideo/login.dart';
import 'package:freevideo/random.dart';
import 'package:freevideo/ui/appdrawer.dart';
import 'package:freevideo/ui/item.dart';
import 'package:freevideo/ui/repository.dart';
import 'package:freevideo/ui/search_delegate.dart';
import 'package:freevideo/ui/label_below_icon.dart';
import 'package:freevideo/video_play.dart';
import 'package:hive/hive.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'api/api_client.dart';
import 'utils/screen_util.dart';

class HomePage1 extends StatefulWidget {
  final editIndex;
  const HomePage1({this.editIndex});

  @override
  _HomePage1State createState() => _HomePage1State();
}

class _HomePage1State extends State<HomePage1> {
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
  int activeindex = 0;
  List pushMovies = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPushMovies();
    userBox = Hive.box('user');
    followlistSourceRepository = Repository(pagetag: 'userfollow');
    checkAuth();
    fetchNavbar();
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

  Future getPushMovies() async {
    ApiClient client = ApiClient();
    Map data = await client.getPushMovies();
    setState(() {
      pushMovies = data['pushmovies'];
    });
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
    Widget _setbackground(bool full, Widget widget, double height) {
      widget = Container(
          width: double.infinity,
          height: height,
          child: widget,
          color: Colors.white,
          alignment: Alignment.center);
      return widget;
    }

    Widget getIndicator(BuildContext context) {
      final TargetPlatform platform = Theme.of(context).platform;
      return platform == TargetPlatform.iOS
          ? const CupertinoActivityIndicator(
              animating: true,
              radius: 16.0,
            )
          : CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            );
    }

    //you can use IndicatorWidget or build yourself widget
    //in this demo, we define all status.
    Widget _buildIndicator(BuildContext context, IndicatorStatus status) {
      //if your list is sliver list ,you should build sliver indicator for it
      //isSliver=true, when use it in sliver list
      const bool isSliver = true;

      Widget widget;
      switch (status) {
        case IndicatorStatus.none:
          widget = Container(height: 0.0);
          break;
        case IndicatorStatus.loadingMoreBusying:
          widget = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 5.0),
                height: 15.0,
                width: 15.0,
                child: getIndicator(context),
              ),
              const Text('正在加载...不要着急')
            ],
          );
          widget = _setbackground(false, widget, 35.0);
          break;
        case IndicatorStatus.fullScreenBusying:
          widget = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 0.0),
                height: 30.0,
                width: 30.0,
                child: getIndicator(context),
              ),
              const Text('正在加载...不要着急')
            ],
          );
          widget = _setbackground(true, widget, 35.0);
          if (isSliver) {
            widget = SliverFillRemaining(
              child: widget,
            );
          } else {
            widget = CustomScrollView(
              slivers: <Widget>[
                SliverFillRemaining(
                  child: widget,
                )
              ],
            );
          }
          break;
        case IndicatorStatus.error:
          widget = const Text(
            '好像出现了问题呢？',
          );
          widget = _setbackground(false, widget, 35.0);

          widget = GestureDetector(
            onTap: () {
              listSourceRepository.errorRefresh();
            },
            child: widget,
          );

          break;
        case IndicatorStatus.fullScreenError:
          widget = const Text(
            '好像出现了问题呢？',
          );
          widget = _setbackground(true, widget, 35.0);
          widget = GestureDetector(
            onTap: () {
              listSourceRepository.errorRefresh();
            },
            child: widget,
          );
          if (isSliver) {
            widget = SliverFillRemaining(
              child: widget,
            );
          } else {
            widget = CustomScrollView(
              slivers: <Widget>[
                SliverFillRemaining(
                  child: widget,
                )
              ],
            );
          }
          break;
        case IndicatorStatus.noMoreLoad:
          widget = const Text('没有更多的了。。不要拖了');
          widget = _setbackground(false, widget, 35.0);
          break;
        case IndicatorStatus.empty:
          widget = const Text('没有推荐内容！');
          widget = _setbackground(true, widget, 35.0);
          if (isSliver) {
            widget = SliverToBoxAdapter(
              child: widget,
            );
          } else {
            widget = CustomScrollView(
              slivers: <Widget>[
                SliverFillRemaining(
                  child: widget,
                )
              ],
            );
          }
          break;
      }
      return widget;
    }

    Widget indexMovie() {
      return LoadingMoreSliverList(
        SliverListConfig<dynamic>(
          waterfallFlowDelegate: WaterfallFlowDelegate(
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          indicatorBuilder: _buildIndicator,
          itemBuilder: buildWaterfallFlowItem,
          sourceList: listSourceRepository,
          padding: EdgeInsets.all(5.0),
          lastChildLayoutType: LastChildLayoutType.foot,
        ),
      );
    }

    Future _handleRefresh() async {
      return await followlistSourceRepository.refresh(true);
    }

    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: Colors.black87,
              leading: Container(
                  padding: EdgeInsets.only(left: 12.0, top: 6.0, bottom: 6.0),
                  child: InkWell(
                    onTap: () {
                      userBox.get('user') == null
                          ? Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => LoginScreen()))
                          : widget.editIndex(3);
                    },
                    child: CircleAvatar(
                      radius: 10,
                      backgroundImage: AssetImage('assets/default.jpg'),
                      child: userBox.get('user') == null
                          ? Text('')
                          : Text(
                              userBox.get('user')['username'].substring(0, 1),
                              style: TextStyle(fontSize: 20.0)),
                    ),
                  )),
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
                    LoadingMoreCustomScrollView(shrinkWrap: true, slivers: <
                        Widget>[
                      SliverList(
                          delegate: SliverChildListDelegate([
                        AspectRatio(
                          aspectRatio: 1.75,
                          child: pushMovies.length == 0
                              ? Center(child: CircularProgressIndicator())
                              : Swiper(
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    String src = ApiClient.host +
                                        pushMovies[index]['movieid']['poster']
                                            .replaceAll('./public', '');
                                    return Stack(
                                        fit: StackFit.expand,
                                        children: <Widget>[
                                          Container(
                                              child: new Image.network(
                                            src,
                                            fit: BoxFit.cover,
                                          )),
                                          Container(
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                Colors.black54,
                                              ],
                                              stops: [0.8, 1.0],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              tileMode: TileMode.repeated,
                                            )),
                                          ),
                                        ]);
                                  },
                                  onIndexChanged: (index) => setState(() {
                                    activeindex = index;
                                  }),
                                  onTap: (index) => Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    String id =
                                        pushMovies[index]['movieid']['_id'];
                                    return PlayPage(
                                        id: id,
                                        type: pushMovies[index]['movieid']
                                                    ['status'] !=
                                                'finished'
                                            ? 'tv'
                                            : 'movie');
                                  })),
                                  itemCount: pushMovies.length,
                                  pagination: new SwiperPagination(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 8.0),
                                      builder: new SwiperCustomPagination(
                                          builder: (BuildContext context,
                                              SwiperPluginConfig config) {
                                        return new ConstrainedBox(
                                          child: new Row(
                                            children: <Widget>[
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    97.0,
                                                child: new Text(
                                                  pushMovies[activeindex]
                                                          ['movieid']
                                                      ['originalname'],
                                                  maxLines: 1,
                                                  softWrap: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 18.0,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              new Expanded(
                                                child: new Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child:
                                                      new DotSwiperPaginationBuilder(
                                                              color:
                                                                  Colors.white,
                                                              activeColor:
                                                                  Colors.blue,
                                                              size: 10.0,
                                                              activeSize: 10.0)
                                                          .build(
                                                              context, config),
                                                ),
                                              )
                                            ],
                                          ),
                                          constraints:
                                              new BoxConstraints.expand(
                                                  height: 50.0),
                                        );
                                      })),
                                ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              LabelBelowIcon(
                                icon: Icons.favorite,
                                label: '热门',
                                circleColor: Colors.blue,
                                onPressed: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return Hotspage();
                                })),
                              ),
                              LabelBelowIcon(
                                icon: Icons.explore,
                                label: '随机',
                                circleColor: Colors.orange,
                                onPressed: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return Randompage();
                                })),
                              ),
                              LabelBelowIcon(
                                icon: Icons.description,
                                label: '文章',
                                circleColor: Colors.lime,
                                onPressed: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return ArticlesPage();
                                })),
                              ),
                              LabelBelowIcon(
                                icon: Icons.image,
                                label: '美图',
                                circleColor: Colors.amber,
                                onPressed: () => Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return ImagesPage();
                                })),
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        SizedBox(height: 8.0),
                      ])),
                      indexMovie(),
                    ]),
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
                                            widget.editIndex(1);
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

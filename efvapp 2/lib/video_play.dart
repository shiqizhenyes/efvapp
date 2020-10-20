import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_page_tracker/flutter_page_tracker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freevideo/category.dart';
import 'package:freevideo/tag.dart';
import 'package:freevideo/ui/item.dart';
import 'package:freevideo/ui/photo_preview.dart';
import 'package:freevideo/ui/repository.dart';
import 'package:freevideo/utils/helper.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'api/api_client.dart';

class PlayPage extends StatefulWidget with WidgetsBindingObserver{
  final String id;
  final String type;
  PlayPage({this.id, this.type});

  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> with PageTrackerAware, TrackerPageMixin {
  final FijkPlayer player = FijkPlayer();
  String url = 'https://www.baidu.com';
  Map video;
  Map tv;
  Box userBox;
  Box likes;
  String m3u8;
  List photos = [];
  int _selectedIndex = 0;
  String dropdownValue;
  ScrollController _scrollController = new ScrollController();
  Repository listSourceRepository;
  String _localPath;
  bool _permissionReady = false;
  bool fullscreen = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userBox = Hive.box('user');
    likes = Hive.box('likes');
    player.addListener(_fijkValueListener);
    fetchMovieData();
    initDownload();
    FijkPlugin.keepScreenOn(true);
  }

  Future<Null> initDownload() async {
    _permissionReady = await _checkPermission();
    _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download';
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();

    if (!hasExisted) {
      savedDir.create();
    }
  }
  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void didPageView() {
      super.didPageView();
      // 发送页面露出事件
      print('页面进入');
      player.start();
  }

  @override
  void didPageExit() {
      super.didPageExit();
      // 发送页面离开事件
      print('页面离开了');
      if(!fullscreen) {
        player.pause();
      }
  }

  Future fetchM3u8() async {
    ApiClient client = new ApiClient();
    int hd = video['m3u8paths'][0]['hd'];
    if (userBox.get('hd') != null) {
      hd = int.parse(userBox.get('hd'));
    }
    Map data =
        await client.getM3u8(hd.toString(), widget.id, userBox.get('token'));
    if (data['message'] != null) {
      showMessage(data['message']);
    }
    if (data['m3u8'] != null) {
      setState(() {
        m3u8 = ApiClient.host + data['m3u8'];
        player.setDataSource(m3u8, autoPlay: true);
        dropdownValue = getHd(data['hd']);
      });
    }
  }

  Future<void> fetchMovieData() async {
    ApiClient client = new ApiClient();
    String type = widget.type;
    Map data = await client.getPlay(type, this.widget.id);
    if (data['success'] == 0) {
      showMessage(data['message']);
      return Navigator.of(context).pop();
    }
    int hd = data['movie']['m3u8paths'][0]['hd'];
    if (type == 'movie') {
      setState(() {
        video = data['movie'];
        photos = data['photos'];
        dropdownValue = getHd(hd);
        listSourceRepository = Repository(pagetag: 'tags',tags: video['tags'].join(','));
      });
    } else {
      setState(() {
        video = data['movie'];
        tv = data['tv'];
        photos = data['photos'];
        dropdownValue = getHd(hd);
        listSourceRepository = Repository(pagetag: 'tags',tags: tv['tags'].join(','));
      });
      if (mounted) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent *
                _selectedIndex /
                (tv['episodes'].length - 1),
          );
        }
      }
    }
    fetchM3u8();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    listSourceRepository?.dispose();
    player?.removeListener(_fijkValueListener);
    player?.release();
    FijkPlugin.keepScreenOn(false);
  }

  void _fijkValueListener() {
    FijkValue value = player.value;
    FijkState state = value.state;
    bool thefullscreen = value.fullScreen;
    setState(() {
      fullscreen = thefullscreen;
    });
    if (state == FijkState.started) {
      FijkPlugin.keepScreenOn(true);
    } else if (state == FijkState.paused) {
      FijkPlugin.keepScreenOn(false);
    }
  }
  Future changeEpisode(String id) async {
    ApiClient client = new ApiClient();
    int hd = 480;
    if (userBox.get('hd') != null) {
      hd = int.parse(userBox.get('hd'));
    }
    Map data =
        await client.getM3u8(hd.toString(), widget.id, userBox.get('token'));
    if (data['message'] != null) {
      showMessage(data['message']);
    }
    if (data['m3u8'] != null) {
      await player.reset();
      setState(() {
        m3u8 = ApiClient.host + data['m3u8'];
        player.setDataSource(m3u8, autoPlay: true);
      });
    }
    Map moviedata = await client.getPlay('movie', id);
    setState(() {
      video['originalname'] = moviedata['movie']['originalname'];
      photos = moviedata['photos'];
    });
    // if (m3u8paths.indexOf(getW(dropdownValue)) > -1) {
    //   setState(() {
    //     video = moviedata['movie'];
    //     photos = data['photos'];
    //   });
    // } else {
    //   setState(() {
    //     dropdownValue = getHd(moviedata['movie']['m3u8paths'][0]['hd']);
    //     video = moviedata['movie'];
    //     photos = data['photos'];
    //   });
    // }
  }
  String getW(String hd) {
    String type;
    if (hd == '240P') {
      type = '320';
    } else if (hd == '360P') {
      type = '480';
    } else if (hd == '480P') {
      type = '640';
    } else if (hd == '640P') {
      type = '1138';
    } else if (hd == '720P') {
      type = '1280';
    } else if (hd == '1080P') {
      type = '1920';
    } else if (hd == '2k') {
      type = '2560';
    } else if (hd == '20000') {
      type = '20000';
    }
    return type;
  }
  Future changeM3u8(String newValue) async {
    String thetype;
    if (newValue == '240P') {
      thetype = '320';
    } else if (newValue == '360P') {
      thetype = '480';
    } else if (newValue == '480P') {
      thetype = '640';
    } else if (newValue == '640P') {
      thetype = '1138';
    } else if (newValue == '720P') {
      thetype = '1280';
    } else if (newValue == '1080P') {
      thetype = '1920';
    } else if (newValue == '2k') {
      thetype = '2560';
    } else if (newValue == '20000') {
      thetype = '20000';
    }
    ApiClient client = new ApiClient();
    userBox.put('hd', thetype);
    Map data =
        await client.getM3u8(thetype, widget.id, userBox.get('token'));
    if (data['message'] != null) {
      showMessage(data['message']);
    }
    if (data['m3u8'] != null) {
      await player.reset();
      setState(() {
        m3u8 = ApiClient.host + data['m3u8'];
        player.setDataSource(m3u8, autoPlay: true);
      });
    }
  }
  Widget info() {
    return dropdownValue == null
        ? Container(
            color: Colors.white,
            child: Center(child: CircularProgressIndicator()))
        : Container(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                          backgroundColor: Colors.white,
                          context: context,
                          builder: (BuildContext bc) {
                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Container(
                                  height: MediaQuery.of(context).size.height *
                                      2 /
                                      3,
                                  child: ListView(
                                    children: <Widget>[
                                      Text(
                                        '简介',
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                      SizedBox(
                                        height: 4.0,
                                      ),
                                      Text(tv != null
                                          ? tv['summary']??'暂无简介'
                                          : video['summary']??'暂无简介'),
                                    ],
                                  )),
                            );
                          });
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            video['originalname'],
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                          SizedBox(height: 2.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Image.asset("assets/play_video.png",
                                  color: Colors.grey, height: 12, width: 12),
                              Text(
                                  tv != null
                                      ? tv['count'].toString() + ' · 查看简介'
                                      : video['count'].toString() + ' · 查看简介',
                                  style: TextStyle(
                                      fontSize: 12.0, color: Colors.grey)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  DropdownButton<String>(
                    dropdownColor: Colors.white,
                    value: dropdownValue,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 20,
                    elevation: 16,
                    style: TextStyle(color: Colors.black87),
                    underline: Container(
                      height: 2,
                      color: Colors.blue,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                      changeM3u8(newValue);
                    },
                    items: List.generate(video['m3u8paths'].length, (index) {
                      String hd = '240P';
                      Map value = video['m3u8paths'][index];
                      hd = getHd(value['hd']);
                      return DropdownMenuItem<String>(
                        value: hd,
                        child: Text(hd),
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
  }

  Widget xuanji() {
    return tv == null
        ? Container()
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('选集'),
              ),
              Container(
                height: 32,
                child: ListView.builder(
                  shrinkWrap: true,
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: tv['episodes'].length,
                  itemBuilder: (context, index) {
                    return Container(
                        height: 32.0,
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                                color: _selectedIndex == index
                                    ? Colors.blue
                                    : Colors.black12,
                                width: 1.0)),
                        child: InkWell(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 15.0),
                            child: Text(
                              tv['episodes'][index]['episode'],
                              style: TextStyle(
                                  color: _selectedIndex == index
                                      ? Colors.blue
                                      : Colors.black87),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                            var id = tv['episodes'][index]['movieid'];
                            changeEpisode(id);
                          },
                        ));
                  },
                ),
              ),
            ],
          );
  }

  Widget buildTagsWidget() {
    List<Widget> lists = [Container()];
    final categorycolor = Helper.hexToColor("#1e87f0");
    Map item = video;
    if (tv != null) {
      item = tv;
    }
    if (item['category'] != null) {
      lists.add(InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return CategoryPage(
              category: item['category'],
            );
          }));
        },
        child: Container(
          padding: EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: categorycolor, width: 1.0),
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          child: Text(
            item['category'],
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 12.0,
                color: categorycolor),
          ),
        ),
      ));
    }
    if (item['tags'].length > 0) {
      lists.addAll(item['tags'].map<Widget>((tag) {
        final color = Helper.hexToColor("#ea5a5a");
        return InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) {
              return TagPage(
                tag: tag,
              );
            }));
          },
          child: Container(
            padding: EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border.all(color: color, width: 1.0),
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            child: Text(
              tag,
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: 12.0,
                  color: color),
            ),
          ),
        );
      }).toList());
    }

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text('标签'),
              padding: EdgeInsets.symmetric(vertical: 8.0),
            ),
            Wrap(runSpacing: 5.0, spacing: 5.0, children: lists),
          ],
        ));
  }

  Widget actions() {
    String title = video['originalname'];
    String shareurl = ApiClient.host;
    bool liked = false;
    String id;
    Map object;
    ApiClient client = new ApiClient();
    if(tv!=null) {
      shareurl += '/play/' + video['_id'];
      liked = likes.containsKey(tv['_id']);
      id = tv["_id"];
      object = tv;
    } else {
      shareurl += '/movie/' + video['_id'];
      liked = likes.containsKey(video["_id"]);
      id = video["_id"];
      object = video;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            liked ? likes.delete(id) : likes.put(id, object);
            if(!liked) {
              showMessage('添加收藏成功，登录后在个人页面中我的收藏中查看！');
            }
          },
          child: Column(
            children: <Widget>[
              Icon(Icons.favorite,color: liked ? Colors.red : Colors.black),
              Text('收藏', style: TextStyle(fontSize: 12.0, color: likes.containsKey(video["_id"]) ? Colors.red : Colors.black,)),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
        GestureDetector(
          onTap: () async {
            if(video['thirdm3u8'] != null && video['thirdm3u8'].length>0) {
              showMessage('此视频不提供下载！');
              return;
            }
            if(userBox.containsKey('user')) {
              Map data = await client.getDownloadPrice(userBox.get('token'), video["_id"]);
              if(data['success'] == 0) {
                showMessage(data['message']);
              } else if (data['success'] == 2) {
                print(ApiClient.host + data['path'].replaceAll('./public', '') + '&id=' + video['_id']);
                if(_permissionReady) {
                  final taskId  = await FlutterDownloader.enqueue(
                  url: ApiClient.host + data['path'].replaceAll('./public', '') +'&id=' + video['_id'],
                  savedDir: _localPath,
                  fileName: video['originalname'],
                  showNotification: true,
                  openFileFromNotification: true);
                  print(taskId);
                  showMessage('开始下载，通知栏中可查看下载状态！');
                } else {
                  showMessage('请开启APP的文件储存权限！');
                }
              } else if (data['success'] == 1) {
                String price = data['price'].toString();
                Map portal = userBox.get('portal');
                String duration = portal['downloadduration'].toString();
                if(!_permissionReady) {
                  showMessage('请开启APP管理中的文件储存权限！');
                  return;
                }
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    return AlertDialog(
                      title: new Text("提示"),
                      content: new Text("您是否愿意使用 $price 积分购买此视频的下载权限，在 $duration 小时内可无限次下载？"),
                      actions: <Widget>[
                        // usually buttons at the bottom of the dialog
                        new FlatButton(
                          child: new Text("关闭"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        new FlatButton(
                          child: new Text("确定"),
                          onPressed: () async {
                            Map data = await client.getAppDownload(userBox.get('token'), video['_id']);
                            if(data['success'] == 1) {
                              print(ApiClient.host + data['path'].replaceAll('./public', ''));
                              if(_permissionReady) {
                                await FlutterDownloader.enqueue(
                                url: ApiClient.host + data['path'].replaceAll('./public', '') + '&id=' + video['_id'],
                                savedDir: _localPath,
                                fileName: video['originalname'],
                                showNotification: true,
                                openFileFromNotification: true);
                                showMessage('开始下载，通知栏中可查看下载状态！');
                              } else {
                                showMessage('请开启APP的文件储存权限！');
                              }
                            } else if (data['success'] == 0) {
                              showMessage(data['message']);
                            }
                          },
                        ),
                      ],
                    );
                  });
              }
            } else {
              showMessage('请登录之后再使用下载功能！');
            }
          },
          child: Column(
            children: <Widget>[
              Icon(Icons.file_download,color: Colors.black),
              Text('下载', style: TextStyle(fontSize: 12.0, color: Colors.black,)),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
        GestureDetector(
          onTap: () {
            String price;
            ApiClient client = new ApiClient();
            Map portal = userBox.get('portal');
            if(video['price']==null) {
              price = portal['price'].toString();
            } else {
              price = video['price'].toString();
            }
            if(userBox.containsKey('user')) {
              showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) {
                return AlertDialog(
                  title: new Text("提示"),
                  content: new Text("是否花费 $price 积分点播此视频完整版？"),
                  actions: <Widget>[
                    // usually buttons at the bottom of the dialog
                    new FlatButton(
                      child: new Text("关闭"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    new FlatButton(
                      child: new Text("确定"),
                      onPressed: () async {
                        Map data = await client.buyMovie(userBox.get('token'), video['_id']);
                        showMessage(data['message']);
                        if(data['success'] == 1) {
                          await player.reset();
                          player.setDataSource(m3u8, autoPlay:true);
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                );
              });
            } else {
              showMessage('请登录之后再使用积分点播！');
            }
          },
          child: Column(
            children: <Widget>[
              Icon(Icons.ondemand_video,color: Colors.black),
              Text('点播', style: TextStyle(fontSize: 12.0, color: Colors.black,)),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
        GestureDetector(
          onTap: () {
            Share.share('$title 在线观看:$shareurl', subject: '$title');
          },
          child: Column(
            children: <Widget>[
              Icon(Icons.share,color: Colors.black),
              Text('分享', style: TextStyle(fontSize: 12.0, color: Colors.black,)),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ],
    );
  }
  Widget pushMovie() {
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

  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }
  Future<bool> _checkPermission() async {
    PermissionStatus permission = await Permission.storage.status;
    if (permission != PermissionStatus.granted) {
      if (await Permission.storage.request().isGranted) {
        return true;
      }
    } else {
      return true;
    }
    return false;
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
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          );
  }
  @override
  Widget build(BuildContext context) {
    // if (m3u8 == null) {
    //   return Scaffold(
    //       body: Center(
    //     child: CupertinoActivityIndicator(),
    //   ));
    // }
    return Scaffold(
        appBar: AppBar(title: Text('视频播放')),
        body: ValueListenableBuilder(
          valueListenable: likes.listenable(),
          builder: (context, Box<dynamic> box, _) {
            return video == null ? Center(child: CircularProgressIndicator(),) : LoadingMoreCustomScrollView(
              shrinkWrap: true,
            slivers: <Widget>[
                SliverList(delegate: SliverChildListDelegate([
                  AspectRatio(aspectRatio: 1.75, child: 
                    m3u8 == null
                          ? Container(
                              color: Colors.black,
                              child: Center(child: CircularProgressIndicator()))
                          : FijkView(
                              color: Colors.black,
                              player: player,
                              fit: FijkFit.contain,
                              panelBuilder: fijkPanel2Builder(fill: true),
                            )
                  ),
                  info(),
                  actions(),
                  Divider(),
                  xuanji(),
                  tv != null ? SizedBox(height: 10.0) : SizedBox(height: 0),
                  buildTagsWidget(),
                  Divider(),
                  SizedBox(height: 10.0),
                  MovieDetailPhotots(photos, video['_id']),
                  Divider(),
                ])),
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('猜您喜欢'),
                ),),
                pushMovie(),
                // LikeViews(video['likes'], player)
              ],
            );
          })
        
        
        );
  }
}

Widget titleWidget(String title) {
  return Padding(
    padding: const EdgeInsets.only(
      top: 16,
      left: 8,
      right: 8,
    ),
    child: Text(
      title,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      maxLines: 2,
      style: TextStyle(
        fontSize: 16,
      ),
    ),
  );
}

String getHd(int path) {
  String hd = '';
  if (path == 320) {
    hd = '240P';
  } else if (path == 480) {
    hd = '360P';
  } else if (path == 640) {
    hd = '480P';
  } else if (path == 1138) {
    hd = '640P';
  } else if (path == 1280) {
    hd = '720P';
  } else if (path == 1920) {
    hd = '1080P';
  } else if (path == 2560) {
    hd = '2K';
  } else if (path == 20000) {
    hd = '原画';
  }
  return hd;
}

///
/// Views Widget
///
Widget viewsWidget(int count) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Text(
      "$count 次播放",
      textAlign: TextAlign.left,
      softWrap: true,
      maxLines: 2,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    ),
  );
}

class PhotoItem extends StatelessWidget {
  final String photo;
  final int index;
  final List<ImageProvider> providers;
  final List imageUrls;

  const PhotoItem(this.photo, this.index, this.providers, this.imageUrls);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8, bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => PhotoPreview(
                  providers: providers, index: index, imageUrls: imageUrls)));
        },
        child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Hero(
              tag: 'photo$index',
              child: Image(
                image: CachedNetworkImageProvider(ApiClient.host + photo),
                width: 160,
                fit: BoxFit.cover,
              ),
            )),
      ),
    );
  }
}

class MovieDetailPhotots extends StatelessWidget {
  final List photos;
  final String movieId;

  const MovieDetailPhotots(this.photos, this.movieId);

  @override
  Widget build(BuildContext context) {
    List<ImageProvider> providers = [];
    List<Widget> children = [];

    for (var i = 0; i < photos.length; i++) {
      children.add(PhotoItem(photos[i], i, providers, photos));
      providers.add(CachedNetworkImageProvider(ApiClient.host + photos[i]));
    }

    return Container(
      // padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('截图', style: TextStyle(color: Colors.black)),
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox.fromSize(
            size: Size.fromHeight(120),
            child:
                ListView(scrollDirection: Axis.horizontal, children: children),
          )
        ],
      ),
    );
  }
}

class LikeViews extends StatelessWidget {
  final List lists;
  final FijkPlayer player;
  LikeViews(this.lists, this.player);
  @override
  Widget build(BuildContext context) {
    Widget videoSection(Map video) {
      return InkWell(
        onTap: () {
          player.pause();
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PlayPage(id: video['_id'])));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: AspectRatio(
                aspectRatio: 1.75,
                child: Image(
                  image: CachedNetworkImageProvider(video['poster']),
                ),
              ),
            ),
            SizedBox(height: 6.0),
            Text(
              video['originalname'] ?? video['title'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: TextStyle(fontSize: 14.0),
            )
          ],
        ),
      );
    }

    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(bottom: 10),
              child: Text('猜您喜欢',
                  style: TextStyle(fontSize: 16, color: Colors.black)),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 10 / 8.0,
                crossAxisSpacing: 8,
              ),
              itemCount: lists.length,
              itemBuilder: (context, index) {
                return videoSection(lists[index]);
              },
            ),
          ],
        ));
  }
}
class CommonExtentSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  CommonExtentSliverPersistentHeaderDelegate(this.child, this.extent);
  final Widget child;
  final double extent;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(CommonExtentSliverPersistentHeaderDelegate oldDelegate) {
    //print('shouldRebuild---------------');
    return oldDelegate != this;
  }
}
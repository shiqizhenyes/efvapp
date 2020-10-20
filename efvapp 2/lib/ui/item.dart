import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freevideo/api/api_client.dart';
import 'package:freevideo/article.dart';
import 'package:freevideo/image.dart';
import 'package:freevideo/utils/helper.dart';
import 'package:freevideo/video_play.dart';

Future showMessage(String msg) {
  return Fluttertoast.showToast(msg: msg, backgroundColor: Colors.black54, textColor: Colors.white, gravity: ToastGravity.CENTER, toastLength: Toast.LENGTH_LONG);
}
Widget buildArticleFlowItem(BuildContext c, dynamic item, int index,
    {bool konwSized = true}) {
  return GestureDetector(
    onTap: () {
      Navigator.of(c).push(
          MaterialPageRoute(builder: (_) => ArticlePage(id: item['_id'])));
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildImage(item, konwSized, '文章', c, true),
        SizedBox(
          height: 5.0,
        ),
        buildTitleWidget(item),
      ],
    ),
  );
}

Widget buildImageFlowItem(BuildContext c, dynamic item, int index,
    {bool konwSized = true}) {
  return GestureDetector(
    onTap: () {
      Navigator.of(c)
          .push(MaterialPageRoute(builder: (_) => ImagePage(id: item['_id'])));
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildImage(
            item, konwSized, item['images'].length.toString() + ' P', c, true),
      ],
    ),
  );
}

Widget _buildImage(dynamic item, bool konwSized, String tip, BuildContext c,
    bool isWaterflow) {
  final fontSize = 12.0;
  String host = ApiClient.host;

  Widget image = Stack(
    children: <Widget>[
      ExtendedImage.network(
        isWaterflow
            ? host + item['poster2']['url']
            : host + item['poster'].replaceAll('./public', ''),
        shape: BoxShape.rectangle,
        clearMemoryCacheWhenDispose: true,
        border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.0),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
        loadStateChanged: (value) {
          if (value.extendedImageLoadState == LoadState.loading) {
            Widget loadingWidget = Container(
              alignment: Alignment.center,
              color: Colors.grey.withOpacity(0.8),
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation(Theme.of(c).primaryColor),
              ),
            );
            if (!konwSized) {
              //todo: not work in web
              loadingWidget = AspectRatio(
                aspectRatio: 1.0,
                child: loadingWidget,
              );
            }
            return loadingWidget;
          } else if (value.extendedImageLoadState == LoadState.completed) {
            item['imageRawSize'] = Size(
                value.extendedImageInfo.image.width.toDouble(),
                value.extendedImageInfo.image.height.toDouble());
          }
          return null;
        },
      ),
      Positioned(
        top: 5.0,
        right: 5.0,
        child: Container(
          padding: EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.6),
            border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.0),
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          child: Text(
            tip,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize, color: Colors.white),
          ),
        ),
      )
    ],
  );
  if (konwSized) {
    image = AspectRatio(
      aspectRatio: item['poster2']['width'] / item['poster2']['height'],
      child: image,
    );
  } else if (item['imageRawSize'] != null) {
    image = AspectRatio(
      aspectRatio: item['imageRawSize'].width / item['imageRawSize'].height,
      child: image,
    );
  }
  return image;
}

Widget gridItem(BuildContext c, Map item) {
  return GestureDetector(
    onTap: () {
      Navigator.of(c).push(new MaterialPageRoute(builder: (_) {
        String id = item['title'] != null
            ? item['episodes'][0]['movieid']
            : item['_id'];
        return PlayPage(id: id, type: item['title'] != null ? 'tv' : 'movie');
      }));
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.75,
          child: Container(
              child: ExtendedImage.network(
                  ApiClient.host + item['poster'].replaceAll('./public', ''),
                  fit: BoxFit.cover,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ))),
        ),
        SizedBox(
          height: 5.0,
        ),
        buildTitleWidget(item),
        SizedBox(height: 5.0),
      ],
    ),
  );
}

Widget buildWaterfallFlowItem(BuildContext c, dynamic item, int index,
    {bool konwSized = true}) {
  final fontSize = 12.0;
  String host = ApiClient.host;

  Widget image = Stack(
    children: <Widget>[
      ExtendedImage.network(
        host + item['poster2']['url'],
        shape: BoxShape.rectangle,
        clearMemoryCacheWhenDispose: true,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
        loadStateChanged: (value) {
          if (value.extendedImageLoadState == LoadState.loading) {
            Widget loadingWidget = Container(
              alignment: Alignment.center,
              color: Colors.grey.withOpacity(0.8),
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation(Theme.of(c).primaryColor),
              ),
            );
            if (!konwSized) {
              //todo: not work in web
              loadingWidget = AspectRatio(
                aspectRatio: 1.0,
                child: loadingWidget,
              );
            }
            return loadingWidget;
          } else if (value.extendedImageLoadState == LoadState.completed) {
            item['imageRawSize'] = Size(
                value.extendedImageInfo.image.width.toDouble(),
                value.extendedImageInfo.image.height.toDouble());
          }
          return null;
        },
      ),
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black54],
                begin: Alignment.topCenter,
                end: Alignment(0, 1),
                stops: [0.7, 1])),
      ),
      Positioned(
        bottom: 7.0,
        right: 5.0,
        child: Container(
          padding: EdgeInsets.all(1.0),
          // decoration: BoxDecoration(
          //   color: Colors.grey.withOpacity(0.6),
          //   border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.0),
          //   borderRadius: BorderRadius.all(
          //     Radius.circular(5.0),
          //   ),
          // ),
          child: Text(
            item['title'] != null ? '剧集' : '视频',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize, color: Colors.white),
          ),
        ),
      ),
      Positioned(
        bottom: 5.0,
        left: 5.0,
        child: Container(
          padding: EdgeInsets.all(1.0),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.play_circle_filled,
                color: Colors.white,
                size: 18.0,
              ),
              SizedBox(
                width: 3.0,
              ),
              Text(
                item['count'].toString(),
                style: TextStyle(color: Colors.white, fontSize: fontSize),
              )
            ],
          ),
        ),
      ),
    ],
  );
  if (konwSized) {
    image = AspectRatio(
      aspectRatio: item['poster2']['width'] / item['poster2']['height'],
      child: image,
    );
  } else if (item['imageRawSize'] != null) {
    image = AspectRatio(
      aspectRatio: item['imageRawSize'].width / item['imageRawSize'].height,
      child: image,
    );
  }

  return GestureDetector(
    onTap: () {
      Navigator.of(c).push(new MaterialPageRoute(builder: (_) {
        String id = item['title'] != null
            ? item['episodes'][0]['movieid']
            : item['_id'];
        return PlayPage(id: id, type: item['title'] != null ? 'tv' : 'movie');
      }));
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        image,
        SizedBox(
          height: 5.0,
        ),
        buildTitleWidget(item),
        SizedBox(
          height: 5.0,
        ),
        buildTagsWidget(item),
        SizedBox(
          height: 10.0,
        )
      ],
    ),
  );
}

Widget buildTitleWidget(Map item) {
  return Text(
    item['originalname'] ?? item['title'],
    overflow: TextOverflow.ellipsis,
    softWrap: true,
    maxLines: 2,
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget buildTagsWidget(
  Map item, {
  int maxNum = 6,
}) {
  final fontSize = 12.0;
  List<Widget> lists = [Container()];
  final categorycolor = Helper.hexToColor("#1e87f0");
  if (item['category'] != null) {
    lists.add(Container(
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
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10.0, color: categorycolor),
      ),
    ));
  }
  if (item['tags'].length > 0) {
    lists.addAll(item['tags'].take(maxNum).map<Widget>((tag) {
      final color = Helper.hexToColor("#ea5a5a");
      return Container(
        padding: EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: color, width: 1.0),
          borderRadius: BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Text(
          tag,
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 10.0, color: color),
        ),
      );
    }).toList());
  }

  return Wrap(runSpacing: 5.0, spacing: 5.0, children: lists);
}

Widget buildBottomWidget(Map item, {bool showAvatar = false}) {
  final fontSize = 12.0;
  return Row(
    children: <Widget>[
      showAvatar
          ? ExtendedImage.network(
              item['avatar'],
              width: 25.0,
              height: 25.0,
              shape: BoxShape.circle,
              //enableLoadState: false,
              border:
                  Border.all(color: Colors.grey.withOpacity(0.4), width: 1.0),
              loadStateChanged: (state) {
                if (state.extendedImageLoadState == LoadState.completed) {
                  return null;
                }
                return Image.asset(
                  'assets/avatar.jpg',
                  package: 'flutter_candies_demo_library',
                );
              },
            )
          : Container(),
      Expanded(
        child: Container(),
      ),
      Row(
        children: <Widget>[
          Icon(
            Icons.play_circle_filled,
            color: Colors.amberAccent,
            size: 18.0,
          ),
          SizedBox(
            width: 3.0,
          ),
          Text(
            item['count'].toString(),
            style: TextStyle(color: Colors.black, fontSize: fontSize),
          )
        ],
      ),
    ],
  );
}

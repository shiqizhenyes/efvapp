import 'package:extended_image/extended_image.dart';
import 'package:extended_list/extended_list.dart';
import 'package:flutter/material.dart';
import 'package:freevideo/api/api_client.dart';
import 'package:freevideo/utils/helper.dart';
import 'package:loading_more_list/loading_more_list.dart';

class ImagePage extends StatefulWidget {
  final String id;
  ImagePage({this.id});

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> with TickerProviderStateMixin {
  Map image = new Map();
  ImageRepository imageRepository;
  AnimationController _colorAnimationController;
  Animation _colorTween;

  @override
  void initState() {
    _colorAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    _colorTween =
        ColorTween(begin: Helper.hexToColor("#333333"), end: Colors.transparent)
            .animate(_colorAnimationController);
    super.initState();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
    imageRepository?.dispose();
  }

  Future getData() async {
    ApiClient client = new ApiClient();
    Map data = await client.getImage(widget.id);
    setState(() {
      image = data['image'];
      imageRepository = ImageRepository(images: image['images']);
    });
  }

  bool _scrollListener(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.axis == Axis.vertical) {
      _colorAnimationController.animateTo(scrollInfo.metrics.pixels / 300);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimationController,
      builder: (BuildContext context, Widget child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: _colorTween.value,
                title: image['title'] == null
                    ? Text('图集漫画')
                    : Text(image['title'])),
            body: NotificationListener<ScrollNotification>(
              onNotification: _scrollListener,
              child: Container(
                  child: image['title'] == null
                      ? CircularProgressIndicator()
                      : Container(
                          child: _extendImages(image),
                        )),
            ));
      },
    );
  }
}

Widget _extendImages(Map image) {
  List images = image['images'];
  return ExtendedListView.builder(
    extendedListDelegate: ExtendedListDelegate(

        /// follow max child trailing layout offset and layout with full cross axis extend
        /// last child as loadmore item/no more item in [ExtendedGridView] and [WaterfallFlow]
        /// with full cross axis extend
        //  LastChildLayoutType.fullCrossAxisExtend,

        /// as foot at trailing and layout with full cross axis extend
        /// show no more item at trailing when children are not full of viewport
        /// if children is full of viewport, it's the same as fullCrossAxisExtend
        //  LastChildLayoutType.foot,
        lastChildLayoutTypeBuilder: (index) => index == images.length
            ? LastChildLayoutType.foot
            : LastChildLayoutType.none,
        collectGarbage: (List<int> garbages) {
          print("collect garbage : $garbages");
        },
        viewportBuilder: (int firstIndex, int lastIndex) {
          print("viewport : [$firstIndex,$lastIndex]");
        }),
    //itemExtent: 50.0,
    itemBuilder: (c, index) {
      return Container(
          child: ExtendedImage.network(images[index], cache: false,
              loadStateChanged: (value) {
        if (value.extendedImageLoadState == LoadState.loading) {
          Widget loadingWidget = Container(
            alignment: Alignment.center,
            color: Colors.grey.withOpacity(0.8),
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
            ),
          );
          //todo: not work in web
          loadingWidget = AspectRatio(
            aspectRatio: 1.0,
            child: loadingWidget,
          );
          return loadingWidget;
        }
        return null;
      }));
    },
    itemCount: images.length,
  );
}

class ImageRepository extends LoadingMoreBase<String> {
  bool _hasMore = true;
  bool forceRefresh = false;
  final List images;
  ImageRepository({this.images});
  int page = 1;
  int size = 5;

  @override
  bool get hasMore => (_hasMore && length < 300) || forceRefresh;

  @override
  Future<bool> refresh([bool clearBeforeRequest = false]) async {
    _hasMore = true;
    page = 1;
    //force to refresh list when you don't want clear list before request
    //for the case, if your list already has 20 items.
    forceRefresh = !clearBeforeRequest;
    var result = await super.refresh(clearBeforeRequest);
    forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    List feedList;
    var isSuccess = false;
    try {
      feedList = images.skip(page - 1).take(size).toList();
      if (page == 1) {
        clear();
      }

      for (var item in feedList) {
        if (!contains(item) && hasMore) add(item);
      }

      _hasMore = feedList.isNotEmpty;
      page++;
//      this.clear();
//      _hasMore=false;
      isSuccess = true;
    } catch (exception, stack) {
      isSuccess = false;
      print(exception);
      print(stack);
    }
    return isSuccess;
  }
}

Widget _loadmoreImages(
    Map image, BuildContext c, ImageRepository imageRepository) {
  return LoadingMoreList(
    ListConfig<dynamic>(
      physics: const ClampingScrollPhysics(),
      itemBuilder: (c, item, index) {
        Map size = new Map();
        Widget theimage = ExtendedImage.network(
          item,
          cache: false,
          shape: BoxShape.rectangle,
          clearMemoryCacheWhenDispose: true,
          loadStateChanged: (value) {
            if (value.extendedImageLoadState == LoadState.loading) {
              Widget loadingWidget = Container(
                alignment: Alignment.center,
                color: Colors.grey.withOpacity(0.8),
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                ),
              );
              //todo: not work in web
              loadingWidget = AspectRatio(
                aspectRatio: 1.0,
                child: loadingWidget,
              );
              return loadingWidget;
            } else if (value.extendedImageLoadState == LoadState.completed) {
              size['imageRawSize'] = Size(
                  value.extendedImageInfo.image.width.toDouble(),
                  value.extendedImageInfo.image.height.toDouble());
            }
            return null;
          },
        );
        if (size['imageRawSize'] != null) {
          theimage = AspectRatio(
            aspectRatio:
                size['imageRawSize'].width / size['imageRawSize'].height,
            child: theimage,
          );
        }
        return theimage;
      },
      sourceList: imageRepository,
      padding: EdgeInsets.all(0.0),
      // collectGarbage: (List<int> indexes) {
      //   ///collectGarbage
      //   indexes.forEach((index) {
      //     final item = imageRepository[index];
      //     final provider = ExtendedNetworkImageProvider(
      //       item,
      //     );
      //     provider.evict();
      //   });
      // },
    ),
  );
}

Widget _buildImages(Map image, BuildContext c) {
  List images = image['images'];
  return Column(
      children: images.map((img) {
    Map size = new Map();
    Widget theimage = ExtendedImage.network(
      img,
      cache: false,
      shape: BoxShape.rectangle,
      clearMemoryCacheWhenDispose: true,
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
          //todo: not work in web
          loadingWidget = AspectRatio(
            aspectRatio: 1.0,
            child: loadingWidget,
          );
          return loadingWidget;
        } else if (value.extendedImageLoadState == LoadState.completed) {
          size['imageRawSize'] = Size(
              value.extendedImageInfo.image.width.toDouble(),
              value.extendedImageInfo.image.height.toDouble());
        }
        return null;
      },
    );
    if (size['imageRawSize'] != null) {
      theimage = AspectRatio(
        aspectRatio: size['imageRawSize'].width / size['imageRawSize'].height,
        child: theimage,
      );
    }
    return theimage;
  }).toList());
}

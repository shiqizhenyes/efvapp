import 'package:freevideo/api/api_client.dart';
import 'package:hive/hive.dart';
import 'package:loading_more_list/loading_more_list.dart';

class Repository extends LoadingMoreBase<Map> {
  bool _hasMore = true;
  bool forceRefresh = false;
  final String pagetag;
  final String tag;
  final String category;
  final String type;
  final String tags;
  Repository({this.pagetag, this.tag='', this.tags='', this.category='', this.type='movie,tv'});
  int page = 1;
  int size = 18;
  Box likes = Hive.box('likes');
  Box userBox = Hive.box('user');

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
    ApiClient client = new ApiClient();
    List feedList;
    var isSuccess = false;
    try {
      //to show loading more clearly, in your app,remove this
      print(pagetag);
      switch (pagetag) {
        case "index":
          feedList = await client.getIndex(page, size);
          break;
        case "tag":
          feedList = await client.getVideosByTag(page, size, tag);
          break;
        case "category":
          feedList = await client.getVideosByCategory(page, size, category);
          break;
        case "article":
          feedList = await client.getArticles(page, size, type);
          break;
        case "image":
          feedList = await client.getArticles(page, size, type);
          break;
        case "tags":
          feedList = await client.getVideosByTags(page, size, tags);
          break;
        case "collection":
          try {
            var tmp = likes.values.take(size).skip((page-1)*size);
            feedList = tmp.toList();
          } catch (e) {
            feedList = [];
          }
          break;
        case "userfollow":
          var userfollow = userBox.get('userfollow');
          if(userfollow != null && userfollow.length > 0) {
            feedList = await client.getVideosByTags(page, size, userfollow.join(','));
          } else {
            feedList = [];
          }
          break;
        default:
          break;
      }
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
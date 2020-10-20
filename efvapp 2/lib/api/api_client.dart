import 'package:dio/dio.dart';
import 'dart:async';

class ApiClient {
  static const String baseUrl = 'https://www.leimulamu.com/api2/';
  static const String host = 'https://www.leimulamu.com';
  static const String apiKey = 'domybestthingsisgood2';
  static String title = '雷姆拉姆网';

  var dio = ApiClient.createDio();

  // 获取视频播放信息
  Future<dynamic> getVideo(String movieId) async {
    Response<Map> response = await dio.get('getvideo/$movieId');
    return response.data;
  }

  // 获取首页视频
  Future<dynamic> getIndex(int page, int size) async {
    Response<List> response = await dio.get('getcontents',
        queryParameters: {"page": page, "size": size, "type": 'movie,tv'});
    return response.data;
  }

  // 获取导航及用户状态
  Future<dynamic> getNav() async {
    Response<Map> response = await dio.get('getnav');
    return response.data;
  }

  // 每次登录都检测token是否过期
  Future<dynamic> checkAuth(dynamic token) async {
    Response<Map> response =
        await dio.post('checkauth', data: {"token": token});
    return response.data;
  }

  // 每日签到API
  Future<dynamic> checkIn(dynamic token) async {
    Response<Map> response = await dio.post('checkin', data: {"token": token});
    return response.data;
  }

  //获取热门页面 年度、全部、月度、一周
  Future<dynamic> getHotsBydate() async {
    Response<Map> response = await dio.get('gethotsbydate');
    return response.data;
  }

  // 获取发现页面使用的标签和大分类
  Future<dynamic> getDiscover() async {
    Response<Map> response = await dio.get('gettags');
    return response.data;
  }

  // 试试手气获取随机推荐的电影和剧集
  Future<dynamic> getRandom() async {
    Response<Map> response = await dio.get('getrandom');
    return response.data;
  }

  // 标签页面获取内容
  Future<dynamic> getVideosByTag(
    int page,
    int size,
    String tag,
  ) async {
    Response<List> response = await dio.get('getcontents', queryParameters: {
      "tag": tag,
      "page": page,
      "size": size,
      "type": 'movie,tv'
    });
    return response.data;
  }

  // 播放页面获取推荐视频
  Future<dynamic> getVideosByTags(
    int page,
    int size,
    String tags,
  ) async {
    Response<List> response = await dio.get('getcontents', queryParameters: {
      "tags": tags,
      "page": page,
      "size": size,
      "type": 'movie,tv'
    });
    return response.data;
  }

  // 分类页面获取内容
  Future<dynamic> getVideosByCategory(
    int page,
    int size,
    String category,
  ) async {
    Response<List> response = await dio.get('getcontents', queryParameters: {
      "category": category,
      "page": page,
      "size": size,
      "type": 'movie,tv'
    });
    return response.data;
  }

  // 图集图片获取内容
  Future<dynamic> getImages(
    int page,
    int size,
    String type,
  ) async {
    Response<Map> response = await dio.get('getcontents',
        queryParameters: {"page": page, "size": size, "type": type});
    return response.data;
  }

  // 获取单个图片中的内容
  Future<dynamic> getImage(String id) async {
    Response<Map> response =
        await dio.get('getimage', queryParameters: {"id": id});
    return response.data;
  }

  // 资讯文章获取内容
  Future<dynamic> getArticles(
    int page,
    int size,
    String type,
  ) async {
    Response<List> response = await dio.get('getcontents',
        queryParameters: {"page": page, "size": size, "type": type});
    return response.data;
  }

  // 获取单个文章内容
  Future<dynamic> getArticle(String id) async {
    Response<Map> response =
        await dio.get('getarticle', queryParameters: {"id": id});
    return response.data;
  }

  // 获取VIP用户组信息
  Future<dynamic> getVipgroups() async {
    Response<Map> response = await dio.get('getvipgroups');
    return response.data;
  }

  // 获取VIP用户组价格，根据用户组ID和开通天数
  Future<dynamic> getJiage(String id, String duration) async {
    Response<Map> response = await dio
        .get('getjiage', queryParameters: {"group": id, "duration": duration});
    return response.data;
  }

  // 积分购买VIP用户组, 参数 用户组ID，开通天数，用户登录token，成功返回{success:1, message}
  Future<dynamic> scoreBuyVip(String id, String duration, String token) async {
    Response<Map> response = await dio.post('scorebuyvip',
        data: {"vipgroup": id, "duration": duration, "token": token});
    return response.data;
  }

  // 直接金钱购买VIP用户组, 参数 用户组ID，开通天数，用户登录token， 成功返回创建的订单id
  Future<dynamic> directBuyVip(String id, String duration, String token) async {
    Response<Map> response = await dio.post('directbuyvip',
        data: {"group": id, "duration": duration, "token": token});
    return response.data;
  }

  // 获取订单详情, 根据订单ID，返回支付类型和订单详情。
  Future<dynamic> getItem(String id) async {
    Response<Map> response =
        await dio.get('getitem', queryParameters: {"id": id});
    return response.data;
  }

  // 请求码支付接口，根据订单ID，和码支付类型（1是支付宝，2是QQ支付，3是微信支付），成功返回支付链接。
  Future<dynamic> postCodePay(String id, int type) async {
    Response<Map> response =
        await dio.post('codepay', data: {"id": id, "type": type});
    return response.data;
  }

  // 用户登录账号 通过邮箱和密码
  Future<dynamic> postLogin(String email, String password) async {
    Response<Map> response = await dio
        .post('postlogin', data: {"email": email, "password": password});
    return response.data;
  }

  // 用户注册账号 通过邮箱和密码
  Future<dynamic> postRegister(
      String email, String password, String username) async {
    Response<Map> response = await dio.post('postregister',
        data: {"email": email, "password": password, "username": username});
    return response.data;
  }

  // 使用卡劵，提供卡号和token，返回success和message
  Future<dynamic> postUseCard(String token, String card) async {
    Response<Map> response =
        await dio.post('usecard', data: {"token": token, "card": card});
    return response.data;
  }

  // 获取登录用户的信息
  Future<dynamic> getUser(String id) async {
    Response<Map> response =
        await dio.get('getuser', queryParameters: {"id": id});
    return response.data;
  }

  // 购买积分，提供购买积分数和token，返回success和item订单详情
  Future<dynamic> buyScore(String token, String score) async {
    Response<Map> response =
        await dio.post('buyscore', data: {"token": token, "score": score});
    return response.data;
  }

  // 积分点播视频，传递参数token和视频的id
  Future<dynamic> buyMovie(String token, String id) async {
    Response<Map> response =
        await dio.post('buymovie', data: {"token": token, "id": id});
    return response.data;
  }

  // 获取视频下载的价格，如果已经购买过则直接返回path和success2，传递video的id, 用户的token
  Future<dynamic> getDownloadPrice(String token, String id) async {
    Response<Map> response = await dio
        .get('getdownloadprice', queryParameters: {"token": token, "id": id});
    return response.data;
  }

  // 获取推荐视频。
  Future<dynamic> getPushMovies() async {
    Response<Map> response = await dio.get('pushmovies');
    return response.data;
  }

  // 积分购买下载权限，传递id和token，返回path，根据path构建自己的下载管理器。
  Future<dynamic> getAppDownload(String token, String id) async {
    Response<Map> response = await dio
        .get('appdownload', queryParameters: {"token": token, "id": id});
    return response.data;
  }

  // 播放页获取视频信息，传递type:tv or movie, id，返回视频相关信息。
  Future<dynamic> getPlay(String type, String id) async {
    Response<Map> response =
        await dio.get('getplay', queryParameters: {"type": type, "id": id});
    return response.data;
  }

  // 关注或取消关注标签，传递token和tag，返回success和message
  Future<dynamic> toggleFollow(String token, String tag) async {
    Response<Map> response =
        await dio.post('toggleuserfollow', data: {"token": token, "tag": tag});
    return response.data;
  }

  // 播放页获取m3u8地址，传递token,id,type，返回m3u8地址及提示。
  Future<dynamic> getM3u8(String type, String id, String token) async {
    Response<Map> response = await dio.get('getm3u8',
        queryParameters: {"type": type, "id": id, "token": token});
    return response.data;
  }

  // 搜索视频
  Future<dynamic> getSearch(String q, int page, int size) async {
    Response<List> response = await dio.get('getcontents', queryParameters: {
      "q": q,
      "page": page,
      "size": size,
      "type": "movie,tv"
    });
    return response.data;
  }

  // 热门视频
  Future<dynamic> getHots() async {
    Response<List> response = await dio.get('gethots');
    return response.data;
  }

  static Dio createDio() {
    var options = BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: 10000,
        receiveTimeout: 100000,
        headers: {'token': apiKey});
    return Dio(options);
  }
}

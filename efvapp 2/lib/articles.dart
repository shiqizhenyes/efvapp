import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freevideo/ui/item.dart';
import 'package:freevideo/ui/repository.dart';
import 'package:loading_more_list/loading_more_list.dart';

import 'utils/screen_util.dart';

class ArticlesPage extends StatefulWidget {

  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  Repository listSourceRepository;

  @override
  void initState() {
    // TODO: implement initState
    listSourceRepository = Repository(pagetag: 'article', type: 'article');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    listSourceRepository.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('资讯文章'),
      ),
      body: LayoutBuilder(
        builder: (c, data) {
          final crossAxisCount = max(
              data.maxWidth ~/ (ScreenUtil.instance.screenWidthDp / 2.0), 2);
          return LoadingMoreList(
            ListConfig<dynamic>(
              waterfallFlowDelegate: WaterfallFlowDelegate(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemBuilder: buildArticleFlowItem,
              sourceList: listSourceRepository,
              padding: EdgeInsets.all(5.0),
              lastChildLayoutType: LastChildLayoutType.foot,
            ),
          );
        },
      )
    );
  }
}
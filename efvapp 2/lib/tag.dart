import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freevideo/ui/item.dart';
import 'package:freevideo/ui/repository.dart';
import 'package:loading_more_list/loading_more_list.dart';

import 'utils/screen_util.dart';

class TagPage extends StatefulWidget {
  final String tag;
  TagPage({this.tag});

  @override
  _TagPageState createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  List lists = new List();
  Map navbar = new Map();
  List categories = new List();
  Repository listSourceRepository;

  @override
  void initState() {
    // TODO: implement initState
    listSourceRepository = Repository(pagetag: 'tag', tag: widget.tag);
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
        title: Text('标签：'+widget.tag),
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
              itemBuilder: buildWaterfallFlowItem,
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
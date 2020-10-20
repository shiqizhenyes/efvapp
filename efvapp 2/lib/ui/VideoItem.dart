import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freevideo/ui/web_view.dart';

import '../video_play.dart';

class VideoItem extends StatelessWidget {
  VideoItem(this.video);

  final Map video;

  @override
  Widget build(BuildContext context) {
    return _buildTiles(context);
  }

  Widget _buildTiles(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (video['type'] == 'ad') {
          Navigator.push(context, CupertinoPageRoute(builder: (context) {
            return WebView(url: video['link'], title: video['title']);
          }));
          return;
        }
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PlayPage(id: video['_id'])));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Hero(
                tag: video['_id'],
                child: Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: Color.fromRGBO(2, 18, 37, 0.8),
                        child: AspectRatio(
                          aspectRatio: 1.75,
                          child: Image(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(
                                video['poster'] ?? video['img']),
                          ),
                        ),
                        margin: EdgeInsets.zero,
                      ),
                    ),
                    Icon(
                      Icons.play_circle_outline,
                      size: 64,
                      color: Colors.white,
                    )
                  ],
                  alignment: Alignment(0, 0),
                  fit: StackFit.passthrough,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 8,
                      right: 8,
                      bottom: 8,
                    ),
                    child: CircleAvatar(
                      child: video['type'] == 'video'
                          ? Text('EFV', style: TextStyle(fontSize: 12))
                          : Text(
                              '广告',
                              style: TextStyle(fontSize: 12),
                            ),
                      backgroundColor:
                          video['type'] == 'ad' ? Colors.red : Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 16,
                            left: 8,
                            right: 8,
                          ),
                          child: Text(
                            video['originalname'] ?? video['title'],
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            right: 8,
                            bottom: 8,
                          ),
                          child: Text(
                            video['type'] == 'ad'
                                ? video['body']
                                : video['count'].toString() + " 次播放",
                            softWrap: true,
                            maxLines: 2,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

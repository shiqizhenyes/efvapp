// 此代码来源于https://github.com/Mayandev/morec/blob/9c70a979ff92bef5dc9c9b06d3cda377f0a83f9e/lib/widget/web_view_scene.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:share/share.dart';


class WebView extends StatefulWidget {
  final String url;
  final String title;

  WebView({@required this.url, this.title});


  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: this.widget.url,

      appBar: AppBar(
        elevation: 0,
        title: Text(this.widget.title ?? ''),
        leading: GestureDetector(
            onTap: back,
            child: Icon(Icons.arrow_back),
          ),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              Share.share(this.widget.url);
            },
            child: Icon(Icons.share),
          ),
        ],
      ),
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      initialChild: Container(
        child: const Center(
          child: CupertinoActivityIndicator()
        ),
      ),
    );
  }

   // 返回上个页面
  back() {
    Navigator.pop(context);
  }
}
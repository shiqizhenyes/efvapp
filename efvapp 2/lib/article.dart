import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:freevideo/api/api_client.dart';

class ArticlePage extends StatefulWidget {
  final String id;
  ArticlePage({this.id});

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  Map article = new Map();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  Future getData() async {
    ApiClient client = new ApiClient();
    Map data = await client.getArticle(widget.id);
    setState(() {
      article = data['article'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('文章')),
        body: Container(
            child: article['title'] == null
                ? CircularProgressIndicator()
                : Container(
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        _buildTitle(article),
                        SizedBox(height: 5.0),
                        _buildInfo(article),
                        Markdown(
                          data: article['contentmd'],
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                color: Colors.black87,
                                  fontSize: 14.0, )),
                        ),
                      ],
                    ),
                  )));
  }
}

Widget _buildInfo(Map article) {
  return Container(
    padding: EdgeInsets.only(left: 16.0, right: 16.0),
    child: Row(
      children: <Widget>[Text('用户 admin ' + '发表于：' + article['publishdate'], style: TextStyle(color:Colors.black54),)],
    ),
  );
}

Widget _buildTitle(Map article) {
  return Container(
    padding: EdgeInsets.only(left: 16.0, top: 10.0, right: 16.0),
    child: Text(
      article['title'],
      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:freevideo/api/api_client.dart';
import 'package:freevideo/video_play.dart';

class SearchScreen extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ResultsList(query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return SuggestionList();
  }
}

class ResultsList extends StatefulWidget {
  const ResultsList({this.query});
  final String query;
  @override
  _ResultsListState createState() => _ResultsListState();
}

class _ResultsListState extends State<ResultsList> {
  List results = new List();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getResults(query: widget.query);
  }

  getResults({String query}) async {
    ApiClient apiClient = new ApiClient();
    List data = await apiClient.getSearch(query, 1, 50);
    setState(() {
      results = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (BuildContext context, int i) {
        final Map result = results[i];
        String id = result['title'] != null
            ? result['episodes'][0]['movieid']
            : result['_id'];
        return ListTile(
          title: Text(result['originalname'] ?? result['title']),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return PlayPage(id: id, type: result['title'] != null ? 'tv' : 'movie');
            }));
          },
        );
      },
    );
  }
}

class SuggestionList extends StatefulWidget {
  @override
  _SuggestionListState createState() => _SuggestionListState();
}

class _SuggestionListState extends State<SuggestionList> {
  List suggestions = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHotmovies();
  }

  getHotmovies() async {
    ApiClient client = new ApiClient();
    List data = await client.getHots();
    setState(() {
      suggestions = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int i) {
        final Map suggestion = suggestions[i];
        return ListTile(
          title: Text(suggestion['originalname'] ?? suggestion['title']),
          onTap: () {
            String id = suggestion['title'] != null
            ? suggestion['episodes'][0]['movieid']
            : suggestion['_id'];
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return PlayPage(id: id, type: suggestion['title'] != null ? 'tv' : 'movie');
            }));
          },
        );
      },
    );
  }
}

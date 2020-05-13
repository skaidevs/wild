import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wildstream/models/song.dart';
import 'package:wildstream/widgets/search_song.dart';

class Search extends StatelessWidget {
  final song;

  const Search({Key key, this.song}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text('Search Wildstream'),
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.search,
                ),
                onPressed: () async {
                  final Data result = await showSearch<Data>(
                    context: context,
                    delegate: SongSearch(
                      song: song.hot100SongList,
                    ),
                  );
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result?.name),
                    ),
                  );
                  print("RESULT ${result.name}");
                }),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FaIcon(
              FontAwesomeIcons.search,
              size: 40.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'SEARCH',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

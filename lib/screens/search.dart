import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wildstream/models/song.dart';
import 'package:wildstream/widgets/commons.dart';
import 'package:wildstream/widgets/search_song.dart';

class Search extends StatelessWidget {
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
                    delegate: SongSearch(),
                  );
                  kFlutterToast(
                    context: context,
                    msg: '${result?.name}',
                  );
                  /*Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result?.name),
                    ),
                  );*/
                  print("RESULT ");
                }),
          ),
        ],
      ),
      body: Center(
        child: Container(
          padding: Platform.isIOS
              ? const EdgeInsets.fromLTRB(
                  0.0,
                  0.0,
                  0.0,
                  140.0,
                )
              : const EdgeInsets.fromLTRB(
                  0.0,
                  0.0,
                  0.0,
                  118.0,
                ),
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
      ),
    );
  }
}

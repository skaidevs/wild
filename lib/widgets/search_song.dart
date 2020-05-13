import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/shape/gf_avatar_shape.dart';
import 'package:wildstream/main.dart';
import 'package:wildstream/models/song.dart';

class SongSearch extends SearchDelegate<Data> {
  final Stream<UnmodifiableListView<Data>> song;

  SongSearch({this.song});
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: FaIcon(FontAwesomeIcons.times),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: FaIcon(FontAwesomeIcons.arrowLeft),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<UnmodifiableListView<Data>>(
      stream: song,
      builder: (context, AsyncSnapshot<UnmodifiableListView<Data>> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('NO DATA'),
          );
        }

        final results = snapshot.data.where(
          (song) => song.name.toLowerCase().contains(query),
        );

        return Container(
          color: Theme.of(context).backgroundColor,
          child: ListView(
            children: results
                .map<Widget>(
                  (song) => _buildResults(
                    song: song,
                    context: context,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: Theme.of(context).backgroundColor,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.white),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<UnmodifiableListView<Data>>(
      stream: song,
      builder: (context, AsyncSnapshot<UnmodifiableListView<Data>> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text(
              'NO DATA',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final results = snapshot.data.where(
          (song) => song.name.toLowerCase().contains(query),
        );

        return Container(
          color: Theme.of(context).backgroundColor,
          child: ListView(
            children: results
                .map<Widget>(
                  (song) => _buildSuggestionList(
                    song: song,
                    context: context,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildResults({Data song, BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 6.0,
        vertical: 8.0,
      ),
      child: ListTile(
        key: Key(song.name),
        leading: GFAvatar(
          borderRadius: BorderRadius.all(
            Radius.circular(6.0),
          ),
          shape: GFAvatarShape.standard,
          size: 42.0,
          backgroundImage: NetworkImage(song.songArt.artUrl),
        ),
        title: Text(
          '${song.name}',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(
            top: 10.0,
          ),
          child: Text(
            '${song.artistsToString}',
            style: TextStyle(color: kColorWSGreen),
          ),
        ),
        trailing: Icon(
          Icons.more_horiz,
          color: kColorWSGreen,
        ),
        /*StreamBuilder<ScreenState>(
          stream: _screenStateStream,
          builder: (context, snapshot) {
            final screenState = snapshot.data;
            mediaItem = screenState?.mediaItem;

            if (mediaItem?.id == data.hot100MediaList[index].id) {
              return _mediaIndicator();
            } else {
              return Icon(
                Icons.more_horiz,
                color: kColorWSGreen,
              );
            }
          },
        ),*/
        onTap: () async {
          print("TAPED");

          //TODO play song
//          close(context, song);
//          mediaItem = data.hot100MediaList[index];
//          AudioService.playFromMediaId(mediaItem.id);
        },
        selected: true,
      ),
    );
  }

  Widget _buildSuggestionList({Data song, BuildContext context}) {
    final ThemeData theme = Theme.of(context);

    return ListTile(
      leading: query.isEmpty
          ? const Icon(
              Icons.history,
              color: Colors.white,
            )
          : const Icon(null),
      title: RichText(
        text: TextSpan(
          text: song.name.substring(0, query.length),
          style: theme.textTheme.subhead.copyWith(fontWeight: FontWeight.bold),
          children: <TextSpan>[
            TextSpan(
              text: song.name.substring(query.length),
              style: theme.textTheme.subhead,
            ),
          ],
        ),
      ),
      onTap: () {
        //query = song.name;
        close(context, song);
      },
    );
  }
}

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/shape/gf_avatar_shape.dart';
import 'package:wildstream/main.dart';
import 'package:wildstream/models/song.dart';

class Hot100 extends StatelessWidget {
  final song;

  const Hot100({Key key, this.song}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Hot Build");
    return Container(
      color: Theme.of(context).backgroundColor,
      child: StreamBuilder<UnmodifiableListView<Data>>(
          initialData: UnmodifiableListView<Data>([]),
          stream: song.hot100SongList,
          builder: (context, snapshot) {
//              print('DATA: ${snapshot?.data}');
            return ListView.builder(
              padding: const EdgeInsets.all(2.0),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              /*separatorBuilder: (context, index) => const Divider(
                indent: 90.0,
                thickness: 0.6,
                endIndent: 10.0,
                color: Colors.white30,
              ),*/
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) => _buildSong(
                song: snapshot.data[index],
              ),
            );
          }),
    );
  }

  Widget _buildSong({Data song}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 6.0,
        vertical: 8.0,
      ),
      child: ListTile(
        key: PageStorageKey(1),
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
          print("Taped");
//          mediaItem = data.hot100MediaList[index];
//          AudioService.playFromMediaId(mediaItem.id);
        },
        selected: true,
      ),
    );
  }
}

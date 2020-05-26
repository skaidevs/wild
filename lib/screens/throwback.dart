import 'dart:io';

import 'package:flutter/material.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/shape/gf_avatar_shape.dart';
import 'package:provider/provider.dart';
import 'package:wildstream/models/song.dart';
import 'package:wildstream/providers/latest_hot100_throwback.dart';
import 'package:wildstream/widgets/build_song_item.dart';
import 'package:wildstream/widgets/commons.dart';
import 'package:wildstream/widgets/loadingInfo.dart';

class Throwback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("Throwback Build");
    final _songNotifier = Provider.of<SongsNotifier>(
      context,
      listen: false,
    );
    return Consumer<SongsNotifier>(builder: (context, notifier, _) {
      if (notifier.isLoading) {
        return LoadingInfo();
      }
      return Container(
        padding: Platform.isIOS
            ? const EdgeInsets.fromLTRB(
                0.0,
                0.0,
                0.0,
                116.0,
              )
            : const EdgeInsets.fromLTRB(
                0.0,
                0.0,
                0.0,
                116.0,
              ),
        child: ListView.builder(
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
          itemCount: notifier.throwbackSongList.length,
          itemBuilder: (context, index) => BuildSongItem(
            song: notifier.throwbackSongList[index],
            onTap: () {
              notifier.playMediaFromButtonPressed(
                playButton: 'throw_back',
                playFromId: notifier.throwbackMediaList[index].id,
              );
              /*playFromMediaId(
                mediaId: _songNotifier.throwbackMediaList[index].id,
              );*/
//              print(
//                  'Tapped from ThroBack ${_songNotifier.throwbackMediaList[index].id}');
            },
          ),
        ),
      );
    });
  }

  Widget _buildSong({Data song}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 6.0,
        vertical: 8.0,
      ),
      child: ListTile(
        key: PageStorageKey(2),
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

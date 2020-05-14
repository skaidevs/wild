import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildstream/helpers/play_from_media_id.dart';
import 'package:wildstream/providers/latest_hot100_throwback.dart';
import 'package:wildstream/widgets/build_song_item.dart';
import 'package:wildstream/widgets/loadingInfo.dart';

class Latest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool _isLoadingMedia = false;
    MediaItem currentMediaIndex;
    final _songNotifier = Provider.of<SongsNotifier>(
      context,
      listen: false,
    );
    //_addMedia.fetchMediaList();
    return Container(
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
              120.0,
            ),
      color: Theme.of(context).backgroundColor,
      child: Consumer<SongsNotifier>(builder: (context, notifier, _) {
        if (notifier.isLoading) {
          return LoadingInfo();
        }
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
          itemCount: notifier.latestSongList.length,
          itemBuilder: (context, index) => BuildSongItem(
            song: notifier.latestSongList[index],
            onTap: () {
              playFromMediaId(
                mediaId: _songNotifier.latestSongList[index].songFile.songUrl,
              );
              print('Tapped from Latest ${_songNotifier.mediaList[index].id}');
            },
          ),
        );
      }),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildstream/helpers/mediaItems.dart';
import 'package:wildstream/providers/latest_hot100_throwback.dart';
import 'package:wildstream/widgets/build_lat_hot_thr_item.dart';
import 'package:wildstream/widgets/loadingInfo.dart';

class Hot100 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("Hot Build");
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
            itemCount: notifier.hot100SongList.length,
            itemBuilder: (context, index) {
              final _mediaItem = notifier.hot100MediaList[index];
              return BuildLatestHotThrowBackItem(
                mediaItem: _mediaItem,
                song: notifier.hot100SongList[index],
                index: index,
                songType: songTypes[1],
                onTap: () {
                  playMediaFromButtonPressed(
                    mediaList: notifier.hot100MediaList,
                    playButton: 'hot_100',
                    playFromId: notifier.hot100MediaList[index].id,
                  );
                },
              );
            }),
      );
    });
  }
}

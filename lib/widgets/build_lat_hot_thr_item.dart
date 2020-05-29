import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/shape/gf_avatar_shape.dart';
import 'package:provider/provider.dart';
import 'package:wildstream/helpers/downloads.dart';
import 'package:wildstream/helpers/insert_downloaded_media.dart';
import 'package:wildstream/helpers/mediaItems.dart';
import 'package:wildstream/helpers/screen_state.dart';
import 'package:wildstream/models/song.dart';
import 'package:wildstream/widgets/commons.dart';

class BuildLatestHotThrowBackItem extends StatelessWidget {
  final Data song;
  final int index;
  final String songType;
  final Function onTap;
  final MediaItem mediaItem;

  const BuildLatestHotThrowBackItem({
    Key key,
    this.song,
    this.index,
    this.songType,
    this.onTap,
    this.mediaItem,
  }) : super(key: key);
  printEverything(BuildContext context) async {
    print(await Provider.of<DownloadDao>(
      context,
      listen: false,
    ).allDownloads);
  }

  @override
  Widget build(BuildContext context) {
    final _downloadDao = Provider.of<DownloadDao>(
      context,
      listen: false,
    );
    printEverything(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 14.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Row(
                children: <Widget>[
                  songType == songTypes[1]
                      ? Stack(
                          alignment: const Alignment(1.0, 1.0),
                          children: <Widget>[
                            GFAvatar(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4.0),
                              ),
                              shape: GFAvatarShape.standard,
                              size: 38.0,
                              backgroundImage:
                                  NetworkImage(song.songArt.crops.crop100),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(6.0),
                                  bottomRight: Radius.circular(4.0),
                                ),
                                color: kColorWSYellow,
                              ),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                      : GFAvatar(
                          borderRadius: BorderRadius.all(
                            Radius.circular(6.0),
                          ),
                          shape: GFAvatarShape.standard,
                          size: 36.0,
                          backgroundImage:
                              NetworkImage(song.songArt.crops.crop100),
                        ),
                  SizedBox(
                    width: 16.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${song.name}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${song.artistsToString}',
                          style: kTextStyle(
                            fontSize: 12.0,
                            color: kColorWSGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            if (songType == songTypes[0])
              _streamBuilderAddAndRemove(
                downloadDao: _downloadDao,
                mediaItem: mediaItem,
              ),
            if (songType == songTypes[1])
              _streamBuilderAddAndRemove(
                downloadDao: _downloadDao,
                mediaItem: mediaItem,
              ),
            if (songType == songTypes[2])
              _streamBuilderAddAndRemove(
                downloadDao: _downloadDao,
                mediaItem: mediaItem,
              ),
            StreamBuilder<ScreenState>(
              stream: screenStateStream,
              builder: (context, snapshot) {
                final screenState = snapshot.data;
                MediaItem _mediaItem;
                _mediaItem = screenState?.mediaItem;
                if (_mediaItem?.id == song.songFile.songUrl) {
                  return kMediaIndicator();
                } else {
                  return IconButton(
                    onPressed: () => null,
                    icon: Icon(
                      Icons.more_horiz,
                      color: kColorWSGreen,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  StreamBuilder<bool> _streamBuilderAddAndRemove({
    DownloadDao downloadDao,
    MediaItem mediaItem,
  }) {
    return StreamBuilder<bool>(
        stream: downloadDao.isDownloaded(mediaItem.extras['code']),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && snapshot.data) {
            return IconButton(
              onPressed: () {
                downloadDao.removeDownloads(
                  mediaItem.extras['code'],
                );
                print('REMOVED ${mediaItem.title}');
              },
              icon: Icon(
                Icons.file_download,
                color: kColorWSYellow,
              ),
            );
          }

          return IconButton(
            onPressed: () async {
              insertDownloadedMediaItems(
                mediaItem: mediaItem,
                downloadDao: downloadDao,
              );
            },
            icon: Icon(
              Icons.file_download,
              color: Colors.grey,
            ),
          );
        });
  }
}

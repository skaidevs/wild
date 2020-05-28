import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/shape/gf_avatar_shape.dart';
import 'package:provider/provider.dart';
import 'package:wildstream/helpers/downloads.dart';
import 'package:wildstream/helpers/mediaItems.dart';
import 'package:wildstream/helpers/screen_state.dart';
import 'package:wildstream/models/song.dart';
import 'package:wildstream/providers/latest_hot100_throwback.dart';
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
    print(await Provider.of<Database>(
      context,
      listen: false,
    ).allDownloads);
  }

  @override
  Widget build(BuildContext context) {
    final _songNotifier = Provider.of<SongsNotifier>(
      context,
      listen: false,
    );
    final _database = Provider.of<Database>(
      context,
      listen: false,
    );
    printEverything(context);
    MediaItem _mediaItem;
    _mediaItem = mediaItem;
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
              StreamBuilder<bool>(
                  stream: _database
                      .isDownload(_songNotifier.latestSongList[index].code),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.data) {
                      return IconButton(
                        onPressed: () {
                          _database.removeDownloads(
                            _songNotifier.latestSongList[index].code,
                          );
                          print(
                              'REMOVE ${_songNotifier.latestSongList[index].code}');
                        },
                        icon: Icon(
                          Icons.file_download,
                          color: kColorWSYellow,
                        ),
                      );
                    }

                    return IconButton(
                      onPressed: () async {
                        _addDownload(
                            context: context,
                            songListData: _songNotifier.latestSongList);
                        print(
                            'LATEST ${_songNotifier.latestSongList[index].name}');
                      },
                      icon: Icon(
                        Icons.file_download,
                        color: Colors.grey,
                      ),
                    );
                  }),
            if (songType == songTypes[1])
              StreamBuilder<bool>(
                  stream: _database
                      .isDownload(_songNotifier.hot100SongList[index].code),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.data) {
                      return IconButton(
                        onPressed: () {
                          _database.removeDownloads(
                            _songNotifier.hot100SongList[index].code,
                          );
                          print(
                              'REMOVE ${_songNotifier.hot100SongList[index].code}');
                        },
                        icon: Icon(
                          Icons.file_download,
                          color: kColorWSYellow,
                        ),
                      );
                    }

                    return IconButton(
                      onPressed: () async {
                        _addDownload(
                            context: context,
                            songListData: _songNotifier.hot100SongList);
                        print(
                            'HOT100 ${_songNotifier.hot100SongList[index].name}');
                      },
                      icon: Icon(
                        Icons.file_download,
                        color: Colors.grey,
                      ),
                    );
                  }),
            if (songType == songTypes[2])
              StreamBuilder<bool>(
                  stream: _database
                      .isDownload(_songNotifier.throwbackSongList[index].code),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.data) {
                      return IconButton(
                        onPressed: () {
                          _database.removeDownloads(
                            _songNotifier.throwbackSongList[index].code,
                          );
                          print(
                              'REMOVE ${_songNotifier.throwbackSongList[index].code}');
                        },
                        icon: Icon(
                          Icons.file_download,
                          color: kColorWSYellow,
                        ),
                      );
                    }

                    return IconButton(
                      onPressed: () async {
                        _addDownload(
                            context: context,
                            songListData: _songNotifier.throwbackSongList);
                        print(
                            'HOT100 ${_songNotifier.throwbackSongList[index].name}');
                      },
                      icon: Icon(
                        Icons.file_download,
                        color: Colors.grey,
                      ),
                    );
                  }),
            StreamBuilder<ScreenState>(
              stream: screenStateStream,
              builder: (context, snapshot) {
                final screenState = snapshot.data;
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

  void _addDownload({
    List<Data> songListData,
    BuildContext context,
  }) async {
    final _database = Provider.of<Database>(
      context,
      listen: false,
    );
    int id = Random().nextInt(20000);
    Download _downloaded = Download(
      id: id,
      mediaCode: songListData[index].code,
      mediaIdUri: songListData[index].songFile.songUrl,
      mediaArtUri: songListData[index].songArt.crops.crop500,
      mediaTitle: songListData[index].name,
      mediaAlbum: songListData[index].name,
      mediaArtist: songListData[index].artistsToString,
      mediaDuration: songListData[index].duration,
    );
    await _database.addDownload(_downloaded);
    print(
        'ADDED ${songListData[index].code} AND $id || ${_downloaded.mediaTitle}');
  }
}

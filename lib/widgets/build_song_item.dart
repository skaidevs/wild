import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/shape/gf_avatar_shape.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wildstream/helpers/screen_state.dart';
import 'package:wildstream/models/song.dart';
import 'package:wildstream/widgets/commons.dart';

class BuildSongItem extends StatelessWidget {
  final Data song;
  final int index;
  final String hot100;
  final Function onTap;
  final MediaItem mediaItem;

  const BuildSongItem({
    Key key,
    this.song,
    this.index,
    this.hot100,
    this.onTap,
    this.mediaItem,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    MediaItem _mediaItem;
    _mediaItem = mediaItem;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14.0,
          vertical: 14.0,
        ),
        child:
            /*ListTile(
          //key: PageStorageKey(0),
          leading: hot100 == 'hot100'
              ? Stack(
                  alignment: const Alignment(1.0, 1.0),
                  children: <Widget>[
                    GFAvatar(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                      shape: GFAvatarShape.standard,
                      size: 38.0,
                      backgroundImage: NetworkImage(song.songArt.crops.crop100),
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
                        '$index',
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
                  backgroundImage: NetworkImage(song.songArt.crops.crop100),
                ),
          title: Text(
            '${song.name}',
            style: TextStyle(
              color: kColorWhite,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
            ),
            child: Text(
              '${song.artistsToString}',
              style: TextStyle(color: kColorWSGreen),
            ),
          ),
          trailing: StreamBuilder<ScreenState>(
            stream: _screenStateStream,
            builder: (context, snapshot) {
              final screenState = snapshot.data;
              _mediaItem = screenState?.mediaItem;

              if (_mediaItem?.id == song.songFile.songUrl) {
                return _mediaIndicator();
              } else {
                return Icon(
                  Icons.more_horiz,
                  color: kColorWSGreen,
                );
              }
            },
          ),
          onTap: onTap,
          selected: true,
        ),*/

            Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Row(
                children: <Widget>[
                  hot100 == 'hot100'
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
                                '$index',
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
            StreamBuilder<ScreenState>(
              stream: _screenStateStream,
              builder: (context, snapshot) {
                final screenState = snapshot.data;
                _mediaItem = screenState?.mediaItem;

                if (_mediaItem?.id == song.songFile.songUrl) {
                  return _mediaIndicator();
                } else {
                  return Icon(
                    Icons.more_horiz,
                    color: kColorWSGreen,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  FaIcon _mediaIndicator() {
    return FaIcon(
      FontAwesomeIcons.volumeUp,
      color: kColorWSGreen,
    );
  }

  Stream<ScreenState> get _screenStateStream =>
      Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
        AudioService.queueStream,
        AudioService.currentMediaItemStream,
        AudioService.playbackStateStream,
        (
          queue,
          mediaItem,
          playbackState,
        ) =>
            ScreenState(
          queue: queue,
          mediaItem: mediaItem,
          playbackState: playbackState,
        ),
      );
}

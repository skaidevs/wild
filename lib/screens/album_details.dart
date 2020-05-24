import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wildstream/helpers/screen_state.dart';
import 'package:wildstream/providers/album.dart';
import 'package:wildstream/providers/album_detail.dart';
import 'package:wildstream/widgets/commons.dart';
import 'package:wildstream/widgets/loadingInfo.dart';

class AlbumDetails extends StatelessWidget {
  static const routeName = '/album_detail';

  Expanded _buildButton({
    Color color,
    Color textColor,
    IconData iconData,
    String text,
    Function onPressed,
  }) {
    return Expanded(
      child: Container(
        height: 42,
        child: RaisedButton(
          elevation: 1.0,
          color: color,
          textColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              4.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FaIcon(iconData),
              SizedBox(
                width: 10.0,
              ),
              Text(
                text,
                style: kTextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _detailsNotifier = Provider.of<AlbumDetailNotifier>(
      context,
      listen: false,
    );
    int _albumIndex =
        ModalRoute.of(context).settings.arguments as int; //is the id!
    final _albumNotifier = Provider.of<AlbumNotifier>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_albumNotifier.albumListData[_albumIndex].name}',
          style: kTextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(
              12.0,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      6.0,
                    ),
                    child: Image.network(
                      '${_albumNotifier.albumListData[_albumIndex].albumArt.crop.crop500}',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children:
                              _albumNotifier.albumListData[_albumIndex].artists
                                  .map(
                                    (artist) => Expanded(
                                      child: Text(
                                        '${artist.name}',
                                        style: kTextStyle(
                                          fontSize: 22.0,
                                          color: kColorWSGreen,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 12.0,
                          ),
                          child: Consumer<AlbumDetailNotifier>(
                            builder: (context, _notifier, _) =>
                                _notifier.isLoading
                                    ? Text(
                                        'https://wstr.am',
                                        style: kTextStyle(
                                          color: kColorWSYellow,
                                        ),
                                      )
                                    : Text(
                                        '${_notifier.shotUrl == null ? 'https://wstr.am' : _notifier.shotUrl}',
                                        style: kTextStyle(
                                          color: kColorWSYellow,
                                        ),
                                      ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                              '${_albumNotifier.albumListData[_albumIndex].releasedAt}'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 13.0,
              right: 13.0,
              bottom: 10.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildButton(
                    onPressed: () {
                      _detailsNotifier.playMediaFromButtonPressed(
                        playButton: '_playAllFromButton',
                      );
                      print('playing ALL Button....');
                    },
                    color: kColorWSGreen,
                    textColor: kColorWhite,
                    text: 'Play',
                    iconData: FontAwesomeIcons.play),
                SizedBox(
                  width: 16.0,
                ),
                _buildButton(
                    color: kColorWhite,
                    textColor: kColorWSAltBlack,
                    text: 'Shuffle',
                    iconData: FontAwesomeIcons.random),
              ],
            ),
          ),
          Container(
            child: Consumer<AlbumDetailNotifier>(
              builder: (context, _notifier, _) => _notifier.isLoading
                  ? Center(
                      child: LoadingInfo(),
                    )
                  : Container(
                      padding: Platform.isIOS
                          ? const EdgeInsets.fromLTRB(
                              0.0,
                              0.0,
                              0.0,
                              120.0,
                            )
                          : const EdgeInsets.fromLTRB(
                              0.0,
                              0.0,
                              0.0,
                              120.0,
                            ),
                      child: ListView.builder(
                          //padding: const EdgeInsets.all(2.0),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: _notifier.detailAlbumList.length,
                          itemBuilder: (context, index) {
                            index = index;
                            return InkWell(
                              onTap: () {
                                _notifier.playMediaFromButtonPressed(
                                  playFromId: _notifier
                                      .detailAlbumList[index].songFile.songUrl,
                                );
                                print('playing from id....');
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0,
                                  vertical: 16.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            '${index + 1}.',
                                            style: kTextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: kColorWSGreen,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  '${_notifier.detailAlbumList[index].name}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  '${_notifier.detailAlbumList[index].artistsToString}',
                                                  style: kTextStyle(
                                                    fontSize: 14.0,
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
                                        MediaItem _mediaItem =
                                            screenState?.mediaItem;
                                        if (_mediaItem?.id ==
                                            _notifier.mediaList[index].id) {
                                          return _mediaIndicator();
                                        } else {
                                          return Icon(
                                            Icons.more_horiz,
                                            color: kColorWSGreen,
                                          );
                                        }
                                      },
                                    ),

//                               _playButton(context: context),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
            ),
          ),
        ],
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

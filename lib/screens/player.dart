import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/components/loader/gf_loader.dart';
import 'package:getflutter/shape/gf_avatar_shape.dart';
import 'package:marquee_flutter/marquee_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wildstream/helpers/background.dart';
import 'package:wildstream/helpers/screen_state.dart';
import 'package:wildstream/widgets/commons.dart';
import 'package:wildstream/widgets/positionIndicator.dart';

class PlayerStreamBuilder extends StatelessWidget {
  final BehaviorSubject<double> dragPositionSubject;

  const PlayerStreamBuilder({
    Key key,
    this.dragPositionSubject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _isRepeatEnable = false;
    bool _isShuffledEnable = false;

    final _audioPlayerTask = Provider.of<AudioPlayerTask>(
      context,
      listen: true,
    );
    print("Provider.of ${_audioPlayerTask.getIsRepeatEnable}");

    return Container(
      color: Theme.of(context).backgroundColor,
      child: StreamBuilder<ScreenState>(
        stream: _screenStateStream,
        builder: (context, snapshot) {
          final screenState = snapshot.data;
          final queue = screenState?.queue;
          final mediaItem = screenState?.mediaItem;
          final state = screenState?.playbackState;
          final basicState = state?.basicState ?? BasicPlaybackState.none;
          if (snapshot.hasError)
            print("ERROR On StreamBuilder ${snapshot.error}");
          print(
              "Changes in UI ${queue?.length} || ${mediaItem?.title} ||-- ${state?.position}|| || ${basicState.toString()}");
          return snapshot.hasData
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (mediaItem?.artUri != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: GFAvatar(
                          borderRadius: BorderRadius.all(
                            Radius.circular(6.0),
                          ),
                          shape: GFAvatarShape.standard,
                          size: 200.0,
                          backgroundImage: NetworkImage(mediaItem.artUri),
                        ),
                      ),
                    if (mediaItem?.title != null)
                      Container(
                        width: MediaQuery.of(context).size.width - 80,
                        height: 30,
                        child: MarqueeWidget(
                          ratioOfBlankToScreen: 0.6,
                          scrollAxis: Axis.horizontal,
                          text: mediaItem.title,
                          textStyle: TextStyle(
                            fontSize: 22.0,
                            color: kColorWhite,
                          ),
                        ),
                      ),
                    if (mediaItem?.artist != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 20.0,
                          left: 8.0,
                          right: 8.0,
                          top: 10.0,
                        ),
                        child: Text(
                          mediaItem.artist,
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                      ),
                    if (queue != null && queue.isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: FaIcon(FontAwesomeIcons.stepBackward),
                            disabledColor: Theme.of(context).bottomAppBarColor,
                            color: Theme.of(context).accentColor,
                            iconSize: 38.0,
                            onPressed: mediaItem == queue.first
                                ? null
                                : AudioService.skipToPrevious,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (basicState == BasicPlaybackState.playing)
                                pauseButton(context: context)
                              else if (basicState == BasicPlaybackState.paused)
                                playButton(context: context)
                              else if (basicState ==
                                      BasicPlaybackState.buffering ||
                                  basicState ==
                                      BasicPlaybackState.skippingToNext ||
                                  basicState ==
                                      BasicPlaybackState.skippingToPrevious)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 60.0,
                                    height: 60.0,
                                    child: GFLoader(
                                      size: 60.0,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          IconButton(
                            disabledColor: Theme.of(context).bottomAppBarColor,
                            icon: FaIcon(FontAwesomeIcons.stepForward),
                            iconSize: 38.0,
                            color: Theme.of(context).accentColor,
                            onPressed: mediaItem == queue.last
                                ? null
                                : AudioService.skipToNext,
                          ),
                        ],
                      ),
                    if (basicState == BasicPlaybackState.none) ...[
                      Text(
                        'BasicPlaybackState.none # $basicState',
                        style: TextStyle(color: kColorWhite),
                      )
                    ] else if (basicState != BasicPlaybackState.none &&
                        basicState != BasicPlaybackState.stopped) ...[
                      SizedBox(
                        height: 20.0,
                      ),
                      PositionIndicator(
                        dragPositionSubject: dragPositionSubject,
                        mediaItem: mediaItem,
                        state: state,
                      ),
                      Text(
                        "State: " +
                            "$basicState".replaceAll(RegExp(r'^.*\.'), ''),
                        style: TextStyle(
                          color: kColorWhite,
                        ),
                      ),
                      StreamBuilder(
                        stream: AudioService.customEventStream,
                        builder: (context, snapshot) {
                          return Text(
                            "custom event: ${snapshot.data}",
                            style: TextStyle(color: kColorWhite),
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          StreamBuilder(
                              stream: AudioService.customEventStream,
                              builder: (context, snapshot) {
                                return IconButton(
                                  icon: FaIcon(FontAwesomeIcons.random),
                                  iconSize: 26.0,
                                  color: _isShuffledEnable
                                      ? Theme.of(context).accentColor
                                      : Theme.of(context).bottomAppBarColor,
                                  onPressed: () {
                                    _isShuffledEnable =
                                        _isShuffledEnable ? false : true;
                                    AudioService.customAction(
                                        'shuffle', _isShuffledEnable);
                                    print("SHUFFED TAPED $_isShuffledEnable");
                                  },
                                );
                              }),
                          stopButton(context: context),
                          StreamBuilder(
                              stream: AudioService.customEventStream,
                              builder: (context, snapshot) {
                                return IconButton(
                                  disabledColor:
                                      Theme.of(context).bottomAppBarColor,
                                  icon: FaIcon(FontAwesomeIcons.redoAlt),
                                  iconSize: 26.0,
                                  color: _isRepeatEnable
                                      ? Theme.of(context).accentColor
                                      : Theme.of(context).bottomAppBarColor,
                                  onPressed: () {
                                    _isRepeatEnable =
                                        _isRepeatEnable ? false : true;
                                    AudioService.customAction(
                                        'repeat', _isRepeatEnable);
                                    print("REPEAT TAPED $_isRepeatEnable");
                                  },
                                );
                              }),
                        ],
                      )
                    ],
                  ],
                )
              : Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  /// Encapsulate all the different data we're interested in into a single
  /// stream so we don't have to nest StreamBuilders.
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

  RaisedButton startButton(String label, VoidCallback onPressed) =>
      RaisedButton(
        child: Text(label),
        onPressed: onPressed,
      );

  IconButton playButton({BuildContext context}) => IconButton(
        icon: FaIcon(FontAwesomeIcons.playCircle),
        color: Theme.of(context).accentColor,
        iconSize: 60.0,
        onPressed: AudioService.play,
      );

  IconButton pauseButton({BuildContext context}) => IconButton(
        icon: FaIcon(FontAwesomeIcons.pauseCircle),
        color: Theme.of(context).accentColor,
        iconSize: 60.0,
        onPressed: AudioService.pause,
      );

  IconButton stopButton({BuildContext context}) => IconButton(
        icon: FaIcon(FontAwesomeIcons.stop),
        color: Theme.of(context).accentColor,
        iconSize: 24.0,
        onPressed: AudioService.stop,
      );
}

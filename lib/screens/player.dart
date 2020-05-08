import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/shape/gf_avatar_shape.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wildstream/helpers/screen_state.dart';
import 'package:wildstream/widgets/positionIndicator.dart';

class PlayerStreamBuilder extends StatelessWidget {
  final BehaviorSubject<double> dragPositionSubject;

  const PlayerStreamBuilder({
    Key key,
    this.dragPositionSubject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ScreenState>(
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
                children: [
                  if (mediaItem?.artUri != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: GFAvatar(
                        borderRadius: BorderRadius.all(
                          Radius.circular(6.0),
                        ),
                        shape: GFAvatarShape.standard,
                        size: 150.0,
                        backgroundImage: NetworkImage(mediaItem.artUri),
                      ),
                    ),
                  if (queue != null && queue.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.skip_previous),
                          iconSize: 64.0,
                          onPressed: mediaItem == queue.first
                              ? null
                              : AudioService.skipToPrevious,
                        ),
                        IconButton(
                          icon: Icon(Icons.skip_next),
                          iconSize: 64.0,
                          onPressed: mediaItem == queue.last
                              ? null
                              : AudioService.skipToNext,
                        ),
                      ],
                    ),
                  if (mediaItem?.title != null) Text(mediaItem.title),
                  if (basicState == BasicPlaybackState.none) ...[
                    Text('BasicPlaybackState.none # $basicState')
                  ] else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (basicState == BasicPlaybackState.playing)
                          pauseButton()
                        else if (basicState == BasicPlaybackState.paused)
                          playButton()
                        else if (basicState == BasicPlaybackState.buffering ||
                            basicState == BasicPlaybackState.skippingToNext ||
                            basicState == BasicPlaybackState.skippingToPrevious)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 50.0,
                              height: 50.0,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        stopButton(),
                      ],
                    ),
                  if (basicState != BasicPlaybackState.none &&
                      basicState != BasicPlaybackState.stopped) ...[
                    PositionIndicator(
                      dragPositionSubject: dragPositionSubject,
                      mediaItem: mediaItem,
                      state: state,
                    ),
                    Text("State: " +
                        "$basicState".replaceAll(RegExp(r'^.*\.'), '')),
                    StreamBuilder(
                      stream: AudioService.customEventStream,
                      builder: (context, snapshot) {
                        return Text("custom event: ${snapshot.data}");
                      },
                    ),
                  ],
                ],
              )
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  /// Encapsulate all the different data we're interested in into a single
  /// stream so we don't have to nest StreamBuilders.
  Stream<ScreenState> get _screenStateStream =>
      Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
        AudioService.queueStream,
        AudioService.currentMediaItemStream,
        AudioService.playbackStateStream,
        (queue, mediaItem, playbackState) => ScreenState(
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

  IconButton playButton() => IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 64.0,
        onPressed: AudioService.play,
      );

  IconButton pauseButton() => IconButton(
        icon: Icon(Icons.pause),
        iconSize: 64.0,
        onPressed: AudioService.pause,
      );

  IconButton stopButton() => IconButton(
        icon: Icon(Icons.stop),
        iconSize: 64.0,
        onPressed: AudioService.stop,
      );
}

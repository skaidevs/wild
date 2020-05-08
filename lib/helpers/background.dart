import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl skipToNextControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_next',
  label: 'Next',
  action: MediaAction.skipToNext,
);
MediaControl skipToPreviousControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_previous',
  label: 'Previous',
  action: MediaAction.skipToPrevious,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

class AudioPlayerTask extends BackgroundAudioTask with ChangeNotifier {
  final _queue = <MediaItem>[];

  int _queueIndex = -1;
  AudioPlayer _audioPlayer = new AudioPlayer();
  Completer _completer = Completer();
  BasicPlaybackState _skipState;
  bool _playing;
  int _platFromIdIndex;

  bool get hasNext => _queueIndex + 1 < _queue.length;

  bool get hasPrevious => _queueIndex > 0;

  MediaItem get mediaItem => _queue[_queueIndex];

  MediaItem findMediaById({String mediaId}) {
    return _queue.firstWhere((media) => media.id == mediaId);
  }

  BasicPlaybackState _eventToBasicState(AudioPlaybackEvent event) {
    if (event.buffering) {
      return BasicPlaybackState.buffering;
    } else {
      switch (event.state) {
        case AudioPlaybackState.none:
          return BasicPlaybackState.none;
        case AudioPlaybackState.stopped:
          return BasicPlaybackState.stopped;
        case AudioPlaybackState.paused:
          return BasicPlaybackState.paused;
        case AudioPlaybackState.playing:
          return BasicPlaybackState.playing;
        case AudioPlaybackState.connecting:
          return _skipState ?? BasicPlaybackState.connecting;
        case AudioPlaybackState.completed:
          return BasicPlaybackState.stopped;
        default:
          throw Exception("Illegal state");
      }
    }
  }

  @override
  Future<void> onStart() async {
    print("onStart called ");
    var playerStateSubscription = _audioPlayer.playbackStateStream
        .where((state) => state == AudioPlaybackState.completed)
        .listen((state) {
      print("playerStateSubscription... ${state.toString()}");
      _handlePlaybackCompleted();
    });
    var eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      print("eventSubscription position ${event.state}");
      final state = _eventToBasicState(event);
      if (state != BasicPlaybackState.stopped) {
        print("eventSubscription...  {{ ${state.toString()}");
        _setState(
          state: state,
          position: state.index ?? event.position.inMilliseconds,
        );
      }
    });

    print("onStart $_queue");

    //Code additions (for async issue)
    _skipState = null;
    _playing = false;
    _setState(state: BasicPlaybackState.none);
    print('_setState(state: BasicPlaybackState.paused..');

    await _completer.future;
    print('dispose Called..... $playerStateSubscription');

    playerStateSubscription.cancel();
    eventSubscription.cancel();
  }

  @override
  void onAddQueueItem(MediaItem mediaItem) async {
//    print("onAddQueueItem Called");
    _queue.add(mediaItem);
    AudioServiceBackground.setQueue(_queue);
    super.onAddQueueItem(mediaItem);
  }

  @override
  void onPlayFromMediaId(String mediaId) async {
    // play the item at mediaItems[mediaId]
    if (_playing == false) {
      _playing = true;
      print("onPlayFromMediaId  $_playing ?");
    }
    print("onPlayFromMediaId Called.. $_playing");
    var mediaItem = findMediaById(mediaId: mediaId);
    _platFromIdIndex = _queue.indexOf(mediaItem);
    print("index $_platFromIdIndex");
    _skip(_platFromIdIndex);
//    AudioServiceBackground.setQueue(_queue);
    AudioServiceBackground.sendCustomEvent('onPlayFromMediaId @index');
    print("run after _skip(_platFromIdIndex)");
  }

  void _handlePlaybackCompleted() {
    if (hasNext) {
      onSkipToNext();
    } else {
      onStop();
    }
  }

  bool _isReadyToPlay() {
    print("QUE LIST} ${_queue.length}");

    print("Is ready to play: ${_queue.isNotEmpty}");
    return _queue.isNotEmpty;
  }

  void playPause() {
    if (AudioServiceBackground.state.basicState == BasicPlaybackState.playing)
      onPause();
    else
      onPlay();
  }

  @override
  Future<void> onSkipToNext() => _skip(1);

  @override
  Future<void> onSkipToPrevious() => _skip(-1);

  Future<void> _skip(int offset) async {
    print("1 $_queueIndex $offset  $_platFromIdIndex");

    int newPos = _queueIndex + offset;

    if (_platFromIdIndex != null) {
      newPos = _platFromIdIndex;
      print("Run newpos $_platFromIdIndex");
    }
    print("2 $newPos");

    if (!(newPos >= 0 && newPos < _queue.length)) return;

    print("3 $_playing");

    if (_playing == null) {
      print("4");
      // First time, we want to start playing
      _playing = true;
    } else if (_playing) {
      print("5");
      // Stop current item
      await _audioPlayer.stop();
    }
    // Load next item
    print("6");

    _queueIndex = newPos;
    print("7 newPos $_queueIndex $offset");

    AudioServiceBackground.setMediaItem(mediaItem);

    _skipState = offset > 0
        ? BasicPlaybackState.skippingToNext
        : BasicPlaybackState.skippingToPrevious;
    print("8 $offset");
    //TODO: onPause() Before going to next

//    onPause();
    print("onPause() Before going to next ${_skipState}");
    try {
      await _audioPlayer.setUrl(mediaItem.id);
    } catch (error) {
      print("error setUrl ${error.toString()}");
    }
    _skipState = null;
    _platFromIdIndex = null;

    print("9 $_skipState $_platFromIdIndex");

    // Resume playback if we were playing
    if (_playing) {
      print("10");
      onPlay();
    } else {
      print("11");
      _setState(state: BasicPlaybackState.paused);
    }
  }

  @override
  void onPlay() async {
    final state = _audioPlayer.playbackState;
    if (!_isReadyToPlay()) {
      // Nothing to play.
      return;
    }
    if (state != AudioPlaybackState.none ||
        state != AudioPlaybackState.connecting) {
      print("_queueIndex $_queueIndex || Playing? $_playing || $state");
      if (_queueIndex == -1) {
        print('onSkipToNext() will automatically play ');
        await onSkipToNext(); // will automatically play
      } else {
        // normal play code
        if (_skipState == null) {
          _playing = true;
          _audioPlayer.play();
          print('onPlay ... @ $_playing');
          AudioServiceBackground.sendCustomEvent('just played');
          print('Called after auto');
        }
      }
    } else {
      print("AudioPlaybackState.none");
    }
  }

  @override
  void onPause() {
    if (_skipState == null) {
      _playing = false;
      _audioPlayer.pause();
      AudioServiceBackground.sendCustomEvent('just paused');
    }
  }

  @override
  void onSeekTo(int position) {
    print("Duration ${position.toString()}");
    _audioPlayer.seek(Duration(milliseconds: position));
  }

  @override
  void onClick(MediaButton button) {
    playPause();
  }

  @override
  Future<void> onStop() async {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
    _setState(state: BasicPlaybackState.stopped);
    _completer.complete();
  }

  void _setState({@required BasicPlaybackState state, int position}) {
    if (position == null) {
      position = _audioPlayer.playbackEvent.position.inMilliseconds;
      print("playbackEvent.position $position and State $state");
    }
    AudioServiceBackground.setState(
      controls: getControls(state),
      systemActions: [MediaAction.seekTo],
      basicState: state,
      position: position,
    );
  }

  List<MediaControl> getControls(BasicPlaybackState state) {
    if (_playing) {
      return [
        skipToPreviousControl,
        pauseControl,
        stopControl,
        skipToNextControl
      ];
    } else {
      return [
        skipToPreviousControl,
        playControl,
        stopControl,
        skipToNextControl
      ];
    }
  }
}

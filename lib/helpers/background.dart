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
      final state = _eventToBasicState(event);
      if (state != BasicPlaybackState.stopped) {
        print("eventSubscription...  {{ ${state.toString()}");
        _setState(
          state: state,
          position: event.position.inMilliseconds,
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
    var mediaItem = findMediaById(mediaId: mediaId);
    final state = _audioPlayer.playbackState;

    print("onPlayFromMediaId Called.. $_playing}");
    print("onPlayFromMediaId Called $_skipState}");
    print("..play  ${_queue[_queueIndex].title}");
    AudioServiceBackground.setMediaItem(mediaItem);
    //_queue[_queueIndex] = mediaItem;

    try {
      print("_audioPlayer.playbackState.. ${state.toString()}");
      await _audioPlayer.setUrl(mediaId);
      AudioServiceBackground.setQueue(_queue);
      print("onPlayFromMediaId.. ${_queue[_queueIndex].title}");
      await _audioPlayer.play();
      AudioServiceBackground.sendCustomEvent('onPlayFromMediaId @index');
    } catch (e) {
      print("Error _audioPlayer.setUrl(mediaId) $e");
    }

    print("run after _audioPlayer.playbackState${state.toString()}");
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
    //TODO: onPause() Before going to next
    final newPos = _queueIndex + offset;
    if (!(newPos >= 0 && newPos < _queue.length)) return;
    if (_playing == null) {
      // First time, we want to start playing
      _playing = true;
    } else if (_playing) {
      // Stop current item
      await _audioPlayer.stop();
    }
    // Load next item
    _queueIndex = newPos;
    AudioServiceBackground.setMediaItem(mediaItem);
    _skipState = offset > 0
        ? BasicPlaybackState.skippingToNext
        : BasicPlaybackState.skippingToPrevious;
    onPause();
    await _audioPlayer.setUrl(mediaItem.id);
    _skipState = null;
    // Resume playback if we were playing
    if (_playing) {
      onPlay();
    } else {
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
      if (_queueIndex == -1) {
        print(
            'await onSkipToNext(); // your code will automatically play Called');
        await onSkipToNext(); // your code will automatically play
      } else {
        // your normal play code
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
      print("playbackEvent.position.inMilliseconds $position");
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

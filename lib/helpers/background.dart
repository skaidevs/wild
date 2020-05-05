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
    var playerStateSubscription = _audioPlayer.playbackStateStream
        .where((state) => state == AudioPlaybackState.completed)
        .listen((state) {
      print("playerStateSubscription... ${state.toString()}");

      _handlePlaybackCompleted();
    });
    var eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      final state = _eventToBasicState(event);
      if (state != BasicPlaybackState.stopped) {
        print("eventSubscription... ${state.toString()}");

        _setState(
          state: state,
          position: event.position.inMilliseconds,
        );
      }
    });

//    await AudioServiceBackground.setQueue(_queue);
    print("onStart $_queue");
    //Code additions (for async issue)
    print("Code additions (for async issue)... $_skipState // $_playing");
    _skipState = null;
    _playing = false;
    print("Afrer Code additions (for async issue)... $_skipState // $_playing");

//    _setState(state: BasicPlaybackState.paused);
//    await onSkipToNext();
    await _completer.future;
    playerStateSubscription.cancel();
    eventSubscription.cancel();
  }

  @override
  void onAddQueueItem(MediaItem mediaItem) async {
//    _queue.clear();
    _queue.add(mediaItem);
    AudioServiceBackground.setQueue(_queue);
    print("onAddQueueItem } ${mediaItem.title}");
    if (_queueIndex == -1) {
      await onSkipToNext(); // your code will automatically play
    }
    super.onAddQueueItem(mediaItem);
  }

  void _handlePlaybackCompleted() {
    if (hasNext) {
      onSkipToNext();
    } else {
      onStop();
    }
  }

  bool _isReadyToPlay() {
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
  void onPlay() {
    if (!_isReadyToPlay()) {
      // Nothing to play.
      return;
    }
    if (_skipState == null) {
      _playing = true;
      _audioPlayer.play();
      AudioServiceBackground.sendCustomEvent('just played');
    }
/*    if (_queueIndex == -1) {
      await onSkipToNext(); // your code will automatically play
    } else {
      // your normal play code
      if (_skipState == null) {
        _playing = true;
        _audioPlayer.play();
        print('onPlay ... @ $_playing');
        AudioServiceBackground.sendCustomEvent('just played');
      }
    }*/
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

  /*int _queueIndex = -1;
  AudioPlayer _audioPlayer = new AudioPlayer();
  Completer _completer = Completer();
  BasicPlaybackState _skipState;
  bool _playing;

  bool get hasNext => _queueIndex + 1 < _queue.length;

  bool get hasPrevious => _queueIndex > 0;

  MediaItem get mediaItem => _queue[_queueIndex];

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
    print("onStart Called");

    var playerStateSubscription = _audioPlayer.playbackStateStream
        .where((state) => state == AudioPlaybackState.completed)
        .listen((state) {
      print("playerStateSubscription... ${state.toString()}");

      _handlePlaybackCompleted();
    });
    var eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      final state = _eventToBasicState(event);
      if (state != BasicPlaybackState.stopped) {
        _setState(
          state: state,
          position: event.position.inMilliseconds,
        );
        print("eventSubscription... ${state.toString()}");
      }
    });

    print("Called");

    AudioServiceBackground.setQueue(_queue);
    print("Called..");
//    await onSkipToNext();

    //Code additions (for async issue)
//    print("Code additions (for async issue)... $_skipState // $_playing");
//    _skipState = null;
//    _playing = false;
//    _setState(state: BasicPlaybackState.paused);
    await _completer.future;
    playerStateSubscription.cancel();
    eventSubscription.cancel();
    print("Called.....");
  }

  @override
  void onAddQueueItem(MediaItem mediaItem) async {
//    _queue.clear();
    _queue.add(mediaItem);
    // AudioServiceBackground.setQueue(_queue);
    // await onSkipToNext();
    print("onAddQueueItem } ${mediaItem.title}");
    super.onAddQueueItem(mediaItem);
  }

  void _handlePlaybackCompleted() {
    if (hasNext) {
      onSkipToNext();
    } else {
      onStop();
    }
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
    final newPos = _queueIndex + offset;
    print("_skip..: ${newPos}");
    print("_skip.... : ${!(newPos >= 0 && newPos < _queue.length)}");
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
    print("_skip _queueIndex  $_queueIndex");
    AudioServiceBackground.setMediaItem(mediaItem);
    _skipState = offset > 0
        ? BasicPlaybackState.skippingToNext
        : BasicPlaybackState.skippingToPrevious;
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
    if (!_isReadyToPlay()) {
      // Nothing to play.
      return;
    }

//    if (_skipState == null) {
//      _playing = true;
//      _audioPlayer.play();
//      print('onPlay ... @ $_playing');
//      AudioServiceBackground.sendCustomEvent('just played');
//    }
    if (_queueIndex == -1) {
      await onSkipToNext(); // your code will automatically play
    } else {
      // your normal play code
      if (_skipState == null) {
        _playing = true;
        _audioPlayer.play();
        print('onPlay ... @ $_playing');
        AudioServiceBackground.sendCustomEvent('just played');
      }
    }
  }

//  private boolean isReadyToPlay() {
//    log("Is ready to play: " + (!mPlaylist.isEmpty()));
//    return (!mPlaylist.isEmpty());
//  }
  bool _isReadyToPlay() {
    print("Is ready to play: ${_queue.isNotEmpty}");
    return _queue.isNotEmpty;
  }

  @override
  void onPrepare() {
    // TODO: implement onPrepare
    super.onPrepare();
  }

  @override
  void onPause() {
    if (_skipState == null) {
      print("onPause");
      _playing = false;
      _audioPlayer.pause();
      AudioServiceBackground.sendCustomEvent('just paused');
    }
  }

  @override
  void onSeekTo(int position) {
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
  }*/
  /*int _queueIndex = -1;
  AudioPlayer _audioPlayer = new AudioPlayer();
  Completer _completer = Completer();
  BasicPlaybackState _skipState;
  bool _playing;

  bool get hasNext => _queueIndex + 1 < _queue.length;

  bool get hasPrevious => _queueIndex > 0;

  MediaItem get mediaItem => _queue[_queueIndex];

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
    print("onStart Called");

    var playerStateSubscription = _audioPlayer.playbackStateStream
        .where((state) => state == AudioPlaybackState.completed)
        .listen((state) {
      print("playerStateSubscription... ${state.toString()}");

      _handlePlaybackCompleted();
    });
    var eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      final state = _eventToBasicState(event);
      if (state != BasicPlaybackState.stopped) {
        _setState(
          state: state,
          position: event.position.inMilliseconds,
        );
        print("eventSubscription... ${state.toString()}");
      }
    });

    AudioServiceBackground.setQueue(_queue);
//    await onSkipToNext();
    //Code additions (for async issue)
    print("Code additions (for async issue)... $_skipState // $_playing");

    _skipState = null;
    _playing = false;
    _setState(state: BasicPlaybackState.paused);

    await _completer.future;
    playerStateSubscription.cancel();
    eventSubscription.cancel();
  }

  @override
  void onAddQueueItem(MediaItem mediaItem) async {
    super.onAddQueueItem(mediaItem);
    _queue.add(mediaItem);

    // AudioServiceBackground.setQueue(_queue);
    // await onSkipToNext();
    print("onAddQueueItem } ${_queue[1].title}");
  }

  @override
  Future<void> onReplaceQueue(List<MediaItem> queue) {
    // TODO: implement onReplaceQueue
    return super.onReplaceQueue(queue);
  }

  @override
  void onPlayFromMediaId(String mediaId) async {
    // play the item at mediaItems[mediaId]
    await _audioPlayer.setUrl(mediaId);
    print("onPlayFromMediaId// ${mediaId.toString()}");
    _audioPlayer.play();
  }

  @override
  void onPlayMediaItem(MediaItem mediaItem) async {
    super.onPlayMediaItem(mediaItem);
    await _audioPlayer.setUrl(mediaItem.id);
    print("onPlayMediaItem............ ${mediaItem.id}");

    _audioPlayer.play();
  }

  void _handlePlaybackCompleted() {
    print("_handlePlaybackCompleted... $hasNext");

    if (hasNext) {
      onSkipToNext();
    } else {
      onStop();
    }
  }

  void playPause() {
    print(
        "playPause... ${AudioServiceBackground.state.basicState == BasicPlaybackState.playing}");

    if (AudioServiceBackground.state.basicState == BasicPlaybackState.playing)
      onPause();
    else
      onPlay();
//    onPause();
  }

  @override
  Future<void> onSkipToNext() => _skip(1);

  @override
  Future<void> onSkipToPrevious() => _skip(-1);

  Future<void> _skip(int offset) async {
    final newPos = _queueIndex + offset;
    print("_skip..: ${newPos}");
    print("_skip.... : ${!(newPos >= 0 && newPos < _queue.length)}");

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
    print("_skip _queueIndex  $_queueIndex");

    _skipState = offset > 0
        ? BasicPlaybackState.skippingToNext
        : BasicPlaybackState.skippingToPrevious;
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
    if (_queueIndex == -1) {
      await onSkipToNext(); // your code will automatically play
    } else {
      // your normal play code
      if (_skipState == null) {
        _playing = true;
        _audioPlayer.play();
        print('onPlay ... @ $_playing');
        AudioServiceBackground.sendCustomEvent('just played');
      }
    }
//    if (_skipState == null) {
//      _playing = true;
//      _audioPlayer.play();
//      print('onPlay ... @ $_playing');
//
//      AudioServiceBackground.sendCustomEvent('just played');
//    }
  }

  @override
  void onPause() {
    if (_skipState == null) {
      _playing = false;
      _audioPlayer.pause();
      print('onPause ... @ $_playing');

      AudioServiceBackground.sendCustomEvent('just paused');
    }
  }

  @override
  void onSeekTo(int position) {
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
  }*/
}

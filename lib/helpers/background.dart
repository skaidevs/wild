import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:wildstream/providers/recorded_stream_download.dart';

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
  List<MediaItem> _queue = <MediaItem>[];

  var _newQueue = <MediaItem>[];

  var _mediaItemIndex;
  int _queueIndex = -1;
  AudioPlayer _audioPlayer = new AudioPlayer();
  Completer _completer = Completer();
  BasicPlaybackState _skipState;
  bool _playing;
  int _playFromIdIndex;
  int _repeatIndex;
  bool _isRepeatEnable = false;
  bool _isShuffledEnable = false;

  bool get getIsRepeatEnable => _isRepeatEnable;

  bool get hasNext => _queueIndex + 1 < _queue.length;

  bool get hasPrevious => _queueIndex > 0;

  MediaItem get mediaItem => _queue[_queueIndex];

  RecordedStreamDownload _streamDownload = RecordedStreamDownload();

  MediaItem findMediaById({String mediaId}) {
    return _queue.firstWhere((media) => media.id == mediaId,
        orElse: () => null);
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
      print("playerStateSubscription... ${mediaItem?.duration} $_queueIndex");

      _handlePlaybackCompleted();
    });
    print("StateSubscription... $playerStateSubscription");

    var eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      print("eventSubscription position ${event.state} ");
      final state = _eventToBasicState(event);
      if (state != BasicPlaybackState.stopped) {
        _setState(
          state: state,
          position: event.position.inMilliseconds,
        );
      }
    });

    print("onStart $_queue $_queueIndex");

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
  void onAddQueueItem(MediaItem mediaItem) {
    _queue.add(mediaItem);
    AudioServiceBackground.setQueue(_queue);

    print("onAddQueueItem Called ${_queue.length}");
    super.onAddQueueItem(mediaItem);
  }

  @override
  Future<void> onReplaceQueue(List<MediaItem> queue) async {
    _queue.clear();
    _playing = true;

    print('onReplaceQueue called first ${_queue.length} and  $_playing');

    queue.forEach((media) async {
      _queue.add(media);
      //_queueIndex = 0;
    });
    await AudioServiceBackground.setQueue(_queue);
    _queueIndex = 0;
    _skip(_queueIndex);

    return super.onReplaceQueue(queue);
  }

  @override
  void onPlayFromMediaId(String mediaId) async {
    // play the item at mediaItems[mediaId]
    if (_playing == false) {
      _playing = true;
    }
    _mediaItemIndex = findMediaById(mediaId: mediaId);
    _playFromIdIndex = _queue.indexOf(_mediaItemIndex);
    print("index $_playFromIdIndex amd $_queueIndex");
    print("onPlayFromMediaId Called.. ${_queue.length}");

    _skip(_playFromIdIndex);
//    AudioServiceBackground.setQueue(_queue);
    AudioServiceBackground.sendCustomEvent('onPlayFromMediaId @index');
  }

  @override
  Future onCustomAction(String name, arguments) {
    // TODO: implement onCustomAction
    List<MediaItem> _originalQueue = <MediaItem>[];

    if (name == 'repeat') {
      if (arguments) {
        _isRepeatEnable = arguments;
      } else {
        _isRepeatEnable = arguments;
      }
//      _isShuffledEnable = false;
      AudioServiceBackground.sendCustomEvent(_isRepeatEnable);
    } else if (name == 'shuffle') {
      if (arguments) {
        _isShuffledEnable = arguments;
        _queue = _originalQueue;
        _queue.shuffle();
        //AudioServiceBackground.setQueue(_queue);

        print("Shuffled= $_isShuffledEnable ${_queue.length}");
      } else {
        _isShuffledEnable = arguments;
        _originalQueue = _queue;
        //AudioServiceBackground.setQueue(_queue);
        print("Shuffled= $_isShuffledEnable ${_queue.length} ");
      }
//      _isRepeatEnable = false;
      AudioServiceBackground.sendCustomEvent(_isShuffledEnable);
      print(
          "From ShuffledEnable $name | $arguments | $_isShuffledEnable and RepeatEnable $_isRepeatEnable");
    }

    if (name == 'repeat') {
    } else if (name == 'shuffle') {}

    return super.onCustomAction(name, arguments);
  }

  void _handlePlaybackCompleted() async {
    if (_queue.last == _queue[_queueIndex]) {
      _queueIndex = -1;
      print("LAST QUEUE ${_queue.last} and ${_queue.length}");
    }
    if (hasNext && _isRepeatEnable == false) {
      print("hasNext...");
      onSkipToNext();
    } else if (_isRepeatEnable) {
      final state = _audioPlayer.playbackState;
      Duration position = Duration(milliseconds: 1000);
      if (state == AudioPlaybackState.completed) {
        print(
            "state repeat ${position.inMilliseconds} $state $_isRepeatEnable");
        _audioPlayer.seek(position);
        onPlay();
      }
    } else {
      onStop();
    }
    _sendStreamCount();
  }

  void _sendStreamCount() async {
    try {
      await _streamDownload.streamCount(code: mediaItem.extras['code']);
      print('send stream count true');
    } catch (e) {
      print('Error sending strem count $e');
    }
    /*final state = _audioPlayer.playbackState;
    var _mediaDuration = mediaItem.duration;
    var _durationInPercentage = (mediaItem.duration * 20 / 100);

    if (state == AudioPlaybackState.completed &&
        _durationInPercentage <= _mediaDuration) {
      print("STATE111 ${mediaItem.duration} and $_durationInPercentage");
      try {
        await _streamDownload.streamCount(code: mediaItem.extras['code']);
        print('send stream count true');
      } catch (e) {
        print('Error sending strem count $e');
      }
    }*/
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
  Future<void> onSkipToNext({int position}) => _skip(1);

  @override
  Future<void> onSkipToPrevious() => _skip(-1);

  Future<void> _skip(int offset) async {
    print("1 $_queueIndex $offset  $_repeatIndex");

    int newPos = _queueIndex + offset;

    if (_playFromIdIndex != null) {
      newPos = _playFromIdIndex;
      print("Run newpos $_playFromIdIndex");
    }

    print("2 $newPos ");

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
    print("7 newPos $_queueIndex $offset \\ $_repeatIndex");

    AudioServiceBackground.setMediaItem(mediaItem);

    _skipState = offset > 0
        ? BasicPlaybackState.skippingToNext
        : BasicPlaybackState.skippingToPrevious;
    print("8 $offset");
    //TODO: onPause() Before going to next

//    onPause();
    print("onPause() Before going to next $_skipState");
    try {
      await _audioPlayer.setUrl(mediaItem.id);
    } catch (error) {
      print("error setUrl ${error.toString()}");
    }

    _skipState = null;
    _playFromIdIndex = null;

    print("9 $_skipState $_playFromIdIndex");

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
    //print("Duration ${position?.toString()}");
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

  /* Handling Audio Focus */
  @override
  void onAudioFocusGained() {
    _audioPlayer.setVolume(1.0);
    if (AudioServiceBackground.state.basicState == BasicPlaybackState.paused)
      onPlay();
  }

  @override
  void onAudioFocusLost() {
    onPause();
  }

  @override
  void onAudioFocusLostTransient() {
    onPause();
  }

  @override
  void onAudioFocusLostTransientCanDuck() {
    _audioPlayer.setVolume(0.5);
  }

  @override
  void onAudioBecomingNoisy() {
    onPause();
  }

  void _setState({@required BasicPlaybackState state, int position}) {
    if (position == null) {
      position = _audioPlayer.playbackEvent.position.inMilliseconds;
      //print("playbackEvent.position $position and State $state");
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

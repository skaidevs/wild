import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wildstream/models/song.dart';

class Hot100List with ChangeNotifier {
  List<MediaItem> _hot100MediaList = [];

  List<MediaItem> get hot100MediaList {
    return [..._hot100MediaList];
  }

  Future<List<MediaItem>> loadHot100() async {
    return _fetchHot100();
  }

  Future<List<MediaItem>> _fetchHot100() async {
    List<Data> _hot100SongList = [];
    Song _hot100Songs;

    String token =
        'aHOtlc4qu8WQmkBKQPX51GSepTGcHFqVRflQYeqLqDAjTELYkVZYHJIxDPfa6RC7ry2wVnMAlGMkmRB4psJz7s01m94cYaBf0QwKzrQ62Qmhts7lzXQ4hE9zWWocW0oIATYsHW3Vt6H4RkWsnVpTD4eYEM58mPTcoLGAahhdKHWS864LCNjj7lk2cbcFsr6qhUlDk4es';
    try {
      http.Response response = await http.get(
        Uri.encodeFull(
          'https://www.wildstream.ng/api/songs?type=hot_100&token=$token',
        ),
      );
      var extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null) {
        return null;
      }
      _hot100Songs = Song.fromJson(extractedData);

      if (_hot100Songs.name == 'Hot 100') {
        _hot100SongList = _hot100Songs.data.toList();
        if (_hot100MediaList.isEmpty) {
          _hot100MediaList.clear();
          _hot100SongList.forEach((mediaData) => {
                _hot100MediaList.add(
                  MediaItem(
                    id: mediaData.songFile.songUrl,
                    album: mediaData.name,
                    title: mediaData.name,
                    artist: mediaData.artistsToString,
                    duration: mediaData.duration,
                    artUri: mediaData.songArt.artUrl,
                  ),
                ),
              });
          notifyListeners();
          print("Media Data ${_hot100MediaList.length}");
        }
      }
    } catch (error) {
      print("Error fetching Hot100 Songs $error");
    }

    return _hot100MediaList;
  }

  /////////////

  /*int _queueIndex = -1;
  AudioPlayer _audioPlayer = new AudioPlayer();
  Completer _completer = Completer();
  BasicPlaybackState _skipState;
  bool _playing;

  bool get hasNext => _queueIndex + 1 < _queue.length;

  bool get hasPrevious => _queueIndex > 0;

  MediaItem get mediaItem => _queue[_queueIndex];

  BasicPlaybackState _eventToBasicState(AudioPlaybackEvent event) {
    print("Item ${_queue.length} /and ${_audioPlayer.durationStream}");
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
      _handlePlaybackCompleted();
    });
    var eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      final state = _eventToBasicState(event);
      if (state != BasicPlaybackState.stopped) {
        _setState(
          state: state,
          position: event.position.inMilliseconds,
        );
      }
      notifyListeners();
    });

    AudioServiceBackground.setQueue(_queue);
    await onSkipToNext();
    await _completer.future;
    playerStateSubscription.cancel();
    eventSubscription.cancel();
    notifyListeners();
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
    if (_skipState == null) {
      _playing = true;
      _audioPlayer.play();
    }
  }

  @override
  void onPause() {
    if (_skipState == null) {
      _playing = false;
      _audioPlayer.pause();
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
  void onStop() {
    _audioPlayer.stop();
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

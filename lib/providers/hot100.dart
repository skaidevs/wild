import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wildstream/models/song.dart';

class Hot100List with ChangeNotifier {
  List<Data> _hot100SongsList = [];

  List<Data> get hot100ListSongs {
    return [..._hot100SongsList];
  }

  Future<Song> loadHot100() async {
    return _fetchHot100();
  }

  Future<Song> _fetchHot100() async {
    List<MediaItem> _hot100MediaList = [];
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
        _hot100SongsList = _hot100Songs.data.toList();
        var _lastQueuedItems = AudioService.queue;
        if (_hot100MediaList.isEmpty || _hot100MediaList == null) {
//          _hot100MediaList.clear();
          _hot100SongsList.forEach((mediaData) => {
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

          print("AudioService.queue.... $_lastQueuedItems");
          if (Platform.isIOS) {
            if (_lastQueuedItems == null) {
              await AudioService.addQueueItems(_hot100MediaList);
              print(
                  "Platform.isIOS AudioService.addQueueItem Called ${_hot100MediaList.length}");
              AudioService.play();
            } else {
              notifyListeners();
              print(
                  "Platform.isIOS _lastQueuedItems ${_lastQueuedItems.length}");
              return _hot100Songs;
            }
          } else {
            if (_lastQueuedItems.isEmpty) {
              await AudioService.addQueueItems(_hot100MediaList);
              print(
                  "AudioService.addQueueItem Called ${_hot100MediaList.length}");
              AudioService.play();
            } else {
              notifyListeners();
              print("_lastQueuedItems ${_lastQueuedItems.length} ");
              return _hot100Songs;
            }
          }

          notifyListeners();
        }
      }
    } catch (error) {
      print("Error fetching Hot100 Songs $error");
    }

    return _hot100Songs;
  }
}

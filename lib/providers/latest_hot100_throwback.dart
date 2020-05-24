import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wildstream/helpers/background.dart';
import 'package:wildstream/models/song.dart';

enum SongTypes {
  latest,
  hot100,
  throwback,
}
const baseUrl = 'https://www.wildstream.ng/api/';
const token =
    'iX62dkPex5pV1oA3TgzretMJHECqmlu8uBuCwOjbtZ5wao3rHpP7H4H61XvuFiDS3zBEUVt2L9TFqMFM4zhROBNFXP5O2sIdjnj7qQRnWWlQ7LIkxQLceZ0K98BieLQWdACr4t5dwGcWexZz555RhUjedBIXrkLapewmDJRzLvmDBxNdvAVEc9qz0aidke5w3RyBvoLk';

class SongsNotifier with ChangeNotifier {
  Map<String, List<Data>> _cachedSongs;
  static List<String> _songTypesIds = [
    'latest',
    'hot_100',
    'throw_back',
  ];
  List<Data> _songListData = [];
  UnmodifiableListView<Data> get songListData =>
      UnmodifiableListView(_songListData);

  List<Data> _latestSongList = [];
  UnmodifiableListView<Data> get latestSongList =>
      UnmodifiableListView(_latestSongList);

  List<Data> _hot100SongList = [];
  UnmodifiableListView<Data> get hot100SongList =>
      UnmodifiableListView(_hot100SongList);

  List<Data> _throwbackSongList = [];
  UnmodifiableListView<Data> get throwbackSongList =>
      UnmodifiableListView(_throwbackSongList);

  List<MediaItem> _latestMediaList = [];
  List<MediaItem> get latestMediaList {
    return [..._latestMediaList];
  }

  List<MediaItem> _hot100MediaList = [];
  List<MediaItem> get hot100MediaList {
    return [..._hot100MediaList];
  }

  List<MediaItem> _throwbackMediaList = [];
  List<MediaItem> get throwbackMediaList {
    return [..._throwbackMediaList];
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  _startPlayer() async {
    await AudioService.start(
      backgroundTaskEntrypoint: _audioPlayerTaskEntryPoint,
      androidNotificationChannelName: 'WildStream',
      notificationColor: 0xFF0A0A0A,
      androidNotificationIcon: 'drawable/ic_notification',
      enableQueue: true,
    );
  }

  SongsNotifier() : _cachedSongs = Map() {
    //_cachedSongs = Map<String, List<Data>>();
    _initializeSongs().then((_) async {
      if ('latest' == _songTypesIds[0]) {
        await _startPlayer();
        _concertToMediaItem(
                mediaList: _latestSongList, addConvertedMedia: _latestMediaList)
            .then((_) async {
          await AudioService.addQueueItems(_latestMediaList);
          AudioService.play();
        }).then((_) {
          _isLoading = false;
          notifyListeners();
        });
        print('converted latest MEDIA');
      }
      if ('hot_100' == _songTypesIds[1]) {
        _concertToMediaItem(
          mediaList: _hot100SongList,
          addConvertedMedia: _hot100MediaList,
        );
        print('converted Hot100 MEDIA');
      }
      if ('throw_back' == _songTypesIds[2]) {
        _concertToMediaItem(
          mediaList: _throwbackSongList,
          addConvertedMedia: _throwbackMediaList,
        );
        print('converted Throwback MEDIA');
      }
    });
  }

  void playMediaFromButtonPressed({
    String playButton,
    String playFromId,
  }) async {
    if (playButton == _songTypesIds[0]) {
      await AudioService.replaceQueue(_latestMediaList).then((_) {
        AudioService.playFromMediaId(playFromId);
        print('Played From Latest: ${_latestMediaList.length}');
      });
    } else if (playButton == _songTypesIds[1]) {
      await AudioService.replaceQueue(_hot100MediaList).then((_) {
        AudioService.playFromMediaId(playFromId);
        print('Played From HOT100: ${_hot100MediaList.length}');
      });
    } else if (playButton == _songTypesIds[2]) {
      await AudioService.replaceQueue(_throwbackMediaList).then((_) {
        AudioService.playFromMediaId(playFromId);
        print('Played From THROWBACK: ${_throwbackMediaList.length}');
      });
    }
  }

  Future _concertToMediaItem({
    List<Data> mediaList,
    List<MediaItem> addConvertedMedia,
  }) async {
    mediaList.forEach((media) async {
      addConvertedMedia.add(MediaItem(
          id: media.songFile.songUrl,
          album: media.name,
          title: media.name,
          artist: media.artistsToString,
          duration: media.duration,
          artUri: media.songArt.crops.crop500,
          extras: {
            'code': media.code,
          }));
      //print('MediaItems CONVERTED >: ${_mediaList.toList()}');
    });
  }

  Future<void> _initializeSongs() async {
    _latestSongList = _songListData = await _updateSongs(
      songType: _songTypesIds[0],
    );
    _hot100SongList = _songListData = await _updateSongs(
      songType: _songTypesIds[1],
    );
    _throwbackSongList = _songListData = await _updateSongs(
      songType: _songTypesIds[2],
    );
  }

  Future<List<Data>> _updateSongs({String songType}) async {
    _isLoading = true;
    notifyListeners();
    final futureSong = await _getSongs(type: songType);
    return futureSong;
  }

  Future<List<Data>> _getSongs({String type}) async {
    print("Song Type   $type");

    if (!_cachedSongs.containsKey(type)) {
      final songsResponse = await http.get(
        Uri.encodeFull('$baseUrl${'songs?type='}$type&token=$token'),
      );
      if (songsResponse.statusCode == 200) {
        var extractedData = json.decode(songsResponse.body);
        if (extractedData == null) {
          return null;
        }
        Song song = Song.fromJson(extractedData);
        _cachedSongs[type] = song.data;
      } else {
        throw WildStreamError(
            'Songs $type could not be fetched. {{}} ${songsResponse.body}');
      }
    }

    //print("_cachedSongs:  ${_cachedSongs[type]}");

    return _cachedSongs[type];
  }

///////////////////////////
/*Future<List<MediaItem>> fetchMediaList() async {
    print("_latestSubject ${_latestSongList?.length}");

    var _lastQueuedItems = AudioService.queue;
    if (_lastQueuedItems == null || _lastQueuedItems.isEmpty) {
      if (_latestSongList != null) {
        await _startPlayer();
        _mediaList.forEach((media) async {
          */ /*_mediaList.add(MediaItem(
            id: media.songFile.songUrl,
            album: media.name,
            title: media.name,
            artist: media.artistsToString,
            duration: media.duration,
            artUri: media.songArt.crops.crop500,
          ));*/ /*
          print('MediaItems >: ${_mediaList.toList()}');
          notifyListeners();
        });
        print('Called Last?: ${_mediaList.toList()}');
        await AudioService.addQueueItems(mediaList);
        AudioService.play();
      }
    } else {
      print("length is Not 0 ${_lastQueuedItems.length} ");

      return null;
    }
    return _mediaList;
  }*/
}

class WildStreamError {
  final String message;

  WildStreamError(this.message);
}

void _audioPlayerTaskEntryPoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class Hot100List with ChangeNotifier {
  /*List<MediaItem> _hot100MediaList = [];
  List<MediaItem> get hot100MediaList {
    return [..._hot100MediaList];
  }

  Future<List<MediaItem>> loadHot100() async {
    return _fetchHot100();
  }

  Future<List<MediaItem>> _fetchHot100() async {
    List<Data> _hot100SongsList = [];
    Song _hot100Songs;
    String token =
        'u8BC3Y6XaWGlplNldAljni4YHbiCSlsTKTteiGe4E9ibaN49rf5pcZRcDkz40zOky8oZeuDXYdRCj15rGbpp66ThucN8OAb735gbvnhEJNN6aSIz0ck0RjDzbjVmKZHan5pYUlriitSCNDDPWRYriumIB1R8HlPmVWO7IQ5k6TQNvEWSNduaMB7IuKHknbVPGqodBtlf';
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
        print("Hott.... ${_hot100SongsList[1].songArt.crops.crop500}");

        var _lastQueuedItems = AudioService.queue;
        if (_hot100MediaList.isEmpty || _hot100MediaList == null) {
          _hot100SongsList.forEach((mediaData) => {
                _hot100MediaList.add(
                  MediaItem(
                    id: mediaData.songFile.songUrl,
                    album: mediaData.name,
                    title: mediaData.name,
                    artist: mediaData.artistsToString,
                    duration: mediaData.duration,
                    artUri: mediaData.songArt.crops.crop500,
                  ),
                ),
              });

          print("AudioService.queue.... $_lastQueuedItems");
*/ /*          if (Platform.isIOS) {
            if (_lastQueuedItems == null) {
              await AudioService.addQueueItems(_hot100MediaList);
              print(
                  "Platform.isIOS AudioService.addQueueItem Called ${_hot100MediaList.length}");
              AudioService.play();
            } else {
              notifyListeners();
              print(
                  "Platform.isIOS _lastQueuedItems ${_lastQueuedItems.length}");
              return _hot100MediaList;
            }
          } else {
            if (_lastQueuedItems.isEmpty) {
              await AudioService.addQueueItems(_hot100MediaList);
              print(
                  "AudioService.addQueueItem Called ${_hot100MediaList.length}");
//              AudioService.play();
            } else {
              notifyListeners();
              print("_lastQueuedItems ${_lastQueuedItems.length} ");
              return _hot100MediaList;
            }
          }*/ /*

          notifyListeners();
        }
      }
    } catch (error) {
      print("Error fetching Hot100 Songs $error");
    }

    return _hot100MediaList;
  }*/
}

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/subjects.dart';
import 'package:wildstream/models/song.dart';

enum SongTypes {
  latest,
  hot100,
  throwback,
}

class SongsNotifier with ChangeNotifier {
  Map<String, List<Data>> _cachedSongs;
  Stream<UnmodifiableListView<Data>> get latestSongList =>
      _latestSubject.stream;
  Stream<UnmodifiableListView<Data>> get hot100SongList =>
      _hot100Subject.stream;
  Stream<UnmodifiableListView<Data>> get throwbackSongList =>
      _throwbackSubject.stream;

  final _latestSubject = BehaviorSubject<UnmodifiableListView<Data>>();
  final _hot100Subject = BehaviorSubject<UnmodifiableListView<Data>>();
  final _throwbackSubject = BehaviorSubject<UnmodifiableListView<Data>>();

  Sink<SongTypes> get songTypes => _songTypesController.sink;
  final _songTypesController = StreamController<SongTypes>();
  List<Data> songListData = [];

  var _songs = <Data>[];

//  Future<Song> loadSongs({String songType}) async {
//    return _getSongsAndUpdate(ids: );
//  }

  static List<String> _songTypesIds = [
    'latest',
    'hot_100',
    'throw_back',
  ];

  Stream<bool> get isLoading => _isLoadingSubject.stream;
  final _isLoadingSubject = BehaviorSubject<bool>.seeded(false);

  Future<String> _getSongsIds({SongTypes type}) async {
    return _songTypesIds[0];
  }

  SongsNotifier() {
    _cachedSongs = Map<String, List<Data>>();
    _initializeSongs();
    _songTypesController.stream.listen((songTypes) async {
      print("Invalid $_cachedSongs");
      print('Latest1 ${_latestSubject.length}');

      _getSongsAndUpdate(type: _songTypesIds[0], subject: _latestSubject);
      print('Hot1001 ${_hot100Subject.length}');

      _getSongsAndUpdate(type: _songTypesIds[1], subject: _hot100Subject);
      print('Throw back1 ${_throwbackSubject.length}');

      _getSongsAndUpdate(type: _songTypesIds[2], subject: throwbackSongList);
      /*switch (songTypes) {
        case SongTypes.latest:
          print('Latest1 ${_latestSubject.length}');
          _getSongsAndUpdate(type: _songTypesIds[0], subject: _latestSubject);
          break;
        case SongTypes.hot100:
          print('Hot1001 ${_hot100Subject.length}');

          _getSongsAndUpdate(type: _songTypesIds[1], subject: _hot100Subject);
          break;
        case SongTypes.throwback:
          print('Throw back1 ${_throwbackSubject.length}');

          _getSongsAndUpdate(
              type: _songTypesIds[2], subject: throwbackSongList);
          break;
        default:
          print("Invalid TYPE");
          break;
      }*/
    });
  }

  Future<void> _initializeSongs() async {
    _getSongsAndUpdate(type: _songTypesIds[0], subject: _latestSubject);
    _getSongsAndUpdate(type: _songTypesIds[1], subject: _hot100Subject);
    _getSongsAndUpdate(type: _songTypesIds[2], subject: throwbackSongList);
//    _getSongsAndUpdate(type: await _getSongsIds(type: SongTypes.latest));
  }

  Future _getSongsAndUpdate(
      {BehaviorSubject<UnmodifiableListView<Data>> subject,
      String type}) async {
    _isLoadingSubject.add(true);
    await _updateSongs(type);
    subject.add(
      UnmodifiableListView(_songs),
    );
    _isLoadingSubject.add(false);
  }

  Future<Null> _updateSongs(songType) async {
    final futureSong = await _getSongs(type: songType);
//    print('object whats here: ${futureSong}');
    _songs = futureSong;
  }

  static const _baseUrl = 'https://www.wildstream.ng/api/songs?type=';

  Future<List<Data>> _getSongs({String type}) async {
    String token =
        'u8BC3Y6XaWGlplNldAljni4YHbiCSlsTKTteiGe4E9ibaN49rf5pcZRcDkz40zOky8oZeuDXYdRCj15rGbpp66ThucN8OAb735gbvnhEJNN6aSIz0ck0RjDzbjVmKZHan5pYUlriitSCNDDPWRYriumIB1R8HlPmVWO7IQ5k6TQNvEWSNduaMB7IuKHknbVPGqodBtlf';
    print("_cachedSongs.containsKey(type)   $type");

    if (!_cachedSongs.containsKey(type)) {
      final songsResponse = await http.get('$_baseUrl$type&token=$token');
      if (songsResponse.statusCode == 200) {
        var extractedData = json.decode(songsResponse.body);
        if (extractedData == null) {
          return null;
        }
        Song song = Song.fromJson(extractedData);
        _cachedSongs[type] = song.data;
//        print("Check   ${_cachedSongs[type]}");
      } else {
        throw WildStreamError('Songs $type could not be fetched.');
      }
    }
//    print("_cachedSongs   ${_cachedSongs[type]}");
    return _cachedSongs[type];
  }

  void close() {
    _throwbackSubject.close();
    _hot100Subject.close();
    _latestSubject.close();

    _songTypesController.close();
    _isLoadingSubject.close();
  }
}

class WildStreamError {
  final String message;

  WildStreamError(this.message);
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

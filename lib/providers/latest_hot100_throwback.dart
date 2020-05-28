import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wildstream/helpers/mediaItems.dart';
import 'package:wildstream/models/song.dart';

const baseUrl = 'https://www.wildstream.ng/api/';
const token =
    'uij7DHm8k8BBIlwdsWjGde0UM4HeztSOU2VZCVrhKuYGe3VidGyoKnguik7bmkyJBOjEAGSgFbKEhI18no1VPJr3thIRw6HhdpYaVFTdXzkJi3hNjSYX5r8sIe4onYYKia28KjTk38MJrUzq7oPHZqUn6TvFOryYb9LqVDzipBP2aH3ubsc3txQOGsxMRQlc4L2vyvyz';

class SongsNotifier with ChangeNotifier {
  Map<String, List<Data>> _cachedSongs;
  UnmodifiableListView<String> get songTypesIds =>
      UnmodifiableListView(songTypes);

  List<Data> _songListData = [];
  UnmodifiableListView<Data> get songListData =>
      UnmodifiableListView(_songListData);

  List<Data> _mediaItems = [];
  UnmodifiableListView<Data> get mediaItems =>
      UnmodifiableListView(_mediaItems);

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

  SongsNotifier() : _cachedSongs = Map() {
    //_cachedSongs = Map<String, List<Data>>();
    _initializeSongs().then((_) async {
      if ('latest' == songTypes[0]) {
        await startPlayer();
        concertSongsToMediaItem(
          songsList: _latestSongList,
          mediaItems: _latestMediaList,
        ).then((_) async {
          await AudioService.addQueueItems(_latestMediaList);
          AudioService.play();
        }).then((_) {
          print('SONGS LIST ITEMS>> ${songListData.length}');
          _isLoading = false;
          notifyListeners();
        });
      }
      if ('hot_100' == songTypes[1]) {
        concertSongsToMediaItem(
          songsList: _hot100SongList,
          mediaItems: _hot100MediaList,
        );
        print('converted Hot100 MEDIA');
      }
      if ('throw_back' == songTypes[2]) {
        concertSongsToMediaItem(
          songsList: _throwbackSongList,
          mediaItems: _throwbackMediaList,
        );
        print('converted Throwback MEDIA');
      }
    });
  }

//  Iterable<String> get songTypes => null;

  Future<void> _initializeSongs() async {
    _latestSongList = _songListData = await _updateSongs(
      songType: songTypes[0],
    );
    _hot100SongList = _songListData = await _updateSongs(
      songType: songTypes[1],
    );
    _throwbackSongList = _songListData = await _updateSongs(
      songType: songTypes[2],
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

import 'dart:collection';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:wildstream/helpers/mediaItems.dart';
import 'package:wildstream/models/album_details.dart';
import 'package:wildstream/providers/latest_hot100_throwback.dart';

class AlbumDetailNotifier with ChangeNotifier {
  Map<String, AlbumData> _cachedAlbumDetail;
  List<Songs> _detailAlbumList = [];
  UnmodifiableListView<Songs> get detailAlbumList =>
      UnmodifiableListView(_detailAlbumList);
  List<MediaItem> _mediaList = [];
  List<MediaItem> get mediaList {
    return [..._mediaList];
  }

  List<String> _mediaInQueue = [];
  List<String> get mediaInQueue {
    return [..._mediaInQueue];
  }

  String _albumCode;
  String get albumCode => _albumCode;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _shotUrl;
  String get shotUrl => _shotUrl;

  Future<void> loadAlumsDetailList({
    String code,
  }) async {
    return await _initializeAndUpdateSongs(code: code);
  }

  AlbumDetailNotifier() : _cachedAlbumDetail = Map() {
    _initializeAndUpdateSongs();
  }

  Future<AlbumData> _initializeAndUpdateSongs({String code}) async {
    _isLoading = true;
    notifyListeners();
    final futureSong = await _getAlumsDetailList(code: code);
    if (futureSong != null) {
      _shotUrl = futureSong.shortUrl;
      _detailAlbumList = futureSong.songs;
      convertAlbumDetailsToMediaItem(
        detailAlbumSongList: _detailAlbumList,
        mediaItems: _mediaList,
      ).then((_) {
        _isLoading = false;
        notifyListeners();
        print('Length  and${_detailAlbumList?.length} ');
      });
    }
    return futureSong;
  }

  Future<AlbumData> _getAlumsDetailList({String code}) async {
    print('CODE!!!!! $code');
    if (code == null) {
      return null;
    }
    if (!_cachedAlbumDetail.containsKey(code)) {
      final albumDetailResponse = await http.get(
        Uri.encodeFull('$baseUrl' + 'album/' + '$code?&token=$token'),
      );
      //print('1111: ${albumDetailResponse.body}');

      if (albumDetailResponse.statusCode == 200) {
        var extractedData = json.decode(albumDetailResponse.body);
        if (extractedData == null) {
          return null;
        }
        AlbumSong _album = AlbumSong.fromJson(extractedData);

        _cachedAlbumDetail[code] = _album.data;
      } else {
        _isLoading = false;
        notifyListeners();
        throw WildStreamError(
            'Album could not be fetched. {{}} ${albumDetailResponse.body}');
      }
    }
    return _cachedAlbumDetail[code];
  }
}

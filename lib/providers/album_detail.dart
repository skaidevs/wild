import 'dart:collection';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:wildstream/models/album_details.dart';
import 'package:wildstream/providers/latest_hot100_throwback.dart';

class AlbumDetailNotifier with ChangeNotifier {
  Map<String, List<Songs>> _cachedAlbumDetail;
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

  Future<List<Songs>> loadAlumsDetailList({
    String code,
  }) async {
    return await _getAlumsDetailList(code: code).then((_) async {
      /*var _lastQueuedItems = AudioService.queue;
      if (_lastQueuedItems.isNotEmpty) {
        _lastQueuedItems.clear();

        print('Queue Changed >: ${_lastQueuedItems.length}');
      }*/

      /* if (_mediaInQueue[0] == _albumCode && _mediaInQueue.isNotEmpty) {
        print('AL_ready in >: $_albumCode');
        _isLoading = false;
        notifyListeners();
        return;
      } else {
        _concertToMediaItem(detailAlbumSongList: _detailAlbumList);
        //await AudioService.replaceQueue(_mediaList);
        print('Queue Changed >: ${_mediaInQueue.length}');
        _mediaInQueue.add(code);
        _isLoading = false;
        notifyListeners();
      }*/

      _concertToMediaItem(detailAlbumSongList: _detailAlbumList);
//      await AudioService.replaceQueue(_mediaList);
//      print('Queue Changed >: ${_mediaInQueue.length}');
      _isLoading = false;
      notifyListeners();
      print('CALLED IN ALBUM QUEUE');
      return;
    });
  }

  void playMediaFromButtonPressed({
    String playButton,
    String playFromId,
  }) async {
    if (playButton == '_playAllFromButton') {
      await AudioService.replaceQueue(_mediaList);
      AudioService.play();
      print('Played ALL From Button: ${_mediaInQueue.length}');
    } else {
      await AudioService.replaceQueue(_mediaList).then((_) {
        AudioService.playFromMediaId(playFromId);
      });
      print('Played from ID: ${_mediaInQueue.length}');
    }
  }

  AlbumDetailNotifier() : _cachedAlbumDetail = Map() {}

  Future _concertToMediaItem({List<Songs> detailAlbumSongList}) async {
    _mediaList.clear();
    detailAlbumSongList.forEach((media) async {
      _mediaList.add(
        MediaItem(
            id: media.songFile.songUrl,
            album: media.name,
            title: media.name,
            artist: media.artistsToString,
            duration: media.duration,
            artUri: media.songArt.crops.crop500,
            extras: {
              'code': media.code,
            }),
      );
//      print('MediaItems CONVERTED >: ${_mediaList.toList()}');
    });
  }

  Future<List<Songs>> _getAlumsDetailList({String code}) async {
    _isLoading = true;
    notifyListeners();
    final albumDetailResponse = await http.get(
      Uri.encodeFull('$baseUrl' + 'album/' + '$code?&token=$token'),
    );
    //print('URL $baseUrl' + 'album/' + '$code?&token=$token');
    //print('1111: ${albumDetailResponse.body}');

    if (albumDetailResponse.statusCode == 200) {
      _detailAlbumList.clear();

      var extractedData =
          json.decode(albumDetailResponse.body); //as Map<String, dynamic>;

      //print('RESPONSE: ${albumDetailResponse.body}');
      //print('RUN AND ${extractedData.toString()}');

      if (extractedData == null) {
        return null;
      }
      AlbumSong album = AlbumSong.fromJson(extractedData);

      //print('RUN ALBUMLIST ${album.data}');

      _detailAlbumList = album.data.songs;
      _shotUrl = album.data.shortUrl;

      notifyListeners();
      _albumCode = code;
//      print(
//          'ALBUMLIST???? ${album.data.songs.length}  and ${_detailAlbumList.length}');
    } else {
      print('ERROR ${albumDetailResponse.body}');
      _isLoading = false;
      notifyListeners();
      throw WildStreamError(
          'Album could not be fetched. {{}} ${albumDetailResponse.body}');
    }
    return _detailAlbumList;
  }
}

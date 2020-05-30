import 'dart:collection';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wildstream/models/search.dart';
import 'package:wildstream/providers/latest_hot100_throwback.dart';

class SearchNotifier with ChangeNotifier {
  Map<String, Search> _cachedSearchSongs;

  List<Data> _searchSongList = [];
  UnmodifiableListView<Data> get searchSongList =>
      UnmodifiableListView(_searchSongList);

  List<MediaItem> _mediaList = [];
  List<MediaItem> get mediaList {
    return [..._mediaList];
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<Search> loadSearchedSongs({
    String query,
  }) {
    return _getSearchedSongs(query: query);
  }

  Future _concertToMediaItem({List<Data> searchSongList}) async {
    _mediaList.clear();
    searchSongList.forEach((media) async {
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
      print('MediaItems CONVERTED >: ${_mediaList.toList()}');
    });
  }

  Future<Search> _getSearchedSongs({String query}) async {
    _isLoading = true;
    notifyListeners();
    print('CODE!!!!! $query');
    if (query == null) {
      return null;
    }
    Search _searchedSongs;
    final searchedSongsResponse = await http.get(
      Uri.encodeFull('${baseUrl}songs/search?type=&token=$token&query=$query'),
    );
    print('URL: ${'${baseUrl}songs/search?type=&token=$token&query=$query'}');

    //print('1111: ${searchedSongsResponse.body}');

    if (searchedSongsResponse.statusCode == 200) {
      var extractedData = json.decode(searchedSongsResponse.body);
      if (extractedData == null) {
        return null;
      }
      _searchedSongs = Search.fromJson(extractedData);
      _searchSongList = _searchedSongs.data;
      //print('DATA: ${_searchedSongs.query} AND ${_searchedSongs.data[0].name}');

      _concertToMediaItem(searchSongList: _searchSongList).then((_) {
        _isLoading = false;
        notifyListeners();
        //print('Length  and${_mediaList?.length} ');
      });
    } else {
      _isLoading = false;
      notifyListeners();
      throw WildStreamError(
          'Album could not be fetched. {{}} ${searchedSongsResponse.body}');
    }
    return _searchedSongs;
  }
}

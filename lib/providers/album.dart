import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wildstream/models/album.dart';

import 'latest_hot100_throwback.dart';

class AlbumNotifier with ChangeNotifier {
  Map<String, List<Data>> _cachedAlbums;

  List<Data> _albumListData = [];
  UnmodifiableListView<Data> get albumListData =>
      UnmodifiableListView(_albumListData);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Data findAlbumById({String code}) {
    return _albumListData.firstWhere((id) => id.code == code);
  }

  AlbumNotifier() : _cachedAlbums = Map() {
    //_cachedSongs = Map<String, List<Data>>();
    _initializeAlbum().then((_) async {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _initializeAlbum() async {
    _albumListData = await _updateAlbums();
  }

  Future<List<Data>> _updateAlbums() async {
    _isLoading = true;
    notifyListeners();
    final futureAlbums = await getAlums();
    print('Length ${futureAlbums[1].name}');
    return futureAlbums;
  }

  Future<List<Data>> getAlums() async {
    String albums = 'albums';

    if (!_cachedAlbums.containsKey(albums)) {
      final albumResponse = await http.get(
        Uri.encodeFull('$baseUrl$albums?&token=$token'),
      );
      print('${'$baseUrl$albums?&token=$token'}');
      //print('RESPONSE: ${albumResponse.body}');

      if (albumResponse.statusCode == 200) {
        var extractedData =
            json.decode(albumResponse.body); //as Map<String, dynamic>;
        if (extractedData == null) {
          return null;
        }
        Album album = Album.fromJson(extractedData);
        print('RUN ${album.data[1].artists}');

        _cachedAlbums[albums] = album.data;

        print('RUN?? ${album.data.length}');
      } else {
        throw WildStreamError(
            'Album could not be fetched. {{}} ${albumResponse.body}');
      }
    }
    print('run4..... ${_cachedAlbums[albums]}');

    return _cachedAlbums[albums];
  }
}

// A function that converts a response body into a List<Photo>.
List<Data> parseAlbums(String responseBody) {
  print('run1');

  final parsed = json.decode(responseBody);
  print('run2');

  final albumResponse = new Album.fromJson(parsed);
  print('run3');

  return albumResponse.data;
}

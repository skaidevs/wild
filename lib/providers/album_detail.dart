import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:wildstream/models/album_details.dart';
import 'package:wildstream/providers/latest_hot100_throwback.dart';

class AlbumDetailNotifier with ChangeNotifier {
  Map<String, List<Songs>> _cachedAlbumDetail;
  List<Songs> _detailAlbumList = [];
  UnmodifiableListView<Songs> get detailAlbumList =>
      UnmodifiableListView(_detailAlbumList);

  Future<List<Songs>> loadAlumsDetailList({
    String code,
  }) async {
    return await _getAlumsDetailList(code: code);
  }

  Future<List<Songs>> _getAlumsDetailList({String code}) async {
    final albumDetailResponse = await http.get(
      Uri.encodeFull('$baseUrl' + 'album/' + '$code?&token=$token'),
    );
    print('URL $baseUrl' + 'album/' + '$code?&token=$token');
    //print('1111: ${albumDetailResponse.body}');

    if (albumDetailResponse.statusCode == 200) {
      _detailAlbumList.clear();
      var extractedData =
          json.decode(albumDetailResponse.body); //as Map<String, dynamic>;

      //print('RESPONSE: ${albumDetailResponse.body}');
      print('RUN AND ${extractedData.toString()}');

      if (extractedData == null) {
        return null;
      }
      AlbumSong album = AlbumSong.fromJson(extractedData);

      print('RUN ALBUMLIST ${album.data}');

      _detailAlbumList = album.data.songs;

      notifyListeners();
      print(
          'ALBUMLIST???? ${album.data.songs.length}  and ${_detailAlbumList.length}');
    } else {
      print('ERROR ${albumDetailResponse.body}');

      throw WildStreamError(
          'Album could not be fetched. {{}} ${albumDetailResponse.body}');
    }
    return _detailAlbumList;
  }
}

import 'package:flutter/cupertino.dart';

class Album with ChangeNotifier {
  final List<Data> data;

  Album({this.data});
  factory Album.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['data'] as List;
    List<Data> albumData = list.map((i) => Data.fromJson(i)).toList();
    return Album(
      data: albumData,
    );
  }
}

class Data with ChangeNotifier {
  final String code;
  final String name;
  final List<Artists> artists;
  final AlbumArt albumArt;
  final String releasedAt;

  Data({
    this.code,
    this.name,
    this.artists,
    this.albumArt,
    this.releasedAt,
  });

  factory Data.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['artists'] as List;
    List<Artists> artistsData = list.map((i) => Artists.fromJson(i)).toList();

    return Data(
      code: parsedJson['code'] as String,
      name: parsedJson['name'] as String,
      albumArt: AlbumArt.fromJson(parsedJson['album_art']),
      artists: artistsData,
      releasedAt: parsedJson['released_at'] as String,
    );
  }
}

class AlbumArt with ChangeNotifier {
  final String url;
  final Crop crop;

  AlbumArt({this.url, this.crop});
  factory AlbumArt.fromJson(Map<String, dynamic> parsedJson) {
    return AlbumArt(
      url: parsedJson['url'] as String,
      crop: Crop.fromJson(parsedJson['crops']),
    );
  }
}

class Crop with ChangeNotifier {
  final String crop200;

  Crop({this.crop200});
  factory Crop.fromJson(Map<String, dynamic> parsedJson) {
    return Crop(
      crop200: parsedJson['200'] as String,
    );
  }
}

class Artists with ChangeNotifier {
  final String name;

  Artists({this.name});

  factory Artists.fromJson(Map<String, dynamic> parsedJson) {
    return Artists(
      name: parsedJson['name'] as String,
    );
  }
}

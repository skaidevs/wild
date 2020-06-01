import 'package:flutter/foundation.dart';
import 'package:wildstream/providers/download.dart';

class Search with ChangeNotifier {
  final String query;
  final List<Data> data;
  Search({
    this.query,
    this.data,
  });
  factory Search.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['data'] as List;
    List<Data> songsData = list.map((i) => Data.fromJson(i)).toList();
    return Search(
      query: parsedJson['query'],
      data: songsData,
    );
  }
}

class Data with ChangeNotifier {
  final String code;
  final String name;
  final String shortUrl;
  final String artistsToString;
  final int duration;
  final String releasedAt;
  final SongFile songFile;
  final SongArt songArt;
  final TaskInfo downloadTask;

  Data(
      {this.code,
      this.name,
      this.shortUrl,
      this.artistsToString,
      this.duration,
      this.releasedAt,
      this.songFile,
      this.songArt,
      this.downloadTask});

  factory Data.fromJson(Map<dynamic, dynamic> parsedJson) {
    int calculatedDuration(int duration) {
      final _times = 1000;
      final _newDuration = duration * _times;
      return _newDuration;
    }

    return Data(
      code: parsedJson['code'] as String,
      name: parsedJson['name'] as String,
      shortUrl: parsedJson['short_url'] as String,
      artistsToString: parsedJson['artists_to_string'] as String,
      duration: calculatedDuration(parsedJson['duration']),
      releasedAt: parsedJson['released_at'] as String,
      songFile: SongFile.fromJson(parsedJson['file']),
      songArt: SongArt.fromJson(parsedJson['song_art']),
      downloadTask: TaskInfo(link: '', name: ''),
    );
  }
}

class SongFile with ChangeNotifier {
  final String songUrl;
  SongFile({this.songUrl});
  factory SongFile.fromJson(Map<String, dynamic> parsedJson) {
    return SongFile(
      songUrl: parsedJson['url'] as String,
    );
  }
}

class SongArt with ChangeNotifier {
  final String artUrl;
  Crops crops;

  SongArt({this.artUrl, this.crops});

  factory SongArt.fromJson(Map<String, dynamic> parsedJson) {
    return SongArt(
      artUrl: parsedJson['url'] as String,
      crops: Crops.fromJson(parsedJson['crops']),
    );
  }
}

class Crops with ChangeNotifier {
  final String crop500;
  final String crop100;
  Crops({this.crop500, this.crop100});

  factory Crops.fromJson(Map<String, dynamic> parsedJson) {
    return Crops(
      crop100: parsedJson['100'] as String,
      crop500: parsedJson['500'] as String,
    );
  }
}

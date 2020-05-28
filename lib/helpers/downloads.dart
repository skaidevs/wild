import 'dart:io';

import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'downloads.g.dart';

// Define tables that can model a database of recipes.

class Downloads extends Table {
  @override
  Set<Column> get primaryKey => {id, mediaCode};
  //MediaID
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mediaCode => text()();
  TextColumn get mediaIdUri => text()();
  TextColumn get mediaArtUri => text()();
  TextColumn get mediaTitle => text()();
  TextColumn get mediaAlbum => text()();
  TextColumn get mediaArtist => text()();
  IntColumn get mediaDuration => integer()();
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(
      p.join(dbFolder.path, 'db.sqlite'),
    );
    return VmDatabase(file);
  });
}

@UseMoor(
  tables: [Downloads],
)
class Database extends _$Database {
  Database() : super(_openConnection());

  @override
  int get schemaVersion => 1;

/*  void addDownloads(MediaItem mediaItem) {
    int id = Random().nextInt(20000);
    var _mediaItems = Download(
      id: id,
      mediaIdUri: mediaItem.id,
      mediaArtUri: mediaItem.artUri,
      mediaTitle: mediaItem.title,
      mediaAlbum: mediaItem.title,
      mediaArtist: mediaItem.artist,
      mediaDuration: mediaItem.duration,
      mediaCode: mediaItem.extras['code'],
    );
    print('myInt ${_mediaItems.id}');

    into(downloads).insert(_mediaItems);
  }*/

  Future addDownload(Download download) => into(downloads).insert(download);

  void removeDownloads(String code) => (delete(downloads)
        ..where(
          (media) => media.mediaCode.equals(code),
        ))
      .go();

  // loads all todo entries
  Future<List<Download>> get allDownloads => select(downloads).get();

  // watches all todo entries in a given category. The stream will automatically
  // emit new items whenever the underlying data changes.
  Stream<bool> isDownload(String code) {
    return (select(downloads)
          ..where(
            (download) => download.mediaCode.equals(code),
          ))
        .watch()
        .map((downloadList) => downloadList.length >= 1);
  }
}

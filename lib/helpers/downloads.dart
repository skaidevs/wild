import 'dart:collection';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wildstream/helpers/mediaItems.dart';

part 'downloads.g.dart';

// Define tables that can model a database of Media.

class Downloads extends Table {
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
    // put the database file, called db.wildStream here, into the documents folder
    // for the app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(
      p.join(dbFolder.path, 'db.wildStream'),
    );
    return VmDatabase(file);
  });
}

@UseMoor(tables: [Downloads], daos: [DownloadDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

@UseDao(tables: [Download])
class DownloadDao extends DatabaseAccessor<AppDatabase>
    with _$DownloadDaoMixin {
  final AppDatabase db;
  final List<MediaItem> _mediaItems = [];
  UnmodifiableListView<MediaItem> get mediaItems =>
      UnmodifiableListView(_mediaItems);

  DownloadDao(this.db) : super(db);

  Future<List<Download>> get allDownloads => select(db.downloads).get();
  void convertedMediaItem() {
    allDownloads.then((downloadList) {
      if (downloadList.length != _mediaItems.length) {
        _mediaItems.clear();
        concertDownloadToMediaItem(
          downloadList: downloadList,
          mediaItems: _mediaItems,
        );
        print('DOWNLOADS: ${downloadList.length} {} ${_mediaItems.length}');
        return;
      } else {
        print('DOWNLOADS: ${downloadList.length} EQUAL ${_mediaItems.length}');
        return;
      }
    });
  }

  Stream<List<Download>> watchAllDownloads() {
    convertedMediaItem();
    return (select(db.downloads)
          ..orderBy([
            (table) => OrderingTerm(
                  expression: table.id,
                  mode: OrderingMode.desc,
                )
          ]))
        .watch();
  }

  Future insertDownload(Insertable<Download> download) =>
      into(db.downloads).insert(download);

  Future removeDownloads(String code) => (delete(db.downloads)
        ..where(
          (media) => media.mediaCode.equals(code),
        ))
      .go();

  Stream<bool> isDownloaded(String code) {
    return (select(db.downloads)
          ..where(
            (download) => download.mediaCode.equals(code),
          ))
        .watch()
        .map((downloadList) => downloadList.length >= 1);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downloads.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class Download extends DataClass implements Insertable<Download> {
  final int id;
  final String mediaCode;
  final String mediaIdUri;
  final String mediaArtUri;
  final String mediaTitle;
  final String mediaAlbum;
  final String mediaArtist;
  final int mediaDuration;
  Download(
      {@required this.id,
      @required this.mediaCode,
      @required this.mediaIdUri,
      @required this.mediaArtUri,
      @required this.mediaTitle,
      @required this.mediaAlbum,
      @required this.mediaArtist,
      @required this.mediaDuration});
  factory Download.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return Download(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      mediaCode: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}media_code']),
      mediaIdUri: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}media_id_uri']),
      mediaArtUri: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}media_art_uri']),
      mediaTitle: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}media_title']),
      mediaAlbum: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}media_album']),
      mediaArtist: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}media_artist']),
      mediaDuration: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}media_duration']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || mediaCode != null) {
      map['media_code'] = Variable<String>(mediaCode);
    }
    if (!nullToAbsent || mediaIdUri != null) {
      map['media_id_uri'] = Variable<String>(mediaIdUri);
    }
    if (!nullToAbsent || mediaArtUri != null) {
      map['media_art_uri'] = Variable<String>(mediaArtUri);
    }
    if (!nullToAbsent || mediaTitle != null) {
      map['media_title'] = Variable<String>(mediaTitle);
    }
    if (!nullToAbsent || mediaAlbum != null) {
      map['media_album'] = Variable<String>(mediaAlbum);
    }
    if (!nullToAbsent || mediaArtist != null) {
      map['media_artist'] = Variable<String>(mediaArtist);
    }
    if (!nullToAbsent || mediaDuration != null) {
      map['media_duration'] = Variable<int>(mediaDuration);
    }
    return map;
  }

  DownloadsCompanion toCompanion(bool nullToAbsent) {
    return DownloadsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      mediaCode: mediaCode == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaCode),
      mediaIdUri: mediaIdUri == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaIdUri),
      mediaArtUri: mediaArtUri == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaArtUri),
      mediaTitle: mediaTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaTitle),
      mediaAlbum: mediaAlbum == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaAlbum),
      mediaArtist: mediaArtist == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaArtist),
      mediaDuration: mediaDuration == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaDuration),
    );
  }

  factory Download.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Download(
      id: serializer.fromJson<int>(json['id']),
      mediaCode: serializer.fromJson<String>(json['mediaCode']),
      mediaIdUri: serializer.fromJson<String>(json['mediaIdUri']),
      mediaArtUri: serializer.fromJson<String>(json['mediaArtUri']),
      mediaTitle: serializer.fromJson<String>(json['mediaTitle']),
      mediaAlbum: serializer.fromJson<String>(json['mediaAlbum']),
      mediaArtist: serializer.fromJson<String>(json['mediaArtist']),
      mediaDuration: serializer.fromJson<int>(json['mediaDuration']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mediaCode': serializer.toJson<String>(mediaCode),
      'mediaIdUri': serializer.toJson<String>(mediaIdUri),
      'mediaArtUri': serializer.toJson<String>(mediaArtUri),
      'mediaTitle': serializer.toJson<String>(mediaTitle),
      'mediaAlbum': serializer.toJson<String>(mediaAlbum),
      'mediaArtist': serializer.toJson<String>(mediaArtist),
      'mediaDuration': serializer.toJson<int>(mediaDuration),
    };
  }

  Download copyWith(
          {int id,
          String mediaCode,
          String mediaIdUri,
          String mediaArtUri,
          String mediaTitle,
          String mediaAlbum,
          String mediaArtist,
          int mediaDuration}) =>
      Download(
        id: id ?? this.id,
        mediaCode: mediaCode ?? this.mediaCode,
        mediaIdUri: mediaIdUri ?? this.mediaIdUri,
        mediaArtUri: mediaArtUri ?? this.mediaArtUri,
        mediaTitle: mediaTitle ?? this.mediaTitle,
        mediaAlbum: mediaAlbum ?? this.mediaAlbum,
        mediaArtist: mediaArtist ?? this.mediaArtist,
        mediaDuration: mediaDuration ?? this.mediaDuration,
      );
  @override
  String toString() {
    return (StringBuffer('Download(')
          ..write('id: $id, ')
          ..write('mediaCode: $mediaCode, ')
          ..write('mediaIdUri: $mediaIdUri, ')
          ..write('mediaArtUri: $mediaArtUri, ')
          ..write('mediaTitle: $mediaTitle, ')
          ..write('mediaAlbum: $mediaAlbum, ')
          ..write('mediaArtist: $mediaArtist, ')
          ..write('mediaDuration: $mediaDuration')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          mediaCode.hashCode,
          $mrjc(
              mediaIdUri.hashCode,
              $mrjc(
                  mediaArtUri.hashCode,
                  $mrjc(
                      mediaTitle.hashCode,
                      $mrjc(
                          mediaAlbum.hashCode,
                          $mrjc(mediaArtist.hashCode,
                              mediaDuration.hashCode))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Download &&
          other.id == this.id &&
          other.mediaCode == this.mediaCode &&
          other.mediaIdUri == this.mediaIdUri &&
          other.mediaArtUri == this.mediaArtUri &&
          other.mediaTitle == this.mediaTitle &&
          other.mediaAlbum == this.mediaAlbum &&
          other.mediaArtist == this.mediaArtist &&
          other.mediaDuration == this.mediaDuration);
}

class DownloadsCompanion extends UpdateCompanion<Download> {
  final Value<int> id;
  final Value<String> mediaCode;
  final Value<String> mediaIdUri;
  final Value<String> mediaArtUri;
  final Value<String> mediaTitle;
  final Value<String> mediaAlbum;
  final Value<String> mediaArtist;
  final Value<int> mediaDuration;
  const DownloadsCompanion({
    this.id = const Value.absent(),
    this.mediaCode = const Value.absent(),
    this.mediaIdUri = const Value.absent(),
    this.mediaArtUri = const Value.absent(),
    this.mediaTitle = const Value.absent(),
    this.mediaAlbum = const Value.absent(),
    this.mediaArtist = const Value.absent(),
    this.mediaDuration = const Value.absent(),
  });
  DownloadsCompanion.insert({
    this.id = const Value.absent(),
    @required String mediaCode,
    @required String mediaIdUri,
    @required String mediaArtUri,
    @required String mediaTitle,
    @required String mediaAlbum,
    @required String mediaArtist,
    @required int mediaDuration,
  })  : mediaCode = Value(mediaCode),
        mediaIdUri = Value(mediaIdUri),
        mediaArtUri = Value(mediaArtUri),
        mediaTitle = Value(mediaTitle),
        mediaAlbum = Value(mediaAlbum),
        mediaArtist = Value(mediaArtist),
        mediaDuration = Value(mediaDuration);
  static Insertable<Download> custom({
    Expression<int> id,
    Expression<String> mediaCode,
    Expression<String> mediaIdUri,
    Expression<String> mediaArtUri,
    Expression<String> mediaTitle,
    Expression<String> mediaAlbum,
    Expression<String> mediaArtist,
    Expression<int> mediaDuration,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaCode != null) 'media_code': mediaCode,
      if (mediaIdUri != null) 'media_id_uri': mediaIdUri,
      if (mediaArtUri != null) 'media_art_uri': mediaArtUri,
      if (mediaTitle != null) 'media_title': mediaTitle,
      if (mediaAlbum != null) 'media_album': mediaAlbum,
      if (mediaArtist != null) 'media_artist': mediaArtist,
      if (mediaDuration != null) 'media_duration': mediaDuration,
    });
  }

  DownloadsCompanion copyWith(
      {Value<int> id,
      Value<String> mediaCode,
      Value<String> mediaIdUri,
      Value<String> mediaArtUri,
      Value<String> mediaTitle,
      Value<String> mediaAlbum,
      Value<String> mediaArtist,
      Value<int> mediaDuration}) {
    return DownloadsCompanion(
      id: id ?? this.id,
      mediaCode: mediaCode ?? this.mediaCode,
      mediaIdUri: mediaIdUri ?? this.mediaIdUri,
      mediaArtUri: mediaArtUri ?? this.mediaArtUri,
      mediaTitle: mediaTitle ?? this.mediaTitle,
      mediaAlbum: mediaAlbum ?? this.mediaAlbum,
      mediaArtist: mediaArtist ?? this.mediaArtist,
      mediaDuration: mediaDuration ?? this.mediaDuration,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mediaCode.present) {
      map['media_code'] = Variable<String>(mediaCode.value);
    }
    if (mediaIdUri.present) {
      map['media_id_uri'] = Variable<String>(mediaIdUri.value);
    }
    if (mediaArtUri.present) {
      map['media_art_uri'] = Variable<String>(mediaArtUri.value);
    }
    if (mediaTitle.present) {
      map['media_title'] = Variable<String>(mediaTitle.value);
    }
    if (mediaAlbum.present) {
      map['media_album'] = Variable<String>(mediaAlbum.value);
    }
    if (mediaArtist.present) {
      map['media_artist'] = Variable<String>(mediaArtist.value);
    }
    if (mediaDuration.present) {
      map['media_duration'] = Variable<int>(mediaDuration.value);
    }
    return map;
  }
}

class $DownloadsTable extends Downloads
    with TableInfo<$DownloadsTable, Download> {
  final GeneratedDatabase _db;
  final String _alias;
  $DownloadsTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _mediaCodeMeta = const VerificationMeta('mediaCode');
  GeneratedTextColumn _mediaCode;
  @override
  GeneratedTextColumn get mediaCode => _mediaCode ??= _constructMediaCode();
  GeneratedTextColumn _constructMediaCode() {
    return GeneratedTextColumn(
      'media_code',
      $tableName,
      false,
    );
  }

  final VerificationMeta _mediaIdUriMeta = const VerificationMeta('mediaIdUri');
  GeneratedTextColumn _mediaIdUri;
  @override
  GeneratedTextColumn get mediaIdUri => _mediaIdUri ??= _constructMediaIdUri();
  GeneratedTextColumn _constructMediaIdUri() {
    return GeneratedTextColumn(
      'media_id_uri',
      $tableName,
      false,
    );
  }

  final VerificationMeta _mediaArtUriMeta =
      const VerificationMeta('mediaArtUri');
  GeneratedTextColumn _mediaArtUri;
  @override
  GeneratedTextColumn get mediaArtUri =>
      _mediaArtUri ??= _constructMediaArtUri();
  GeneratedTextColumn _constructMediaArtUri() {
    return GeneratedTextColumn(
      'media_art_uri',
      $tableName,
      false,
    );
  }

  final VerificationMeta _mediaTitleMeta = const VerificationMeta('mediaTitle');
  GeneratedTextColumn _mediaTitle;
  @override
  GeneratedTextColumn get mediaTitle => _mediaTitle ??= _constructMediaTitle();
  GeneratedTextColumn _constructMediaTitle() {
    return GeneratedTextColumn(
      'media_title',
      $tableName,
      false,
    );
  }

  final VerificationMeta _mediaAlbumMeta = const VerificationMeta('mediaAlbum');
  GeneratedTextColumn _mediaAlbum;
  @override
  GeneratedTextColumn get mediaAlbum => _mediaAlbum ??= _constructMediaAlbum();
  GeneratedTextColumn _constructMediaAlbum() {
    return GeneratedTextColumn(
      'media_album',
      $tableName,
      false,
    );
  }

  final VerificationMeta _mediaArtistMeta =
      const VerificationMeta('mediaArtist');
  GeneratedTextColumn _mediaArtist;
  @override
  GeneratedTextColumn get mediaArtist =>
      _mediaArtist ??= _constructMediaArtist();
  GeneratedTextColumn _constructMediaArtist() {
    return GeneratedTextColumn(
      'media_artist',
      $tableName,
      false,
    );
  }

  final VerificationMeta _mediaDurationMeta =
      const VerificationMeta('mediaDuration');
  GeneratedIntColumn _mediaDuration;
  @override
  GeneratedIntColumn get mediaDuration =>
      _mediaDuration ??= _constructMediaDuration();
  GeneratedIntColumn _constructMediaDuration() {
    return GeneratedIntColumn(
      'media_duration',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [
        id,
        mediaCode,
        mediaIdUri,
        mediaArtUri,
        mediaTitle,
        mediaAlbum,
        mediaArtist,
        mediaDuration
      ];
  @override
  $DownloadsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'downloads';
  @override
  final String actualTableName = 'downloads';
  @override
  VerificationContext validateIntegrity(Insertable<Download> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id'], _idMeta));
    }
    if (data.containsKey('media_code')) {
      context.handle(_mediaCodeMeta,
          mediaCode.isAcceptableOrUnknown(data['media_code'], _mediaCodeMeta));
    } else if (isInserting) {
      context.missing(_mediaCodeMeta);
    }
    if (data.containsKey('media_id_uri')) {
      context.handle(
          _mediaIdUriMeta,
          mediaIdUri.isAcceptableOrUnknown(
              data['media_id_uri'], _mediaIdUriMeta));
    } else if (isInserting) {
      context.missing(_mediaIdUriMeta);
    }
    if (data.containsKey('media_art_uri')) {
      context.handle(
          _mediaArtUriMeta,
          mediaArtUri.isAcceptableOrUnknown(
              data['media_art_uri'], _mediaArtUriMeta));
    } else if (isInserting) {
      context.missing(_mediaArtUriMeta);
    }
    if (data.containsKey('media_title')) {
      context.handle(
          _mediaTitleMeta,
          mediaTitle.isAcceptableOrUnknown(
              data['media_title'], _mediaTitleMeta));
    } else if (isInserting) {
      context.missing(_mediaTitleMeta);
    }
    if (data.containsKey('media_album')) {
      context.handle(
          _mediaAlbumMeta,
          mediaAlbum.isAcceptableOrUnknown(
              data['media_album'], _mediaAlbumMeta));
    } else if (isInserting) {
      context.missing(_mediaAlbumMeta);
    }
    if (data.containsKey('media_artist')) {
      context.handle(
          _mediaArtistMeta,
          mediaArtist.isAcceptableOrUnknown(
              data['media_artist'], _mediaArtistMeta));
    } else if (isInserting) {
      context.missing(_mediaArtistMeta);
    }
    if (data.containsKey('media_duration')) {
      context.handle(
          _mediaDurationMeta,
          mediaDuration.isAcceptableOrUnknown(
              data['media_duration'], _mediaDurationMeta));
    } else if (isInserting) {
      context.missing(_mediaDurationMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Download map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Download.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $DownloadsTable createAlias(String alias) {
    return $DownloadsTable(_db, alias);
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $DownloadsTable _downloads;
  $DownloadsTable get downloads => _downloads ??= $DownloadsTable(this);
  DownloadDao _downloadDao;
  DownloadDao get downloadDao =>
      _downloadDao ??= DownloadDao(this as AppDatabase);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [downloads];
}

// **************************************************************************
// DaoGenerator
// **************************************************************************

mixin _$DownloadDaoMixin on DatabaseAccessor<AppDatabase> {}

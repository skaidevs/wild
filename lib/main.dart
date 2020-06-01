import 'dart:isolate';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:wildstream/helpers/background.dart';
import 'package:wildstream/helpers/downloads_database.dart';
import 'package:wildstream/providers/album.dart';
import 'package:wildstream/providers/album_detail.dart';
import 'package:wildstream/providers/bottom_navigator.dart';
import 'package:wildstream/providers/download.dart';
import 'package:wildstream/providers/latest_hot100_throwback.dart';
import 'package:wildstream/providers/recorded_stream_download.dart';
import 'package:wildstream/providers/search.dart';
import 'package:wildstream/screens/album_details.dart';
import 'package:wildstream/screens/search.dart';
import 'package:wildstream/screens/wildstream_home_page.dart';
import 'package:wildstream/widgets/commons.dart';

const debug = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: debug);

  runApp(WildStreamApp());
}

GlobalKey<NavigatorState> _mainNavigatorKey = GlobalKey<NavigatorState>();

class WildStreamApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;

    final newTextTheme = Theme.of(context).textTheme.apply(
          bodyColor: kColorWhite,
          displayColor: kColorWhite,
        );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SongsNotifier>(
          create: (_) => SongsNotifier(),
          child: WildStreamHomePage(),
        ),
        ChangeNotifierProvider<AudioPlayerTask>(
          create: (_) => AudioPlayerTask(),
        ),
        ChangeNotifierProvider<RecordedStreamDownload>(
          create: (_) => RecordedStreamDownload(),
        ),
        ChangeNotifierProvider<AlbumNotifier>(
          create: (_) => AlbumNotifier(),
        ),
        ChangeNotifierProvider<AlbumDetailNotifier>(
          create: (_) => AlbumDetailNotifier(),
          child: AlbumDetails(),
        ),
        ChangeNotifierProvider<BottomNavigation>(
          create: (_) => BottomNavigation(),
          child: WildStreamHomePage(),
        ),
        ChangeNotifierProvider<SearchNotifier>(
          create: (_) => SearchNotifier(),
          child: Search(),
        ),
        Provider<DownloadDao>(
          create: (_) => AppDatabase().downloadDao,
          child: WildStreamHomePage(),
          dispose: (context, db) => db.db.close(),
        ),
        ChangeNotifierProvider<DownloadNotifier>(
          create: (_) => DownloadNotifier(),
          child: Search(),
        ),
      ],
      child: MaterialApp(
        key: _mainNavigatorKey,
        title: 'WildStream',
        theme: ThemeData(
            brightness: Brightness.dark,
            accentColorBrightness: Brightness.dark,
            backgroundColor: bg_color,
//            primarySwatch: bg_color,
            primaryColor: Color(0XFF1E222A),
            bottomAppBarColor: Color(0XFF1E222A),
            accentColor: const Color(0XFF029D75),
            hintColor: Colors.white,
            textTheme: newTextTheme),
        debugShowCheckedModeBanner: false,
        home: PermissionGranted(
          platform: platform,
        ),
      ),
    );
  }
}

class PermissionGranted extends StatefulWidget {
  final TargetPlatform platform;

  const PermissionGranted({Key key, this.platform}) : super(key: key);

  @override
  _PermissionGrantedState createState() => _PermissionGrantedState();
}

class _PermissionGrantedState extends State<PermissionGranted> {
  void _bindBackgroundIsolate() {
    Future.delayed(Duration.zero).then((_) async {
      final _downloadNotifier = Provider.of<DownloadNotifier>(
        context,
        listen: false,
      );
      _downloadNotifier.bindBackgroundIsolate();
      FlutterDownloader.registerCallback(downloadCallback);
      _downloadNotifier.prepare(platform: widget.platform);
    });
  }

  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadNotifier>(
      builder: (context, notifier, _) => notifier.isLoading
          ? new Center(
              child: new CircularProgressIndicator(),
            )
          : notifier.permissionReady
              ? AudioServiceWidget(
                  child: WildStreamHomePage(
                    title: 'WildStream',
                    platform: widget.platform,
                  ),
                )
              : Scaffold(
                  appBar: AppBar(
                    title: Text('Grant Permission'),
                  ),
                  body: new Container(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              'Please grant accessing storage permission to continue -_-',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.blueGrey, fontSize: 18.0),
                            ),
                          ),
                          SizedBox(
                            height: 32.0,
                          ),
                          FlatButton(
                            onPressed: () {
                              setState(() {
                                notifier.hasGrantedPermission(
                                  platform: widget.platform,
                                );
                              });
                            },
                            child: Text(
                              'Retry',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}

void downloadCallback(String id, DownloadTaskStatus status, int progress) {
  if (debug) {
    print(
        'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
  }
  final SendPort send =
      IsolateNameServer.lookupPortByName('downloader_send_port');
  send.send([id, status, progress]);
}

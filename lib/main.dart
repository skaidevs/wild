import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/getflutter.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wildstream/helpers/background.dart';
import 'package:wildstream/providers/hot100.dart';

void main() => runApp(WildStreamApp());

const MaterialColor bg_color = const MaterialColor(
  0xFF0A0A0A,
  const <int, Color>{
    50: const Color(0xFF0A0A0A),
    100: const Color(0xFF0A0A0A),
    200: const Color(0xFF0A0A0A),
    300: const Color(0xFF0A0A0A),
    400: const Color(0xFF0A0A0A),
    500: const Color(0xFF0A0A0A),
    600: const Color(0xFF0A0A0A),
    700: const Color(0xFF0A0A0A),
    800: const Color(0xFF0A0A0A),
    900: const Color(0xFF0A0A0A),
  },
);
const Color kColorWSGreen = Color(0xFF029D75);
List<MediaItem> _queue = [
  MediaItem(
    id: "https://cdn.wildstream.ng/storage/jungle/music/2019/3/9/imported-jy9orzxchz2q7ztywtdj.mp3",
    album: "Location..",
    title: "Location",
    artist: "Dave (feat. Burna Boy)",
    duration: 573980,
    artUri:
        "https://cdn.wildstream.ng/storage/jungle/featured_images/M0RFK2rW5KY.png",
  ),
  MediaItem(
    id: "https://cdn.wildstream.ng/storage/jungle/music/2019/10/2/imported-a0ntuflslqeab.mp3",
    album: "Koto Aye (Vol.2)..",
    title: "Koto Aye (Vol.2)",
    artist: "Davolee, Mr Bee, Mohbad, Tsalt",
    duration: 285690,
    artUri:
        "https://cdn.wildstream.ng/storage/jungle/featured_images/ClyAcxYF8om3e.jpg",
  ),
  MediaItem(
    id: "https://cdn.wildstream.ng/storage/jungle/music/2019/6/21/imported-riszoibwx2q1mfqe.mp3",
    album: "Ello Baby..",
    title: "Ello Baby",
    artist: "Tiwa Savage, Young John, Kizz Daniel",
    duration: 573980,
    artUri:
        "https://cdn.wildstream.ng/storage/jungle/featured_images/mr0Yugxihk.jpg",
  ),
  MediaItem(
    id: "https://cdn.wildstream.ng/storage/jungle/music/2019/11/29/imported-b73xojzkvexxnce.mp3",
    album: "Vibration..",
    title: "Vibration",
    artist: "Fireboy DML",
    duration: 285690,
    artUri:
        "https://cdn.wildstream.ng/storage/jungle/featured_images/LPbfhZ6KHX.jpg",
  ),
];

class WildStreamApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Hot100List>(
          create: (_) => Hot100List(),
          child: WildStreamHomePage(),
        ),
      ],
      child: MaterialApp(
        title: 'Wildstrem',
        theme: ThemeData(
          primarySwatch: bg_color,
        ),
        debugShowCheckedModeBanner: false,
        home: AudioServiceWidget(child: WildStreamHomePage()),
      ),
    );
  }
}

class WildStreamHomePage extends StatefulWidget {
  final String title;

  WildStreamHomePage({Key key, this.title}) : super(key: key);

  @override
  _WildStreamHomePageState createState() => _WildStreamHomePageState();
}

class _WildStreamHomePageState extends State<WildStreamHomePage>
    with WidgetsBindingObserver {
  /// Tracks the position while the user drags the seek bar.
  final BehaviorSubject<double> _dragPositionSubject =
      BehaviorSubject.seeded(null);

  bool _show = true;
  bool _isLoading = false;
  bool _isPlaying = false;
  int _buildIndex = 0;
  int _selectedIndex = 0;

  MediaItem mediaItem;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  Future<List<MediaItem>> _fetchHot100Songs() async {
    return await Provider.of<Hot100List>(
      context,
      listen: false,
    ).loadHot100().catchError((onError) {
      print("Error on Screen $onError");
    });
  }

  void _fetchData() async {
    _isLoading = true;
//    if (_pc == null) {
//      _pc.hide();
//    }

    Future.delayed(
      Duration.zero,
    ).then((_) async {
      _fetchHot100Songs().then((hot100MediaList) async {
        await _startPlayer();
        var _lastQueuedItems = AudioService.queue;
        print("_lastQueuedItems $_lastQueuedItems");

        if (_lastQueuedItems == null || _lastQueuedItems.isEmpty) {
          print("addQueueItem from api ${hot100MediaList.length}");
          await AudioService.addQueueItems(hot100MediaList);
          AudioService.play();
        } else {
          print("length is Not 0 ${_lastQueuedItems.length} ");
          return;
        }
        print("run afer addQueue from api ${hot100MediaList.length}");
      }).then(
        (_) => setState(() => _isLoading = false),
      );
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void initState() {
    super.initState();
    connect();
    WidgetsBinding.instance.addObserver(this);
//    this._startPlayer();
    this._fetchData();
  }

  _startPlayer() async {
//    connect();
    await AudioService.start(
      backgroundTaskEntrypoint: _audioPlayerTaskEntryPoint,
      androidNotificationChannelName: 'WildStream',
      notificationColor: 0xFF0A0A0A,
      androidNotificationIcon: 'mipmap/ic_launcher',
      enableQueue: true,
    );
  }

  void showBottomBar() {
    setState(() {
      _show = true;
    });
  }

  void hideBottomBar() {
    setState(() {
      _show = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disconnect();
    super.dispose();
  }

  AppLifecycleState _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });

    print('didChangeAppLifecycleState called $_notification');

    switch (state) {
      case AppLifecycleState.resumed:
        connect();

        print('AppLifecycleState.resumed called ${state.index}');
        break;
      case AppLifecycleState.paused:
        disconnect();
        print('AppLifecycleState.paused called ${state.index}');
        break;
      default:
        break;
    }
  }

  void connect() async {
    await AudioService.connect();
    print("AudioService.connect() ");
  }

  void disconnect() {
    AudioService.disconnect();
    print("AudioService.disconnect()");
  }

  PanelController _pc = PanelController();

  Widget _mediaIndicator() {
    return Icon(
      Icons.library_music,
      color: kColorWSGreen,
    );
  }

  _onSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    print("BUILD NUMBER ${_buildIndex++}");
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(10.0),
      topRight: Radius.circular(10.0),
    );
    return Scaffold(
//      appBar: AppBar(
//        title: Text('WildStream'),
//      ),
      backgroundColor: bg_color,
      body: SlidingUpPanel(
        controller: _pc,
        onPanelOpened: hideBottomBar,
        onPanelClosed: showBottomBar,
        maxHeight: MediaQuery.of(context).size.height,
        minHeight: _isLoading ? 0.0 : 60.0,
        panel: Center(
          child: StreamBuilder<ScreenState>(
            stream: _screenStateStream,
            builder: (context, snapshot) {
              final screenState = snapshot.data;
              final queue = screenState?.queue;
              mediaItem = screenState?.mediaItem;
              final state = screenState?.playbackState;
              final basicState = state?.basicState ?? BasicPlaybackState.none;

              if (snapshot.hasError)
                print("ERROR On StreamBuilder ${snapshot.error}");

              print(
                  "Changes in UI ${queue?.length} || ${mediaItem?.title} ||-- ${state?.position}|| || ${basicState.toString()}");
              return snapshot.hasData
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (mediaItem?.artUri != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: GFAvatar(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6.0),
                              ),
                              shape: GFAvatarShape.standard,
                              size: 150.0,
                              backgroundImage: NetworkImage(mediaItem.artUri),
                            ),
                          ),
                        if (queue != null && queue.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.skip_previous),
                                iconSize: 64.0,
                                onPressed: mediaItem == queue.first
                                    ? null
                                    : AudioService.skipToPrevious,
                              ),
                              IconButton(
                                icon: Icon(Icons.skip_next),
                                iconSize: 64.0,
                                onPressed: mediaItem == queue.last
                                    ? null
                                    : AudioService.skipToNext,
                              ),
                            ],
                          ),
                        if (mediaItem?.title != null) Text(mediaItem.title),
                        if (basicState == BasicPlaybackState.none) ...[
                          Text('BasicPlaybackState.none # $basicState')
                        ] else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (basicState == BasicPlaybackState.playing)
                                pauseButton()
                              else if (basicState == BasicPlaybackState.paused)
                                playButton()
                              else if (basicState ==
                                      BasicPlaybackState.buffering ||
                                  basicState ==
                                      BasicPlaybackState.skippingToNext ||
                                  basicState ==
                                      BasicPlaybackState.skippingToPrevious)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 50.0,
                                    height: 50.0,
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              stopButton(),
                            ],
                          ),
                        if (basicState != BasicPlaybackState.none &&
                            basicState != BasicPlaybackState.stopped) ...[
                          positionIndicator(mediaItem, state),
                          Text("State: " +
                              "$basicState".replaceAll(RegExp(r'^.*\.'), '')),
                          StreamBuilder(
                            stream: AudioService.customEventStream,
                            builder: (context, snapshot) {
                              return Text("custom event: ${snapshot.data}");
                            },
                          ),
                        ],
                      ],
                    )
                  : Center(child: CircularProgressIndicator());
            },
          ),
        ),
        collapsed: Container(
          decoration: BoxDecoration(
            color: Colors.blueGrey,
          ),
          child: Center(
            child: Text(
              "PLAYER",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: ListView(
            children: <Widget>[
              Consumer<Hot100List>(
                builder: (context, data, child) => ListView.separated(
                  padding: const EdgeInsets.all(2.0),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  separatorBuilder: (context, index) => const Divider(
                    indent: 90.0,
                    thickness: 0.6,
                    endIndent: 10.0,
                    color: Colors.white30,
                  ),
                  itemCount: data.hot100MediaList.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: GFAvatar(
                      borderRadius: BorderRadius.all(
                        Radius.circular(6.0),
                      ),
                      shape: GFAvatarShape.standard,
                      size: 42.0,
                      backgroundImage:
                          NetworkImage(data.hot100MediaList[index].artUri),
                    ),
                    title: Text(
                      '${data.hot100MediaList[index].title}',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                      ),
                      child: Text(
                        '${data.hot100MediaList[index].artist}',
                        style: TextStyle(color: kColorWSGreen),
                      ),
                    ),
                    trailing: mediaItem?.id == data.hot100MediaList[index].id
                        ? _mediaIndicator()
                        : Icon(
                            Icons.more_horiz,
                            color: kColorWSGreen,
                          ),
                    onTap: () async {
                      AudioService.playFromMediaId(
                          data.hot100MediaList[index].id);
//                      setState(() {
//                        mediaItem = data.hot100MediaList[index];
//                      });
                      print("addQueue UI ${data.hot100MediaList[index].title}");
                      mediaItem = data.hot100MediaList[index];

//                      _selectedIndex = 0;
//                      _onSelected(index);
//                      setState(() {
//                      });
                    },
                    selected: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _show
          ? BottomNavigationBar(
              backgroundColor: bg_color,
              currentIndex: 0, // this will be set when a new tab is tapped
              items: [
                BottomNavigationBarItem(
                  icon: new Icon(
                    Icons.home,
                    color: kColorWSGreen,
                  ),
                  title: new Text('Home'),
                ),
                BottomNavigationBarItem(
                  icon: new Icon(
                    Icons.search,
                    color: kColorWSGreen,
                  ),
                  title: new Text('Search'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.library_music,
                    color: kColorWSGreen,
                  ),
                  title: Text(
                    'Playlist',
                  ),
                )
              ],
            )
          : null,
      /* floatingActionButton: FloatingActionButton(
          child: Icon(Icons.stars),
          onPressed: () async {
            print("Item::::::list ${_queue.length}");
//            final q = AudioService.queue;
//            print("Seelected QUEITEM  ${q[0].title}");
            _controller.isOpened ? _controller.hide() : _controller.show();
          }),*/
    );
  }

  /// Encapsulate all the different data we're interested in into a single
  /// stream so we don't have to nest StreamBuilders.
  Stream<ScreenState> get _screenStateStream =>
      Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
          (queue, mediaItem, playbackState) =>
              ScreenState(queue, mediaItem, playbackState));

  RaisedButton startButton(String label, VoidCallback onPressed) =>
      RaisedButton(
        child: Text(label),
        onPressed: onPressed,
      );

  IconButton playButton() => IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 64.0,
        onPressed: AudioService.play,
      );

  IconButton pauseButton() => IconButton(
        icon: Icon(Icons.pause),
        iconSize: 64.0,
        onPressed: AudioService.pause,
      );

  IconButton stopButton() => IconButton(
        icon: Icon(Icons.stop),
        iconSize: 64.0,
        onPressed: AudioService.stop,
      );

  Widget positionIndicator(MediaItem mediaItem, PlaybackState state) {
    double seekPos;
    //TODO: Consider changing slider to also react to seekPos as well (to int can't be called on null)

    String _printDuration(Duration duration) {
      //NOTE: Does not account for days or anything greater than days
      // Duration duration = Duration(milliseconds: ms);
      String twoDigits(int n) {
        if (n >= 10) return "$n";
        return "0$n";
      }

      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      // logger.log();
//      print("Duration $twoDigitMinutes:$twoDigitSeconds");
      if (duration.inHours == 0) return "$twoDigitMinutes:$twoDigitSeconds";
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }

    return StreamBuilder(
      stream: Rx.combineLatest2<double, double, double>(
          _dragPositionSubject.stream,
          Stream.periodic(Duration(milliseconds: 200)),
          (dragPosition, _) => dragPosition),
      builder: (context, snapshot) {
        double position = snapshot.data ?? state.currentPosition.toDouble();
        double duration = mediaItem?.duration?.toDouble();
        return Column(
          children: [
            if (duration != null)
              Slider(
                min: 0.0,
                max: duration,
                value: seekPos ?? max(0.0, min(position, duration)),
                onChanged: (value) {
                  _dragPositionSubject.add(value);
                },
                onChangeEnd: (value) {
                  AudioService.seekTo(value.toInt());
                  // Due to a delay in platform channel communication, there is
                  // a brief moment after releasing the Slider thumb before the
                  // new position is broadcast from the platform side. This
                  // hack is to hold onto seekPos until the next state update
                  // comes through.
                  // TODO: Improve this code.
                  seekPos = value;
                  _dragPositionSubject.add(null);
                },
              ),
            Text("${(state.currentPosition / 1000).toStringAsFixed(3)}"),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 20, 0),
              child: Container(
                transform: Matrix4.translationValues(0.0, -10.0, 0.0),
                child: Row(children: <Widget>[
                  Text(
                    //Shows duration of slider or actual playback state duration
                    "${_printDuration(
                      Duration(
                          milliseconds: _dragPositionSubject.value != null
                              ? _dragPositionSubject.value.toInt()
                              : state.currentPosition),
                    )}",
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                    ),
                  ),

                  Spacer(), //
                  Text(
                    // Value below was originally mediaItem?.duration? (check if this causes errors)
                    //Shows duration of slider or actual playback state duration - current playBack state position
                    mediaItem == null
                        ? "-00:00"
                        : "-${_printDuration(
                            _dragPositionSubject.value != null
                                ? Duration(milliseconds: mediaItem?.duration) -
                                    Duration(
                                      milliseconds:
                                          _dragPositionSubject.value.toInt(),
                                    )
                                : Duration(milliseconds: mediaItem?.duration) -
                                    Duration(
                                        milliseconds: state.currentPosition),
                          )}",
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                    ),
                  ), // use Spacer
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

void _audioPlayerTaskEntryPoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class ScreenState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;
  final PlaybackState playbackState;

  ScreenState(this.queue, this.mediaItem, this.playbackState);
}

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/getflutter.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wildstream/helpers/background.dart';
import 'package:wildstream/helpers/screen_state.dart';
import 'package:wildstream/models/song.dart';
import 'package:wildstream/providers/bottom_navigator.dart';
import 'package:wildstream/providers/latest_hot100_throwback.dart';
import 'package:wildstream/screens/album.dart';
import 'package:wildstream/screens/latest_hot100_throwback.dart';
import 'package:wildstream/screens/player.dart';
import 'package:wildstream/screens/playlist.dart';
import 'package:wildstream/screens/search.dart';

//void main() => runApp(WildStreamApp());
void main() {
  final hcBloc = SongsNotifier();
  runApp(
    WildStreamApp(
      bloc: hcBloc,
    ),
  );
}

class LoadingInfo extends StatefulWidget {
  final Stream<bool> _isLoading;
  LoadingInfo(this._isLoading);

  @override
  _LoadingInfoState createState() => _LoadingInfoState();
}

class _LoadingInfoState extends State<LoadingInfo>
    with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget._isLoading,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData && snapshot.data) {
            _controller.forward().then(
                  (_) => _controller.reverse(),
                );
            return FadeTransition(
              opacity: Tween(
                begin: .5,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeIn,
                ),
              ),
              child: Icon(
                FontAwesomeIcons.hackerNewsSquare,
                size: 30.0,
              ),
            );
          }
          return Container();
        });
  }
}

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
const Color kColorWSAltBlack = Color(0x444444);

const Color kColorWhite = Colors.white;

class WildStreamApp extends StatelessWidget {
  // This widget is the root of your application.
  final SongsNotifier bloc;

  const WildStreamApp({Key key, this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final newTextTheme = Theme.of(context).textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
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
        ChangeNotifierProvider<BottomNavigation>(
          create: (_) => BottomNavigation(),
          child: WildStreamApp(),
        ),
      ],
      child: MaterialApp(
        title: 'Wildstrem',
        theme: ThemeData(
            brightness: Brightness.dark,
            accentColorBrightness: Brightness.dark,
            backgroundColor: bg_color,
            primarySwatch: bg_color,
//          primaryColor: Color(0XFF181818),
            accentColor: const Color(0XFF029D75),
            hintColor: Colors.white,
            textTheme: newTextTheme),
        debugShowCheckedModeBanner: false,
        home: AudioServiceWidget(
          child: WildStreamHomePage(
            bloc: bloc,
            title: 'WildStream',
          ),
        ),
      ),
    );
  }
}

class WildStreamHomePage extends StatefulWidget {
  final String title;
  final SongsNotifier bloc;

  WildStreamHomePage({Key key, this.title, this.bloc}) : super(key: key);

  @override
  _WildStreamHomePageState createState() => _WildStreamHomePageState();
}

class _WildStreamHomePageState extends State<WildStreamHomePage>
    with WidgetsBindingObserver {
  final BehaviorSubject<double> _dragPositionSubject =
      BehaviorSubject.seeded(null);

  bool _show = true;
  bool _isLoading = false;
  bool _isPlaying = false;
  int _buildIndex = 0;
  MediaItem mediaItem;
  int _currentIndex = 0;
  var _bottomNavigation;
  int _bottomNavigationIndex = 0;

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

//  Future<List<Data>> _fetchSongs() async {
//    return await Provider.of<SongsNotifier>(
//      context,
//      listen: false,
//    ).loadSongs(songType: 'latest').catchError((onError) {
//      print("Error on Screen $onError");
//    });
//  }

  void _fetchData() async {
    _isLoading = true;
//    if (_pc == null) {
//      _pc.hide();
//    }

//    Future.delayed(
//      Duration.zero,
//    ).then((_) async {
//      _fetchHot100Songs().then((hot100MediaList) async {
//        await _startPlayer();
//        var _lastQueuedItems = AudioService.queue;
//        print("_lastQueuedItems $_lastQueuedItems");
//
//        if (_lastQueuedItems == null || _lastQueuedItems.isEmpty) {
//          print("addQueueItem from api ${hot100MediaList.length}");
//          await AudioService.addQueueItems(hot100MediaList);
//          AudioService.play();
//        } else {
//          print("length is Not 0 ${_lastQueuedItems.length} ");
//          return;
//        }
//        print("run afer addQueue from api ${hot100MediaList.length}");
//      }).then(
//        (_) => setState(() => _isLoading = false),
//      );
//    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  List<Map<String, Object>> _pages;

  void initState() {
    super.initState();
    _pages = [
      {
        'page': LatestHot100Throwback(
          song: widget.bloc,
        ),
        'title': 'Latest',
      },
      {
        'page': Search(
          song: widget.bloc,
        ),
        'title': 'Search',
      },
      {
        'page': Album(),
        'title': 'Album',
      },
      {
        'page': Playlist(),
        'title': 'Playlist',
      },
    ];

//    _fetchSongs();
//    connect();
//    WidgetsBinding.instance.addObserver(this);
////    this._startPlayer();
//    this._fetchData();
  }

  _startPlayer() async {
//    connect();
    await AudioService.start(
      backgroundTaskEntrypoint: _audioPlayerTaskEntryPoint,
      androidNotificationChannelName: 'WildStream',
      notificationColor: 0xFF0A0A0A,
      androidNotificationIcon: 'drawable/ic_notification',
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
    _dragPositionSubject.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AppLifecycleState _notification;

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

  FaIcon _mediaIndicator() {
    return FaIcon(
      FontAwesomeIcons.volumeUp,
      color: kColorWSGreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    print("BUILD NUMBER ${_buildIndex++}");
    _bottomNavigation = Provider.of<BottomNavigation>(context);

//    final _data = Provider.of<SongsNotifier>(context).songs;
    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(10.0),
      topRight: Radius.circular(10.0),
    );
    return Scaffold(
      /*appBar: _currentIndex == 0
          ? null
          : AppBar(
              title: Text(
                _pages[_bottomNavigation.currentIndex]['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),*/
      backgroundColor: Theme.of(context).backgroundColor,
      body: SlidingUpPanel(
        controller: _pc,
        onPanelOpened: hideBottomBar,
        onPanelClosed: showBottomBar,
        maxHeight: MediaQuery.of(context).size.height,
        minHeight: _isLoading ? 0.0 : 60.0,
        panel: PlayerStreamBuilder(
          dragPositionSubject: _dragPositionSubject,
        ),
        collapsed: StreamBuilder<ScreenState>(
          stream: _screenStateStream,
          builder: (context, snapshot) {
            final screenState = snapshot.data;
            final mediaItem = screenState?.mediaItem;
            final state = screenState?.playbackState;
            final basicState = state?.basicState ?? BasicPlaybackState.none;
            if (snapshot.hasError)
              print("ERROR On StreamBuilder ${snapshot.error}");

            return snapshot.hasData
                ? Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).bottomAppBarColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //TODO: Get Data from StreamBuilder to make it persistence
                        children: <Widget>[
                          Flexible(
                            child: Row(
                              children: <Widget>[
                                GFAvatar(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(6.0),
                                  ),
                                  shape: GFAvatarShape.standard,
                                  size: 30.0,
                                  backgroundImage: mediaItem == null
                                      ? AssetImage('assets/ws_white.png')
                                      : NetworkImage(mediaItem?.artUri),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        mediaItem == null
                                            ? "Wildstream"
                                            : '${mediaItem?.title}',
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: kColorWhite),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        mediaItem == null
                                            ? "Stay connected to the plug"
                                            : '${mediaItem?.artist}',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Theme.of(context).accentColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (basicState == BasicPlaybackState.playing)
                                _pauseButton(context: context)
                              else if (basicState == BasicPlaybackState.paused)
                                _playButton(context: context)
                              else if (basicState ==
                                      BasicPlaybackState.buffering ||
                                  basicState ==
                                      BasicPlaybackState.skippingToNext ||
                                  basicState ==
                                      BasicPlaybackState.skippingToPrevious)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width: 30.0,
                                    height: 30.0,
                                    child: GFLoader(
                                      size: 30.0,
                                    ),
                                  ),
                                ),
                            ],
                          ),
//                        _playButton(context: context),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  );
          },
        ),
        body: _pages[_bottomNavigation.currentIndex]['page']
        /*StreamBuilder<UnmodifiableListView<Data>>(
            initialData: UnmodifiableListView<Data>([]),
            stream: widget.bloc.latestSongList,
            builder: (context, snapshot) {
//              print('DATA: ${snapshot?.data}');
              return ListView.builder(
                padding: const EdgeInsets.all(2.0),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                */ /*separatorBuilder: (context, index) => const Divider(
                  indent: 90.0,
                  thickness: 0.6,
                  endIndent: 10.0,
                  color: Colors.white30,
                ),*/ /*
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) => _buildSong(
                  song: snapshot.data[index],
                ),
              );
            })*/
        ,
      ),
      bottomNavigationBar: _show
          ? BottomNavigationBar(
              backgroundColor: Theme.of(context).bottomAppBarColor,

              currentIndex: _bottomNavigation.currentIndex,
              showSelectedLabels: true,

              // this will be set when a new tab is tapped
              onTap: (index) {
                _bottomNavigation.currentIndex = index;
                _bottomNavigationIndex = index;

                /*if (index == 0) {
                widget.bloc.songTypes.add(SongTypes.latest);
              } else if (index == 1) {
                widget.bloc.songTypes.add(SongTypes.hot100);
              } else {
                widget.bloc.songTypes.add(SongTypes.throwback);
              }*/
              },
              items: const [
                BottomNavigationBarItem(
//                  backgroundColor: Theme.of(context).bottomAppBarColor,
                  icon: const Icon(
                    Icons.home,
                    //color: kColorWSGreen,
                  ),
                  title: Text(''),
                ),
                BottomNavigationBarItem(
//                  backgroundColor: Theme.of(context).bottomAppBarColor,
                  icon: const Icon(
                    Icons.search,
                    //color: kColorWSGreen,
                  ),
                  title: Text(''),
                ),
                BottomNavigationBarItem(
//                  backgroundColor: Theme.of(context).bottomAppBarColor,
                  icon: const Icon(
                    Icons.album,
                    //color: kColorWSGreen,
                  ),
                  title: Text(''),
                ),
                BottomNavigationBarItem(
//                  backgroundColor: Theme.of(context).bottomAppBarColor,
                  icon: const Icon(
                    Icons.playlist_play,
                    //color: kColorWSGreen,
                  ),
                  title: Text(''),
                ),
              ],
              showUnselectedLabels: true,
              selectedItemColor: kColorWSGreen,
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

  Widget _buildSong({Data song}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 6.0,
        vertical: 8.0,
      ),
      child: ListTile(
        key: Key(song.name),
        leading: GFAvatar(
          borderRadius: BorderRadius.all(
            Radius.circular(6.0),
          ),
          shape: GFAvatarShape.standard,
          size: 42.0,
          backgroundImage: NetworkImage(song.songArt.artUrl),
        ),
        title: Text(
          '${song.name}',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(
            top: 10.0,
          ),
          child: Text(
            '${song.artistsToString}',
            style: TextStyle(color: kColorWSGreen),
          ),
        ),
        trailing: Icon(
          Icons.more_horiz,
          color: kColorWSGreen,
        ),
        /*StreamBuilder<ScreenState>(
          stream: _screenStateStream,
          builder: (context, snapshot) {
            final screenState = snapshot.data;
            mediaItem = screenState?.mediaItem;

            if (mediaItem?.id == data.hot100MediaList[index].id) {
              return _mediaIndicator();
            } else {
              return Icon(
                Icons.more_horiz,
                color: kColorWSGreen,
              );
            }
          },
        ),*/
        onTap: () async {
          print("Taped");
//          mediaItem = data.hot100MediaList[index];
//          AudioService.playFromMediaId(mediaItem.id);
        },
        selected: true,
      ),
    );
  }

  IconButton _playButton({BuildContext context}) => IconButton(
        icon: FaIcon(FontAwesomeIcons.playCircle),
        color: Theme.of(context).accentColor,
        iconSize: 30.0,
        onPressed: AudioService.play,
      );

  IconButton _pauseButton({BuildContext context}) => IconButton(
        icon: FaIcon(FontAwesomeIcons.pauseCircle),
        color: Theme.of(context).accentColor,
        iconSize: 30.0,
        onPressed: AudioService.pause,
      );

  /// Encapsulate all the different data we're interested in into a single
  /// stream so we don't have to nest StreamBuilders.
  ///
  Stream<ScreenState> get _screenStateStream =>
      Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
        AudioService.queueStream,
        AudioService.currentMediaItemStream,
        AudioService.playbackStateStream,
        (
          queue,
          mediaItem,
          playbackState,
        ) =>
            ScreenState(
          queue: queue,
          mediaItem: mediaItem,
          playbackState: playbackState,
        ),
      );
}

void _audioPlayerTaskEntryPoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

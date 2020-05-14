import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/components/loader/gf_loader.dart';
import 'package:getflutter/shape/gf_avatar_shape.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wildstream/helpers/screen_state.dart';
import 'package:wildstream/providers/bottom_navigator.dart';
import 'package:wildstream/screens/album.dart';
import 'package:wildstream/screens/player.dart';
import 'package:wildstream/screens/playlist.dart';
import 'package:wildstream/screens/search.dart';
import 'package:wildstream/widgets/commons.dart';

import 'latest_hot100_throwback.dart';

class WildStreamHomePage extends StatefulWidget {
  final String title;
  WildStreamHomePage({Key key, this.title}) : super(key: key);

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
    connect();
    WidgetsBinding.instance.addObserver(this);
    _pages = [
      {
        'page': LatestHot100Throwback(),
        'title': 'Latest',
      },
      {
        'page': Search(),
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

//    this._startPlayer();
//    this._fetchData();
  }

  /*_startPlayer() async {
//    connect();
    await AudioService.start(
      backgroundTaskEntrypoint: _audioPlayerTaskEntryPoint,
      androidNotificationChannelName: 'WildStream',
      notificationColor: 0xFF0A0A0A,
      androidNotificationIcon: 'drawable/ic_notification',
      enableQueue: true,
    );
  }*/

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

  @override
  Widget build(BuildContext context) {
    print("BUILD NUMBER ${_buildIndex++}");
    _bottomNavigation = Provider.of<BottomNavigation>(context);

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
        body: _pages[_bottomNavigation.currentIndex]['page'],
      ),
      bottomNavigationBar: _show
          ? BottomNavigationBar(
              backgroundColor: kColorWSAltBlack,
              type: BottomNavigationBarType.fixed,

              currentIndex: _bottomNavigation.currentIndex,
              showSelectedLabels: true,
              // this will be set when a new tab is tapped
              onTap: (index) {
                _bottomNavigation.currentIndex = index;
                _bottomNavigationIndex = index;
              },
              items: const [
                BottomNavigationBarItem(
                  backgroundColor: kColorWSAltBlack,
                  icon: const Icon(
                    Icons.home,
                    //color: kColorWSGreen,
                  ),
                  title: Text(''),
                ),
                BottomNavigationBarItem(
                  backgroundColor: kColorWSAltBlack,
                  icon: const Icon(
                    Icons.search,
                    //color: kColorWSGreen,
                  ),
                  title: Text(''),
                ),
                BottomNavigationBarItem(
                  backgroundColor: kColorWSAltBlack,
                  icon: const Icon(
                    Icons.album,
                    //color: kColorWSGreen,
                  ),
                  title: Text(''),
                ),
                BottomNavigationBarItem(
                  backgroundColor: kColorWSAltBlack,
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

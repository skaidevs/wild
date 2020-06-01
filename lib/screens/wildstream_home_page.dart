import 'package:audio_service/audio_service.dart';
import 'package:custom_navigator/custom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/components/loader/gf_loader.dart';
import 'package:getflutter/shape/gf_avatar_shape.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wildstream/helpers/mediaItems.dart';
import 'package:wildstream/helpers/screen_state.dart';
import 'package:wildstream/providers/bottom_navigator.dart';
import 'package:wildstream/providers/latest_hot100_throwback.dart';
import 'package:wildstream/providers/search.dart';
import 'package:wildstream/screens/album.dart';
import 'package:wildstream/screens/album_details.dart';
import 'package:wildstream/screens/latest_hot100_throwback.dart';
import 'package:wildstream/screens/player.dart';
import 'package:wildstream/screens/playlist.dart';
import 'package:wildstream/screens/search.dart';
import 'package:wildstream/widgets/commons.dart';
import 'package:wildstream/widgets/loadingInfo.dart';

class WildStreamHomePage extends StatefulWidget {
  final TargetPlatform platform;

  final String title;
  WildStreamHomePage({
    Key key,
    this.title,
    this.platform,
  }) : super(key: key);

  @override
  _WildStreamHomePageState createState() => _WildStreamHomePageState();
}

class _WildStreamHomePageState extends State<WildStreamHomePage>
    with WidgetsBindingObserver {
  final BehaviorSubject<double> _dragPositionSubject =
      BehaviorSubject.seeded(null);
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  PanelController _pc = PanelController();
  List<Map<String, Object>> _pages;

  bool _show = true;
  bool _isLoading = false;
  bool _isPlaying = false;
  int _buildIndex = 0;
  MediaItem mediaItem;
  var _bottomNavigation;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void _fetchSearch() {
    Future.delayed(Duration.zero).then((_) async {
      Provider.of<SearchNotifier>(
        context,
        listen: false,
      ).loadSearchedSongs(query: 'wizkid');
    });
  }

  void initState() {
    _connect();
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
    _fetchSearch();
    super.initState();
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
    _disconnect();
    _dragPositionSubject.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _connect();

        print('AppLifecycleState.resumed called ${state.index}');
        break;
      case AppLifecycleState.paused:
        _disconnect();
        print('AppLifecycleState.paused called ${state.index}');
        break;
      default:
        break;
    }
  }

  void _connect() async {
    await AudioService.connect();
    print("AudioService.connect() ");
  }

  void _disconnect() {
    AudioService.disconnect();
    print("AudioService.disconnect()");
  }

  Future<bool> _onWillPop() {
    return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Confirm Exit"),
                content: Text("Are you sure you want to exit?"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("YES"),
                    onPressed: () async {
                      /*await AudioService.stop();
                      SystemNavigator.pop();*/
                      Navigator.of(context).pop(true);
                      AudioService.stop();
                    },
                  ),
                  FlatButton(
                    child: Text("NO"),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  )
                ],
              );
            }) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    print("BUILD NUMBER ${_buildIndex++}");
    _bottomNavigation = Provider.of<BottomNavigation>(
      context,
    );
    final _notifier = Provider.of<SongsNotifier>(
      context,
    );

    return _notifier.isLoading
        ? LoadingInfo()
        : Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            body: SlidingUpPanel(
              body: CustomNavigator(
                navigatorKey: navigatorKey,
                home: _pages[_bottomNavigation.currentIndex]['page'],
                //Specify your page route [PageRoutes.materialPageRoute] or [PageRoutes.cupertinoPageRoute]
                pageRoute: PageRoutes.materialPageRoute,
                routes: <String, WidgetBuilder>{
                  //"/album_detail": (BuildContext context) => AlbumDetails()
                  AlbumDetails.routeName: (context) => AlbumDetails(),
                },
              ),
              controller: _pc,
              onPanelOpened: hideBottomBar,
              onPanelClosed: showBottomBar,
              maxHeight: MediaQuery.of(context).size.height,
              minHeight: _isLoading ? 0.0 : 60.0,
              panel: PlayerStreamBuilder(
                dragPositionSubject: _dragPositionSubject,
              ),
              collapsed: StreamBuilder<ScreenState>(
                stream: screenStateStream,
                builder: (context, snapshot) {
                  final screenState = snapshot.data;
                  final mediaItem = screenState?.mediaItem;
                  final state = screenState?.playbackState;
                  final basicState =
                      state?.basicState ?? BasicPlaybackState.none;
                  if (snapshot.hasError)
                    print("ERROR On StreamBuilder ${snapshot.error}");

                  return snapshot.hasData
                      ? Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).bottomAppBarColor,
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                                  color: Theme.of(context)
                                                      .accentColor),
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
                                    if (basicState ==
                                        BasicPlaybackState.playing)
                                      _pauseButton(context: context)
                                    else if (basicState ==
                                        BasicPlaybackState.paused)
                                      _playButton(context: context)
                                    else if (basicState ==
                                            BasicPlaybackState.buffering ||
                                        basicState ==
                                            BasicPlaybackState.skippingToNext ||
                                        basicState ==
                                            BasicPlaybackState
                                                .skippingToPrevious)
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
//                               _playButton(context: context),
                              ],
                            ),
                          ),
                        )
                      : Center(
                          child: CircularProgressIndicator(),
                        );
                },
              ),
            ),
            bottomNavigationBar: _show
                ? BottomNavigationBar(
                    backgroundColor: kColorWSAltBlack,
                    type: BottomNavigationBarType.fixed,
                    currentIndex: _bottomNavigation.currentIndex,
                    showSelectedLabels: true,
                    // this will be set when a new tab is tapped
                    onTap: (index) {
                      navigatorKey.currentState.maybePop();
                      _bottomNavigation.currentIndex = index;
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
            /*floatingActionButton: FloatingActionButton(
        child: Icon(Icons.stars),
        onPressed: () async {
          print("Item::::::list ${_queue.length}");
//            final q = AudioService.queue;
//            print("Seelected QUEITEM  ${q[0].title}");
          _controller.isOpened ? _controller.hide() : _controller.show();
        }), */
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
}

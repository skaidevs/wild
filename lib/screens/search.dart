import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/shape/gf_avatar_shape.dart';
import 'package:provider/provider.dart';
import 'package:wildstream/helpers/mediaItems.dart';
import 'package:wildstream/helpers/screen_state.dart';
import 'package:wildstream/models/search.dart' as search;
import 'package:wildstream/providers/download.dart';
import 'package:wildstream/providers/search.dart';
import 'package:wildstream/widgets/commons.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  /* @override
  void initState() {
    super.initState();
  }*/

  @override
  Widget build(BuildContext context) {
    final _searchNotifier = Provider.of<SearchNotifier>(
      context,
      listen: false,
    );

    final _downloadNotifier =
        Provider.of<DownloadNotifier>(context, listen: false);

    return Scaffold(
        //backgroundColor: Theme.of(context).backgroundColor,
        //appBar: FloatAppBar(),
        /*AppBar(
        title: Text('Search Wildstream'),
       actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.search,
                ),
                onPressed: () async {
                  final Data result = await showSearch<Data>(
                    context: context,
                    delegate: SongSearch(),
                  );
                  kFlutterToast(
                    context: context,
                    msg: '${result?.name}',
                  );
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result?.name),
                    ),
                  );
                  print("RESULT ");
                }),
          ),
        ],
      )*/
        body: _downloadNotifier.permissionReady
            ? new Container(
                child: new ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  children: _searchNotifier.searchSongList
                      .map((item) => item.downloadTask == null
                          ? new Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                item.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                    fontSize: 18.0),
                              ),
                            )
                          : new Container(
                              padding:
                                  const EdgeInsets.only(left: 16.0, right: 8.0),
                              child: InkWell(
                                onTap: item.downloadTask.status ==
                                        DownloadTaskStatus.complete
                                    ? () {
                                        _downloadNotifier
                                            .openDownloadedFile(
                                                item.downloadTask)
                                            .then((success) {
                                          if (!success) {
                                            Scaffold.of(context).showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Cannot open this file')));
                                          }
                                        });
                                      }
                                    : null,
                                child: new Stack(
                                  children: <Widget>[
                                    new Container(
                                      width: double.infinity,
                                      height: 64.0,
                                      child: new Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          new Expanded(
                                            child: new Text(
                                              item.name,
                                              maxLines: 1,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          new Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: _buildActionForTask(
                                                downloadNotifier:
                                                    _downloadNotifier,
                                                task: item.downloadTask),
                                          ),
                                        ],
                                      ),
                                    ),
                                    item.downloadTask.status ==
                                                DownloadTaskStatus.running ||
                                            item.downloadTask.status ==
                                                DownloadTaskStatus.paused
                                        ? new Positioned(
                                            left: 0.0,
                                            right: 0.0,
                                            bottom: 0.0,
                                            child: new LinearProgressIndicator(
                                              value:
                                                  item.downloadTask.progress /
                                                      100,
                                            ),
                                          )
                                        : new Container()
                                  ].where((child) => child != null).toList(),
                                ),
                              ),
                            ))
                      .toList(),
                ),
              )
            : new Container(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'Please grant accessing storage permission to continue -_-',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.blueGrey, fontSize: 18.0),
                        ),
                      ),
                      SizedBox(
                        height: 32.0,
                      ),
                      FlatButton(
                          onPressed: () {
//                            _downloadNotifier.checkPermission().then((hasGranted) {
//                              setState(() {
//                                _downloadNotifierpermissionReady = hasGranted;
//                              });
//                            });
                          },
                          child: Text(
                            'Retry',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0),
                          ))
                    ],
                  ),
                ),
              ));
  }

  Widget _buildSearchItem({
    Function onTap,
    search.Data searchSong,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14.0,
          vertical: 14.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Row(
                children: <Widget>[
                  GFAvatar(
                    borderRadius: BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                    shape: GFAvatarShape.standard,
                    size: 38.0,
                    backgroundImage: NetworkImage(
                      searchSong.songArt.crops.crop100,
                    ),
                  ),
                  SizedBox(
                    width: 16.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${searchSong.name}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${searchSong.artistsToString}',
                          style: kTextStyle(
                            fontSize: 12.0,
                            color: kColorWSGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<ScreenState>(
              stream: screenStateStream,
              builder: (context, snapshot) {
                final screenState = snapshot.data;
                final _mediaId = screenState?.mediaItem?.id;
                if (_mediaId == searchSong.songFile.songUrl) {
                  return kMediaIndicator();
                } else {
                  return Icon(
                    Icons.more_horiz,
                    color: kColorWSGreen,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionForTask(
      {DownloadNotifier downloadNotifier, TaskInfo task}) {
    if (task.status == DownloadTaskStatus.undefined) {
      return new RawMaterialButton(
        onPressed: () {
          downloadNotifier.requestDownload(task);
        },
        child: new Icon(Icons.file_download),
        shape: new CircleBorder(),
        constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.running) {
      return new RawMaterialButton(
        onPressed: () {
          downloadNotifier.pauseDownload(task);
        },
        child: new Icon(
          Icons.pause,
          color: Colors.red,
        ),
        shape: new CircleBorder(),
        constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.paused) {
      return new RawMaterialButton(
        onPressed: () {
          downloadNotifier.resumeDownload(task);
        },
        child: new Icon(
          Icons.play_arrow,
          color: Colors.green,
        ),
        shape: new CircleBorder(),
        constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      );
    } else if (task.status == DownloadTaskStatus.complete) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new Text(
            'Ready',
            style: new TextStyle(color: Colors.green),
          ),
          RawMaterialButton(
            onPressed: () {
              downloadNotifier.delete(task);
            },
            child: Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
            shape: new CircleBorder(),
            constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else if (task.status == DownloadTaskStatus.canceled) {
      return new Text('Canceled', style: new TextStyle(color: Colors.red));
    } else if (task.status == DownloadTaskStatus.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new Text('Failed', style: new TextStyle(color: Colors.red)),
          RawMaterialButton(
            onPressed: () {
              downloadNotifier.retryDownload(task);
            },
            child: Icon(
              Icons.refresh,
              color: Colors.green,
            ),
            shape: new CircleBorder(),
            constraints: new BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          )
        ],
      );
    } else {
      return null;
    }
  }
}

class FloatAppBar extends StatelessWidget with PreferredSizeWidget {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: preferredSize.height - 12.0,
          right: 15,
          left: 15,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(
                6.0,
              ),
            ),
            // color: kColorWhite,
            child: Row(
              children: <Widget>[
                Consumer<SearchNotifier>(builder: (context, notifier, _) {
                  return Expanded(
                    child: TextField(
                      style: kTextStyle(
                          color: kColorWSGreen, fontWeight: FontWeight.bold),
                      /*onChanged: (String value) {
                        print("Text field: $value");
                     },*/
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (String searchValue) async {
                        print("search");
                        if (searchValue == null || searchValue.length == 0) {
                          return print('TEXT FIELD IS EMPTY');
                        }
                        await notifier.loadSearchedSongs(
                          query: searchValue.trim(),
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Search WildStream',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                        contentPadding: const EdgeInsets.only(
                          left: 10.0,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: FaIcon(
                    FontAwesomeIcons.search,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

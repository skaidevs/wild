import 'package:flutter/material.dart';
import 'package:getflutter/components/avatar/gf_avatar.dart';
import 'package:getflutter/shape/gf_avatar_shape.dart';
import 'package:provider/provider.dart';
import 'package:wildstream/helpers/downloads.dart';
import 'package:wildstream/helpers/mediaItems.dart';
import 'package:wildstream/helpers/screen_state.dart';
import 'package:wildstream/widgets/commons.dart';

/*class Playlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(),
      body: Text(
        'PLAYLIST',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}*/

/*class CounterStorage {
  */ /* //call this method from init state to create folder if the folder is not exists
  void createFolder() async {
    if (await io.Directory(directory + "/yourDirectoryName").exists() != true) {
      print("Directory not exist");
      new io.Directory(directory + "/your DirectoryName").createSync(recursive: true);
//do your work
    } else {
      print("Directoryexist");

//do your work
    }
  }*/ /*
  Future<String> get _localPath async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    if (await Directory(directory + "/media").exists() != true) {
      print("Directory not exist");
      new Directory(directory + "/media").createSync(recursive: true);
      //do your work
    } else {
      print("Directory exist");
      //do your work
    }
    return directory;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/media/counter').create(recursive: true);
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> writeCounter(int counter) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$counter');
  }
}

class Playlist extends StatefulWidget {
  */ /*final CounterStorage storage;

  Playlist({Key key, @required this.storage}) : super(key: key);*/ /*

  @override
  _PlaylistState createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  CounterStorage storage;
  int _counter;

  */ /*@override
  void initState() {
    super.initState();
    storage = CounterStorage();
    storage.readCounter().then((int value) {
      setState(() {
        _counter = value;
      });
    });
  }*/ /*

  Future<File> _incrementCounter() {
    setState(() {
      _counter++;
    });

    // Write the variable as a string to the file.
    return storage.writeCounter(_counter);
  }

  @override
  Widget build(BuildContext context) {
    final _database = Provider.of<Database>(
      context,
      listen: false,
    );
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text('Reading and Writing Files'),
      ),
      body:
          Container(
        padding: Platform.isIOS
            ? const EdgeInsets.fromLTRB(
                0.0,
                0.0,
                0.0,
                140.0,
              )
            : const EdgeInsets.fromLTRB(
                0.0,
                0.0,
                0.0,
                118.0,
              ),
        child: Column(
          children: <Widget>[
            Text(
              'Button tapped $_counter time${_counter == 1 ? '' : 's'}.',
            ),
            RaisedButton(
              onPressed: _incrementCounter,
              child: Icon(Icons.add),
            ),
          ],
        ),
      ),

    );
  }
}*/
class Playlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text('Offline Downloads'),
      ),
      body: _buildDownloadedList(context),
    );
  }

  StreamBuilder<ScreenState> _buildDownloadedList(BuildContext context) {
    final _downloadDao = Provider.of<DownloadDao>(
      context,
      listen: false,
    );
    return StreamBuilder<ScreenState>(
      stream: screenStateStreamWithDoa(context: context),
      builder: (context, snapshot) {
        final _screenState = snapshot.data;
        final _downloads = _screenState?.downloadDao ?? List();
        final _mediaItem = _screenState?.mediaItem?.id;
        return ListView.builder(
            itemCount: _downloads.length,
            padding: const EdgeInsets.all(2.0),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemBuilder: (_, index) {
              final _itemDownload = _downloads[index];
              return _buildDownloadedItem(
                  downloadDao: _downloadDao,
                  itemDownload: _itemDownload,
                  mediaId: _mediaItem,
                  onTap: () {
                    playMediaFromButtonPressed(
                      mediaList: _downloadDao.mediaItems,
                      playButton: 'offlineDownload',
                      playFromId: _itemDownload.mediaIdUri,
                    );
                  });
            });
      },
    );
  }

  Widget _buildDownloadedItem({
    Download itemDownload,
    DownloadDao downloadDao,
    Function onTap,
    String mediaId,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
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
                      Radius.circular(6.0),
                    ),
                    shape: GFAvatarShape.standard,
                    size: 36.0,
                    backgroundImage:
                        NetworkImage('${itemDownload.mediaArtUri}'),
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
                          '${itemDownload.mediaTitle}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '${itemDownload.mediaArtist}',
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
            SizedBox(
              width: 10.0,
            ),
            IconButton(
              onPressed: () async {
                downloadDao.removeDownloads(
                  itemDownload.mediaCode,
                );
                print('REMOVE Delete ${itemDownload.mediaCode}');
              },
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
            ),
            mediaId == itemDownload.mediaIdUri
                ? kMediaIndicator()
                : IconButton(
                    onPressed: () => null,
                    icon: Icon(
                      Icons.more_horiz,
                      color: kColorWSGreen,
                    ),
                  )
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:wildstream/providers/album.dart';

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

class CounterStorage {
  /* //call this method from init state to create folder if the folder is not exists
  void createFolder() async {
    if (await io.Directory(directory + "/yourDirectoryName").exists() != true) {
      print("Directory not exist");
      new io.Directory(directory + "/your DirectoryName").createSync(recursive: true);
//do your work
    } else {
      print("Directoryexist");

//do your work
    }
  }*/
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
  /*final CounterStorage storage;

  Playlist({Key key, @required this.storage}) : super(key: key);*/

  @override
  _PlaylistState createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  CounterStorage storage;
  int _counter;

  void _fetchAlbum() {
    Future.delayed(Duration(seconds: 1)).then((_) {
      Provider.of<AlbumNotifier>(
        context,
        listen: false,
      ).getAlums();
    });
  }

  @override
  void initState() {
    super.initState();
    storage = CounterStorage();
    storage.readCounter().then((int value) {
      setState(() {
        _counter = value;
      });
    });
    //this._fetchAlbum();
  }

  Future<File> _incrementCounter() {
    setState(() {
      _counter++;
    });

    // Write the variable as a string to the file.
    return storage.writeCounter(_counter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reading and Writing Files')),
      body: Container(
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
                120.0,
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
}

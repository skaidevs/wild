import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Album extends StatefulWidget {
  //final Storage storage;

  //const Album({Key key, @required this.storage}) : super(key: key);
  @override
  _AlbumState createState() => _AlbumState();
}

class _AlbumState extends State<Album> {
  TextEditingController controller = TextEditingController();
  String state;
  Future<Directory> _appDocDir;
  Storage storage;

  @override
  void initState() {
    storage = new Storage(); // add this line

    storage.readData().then((String value) {
      setState(() {
        state = value;
      });
    });
    super.initState();
  }

  Future<File> writeData() async {
    setState(() {
      state = controller.text;
      controller.text = '';
    });

    return storage.writeData(state);
  }

  void getAppDirectory() {
    setState(() {
      _appDocDir = getApplicationDocumentsDirectory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: <Widget>[
            Text('${state ?? 'File is Empty'}'),
            TextField(
              controller: controller,
            ),
            RaisedButton(
              onPressed: writeData,
              child: Text('write to File'),
            ),
            RaisedButton(
              onPressed: getAppDirectory,
              child: Text('Get Dir Path'),
            ),
            FutureBuilder<Directory>(
              future: _appDocDir,
              builder: (context, AsyncSnapshot<Directory> sanpshot) {
                Text text = Text('');
                if (sanpshot.connectionState == ConnectionState.done) {
                  if (sanpshot.hasError) {
                    text = Text('Error: ${sanpshot.error}');
                  } else if (sanpshot.hasData) {
                    text = Text('DATA: ${sanpshot.data.path}');
                  } else {
                    text = Text('Unavail');
                  }
                }

                return Container(
                  child: text,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class Storage {
  Future<String> get localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get localFile async {
    final path = await localPath;
    return File('$path/db.txt');
  }

  Future<String> readData() async {
    try {
      final file = await localFile;
      String body = await file.readAsString();
      return body;
    } catch (e) {
      return e.toString();
    }
  }

  Future<File> writeData(String data) async {
    final file = await localFile;

    return file.writeAsString('$data');
  }
}

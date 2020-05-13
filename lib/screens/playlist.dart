import 'package:flutter/material.dart';

class Playlist extends StatelessWidget {
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
}

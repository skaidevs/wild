import 'package:flutter/material.dart';

class Album extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(),
      body: Container(
        child: Text(
          'ALBUM',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

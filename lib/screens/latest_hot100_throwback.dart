import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wildstream/screens/hot100.dart';
import 'package:wildstream/screens/latest.dart';
import 'package:wildstream/screens/throwback.dart';

class LatestHot100Throwback extends StatefulWidget {
  final song;

  const LatestHot100Throwback({Key key, this.song}) : super(key: key);

  @override
  _LatestHot100ThrowbackState createState() => _LatestHot100ThrowbackState();
}

class _LatestHot100ThrowbackState extends State<LatestHot100Throwback>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  Widget getTabBar() {
    return TabBar(controller: _tabController, tabs: [
      Tab(
        icon: Icon(Icons.new_releases),
        /*text: "Latest",*/
      ),
      Tab(
        icon: FaIcon(FontAwesomeIcons.hotjar),
        /*text: "Hot100",*/
      ),
      Tab(
        icon: Icon(Icons.timer),
        /*text: "Throwback",*/
      ),
    ]);
  }

  Widget getTabBarPages() {
    return TabBarView(controller: _tabController, children: <Widget>[
      Latest(),
      Hot100(),
      Throwback(),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Latest Build");

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: SafeArea(
          child: getTabBar(),
        ),
      ),
      body: getTabBarPages(),
    );
  }
}

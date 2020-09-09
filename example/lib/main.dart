import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kt_drawer_menu/kt_drawer_menu.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  // ignore: close_sinks
  final StreamController<DrawerItemEnum> _streamController =
      StreamController<DrawerItemEnum>.broadcast(sync: true);

  @override
  Widget build(BuildContext context) {
    return KTDrawerMenu(
      width: 360.0,
      radius: 30.0,
      scale: 0.6,
      shadow: 20.0,
      shadowColor: Colors.black12,
      drawer: DrawerPage(streamController: _streamController),
      content: HomePage(streamController: _streamController),
    );
  }
}

enum DrawerItemEnum {
  DASHBOARD,
  MESSAGE,
  SETTINGS,
  ABOUT,
  HELP,
}

// ignore: must_be_immutable
class DrawerPage extends StatelessWidget {
  final StreamController<DrawerItemEnum> streamController;
  DrawerItemEnum selected;

  DrawerPage({Key key, this.streamController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DrawerItemEnum>(
      stream: streamController.stream,
      initialData: DrawerItemEnum.DASHBOARD,
      builder: (context, snapshot) {
        selected = snapshot.data;
        return Container(
          color: Colors.blueGrey[900],
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _getMenu(context, DrawerItemEnum.DASHBOARD),
                    _getMenu(context, DrawerItemEnum.MESSAGE),
                    _getMenu(context, DrawerItemEnum.SETTINGS),
                    _getMenu(context, DrawerItemEnum.ABOUT),
                    _getMenu(context, DrawerItemEnum.HELP),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _getMenu(BuildContext context, DrawerItemEnum menu) {
    switch (menu) {
      case DrawerItemEnum.DASHBOARD:
        return _buildItem(context, menu, "Dashboard", Icons.dashboard, () {});
      case DrawerItemEnum.MESSAGE:
        return _buildItem(context, menu, "Messages", Icons.message, () {});
      case DrawerItemEnum.SETTINGS:
        return _buildItem(context, menu, "Settings", Icons.settings, () {});
      case DrawerItemEnum.ABOUT:
        return _buildItem(context, menu, "About", Icons.info, () {});
      case DrawerItemEnum.HELP:
        return _buildItem(context, menu, "Help", Icons.help_outline, () {});
      default:
        return Container();
    }
  }

  Widget _buildItem(
    BuildContext context,
    DrawerItemEnum menu,
    String title,
    IconData icon,
    Function onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          streamController.sink.add(menu);
          KTDrawerMenu.of(context).closeDrawer();
          onPressed();
        },
        child: Container(
          height: 50,
          padding: EdgeInsets.only(left: 26),
          child: Row(
            children: [
              Icon(icon,
                  color: selected == menu ? Colors.white : Colors.white70,
                  size: 24),
              SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: selected == menu ? 15 : 14,
                  fontWeight:
                      selected == menu ? FontWeight.w500 : FontWeight.w300,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final StreamController<DrawerItemEnum> streamController;

  HomePage({Key key, this.streamController}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DrawerItemEnum selected;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.streamController.stream,
      initialData: DrawerItemEnum.DASHBOARD,
      builder: (context, snapshot) {
        selected = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: _getColor(selected),
            elevation: 0.0,
            leading: IconButton(
              icon: Icon(Icons.dehaze),
              onPressed: () {
                KTDrawerMenu.of(context).toggle();
              },
            ),
            title: Text(
              _getTitle(selected),
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          body: Container(
            color: _getColor(selected),
          ),
        );
      },
    );
  }

  Color _getColor(DrawerItemEnum menu) {
    switch (menu) {
      case DrawerItemEnum.DASHBOARD:
        return Colors.blue;
      case DrawerItemEnum.MESSAGE:
        return Colors.green;
      case DrawerItemEnum.SETTINGS:
        return Colors.purple;
      case DrawerItemEnum.ABOUT:
        return Colors.orange;
      case DrawerItemEnum.HELP:
        return Colors.yellow;
      default:
        return Colors.white;
    }
  }

  String _getTitle(DrawerItemEnum menu) {
    switch (menu) {
      case DrawerItemEnum.DASHBOARD:
        return "DASHBOARD";
      case DrawerItemEnum.MESSAGE:
        return "MESSAGE";
      case DrawerItemEnum.SETTINGS:
        return "SETTINGS";
      case DrawerItemEnum.ABOUT:
        return "ABOUT";
      case DrawerItemEnum.HELP:
        return "HELP";
      default:
        return "";
    }
  }
}

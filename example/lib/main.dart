import 'package:flutter/material.dart';
import 'package:kt_drawer_menu/kt_drawer_menu.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example KTDrawerMenu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: KTDrawerMenu(
          drawer: DrawerPage(),
          content: HomePage(),
        ),
      ),
    );
  }
}

class DrawerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_buildItem("Dashboard", Icons.dashboard, () {})],
        ),
      ),
    );
  }

  Widget _buildItem(String title, IconData icon, Function onPressed) {
    return Container(
      padding: EdgeInsets.only(left: 26),
      child: InkWell(
        highlightColor: Colors.white,
        onTap: () {
          print("ontap");
        },
        child: Container(
          height: 80,
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.dehaze),
          onPressed: () {},
        ),
      ),
      body: Container(
        color: Colors.white,
      ),
    );
  }
}

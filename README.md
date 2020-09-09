<p align="center">
    <img width="300" height="600" src="./example/images/layout.gif"/>
</p>

# KTDrawer

KTDrawer is a library for flutter to create a beautiful drawer menu with with deep customization capabilities.


## Installation

Add 
```bash
kt_drawer_menu : ^lastest_version
```
to your pubspec.yaml and run 
```bash
flutter packages get 
```
in your project's root directory.


## Example

```Dart

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  @override
  Widget build(BuildContext context) {
    return KTDrawerMenu(
      width: 360.0,
      radius: 30.0,
      scale: 0.6,
      shadow: 20.0,
      shadowColor: Colors.black12,
      drawer: DrawerPage(),
      content: HomePage(),
    );
  }
}

```

[Full Example](https://github.com/tuankhaiit/kt_drawer_menu/blob/master/example/lib/main.dart)


## Available settings

### Controller
This actions is only accessible by the children of KTDrawer.

#### Get controller
```Dart
KTDrawerMenu.of(context);
```
#### Open drawer
```Dart
KTDrawerMenu.of(context).openDrawer();
```
#### Close drawer
```Dart
KTDrawerMenu.of(context).closeDrawer();
```
#### Toggle drawer
```Dart
KTDrawerMenu.of(context).toggle();
```

### Drawer
* Set edge drag width.
* Set width of the drawer widget that which can be displayed.

### Content
* Set scale of content widget when it is opened.
* Set radius of content widget when it is opened.
* Set color opacity above content widget when it is opened.
* Set opacity of color when it is opened.
* Set offset to determine the action auto open/close drawer when the tap is stopped.

### Animation
* Change duration for the open/close animation.
* Listen the animation progress updated when drawer is opening/closing.
* Listen drawer state.

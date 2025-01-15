import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mychat/Screens/chat.dart';
import 'package:mychat/Screens/on_user.dart';
import 'package:mychat/Screens/tracking_screen.dart';

class ResponsiveNavBarPage extends StatefulWidget {
  @override
  _ResponsiveNavBarPageState createState() => _ResponsiveNavBarPageState();
}

class _ResponsiveNavBarPageState extends State<ResponsiveNavBarPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedPage = 'Home';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isLargeScreen = width > 800;

    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 0,
          leading: isLargeScreen
              ? null
              : IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Logo",
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
                if (isLargeScreen) Expanded(child: _navBarItems(context))
              ],
            ),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: CircleAvatar(child: _ProfileIcon()),
            )
          ],
        ),
        drawer: isLargeScreen ? null : _drawer(context),
        body: _getBody(),
      ),
    );
  }

  Widget _drawer(BuildContext context) => Drawer(
        child: ListView(
          children: _menuItems
              .map((item) => ListTile(
                    onTap: () {
                      setState(() {
                        _selectedPage = item;
                      });
                      _scaffoldKey.currentState?.openEndDrawer();
                    },
                    title: Text(item),
                  ))
              .toList(),
        ),
      );

  Widget _navBarItems(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _menuItems
            .map(
              (item) => InkWell(
                onTap: () {
                  setState(() {
                    _selectedPage = item;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24.0, horizontal: 16),
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            )
            .toList(),
      );

  Widget _getBody() {
    switch (_selectedPage) {
      case 'Chat':
        return const ChatScreen();
      case 'Tracking':
        return LocationTrackingScreen();
      case 'Users':
      default:
        return UserListScreen();
    }
  }
}

final List<String> _menuItems = <String>['About', 'Chat', 'Tracking'];

enum Menu { itemOne, itemTwo, itemThree }

class _ProfileIcon extends StatelessWidget {
  const _ProfileIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Menu>(
      icon: const Icon(Icons.person),
      offset: const Offset(0, 40),
      onSelected: (Menu item) {},
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
        const PopupMenuItem<Menu>(
          value: Menu.itemOne,
          child: Text('Account'),
        ),
        const PopupMenuItem<Menu>(
          value: Menu.itemTwo,
          onTap: NavigateTracking,
          child: Text('Settings'),
        ),
        PopupMenuItem<Menu>(
          value: Menu.itemThree,
          onTap: logout,
          child: Text('Sign Out'),
        ),
      ],
    );
  }
}

void logout() {
  FirebaseAuth.instance.signOut();
}

void NavigateTracking() {
  void NavigateTrackingg(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationTrackingScreen()),
    );
  }
}

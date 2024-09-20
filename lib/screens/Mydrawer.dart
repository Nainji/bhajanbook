import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  Map<String, List<String>> menu = {};
  Map<String, dynamic> icon = {};


  void handleLogout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    var box = await Hive.openBox('myBox');
    await box.clear();
    await Hive.deleteBoxFromDisk('myBox');

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<String> fetchAndSaveIcon(String label, String url) async {
    var box = await Hive.openBox('myBox');
    var iconData = box.get('icon_$label'); // Check if the icon is already saved

    if (iconData != null) {
      // Icon is already saved locally, return it
      return iconData;
    } else {
      // Fetch the SVG from network and save it
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await box.put('icon_$label', response.body); // Save SVG string locally
        return response.body; // Return fetched SVG data
      } else {
        throw Exception('Failed to load icon');
      }
    }
  }

  getIcon(String label) {
    return icon[label] ?? "";
  }

  Future<void> getItem() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? menuItemsString = prefs.getString('menu');
    await Hive.initFlutter();
    var box = await Hive.openBox('myBox');
    Map<String, dynamic> icons = box.get('icons'); // Get data from Hive

    if (menuItemsString != null) {
      final Map<String, dynamic> decodedMenu = jsonDecode(menuItemsString);
      setState(() {
        menu = decodedMenu.map((key, value) {
          return MapEntry(
              key, List<String>.from(value as List)); // Convert each dynamic list to List<String>
        });
        icon = icons;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getItem();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header with user details
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.yellow[700], // Background color
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50),
            ),
            accountName: Text(
              'Hitesh Dutt Mathur', // Replace with dynamic data
              style: TextStyle(color: Colors.black),
            ),
            accountEmail: Text(
              'hiteshmathur@gmail.com', // Replace with dynamic data
              style: TextStyle(color: Colors.black54),
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ...menu.keys
                    .map((String key) =>
                    buildExpandableMenu(key, menu[key]!))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget for expandable menu items
  Widget buildExpandableMenu(String title, List<String> submenus) {
    if (submenus.isNotEmpty) {
      return ExpansionTile(
        leading: FutureBuilder<String>(
          future: fetchAndSaveIcon(title, getIcon(title)), // Fetch or load icon
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Icon(Icons.error); // Show error icon if failed
            } else {
              // Load SVG from string
              return CircleAvatar(
                backgroundColor: Colors.white,
                child: SvgPicture.string(snapshot.data ?? ""),
              );
            }
          },
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        children: submenus.map((submenu) {
          return ListTile(
            title: Text(submenu),
            leading: Icon(Icons.arrow_right),
            onTap: () {
              Navigator.pushNamed(context, '/$title', arguments: submenu);
            },
          );
        }).toList(),
      );
    } else {
      return ListTile(
        leading: FutureBuilder<String>(
          future: fetchAndSaveIcon(title, getIcon(title)), // Fetch or load icon
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Icon(Icons.error); // Show error icon if failed
            } else {
              // Load SVG from string
              return CircleAvatar(
                backgroundColor: Colors.white,
                child: SvgPicture.string(snapshot.data ?? ""),
              );
            }
          },
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        onTap: () {
          if (title.toLowerCase() == 'logout') {
            handleLogout(context);
          } else {
            Navigator.pushNamed(context, '/$title');
          }
        },
      );
    }
  }
}

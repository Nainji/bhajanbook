import 'package:bhajan_book/screens/base.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppDetailsScreen extends StatefulWidget {
  @override
  _AppDetailsScreenState createState() => _AppDetailsScreenState();
}

class _AppDetailsScreenState extends State<AppDetailsScreen> {
  String appName = '';
  String packageName = '';
  String version = '';
  String buildNumber = '';

  @override
  void initState() {
    super.initState();
    _getAppDetails();
  }

  // Function to get app details using package_info_plus
  Future<void> _getAppDetails() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  BaseLayout(
        title: Text('App Details'),

      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Icon
              Container(

                height: 300,
                child: Image.asset('assets/images/logo_png.png'), // Replace with your app icon
              ),
              SizedBox(height: 30),
              // App Name
              Text(
                "App Name: $appName",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // Package Name
              Text(
                "Package: $packageName",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              // App Version
              Text(
                "Version: $version",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              // Build Number
              Text(
                "Build Number: $buildNumber",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

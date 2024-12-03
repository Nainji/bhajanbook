import 'dart:io';

import 'package:bhajan_book/screens/base.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // To launch URLs in browser

class SocialMediaScreen extends StatefulWidget {
  @override
  State<SocialMediaScreen> createState() => _SocialMediaScreenState();
}

class _SocialMediaScreenState extends State<SocialMediaScreen> {
  Map<String, List<Map<String, dynamic>>> socialMediaData = {};

  // Fetch data from Hive and update state
  Future<void> getSocial() async {
    await Hive.initFlutter();
    var box = await Hive.openBox('myBox');
    var value = box.get('social');

    if (value != null) {
      setState(() {
        socialMediaData = {
          "YouTube Channels": List<Map<String, dynamic>>.from(value['youtube'] ?? []),
          "Facebook Channels": List<Map<String, dynamic>>.from(value['facebook'] ?? []),
          "Instagram Channels": List<Map<String, dynamic>>.from(value['instagram'] ?? []),
          "Blog": [value['blog'] ?? {}], // Wrapping the blog object in a list for consistency
        };
      });
    }
  }

  // Function to open URLs in a browser
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);  // Ensure the URL is parsed as a Uri object
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Handle the error gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  Future<void> openMap(String url) async {
    Uri uri;

      uri = Uri.parse(url);

print(url.substring(8));


    try {

        await launchUrl(uri);

    } catch (e) {
      await launchUrl(uri);
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getSocial(); // Fetch data on initialization
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: socialMediaData.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: socialMediaData.keys.map((String platform) {
            return SizedBox(
              height: 180, // Increased height to accommodate more items
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    platform,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: socialMediaData[platform]!.length,
                    itemBuilder: (context, index) {
                      final channel = socialMediaData[platform]![index];

                      return GestureDetector(
                        onTap: () {
                          final url = channel['url'];
                          if (url != null) {
                            openMap(url);
                          }
                        },
                        child: SizedBox(
                          height: 200,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage:
                                      NetworkImage(channel['image'] as String)

                                ),

                                Text(
                                  channel['title'] ?? "Unknown Channel", // Fallback if title is missing
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      )
          : Center(
        child: CircularProgressIndicator(), // Show loading indicator while data is being fetched
      ),
      title: Text("Social Media"),
    );
  }
}

import 'package:bhajan_book/screens/base.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class PublicationsScreen extends StatefulWidget {
  @override
  _PublicationsScreenState createState() => _PublicationsScreenState();
}

class _PublicationsScreenState extends State<PublicationsScreen> {
  List <dynamic> imageUrls=[];
  String textHeader="";
  getPublications() async {
    await Hive.initFlutter();
    var box = await Hive.openBox('myBox');
    Map<dynamic,dynamic> value = box.get('publications');

    if (value != null) {


      setState(() {
       imageUrls=value['image-url'];
       textHeader=value['text-header'];
      });
    }
    _cacheImages();
  }

  @override
  void initState() {
    super.initState();
    getPublications();
  }
  List<File> cachedImages = [];
  // Function to download and cache images locally
  Future<void> _cacheImages() async {
    final directory = await getApplicationDocumentsDirectory();
    for (String url in imageUrls) {
      final fileName = url.split('/').last;
      final filePath = '${directory.path}/$fileName';
      File file = File(filePath);
      if (!(await file.exists())) {
        // Download the image
        final response = await http.get(Uri.parse(url));
        await file.writeAsBytes(response.bodyBytes);
      }
      cachedImages.add(file);
    }
    setState(() {}); // Update the UI
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
        title: Text("Publications"),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              textHeader,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            cachedImages.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: cachedImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.file(
                        cachedImages[index],
                        width: 200,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



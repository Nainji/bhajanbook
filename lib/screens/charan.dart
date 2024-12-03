import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'base.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'imagePreview.dart';
class AcharyaCharan extends StatefulWidget {
final id;

   AcharyaCharan({required this.id});

  @override
  State<AcharyaCharan> createState() => _AcharyaCharanState();
}

class _AcharyaCharanState extends State<AcharyaCharan> {
  int _currentIndex = 0;
  double _fontSize = 28.0;
  bool isHindi = true;
  bool isLoading=false;

  List<String> images=[];
  Map<dynamic,dynamic> chapter={};

  Dio _dio = Dio();

  // Get the local path to store images
  Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Check if the image exists locally
  Future<File?> _getLocalImage(String imageName) async {
    final path = await _getLocalPath();
    final file = File('$path/$imageName');

    if (await file.exists()) {
      return file;
    }
    return null;
  }

  // Download and save the image locally
  Future<File> _downloadAndSaveImage(String url, String imageName) async {
    final path = await _getLocalPath();
    final filePath = '$path/$imageName';

    await _dio.download(url, filePath);
    return File(filePath);
  }

  // Get the image (either from local storage or download it if not available)
  Future<File> getImage(String url) async {

    final imageName = url.split('/').last; // Extract the image name from the URL
    File? localImage = await _getLocalImage(imageName);

    if (localImage != null) {

      return localImage;
    } else {

      return await _downloadAndSaveImage(url, imageName);
    }
  }




  List<bool> _selectedLanguage = [true, false]; // Initially Hindi is selected
  getChapters() async {
    await Hive.initFlutter();
    var box = await Hive.openBox('myBox');
    List<dynamic> value = box.get('chapters');

    if (value != null) {

      var filteredChapters = value.where((chapter) => chapter['book-id'] == widget.id['id']).toList();

       if(filteredChapters.length==0){

       }else {
         setState(() {
           chapter = filteredChapters.length > 0 ? filteredChapters[0] : {};

           List<String> p = [];
           for (var i = 0; i < chapter['pages'].length; i++) {
             p.add(chapter['pages'][i]['image-url']);
           }
           print(p);
           print("pre");
           images = p;
         });
       }
    }
  }

  @override
  void initState() {
    super.initState();
    getChapters();
  }


  @override
  Widget build(BuildContext context) {

    return isLoading?Center(child: CircularProgressIndicator()):BaseLayout(
      title:Container(
        height: 30, // Set height as needed
        child: widget.id['title'].length>30? Marquee(
          text: widget.id['title'], // The title text
          style: TextStyle(color: Colors.black, fontSize: 20), // Text styling
          scrollAxis: Axis.horizontal, // Scroll horizontally
          crossAxisAlignment: CrossAxisAlignment.start,
          blankSpace: 20.0, // Space after the text before it repeats
          velocity: 50.0, // Reduce speed to prevent overlap
          pauseAfterRound: Duration(seconds: 1), // Pause after each scroll cycle
          startPadding: 10.0,
          accelerationDuration: Duration(milliseconds: 500), // Shorten acceleration duration
          decelerationDuration: Duration(milliseconds: 500), // Shorten deceleration duration
        ):widget.id['title'],
      ),

      child:Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Image Slider
          CarouselSlider(
            options: CarouselOptions(
              enableInfiniteScroll: false,
              height: 250.0,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: images.map((imagePath) {
              return FutureBuilder<File>(
                future: getImage(imagePath),
                builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return GestureDetector(
                          onTap: (){
                            // _showEnlargedImage(context, snapshot.data!);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImagePreviewScreen(imageUrls: images,title: widget.id['title'],index:_currentIndex),
                              ),
                            );
                          },
                          child: Image.file(snapshot.data!, fit: BoxFit.cover));
                    } else {
                      return Center(child: Text('Error loading image'));
                    }
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              );
            }).toList(),
          ),

          // Dot Indicator
          SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.map((url) {
                int index = images.indexOf(url);
                return Container(
                  width: 10.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // borderRadius:BorderRadiusGeometry.lerp(),
                    color: _currentIndex == index
                        ? Colors.yellow[700] // Active indicator color
                        : Colors.grey, // Inactive indicator color
                  ),
                );
              }).toList(),
            ),
          ),

          // Language and Font Size Selection Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ToggleButtons(
                  isSelected: _selectedLanguage,
                  borderRadius: BorderRadius.circular(30),
                  selectedColor: Colors.white,
                  fillColor: Colors.yellow[700],
                  borderColor: Colors.grey,
                  selectedBorderColor: Colors.yellow[700],
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Hindi'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('English'),
                    ),
                  ],
                  onPressed: (int index) {
                    setState(() {
                      _selectedLanguage = [false, false];
                      _selectedLanguage[index] = true;

                      if(index==1){
                        isHindi=false;
                      }else{
                        isHindi=true;
                      }
                    });
                  },
                ),


                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.yellow[700],
                    inactiveTrackColor: Colors.grey[400],
                    thumbColor: Colors.yellow[700],
                    valueIndicatorColor: Colors.yellow[700],
                  ),
                  child: Slider(
                    value: _fontSize,
                    min: 20,
                    max: 100,
                    divisions: 100,
                    label: _fontSize.round().toString(),
                    onChanged: (double newValue) {
                      setState(() {
                        _fontSize = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Display Text
          Expanded(
            child: Container(
              child: SingleChildScrollView(
                child: Text(
                  isHindi ? chapter['text-content-hindi']??"" : chapter['text-content']??"",
                  style: TextStyle(fontSize: _fontSize, color: Colors.brown),
                  textAlign: TextAlign.center,
                ),
              )
            ),
          ),
        ],
      ),
    );

  }
}

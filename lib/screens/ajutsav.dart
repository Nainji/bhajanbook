import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'base.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'imagePreview.dart';
class aajutsav extends StatefulWidget {
  const aajutsav({super.key});

  @override
  State<aajutsav> createState() => _aajutsavState();
}

class _aajutsavState extends State<aajutsav> {
  @override
    int _currentIndex = 0;
    double _fontSize = 28.0;
    bool isHindi = true;
    bool isLoading=false;

    List<String> images=[];
    Map<String,dynamic> menuItems={};
    List<String> hindiTexts=[];
    List<String> englishTexts=[];

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
        // Image is available locally
        return localImage;
      } else {
        // Download and store the image
        return await _downloadAndSaveImage(url, imageName);
      }
    }





    setData() async {
      await Hive.initFlutter();
      var box = await Hive.openBox('myBox');
      List<dynamic> value = box.get('aaj');

      if (value != null) {
        setState(() {
          for (var item in value) {
            images.add(item['image']);
            hindiTexts.add(item['text-hindi']);
            englishTexts.add(item['text']);
          }
          isLoading = false;
        });
      }
    }
    List<bool> _selectedLanguage = [true, false]; // Initially Hindi is selected
    @override
    void initState() {
      super.initState();

setData();
    }
    @override
    Widget build(BuildContext context) {

      return isLoading?Center(child: CircularProgressIndicator()):BaseLayout(
        title: const Text(
          'Aaj Ka Utsav',
          style: TextStyle(fontSize: 26, fontFamily: "TiroDevanagariHindi"),
        ),

        child:SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Image Slider
              CarouselSlider(
                options: CarouselOptions(
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
                                    builder: (context) => ImagePreviewScreen(imageUrls: images,title: "Home",index:_currentIndex),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: images.map((url) {
                  int index = images.indexOf(url);
                  return Container(
                    width: 38.0,
                    height: 8.0,
                    margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      // borderRadius:BorderRadiusGeometry.lerp(),
                      color: _currentIndex == index
                          ? Colors.yellow[700] // Active indicator color
                          : Colors.grey, // Inactive indicator color
                    ),
                  );
                }).toList(),
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: images.length>0?Text(
                  isHindi ? hindiTexts[_currentIndex] : englishTexts[_currentIndex],
                  style: TextStyle(fontSize: _fontSize, color: Colors.brown),
                  textAlign: TextAlign.center,
                ):SizedBox(height: 0,),
              ),
            ],
          ),
        ),
      );

    }
}

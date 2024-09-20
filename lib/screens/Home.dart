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
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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



  getBooks() async{
    final url = "https://yakshha.in/saras_nikunj/api/getBooksByCategory";
    final body = {
      "user_id": "",
      "device_id": "",
      "os": "android",
      "os_version": "10",
      "app_version": "2.0"
    };

    final String token = "56|D1LvxmO2C0NzPXuyzVYj1k48YuEHjKm5YhkVD4yQ"; // Bearer token

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json', // Set content type
          'Authorization': 'Bearer $token'    // Add Bearer token to headers
        },
        body: json.encode(body), // Encode the body to JSON
      );

      if (response.statusCode == 200) {
        await Hive.initFlutter();
        var box = await Hive.openBox('myBox');
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {

            box.put('books', responseData['resp-details']['books']);

        }
      } else {
        // Handle error
        print('Error status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error : $e');
    }
  }


  getChapters() async{
    final url = "https://yakshha.in/saras_nikunj/api/getChaptersByBookId";
    final body = {
      "user_id": "",
      "device_id": "",
      "os": "android",
      "os_version": "10",
      "app_version": "2.0"
    };

    final String token = "56|D1LvxmO2C0NzPXuyzVYj1k48YuEHjKm5YhkVD4yQ"; // Bearer token

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json', // Set content type
          'Authorization': 'Bearer $token'    // Add Bearer token to headers
        },
        body: json.encode(body), // Encode the body to JSON
      );

      if (response.statusCode == 200) {
        await Hive.initFlutter();
        var box = await Hive.openBox('myBox');
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          List<dynamic> home = responseData['resp-details']['Chapters'];

          box.put('chapters', responseData['resp-details']['Chapters']);

        }
      } else {
        // Handle error
        print('Error status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error : $e');
    }
  }
  void _showEnlargedImage(BuildContext context, File imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: AnimatedScale(
            scale: 1.0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut, // Smooth scaling animation
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // Close the dialog when tapped
              },
              child: InteractiveViewer(
                minScale: 0.5, // Minimum zoom level
                maxScale: 4.0, // Maximum zoom level
                child: Image.file(imageFile, fit: BoxFit.contain),
              ),
            ),
          ),
        );
      },
    );
  }


  setData(responseData) async{
    var user;
    await Hive.initFlutter();
    var box = await Hive.openBox('myBox');
    List<dynamic> home = responseData['resp-details']['common-content']['home'];
    final SharedPreferences prefs=await SharedPreferences.getInstance();
    if(prefs.getString('user')!.isNotEmpty) {
      String userString=await prefs.getString('user')??"";
      print(userString);
       user = jsonDecode(userString);
    }
    setState(() {
      for (var item in home) {
        images.add(item['image']);
        hindiTexts.add(item['text-hindi']);
        englishTexts.add(item['text']);
      }


      menuItems= responseData['resp-details']['menu'][user['role']];
      box.put('social', responseData['resp-details']['common-content']['social-media']);
      box.put('darshan',responseData['resp-details']['common-content']['daily-darshan']);
      box.put('panchang',responseData['resp-details']['common-content']['utsav-panchang']);
      box.put('about',responseData['resp-details']['common-content']['about-saras-nikunj']);
      box.put('links',responseData['resp-details']['common-content']['share-app-with-others']);
      box.put('policy',responseData['resp-details']['common-content']['privacy-policy']['privacy-policy-text']);
      box.put('icons',responseData['resp-details']['menu']['icons']);
      prefs.setString("menu", jsonEncode(menuItems));
      isLoading=false;
    });
  }



  getContent() async {
    setState(() {
      isLoading = true;
    });

    await Hive.initFlutter();
    var box = await Hive.openBox('myBox');

    // Check for network connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // No network available, load data from Hive
      var cachedData = box.get('content');
      if (cachedData != null) {
        setData(cachedData);  // Use cached data from Hive
        print("Loaded data from cache.");
      } else {
        print("No network and no cached data available.");
      }
    } else {
      // Network available, make the API call
      final url = "https://yakshha.in/saras_nikunj/api/getContent";
      final body = {
        "user_id": "",
        "device_id": "",
        "os": "android",
        "os_version": "10",
        "app_version": "2.0"
      };

      final String token = "56|D1LvxmO2C0NzPXuyzVYj1k48YuEHjKm5YhkVD4yQ"; // Bearer token

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json', // Set content type
            'Authorization': 'Bearer $token'    // Add Bearer token to headers
          },
          body: json.encode(body), // Encode the body to JSON
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['status'] == 'success') {
            // Store data in Hive
            box.put('content', responseData);
            setData(responseData);  // Set the response data to the UI
            print("Data loaded from API and cached.");
          }
        } else {
          // Handle error
          print('Error status: ${response.statusCode}');
        }
      } catch (e) {
        print('Error : $e');
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  List<bool> _selectedLanguage = [true, false]; // Initially Hindi is selected
  @override
  void initState() {
    super.initState();
    getContent();
    getBooks();
    getChapters();
  }
  @override
  Widget build(BuildContext context) {

    return isLoading?Center(child: CircularProgressIndicator()):BaseLayout(
      title: const Text(
        'श्री सरस संग्रह',
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
                              _showEnlargedImage(context, snapshot.data!);
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
                      min: 0,
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

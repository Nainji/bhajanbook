import 'package:bhajan_book/screens/base.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';  // Import url_launcher

class SarasNikunjScreen extends StatefulWidget {
  @override
  State<SarasNikunjScreen> createState() => _SarasNikunjScreenState();
}

class _SarasNikunjScreenState extends State<SarasNikunjScreen> {
  Map<String, dynamic> details = {};

  getDarshans() async {
    await Hive.initFlutter();
    var box = await Hive.openBox('myBox');
    Map<String, dynamic> value = box.get('about');

    if (value != null) {
      setState(() {
        details = value;
      });
    }
  }

  Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  @override
  void initState() {
    super.initState();
    getDarshans();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: Text(details["Title"]),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carousel Slider for images
              CarouselSlider(
                options: CarouselOptions(
                  height: 200.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
                items: details["slider-images"].map<Widget>((imageData) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.amber,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            imageData["image"],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              // Title Section
              Center(
                child: Text(
                  details["Title"],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              // About Section
              Text(
                "About:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 5),
              Text(
                details["about-saras-nikunj"],
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              // Address Section
              Text(
                "Address:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 5),
              Text(
                details["Address"],
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 40),
              // Button to open Google Maps
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16,horizontal: 20),
                      textStyle: TextStyle(fontSize: 18,color: Colors.white),
                      backgroundColor: Colors.yellow[700]
                  ),
                  onPressed: () {
                    if (details['Latitude'] != null && details['Longitude'] != null) {
                      openMap(details['Latitude'], details['Longitude']);
                    }
                  },
                  child: Text("Open in Google Maps",style: TextStyle(color: Colors.white),),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:bhajan_book/screens/base.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'imagePreview.dart';

class EventsScreen extends StatefulWidget {

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
   List<dynamic> eventData = [];

  getPatra() async {
    await Hive.initFlutter();
    var box = await Hive.openBox('myBox');
     List<dynamic> value = box.get('suchna');

    if (value != null) {


      setState(() {
       eventData=value;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getPatra();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
        title: Text('Utsav Patra and Suchna'),
      child: ListView.builder(
        itemCount: eventData.length,
        itemBuilder: (context, index) {
          final event = eventData[index];
          return EventCard(
            title: event['title'],
            description: event['description'],
            address: event['address'],
            imageUrls: List<String>.from(event['image-url']),
          );
        },
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String title;
  final String description;
  final String address;
  final List<String> imageUrls;

  const EventCard({
    required this.title,
    required this.description,
    required this.address,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color:  Color(0xFFFFF2C2),
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              description,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 10),
            Text(
              address,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 10),
            Container(
              height: 200, // Fixed height for the PageView
              child: PageView.builder(
                itemCount: imageUrls.length,
                controller: PageController(viewportFraction: 0.9), // Increase viewport fraction to avoid cropping
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImagePreviewScreen(imageUrls: imageUrls,title: title,index:index),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: CachedNetworkImage(
                        imageUrl: imageUrls[index],
                        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.contain, // Prevent cropping by containing the image within the box
                        width: double.infinity,
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

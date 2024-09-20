import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // For storing image locally
import 'package:http/http.dart' as http;

import 'base.dart';

class Panchang extends StatefulWidget {
  const Panchang({super.key});

  @override
  State<Panchang> createState() => _PanchangState();
}

class _PanchangState extends State<Panchang> {

  List<dynamic> cards = [];

  getDarshans() async {
    await Hive.initFlutter();
    var box = await Hive.openBox('myBox');
    List<dynamic> value = box.get('panchang');

    if (value != null) {


      setState(() {
        cards = value;
      });
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
      title: Text('Utsav Panchang'),
      child: Column(
        children: [
          Center(
            child: Image.asset(
              'assets/images/logo_png.png', // Put your logo image in the assets folder
              height: 220, // Adjust the size as needed
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                crossAxisCount: 2, // Two items in a row
                crossAxisSpacing: 8, // Horizontal spacing between items
                mainAxisSpacing: 8, // Vertical spacing between items
                children: List.generate(cards.length, (index) {
                  var card = cards[index];
                  return CardItem(
                      card:card
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class CardItem extends StatefulWidget {
  final Map<String, dynamic> card;

  const CardItem({
    required this.card,
  });

  @override
  _CardItemState createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  File? _localImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  // Check if the image exists locally or download it
  Future<void> _loadImage() async {
    String imageUrl = widget.card['image'];
    String fileName = imageUrl.split('/').last;
    final directory = await getApplicationDocumentsDirectory();
    File localFile = File('${directory.path}/$fileName');

    if (await localFile.exists()) {
      // Use the local file if it exists
      setState(() {
        _localImage = localFile;
      });
    } else {
      // Download the image and save it locally
      try {
        http.Response response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          await localFile.writeAsBytes(response.bodyBytes);
          setState(() {
            _localImage = localFile;
          });
        }
      } catch (e) {
        print("Error downloading image: $e");
      }
    }
  }

  // Function to show enlarged image in a popup
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

  @override
  Widget build(BuildContext context) {
    var title = widget.card.keys.map((String key) => key).join();
    return GestureDetector(
      onTap: () {
        if (_localImage != null) {
          
          _showEnlargedImage(context, _localImage!);
        }
      },
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _localImage != null
                  ? Image.file(
                _localImage!,
                fit: BoxFit.cover,
                width: double.infinity,
              )
                  : Image.network(
                widget.card['image'],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to a default image if network fails
                  return Image.asset('assets/images/logo_png.png');
                },
              ),
            ),
            // Uncomment to show title
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Text(
            //     title,
            //     textAlign: TextAlign.center,
            //     style: TextStyle(fontSize: 14),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

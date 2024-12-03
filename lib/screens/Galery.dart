import 'package:flutter/material.dart';
import 'package:bhajan_book/screens/imagePreview.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'base.dart';
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  Map<dynamic,dynamic> cards = {};

  getDarshans() async {
    await Hive.initFlutter();
    var box = await Hive.openBox('myBox');
    Map<dynamic,dynamic> value = box.get('gallery');

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
      title: Text('Gallery'),
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
                children: List.generate(cards.keys.length, (index) {
                  String albumName = cards.keys.elementAt(index);
                  var card = cards[albumName];
                  return CardItem(
                      card:card,
                    name: albumName,
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


class CardItem extends StatelessWidget {
  final  card;
  final name;


  const CardItem({
    required this.card,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    print(card);
    var title=name;
    var imageUrls = List<String>.from(card.map((item) => item['image-url']));
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePreviewScreen(imageUrls: imageUrls,title: title,index: 0,),
          ),
        );
      },
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Image.network(
                card[0]['image-url'],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  // In case the image network fails, fallback to a default image
                  return Image.asset('assets/images/logo_png.png');
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




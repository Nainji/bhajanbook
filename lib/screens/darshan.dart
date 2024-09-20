import 'package:bhajan_book/screens/imagePreview.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'base.dart';

class Darshan extends StatefulWidget {
  const Darshan({super.key});

  @override
  State<Darshan> createState() => _DarshanState();
}

class _DarshanState extends State<Darshan> {

  List<dynamic> cards = [];

  getDarshans() async {
    await Hive.initFlutter();
    var box = await Hive.openBox('myBox');
    List<dynamic> value = box.get('darshan');

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
      title: Text('Daily Darshan'),
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


class CardItem extends StatelessWidget {
  final Map<String,dynamic> card;


  const CardItem({
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    var title=card.keys.map((String key) =>key ).join();
    var imageUrls = List<String>.from(card[title].map((item) => item['image-url']));
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePreviewScreen(imageUrls: imageUrls,title: title,),
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
                card[title][0]['image-url'],
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
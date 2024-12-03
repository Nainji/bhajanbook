import 'package:bhajan_book/screens/base.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

import 'imagePreview.dart';

class Books extends StatefulWidget {
  final category;
  const Books({required this.category});

  @override
  State<Books> createState() => _DarshanState();
}

class _DarshanState extends State<Books> {
  List<dynamic> cards = [];

  getBooks() async {
    await Hive.initFlutter();
    var box = await Hive.openBox('myBox');
    List<dynamic> value = box.get('books');

    if (value != null) {
      var all = [];

      for (int i = 0; i < value.length; i++) {


        if (value[i]['sub_category_name'].toLowerCase() == widget.category.toLowerCase()) {
          all.add(value[i]);
        }
      }

      setState(() {
        cards = all;

      });
    }
  }

  @override
  void initState() {
    super.initState();
      getBooks();
  }

  @override
  Widget build(BuildContext context) {

    return BaseLayout(
      title: Text(widget.category),
      child: Column(
        children: [
          Center(
            child: Image.asset(
              'assets/images/logo_png.png', // Put your logo image in the assets folder
              height: 260, // Adjust the size as needed
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
                    id: card['book_id'],
                    category:widget.category ,
                    type:card['content_type_name'],
                    imagePath: card['cover_front'] != null && card['cover_front'] != ''
                        ? card['cover_front']
                        : 'assets/images/logo_png.png', // Use default logo if no filePath
                    title: card['title_hindi'] ?? card['bookName'],
                    author:card['author_hindi'],
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
  final String imagePath;
  final String title;
  final int id;
  final String type;
  final String category;
  final String author;

  const CardItem({
    required this.id,
    required this.imagePath,
    required this.author,
    required this.type,
    required this.title,
    required this.category
  });

  @override
  _CardItemState createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  late String _localImagePath;

  @override
  void initState() {
    super.initState();
    _localImagePath = '';
    _loadImage();
  }

  Future<void> _loadImage() async {

    var box = await Hive.openBox('imageCache');
    String? localPath = box.get(widget.imagePath);

    if (localPath != null && File(localPath).existsSync()) {

      setState(() {
        _localImagePath = localPath;
      });
    } else {

      _localImagePath = await _downloadAndSaveImage(widget.imagePath);
      box.put(widget.imagePath, _localImagePath); // Save local path to Hive
    }
  }

  Future<String> _downloadAndSaveImage(String imageUrl) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${widget.id}_${widget.title}.png';

    try {
      Dio dio = Dio();
      await dio.download(imageUrl, filePath);
      return filePath;
    } catch (e) {
      print('Error downloading image: $e');
      return ''; // Return empty if download fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePreviewScreen(imageUrls:[widget.imagePath] ,title: widget.title,index:0),
          ),
        );
      },
      onTap: () async {
        final routeName = widget.category == 'Aacharya Charan'
            ? '/acharya'
            : '/chapters';
        final arguments = widget.category == 'Aacharya Charan'
            ? {"id": widget.id, "title": widget.title}
            : {"id": widget.id, "type": widget.type, "title": widget.title};
        if(widget.category == 'Aacharya Charan'){
          await Hive.initFlutter();
          var box = await Hive.openBox('myBox');
          List<dynamic> value = box.get('chapters');

          if (value != null) {
            var filteredChapters = value.where((chapter) =>
            chapter['book-id'] == widget.id).toList();

            if (filteredChapters.length > 0) {
              Navigator.pushNamed(context, routeName, arguments: arguments);
            }
          }
        }else{
          Navigator.pushNamed(context, routeName, arguments: arguments);

        }

      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Card(
              color: Color(0xFFFFF2C2),
              elevation: 0,
              child: _localImagePath.isNotEmpty
                  ? Image.file(
                File(_localImagePath),
                fit: BoxFit.fitHeight,
                width: double.infinity,

              )
                  : Image.network(

                widget.imagePath,
                fit: BoxFit.fitHeight,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/images/logo_png.png');
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Text(
              widget.author,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );

  }
}

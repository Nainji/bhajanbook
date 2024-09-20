import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class PicView extends StatefulWidget {
  final Map<dynamic,dynamic> pages;

  const PicView({required this.pages});

  @override
  State<PicView> createState() => _PicViewState();
}

class _PicViewState extends State<PicView> {
  List<dynamic> chapters=[];
  List<dynamic> filtered=[];


  getChapters() async {
    await Hive.initFlutter();
    var box = await Hive.openBox('myBox');
    List<dynamic> value = box.get('chapters');

    if (value != null) {

      var filteredChapters = value.where((chapter) => chapter['book-id'] == widget.pages['book-id']).toList();

      setState(() {
        chapters = filteredChapters;
        for(var i=0;i<filteredChapters.length;i++){
          filtered.addAll(filteredChapters[i]['pages']);
        }
        print(value.length);
        print(chapters.length);

      });
    }
  }

  @override
  void initState() {
    super.initState();
    getChapters();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height, // Full height of screen
        child: ListView.builder(
          scrollDirection: Axis.horizontal, // Set scroll direction to horizontal
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            var card = filtered[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: Alignment.center, // Center the card vertically
                child: CardItem(
                  imagePath: card['image-url'] != null && card['image-url'] != ''
                      ? card['image-url']
                      : 'assets/images/logo_png.png', // Use default logo if no filePath
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CardItem extends StatefulWidget {
  final String imagePath;

  const CardItem({
    required this.imagePath,
  });

  @override
  _CardItemState createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  late String _localImagePath;
  late TransformationController _transformationController;
  TapDownDetails _doubleTapDetails = TapDownDetails();

  @override
  void initState() {
    super.initState();
    _localImagePath = '';
    _transformationController = TransformationController();
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
    final filePath = '${directory.path}/${widget.imagePath}.png';

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
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: () {
        if (_transformationController.value != Matrix4.identity()) {
          _transformationController.value = Matrix4.identity(); // Reset zoom
        } else {
          final position = _doubleTapDetails.localPosition;
          _transformationController.value = Matrix4.identity()
            ..translate(-position.dx * 2, -position.dy * 2)
            ..scale(2.0); // Zoom in
        }
      },
      child: Card(
        color: Color(0xFFFFF2C2),
        elevation: 4,
        child: SizedBox(
          width: MediaQuery.of(context).size.width, // Full width of screen
          height: MediaQuery.of(context).size.height, // Full height of screen
          child: InteractiveViewer(
            transformationController: _transformationController,
            panEnabled: true, // Allow panning
            scaleEnabled: true, // Allow zooming
            minScale: 1.0,
            maxScale: 4.0, // Limit the maximum zoom
            child: _localImagePath.isNotEmpty
                ? Image.file(
              File(_localImagePath),
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            )
                : Image.network(
              widget.imagePath,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: $error');
                print('Image path: ${widget.imagePath}');
                return Image.asset('assets/images/logo_png.png');
              },
            ),
          ),
        ),
      ),
    );
  }
}

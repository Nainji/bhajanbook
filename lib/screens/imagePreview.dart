import 'package:bhajan_book/screens/base.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImagePreviewScreen extends StatefulWidget {
  final List<dynamic> imageUrls;
  final String title;
  final int index;

  ImagePreviewScreen({required this.imageUrls, required this.title, required this.index});

  @override
  _ImagePreviewScreenState createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  late int _currentIndex;
  TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    print(widget.imageUrls);
    _currentIndex = widget.index; // Initialize current index from widget.index
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: Text(widget.title),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CarouselSlider.builder(
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index, realIndex) {
              return GestureDetector(
                onDoubleTap: () {
                  // Reset or set zoom scale on double-tap
                  _transformationController.value = Matrix4.identity();
                },
                child: InteractiveViewer(
                  panEnabled: true,
                  scaleEnabled: true,
                  transformationController: _transformationController,
                  minScale: 1.0,
                  maxScale: 5.0, // Increased max scale for a smoother zoom experience
                  boundaryMargin: EdgeInsets.all(20),
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrls[index],
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Image.asset('assets/images/logo_png.png'),
                    fadeInDuration: const Duration(milliseconds: 300),
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              viewportFraction: 1.0,
              initialPage: _currentIndex, // Set the initial page to widget.index
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index; // Update current index
                  _transformationController.value = Matrix4.identity(); // Reset zoom on page change
                });
              },
            ),
          ),
          Positioned(
            bottom: 20.0,
            right: 20.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.imageUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
          Positioned(
            top: 20.0,
            right: 20.0,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:bhajan_book/screens/base.dart';
import 'package:bhajan_book/screens/imageView.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';

class FileViewerScreen extends StatefulWidget {
  final  file; // Assuming the file is a Map structure

  FileViewerScreen({required this.file});

  @override
  _FileViewerScreenState createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  int? _currentIndex ;


  @override
  Widget build(BuildContext context) {

    return BaseLayout(
      title: Container(
        height: 30, // Set height as needed
        child: Marquee(
          text: widget.file['data']['title-hindi'], // The title text
          style: TextStyle(color: Colors.black, fontSize: 20), // Text styling
          scrollAxis: Axis.horizontal, // Scroll horizontally
          crossAxisAlignment: CrossAxisAlignment.start,
          blankSpace: 20.0, // Space after the text before it repeats
          velocity: 100.0, // Speed of scrolling
          pauseAfterRound: Duration(seconds: 1), // Pause after each scroll cycle
          startPadding: 10.0,
          accelerationDuration: Duration(seconds: 1),
          decelerationDuration: Duration(milliseconds: 500),
        ),
      ),
      child: Stack(
        children: [
          _buildFileViewer(),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                backgroundColor: Colors.yellow[700],
                onPressed: _showBottomSheet, // Link the bottom sheet here
                child: Icon(Icons.audio_file,color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<String?> _downloadPDF(String url) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${Uri.parse(url).pathSegments.last}';

    final file = File(filePath);

    // Check if the file already exists
    if (await file.exists()) {
      return filePath;
    }

    // File doesn't exist, so download it
    try {
      Dio dio = Dio();
      await dio.download(url, filePath);
      return filePath;
    } catch (e) {
      print('Error downloading PDF: $e');
      return null; // Return null if download fails
    }
  }

  Widget _buildFileViewer() {
    // widget.file['type'].toLowerCase()
    switch (widget.file['type'].toLowerCase()) {
      case 'pdf':
        return FutureBuilder<String?>(
          future: _downloadPDF(widget.file['data']['url-content']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return PDFView(
                  filePath: snapshot.data!,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: false,
                  pageFling: true,
                );
              } else {
                return Center(child: Text('Failed to download PDF'));
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        );
      case 'image':
        return PicView(pages:widget.file['data'] );
      case 'text':
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.file['data']['text-content-hindi'], // Display the actual text content
            style: TextStyle(fontSize: 22),
          ),
        );
      default:
        return Center(
          child: Text("Unsupported file type"),
        );
    }
  }






  void _showBottomSheet() {
    AudioPlayer _audioPlayer = AudioPlayer();
    bool _isPlaying = false;
    Duration _duration = Duration.zero;
    Duration _position = Duration.zero;
    int _currentIndex = 0;

    List<dynamic> audioContent = widget.file['data']['audio-content'];

    // Function to play or pause audio
    void _playPauseAudio(String url) async {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(url));
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    }

    // Update position of the audio
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    // Update total duration of the audio
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Slider to show the progress of the audio
                Slider(
                  value: _position.inSeconds.toDouble(),
                  max: _duration.inSeconds.toDouble(),
                  onChanged: (value) async {
                    final position = Duration(seconds: value.toInt());
                    await _audioPlayer.seek(position);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_position.toString().split('.').first),
                    Text(_duration.toString().split('.').first),
                  ],
                ),
                // List of audio files
                Expanded(
                  child: ListView.builder(
                    itemCount: audioContent.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: IconButton(
                          icon: Icon(_currentIndex == index && _isPlaying
                              ? Icons.pause
                              : Icons.play_arrow),
                          onPressed: () {
                            _currentIndex = index;
                            _playPauseAudio(audioContent[index]['audio-url']);
                          },
                        ),
                        title: Text("Audio ${(index + 1).toString()}"),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
}

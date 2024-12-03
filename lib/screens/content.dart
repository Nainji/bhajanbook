import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:bhajan_book/screens/pdfView.dart';
import 'package:bhajan_book/screens/textView.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

import 'package:bhajan_book/screens/base.dart';
import 'package:bhajan_book/screens/imageView.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:just_audio/just_audio.dart';

class FileViewerScreen extends StatefulWidget {
  final  file; // Assuming the file is a Map structure

  FileViewerScreen({required this.file});

  @override
  _FileViewerScreenState createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {

  PDFViewController? _pdfViewController;
  int _totalPages = 50;
  int _currentPage = 1;

  String getAudioName(name){
     final  temp=name.split("/");
     return temp[temp.length-1].split("_").join(" ");

  }
  @override
  Widget build(BuildContext context) {


    return BaseLayout(
      title: Container(
        height: 30, // Set height as needed
        child: widget.file['data']['title-hindi'].length>30? Marquee(
          text: widget.file['data']['title-hindi'], // The title text
          style: TextStyle(color: Colors.black, fontSize: 20), // Text styling
          scrollAxis: Axis.horizontal, // Scroll horizontally
          crossAxisAlignment: CrossAxisAlignment.start,
          blankSpace: 20.0, // Space after the text before it repeats
          velocity: 50.0, // Reduce speed to prevent overlap
          pauseAfterRound: Duration(seconds: 1), // Pause after each scroll cycle
          startPadding: 10.0,
          accelerationDuration: Duration(milliseconds: 500), // Shorten acceleration duration
          decelerationDuration: Duration(milliseconds: 500), // Shorten deceleration duration
        ):Text( widget.file['data']['title-hindi']),
      ),
      child: Stack(
        children: [
          _buildFileViewer(),
          widget.file['type'].toLowerCase()=="pdf"?SizedBox(height: 0,):Padding(
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

        return PDFViewerPage(url: widget.file['data']['url-content']);
      case 'image':
        return PicView(pages:widget.file['data'] );
      case 'text':
        return CustomCardExample(text:widget.file['data']['text-content-hindi']);
      default:
        return Center(
          child: Text("Unsupported file type"),
        );
    }
  }









  void _showBottomSheet() {
    final AudioPlayer _audioPlayer = AudioPlayer();
    bool _isPlaying = false;
    Duration _duration = Duration.zero;
    Duration _position = Duration.zero;
    int _currentIndex = 0;

    List<dynamic> audioContent = widget.file['data']['audio-content'];

    // Function to check if the file is downloaded and return the file path
    Future<String> _getDownloadedFilePath(String url) async {
      // Get the local directory
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;

      // Get file name from the URL
      String fileName = url.split('/').last;

      // Build full path
      String filePath = '$appDocPath/$fileName';

      // Check if the file already exists
      File file = File(filePath);
      if (await file.exists()) {
        return filePath;
      } else {
        // File does not exist, so download it
        try {
          Dio dio = Dio();
          await dio.download(url, filePath);
          return filePath; // Return the path of the downloaded file
        } catch (e) {
          print("Error downloading file: $e");
          return ''; // Handle error
        }
      }
    }

    // Function to play or pause audio
    void _playPauseAudio(String url) async {
      String filePath = await _getDownloadedFilePath(url);

      if (filePath.isNotEmpty) {
        try {
          if (_isPlaying) {
            await _audioPlayer.pause();
          } else {
            // Play the audio from local file
            await _audioPlayer.play(DeviceFileSource(filePath));  // Use play with DeviceFileSource for local files
          }

          setState(() {
            _isPlaying = !_isPlaying;
          });
        } catch (e) {
          print("Error: $e"); // Print error to debug console
        }
      }
    }

    // Listen for changes in the audio player's position
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    // Listen for changes in the total duration of the audio
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration ?? Duration.zero; // Handle null duration
      });
    });

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return  Container(
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
                      title: Text(getAudioName(audioContent[index]['audio-url'])),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class PDFViewerPage extends StatefulWidget {
  final String url;

  const PDFViewerPage({required this.url, Key? key}) : super(key: key);

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String? localPath;
  bool isLoading = true;
  int? totalPages = 0;
  int currentPage = 0;
  late PDFViewController pdfController;

  @override
  void initState() {
    super.initState();
    downloadFile(widget.url);
  }

  Future<void> downloadFile(String url) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/temp.pdf';
      await Dio().download(url, path);
      setState(() {
        localPath = path;
        isLoading = false;
      });
    } catch (e) {
      print('Error downloading file: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void jumpToPage() async {
    final pageInput = await showDialog<int>(
      context: context,
      builder: (context) {
        int inputPage = currentPage + 1;
        return AlertDialog(
          backgroundColor: Colors.yellow[700],
          title: const Text("Jump to Page"),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Enter page number"),
            onChanged: (value) {
              inputPage = int.tryParse(value) ?? inputPage;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Cancel",style: TextStyle(color: Colors.black),),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, inputPage - 1),
              child: const Text("Go",style: TextStyle(color: Colors.black),),
            ),
          ],
        );
      },
    );

    if (pageInput != null && pageInput >= 0 && pageInput < totalPages!) {
      pdfController.setPage(pageInput);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[700],
      body: Stack(
        children: [
          // PDF View
          if (!isLoading)
            PDFView(
              filePath: localPath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageSnap: true,
              onViewCreated: (controller) {
                pdfController = controller;
              },
              onPageChanged: (page, total) {
                setState(() {
                  currentPage = page!;
                  totalPages = total;
                });
              },
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Page Indicator
          if (!isLoading && totalPages != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Page ${currentPage + 1} of $totalPages',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.input),
                    onPressed: jumpToPage,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

}

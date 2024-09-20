import 'package:bhajan_book/screens/base.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';import 'package:marquee/marquee.dart';

class Chapters extends StatefulWidget {
  final  id;
  const Chapters({required this.id});

  @override
  State<Chapters> createState() => _ChaptersState();
}

class _ChaptersState extends State<Chapters> {
  List<dynamic> chapters = [];
  int currentPage = 1;
  final int itemsPerPage = 6; // Number of items to show per page

  getChapters() async {
    await Hive.initFlutter();
    var box = await Hive.openBox('myBox');
    List<dynamic> value = box.get('chapters');

    if (value != null) {
      // widget.id['id']
      var filteredChapters = value.where((chapter) => chapter['book-id'] == widget.id['id']).toList();

      setState(() {
        chapters = filteredChapters;
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
    return BaseLayout(

      title: Container(
        height: 30, // Set height as needed
        child: Marquee(
          text: widget.id['title'], // The title text
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

      child: chapters.isEmpty
          ? Center(child: Text('No Chapters'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                var chapter =chapters[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: GestureDetector(
                    onTap: (){Navigator.pushNamed(context, '/file',arguments: {"type":widget.id['type'],"data":chapters[index]});},
                    child: Card(
                      color: Color(0xFFFFF2C2),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      child: ListTile(
                        leading: Text(
                          '${index+1}', // Displaying serialNumber on the left side
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        title: Text(
                          chapter['titleHindi'] ?? chapter['title'],
                          style: TextStyle(fontSize: 20),
                        ),
                        trailing: Text(
                          '${chapter['pageNumber']}',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // buildPagination()
        ],
      ),
    );
  }

  Widget buildPagination() {
    int totalPages = (chapters.length / itemsPerPage).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: currentPage > 1
                ? () {
              setState(() {
                currentPage--;
              });
            }
                : null,
          ),
          Text('$currentPage / $totalPages'),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: currentPage < totalPages
                ? () {
              setState(() {
                currentPage++;
              });
            }
                : null,
          ),
        ],
      ),
    );
  }
}
